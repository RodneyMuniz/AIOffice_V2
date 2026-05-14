import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { copyFile, mkdtemp, readdir, rm } from "node:fs/promises";
import { existsSync } from "node:fs";
import { createServer } from "node:net";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const appDir = path.resolve(scriptDir, "..");
const repoRoot = path.resolve(appDir, "..", "..");
const apiDir = path.join(repoRoot, "services", "orchestrator-api");
const seedDir = path.join(repoRoot, "runtime", "state");
const stateDir = await mkdtemp(path.join(os.tmpdir(), "aioffice-r19-smoke-"));

const apiPort = await getFreePort();
const uiPort = await getFreePort();
const apiBaseUrl = `http://127.0.0.1:${apiPort}`;
const uiUrl = `http://127.0.0.1:${uiPort}`;

const processes = [];
let browser;

try {
  await copySeedFiles(seedDir, stateDir);

  const python = resolvePython();
  const apiProcess = startProcess(
    python,
    ["-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", String(apiPort)],
    {
      cwd: apiDir,
      env: { ...process.env, AIO_STATE_DIR: stateDir }
    }
  );
  processes.push(apiProcess);
  await waitForJson(`${apiBaseUrl}/status`, "backend status");

  const viteProcess = startProcess(
    process.execPath,
    [path.join(appDir, "node_modules", "vite", "bin", "vite.js"), "--host", "127.0.0.1", "--port", String(uiPort), "--strictPort"],
    {
      cwd: appDir,
      env: { ...process.env, VITE_AIO_API_BASE_URL: apiBaseUrl }
    }
  );
  processes.push(viteProcess);
  await waitForResponse(uiUrl, "operator UI");

  browser = await launchChromium();
  const page = await browser.newPage({ viewport: { width: 1366, height: 900 } });
  const consoleErrors = [];
  page.on("console", (message) => {
    if (message.type() === "error") {
      consoleErrors.push(message.text());
    }
  });
  page.on("pageerror", (error) => consoleErrors.push(error.message));

  await page.goto(uiUrl, { waitUntil: "networkidle" });
  await page.getByTestId("status-panel").waitFor();
  await assertVisible(page.getByTestId("status-panel"), "status panel");
  const policyPanel = page.getByTestId("policy-settings-panel");
  await policyPanel.waitFor();
  await assertVisible(policyPanel, "policy settings panel");
  await policyPanel.locator(".state-tag", { hasText: "advisory" }).waitFor();
  await policyPanel.getByTestId("policy-mode-select").selectOption("advisory");
  await savePolicy(page, {
    mode: "enforced",
    requireOriginal: true,
    requireRepair: false,
    allowOverride: true
  });
  assert.equal(await policyPanel.getByTestId("policy-allow-override").isChecked(), true, "operator override should be enabled");

  const stamp = Date.now();
  const cardTitle = `Smoke card ${stamp}`;
  const workOrderTitle = `Smoke work order ${stamp}`;

  await page.getByTestId("create-card-title").fill(cardTitle);
  await page.getByTestId("create-card-description").fill("Browser smoke creates a temp-state card.");
  await page.getByTestId("create-card-priority").selectOption("high");
  await page.getByTestId("create-card-submit").click();

  const cardRow = page.getByTestId("cards-list").locator("article").filter({ hasText: cardTitle }).first();
  await cardRow.waitFor();
  const cardId = (await cardRow.locator(".eyebrow").first().textContent())?.trim();
  assert.ok(cardId, "created card id should be visible");

  await page.getByTestId("create-work-order-card").selectOption(cardId);
  await page.getByTestId("create-work-order-title").fill(workOrderTitle);
  await page.getByTestId("create-work-order-description").fill("Browser smoke creates a linked work order.");
  const approvalCheckbox = page.getByTestId("create-work-order-approval");
  if (await approvalCheckbox.isChecked()) {
    await approvalCheckbox.uncheck();
  }
  await page.getByTestId("create-work-order-submit").click();

  const workOrderRow = page.getByTestId("work-orders-list").locator("article").filter({ hasText: workOrderTitle }).first();
  await workOrderRow.waitFor();
  const workOrderId = (await workOrderRow.locator(".eyebrow").first().textContent())?.trim();
  assert.ok(workOrderId, "created work-order id should be visible");

  const originalReadinessPanel = workOrderRow.locator(`[data-testid="qa-readiness-${workOrderId}"]`);
  await originalReadinessPanel.getByText("Blocked: Developer/Codex result is required by current QA handoff policy.").waitFor();
  await originalReadinessPanel.locator(`[data-testid="check-qa-readiness-${workOrderId}"]`).click();
  await originalReadinessPanel.locator(".state-tag", { hasText: "blocked" }).first().waitFor();
  await originalReadinessPanel.getByText("Developer/Codex result is required by current QA handoff policy.").first().waitFor();
  await originalReadinessPanel.getByText("Policy enforced; enforcement on; warning promoted to blocker").waitFor();
  await originalReadinessPanel.getByText("Override available for this handoff request").waitFor();
  const originalOverrideAction = workOrderRow.getByTestId(`override-action-${workOrderId}`);
  await originalOverrideAction.waitFor();
  assert.equal(
    await workOrderRow.getByTestId(`handoff-to-qa-${workOrderId}`).isDisabled(),
    true,
    "enforced original QA policy should keep the normal handoff disabled while blocked"
  );
  assert.equal(
    await originalOverrideAction.getByRole("button", { name: "Handoff to QA with Override" }).isDisabled(),
    true,
    "override handoff button should require a non-empty reason"
  );

  const originalOverrideReason = "Browser smoke operator override for original QA without Developer/Codex result.";
  await originalOverrideAction.locator(`[data-testid="override-reason-${workOrderId}"]`).fill(originalOverrideReason);
  await originalOverrideAction.getByRole("button", { name: "Handoff to QA with Override" }).click();
  const handoffRow = page.getByTestId("handoffs-panel").locator("article").filter({ hasText: workOrderId }).first();
  await handoffRow.waitFor();
  await handoffRow.locator(".state-tag", { hasText: "proposed" }).waitFor();
  await handoffRow.locator("strong").filter({ hasText: "none" }).first().waitFor();
  await handoffRow.locator('[data-testid^="handoff-policy-override-"]').getByText(originalOverrideReason).waitFor();
  await handoffRow.getByText("No developer result captured; handoff was operator override-approved").waitFor();
  const originalOverrideMatch = /R19-POLICY-OVERRIDE-\d+/.exec(await handoffRow.textContent());
  assert.ok(originalOverrideMatch, "original handoff should show policy override id");
  const originalOverrideId = originalOverrideMatch[0];
  const originalOverrideRow = page.getByTestId("policy-overrides-list").locator("article").filter({ hasText: originalOverrideId }).first();
  await originalOverrideRow.waitFor();
  await originalOverrideRow.getByText("work_order_qa_handoff").waitFor();
  await originalOverrideRow.getByText(originalOverrideReason).waitFor();
  await page.getByTestId("events-list").getByText("policy_override_recorded").waitFor();
  await page.getByTestId("evidence-list").getByText("policy_override", { exact: true }).waitFor();
  await originalReadinessPanel.getByText("Blocked: active QA handoff").waitFor();
  assert.equal(
    await workOrderRow.getByTestId(`handoff-to-qa-${workOrderId}`).isDisabled(),
    true,
    "active original QA handoff should disable duplicate handoff"
  );
  await originalReadinessPanel.locator(`[data-testid="check-qa-readiness-${workOrderId}"]`).click();
  await originalReadinessPanel.locator(".state-tag", { hasText: "blocked" }).first().waitFor();
  await originalReadinessPanel.getByText("Active initial_qa handoff").first().waitFor();
  await workOrderRow.getByTestId(`override-unavailable-${workOrderId}`).waitFor();

  await cardRow.locator('[data-testid^="card-status-"][data-testid$="-select"]').selectOption("planned");
  await cardRow.locator('[data-testid^="card-status-"][data-testid$="-reason"]').fill("Browser smoke planned the card.");
  await cardRow.locator('[data-testid^="card-status-"][data-testid$="-submit"]').click();
  await cardRow.locator(".record-title-line .state-tag", { hasText: "planned" }).waitFor();

  await handoffRow.locator('[data-testid^="handoff-reason-"]').fill("Browser smoke accepts the QA handoff.");
  await handoffRow.getByRole("button", { name: "Accept" }).click();
  await handoffRow.locator(".state-tag", { hasText: "accepted" }).waitFor();

  await handoffRow.locator('[data-testid^="qa-result-form-"]').waitFor();
  await handoffRow.locator('[data-testid^="qa-result-select-"]').selectOption("failed");
  await handoffRow.locator('[data-testid^="qa-result-summary-"]').fill("Browser smoke QA failed.");
  await handoffRow.locator('[data-testid^="qa-result-findings-"]').fill("A blocking issue needs a repair work order.");
  await handoffRow
    .locator('[data-testid^="qa-result-next-action-"]')
    .fill("Create a repair work order.");
  await handoffRow.getByRole("button", { name: "Record QA Result" }).click();
  await handoffRow.getByText("QA result recorded: failed").waitFor();

  const qaResultRow = page.getByTestId("qa-results-list").locator("article").filter({ hasText: "Browser smoke QA failed." }).first();
  await qaResultRow.waitFor();
  await qaResultRow.locator(".state-tag", { hasText: "failed" }).waitFor();
  await workOrderRow.locator(".record-title-line .state-tag", { hasText: "blocked" }).waitFor();

  await qaResultRow.locator('[data-testid^="repair-summary-"]').fill("Browser smoke repair request.");
  await qaResultRow.locator('[data-testid^="repair-instructions-"]').fill("Repair the failed browser smoke condition.");
  await qaResultRow.locator('[data-testid^="repair-agent-"]').selectOption("developer_codex");
  await qaResultRow.getByRole("button", { name: "Create Repair Work Order" }).click();
  await qaResultRow.getByText("Repair request created:").waitFor();

  const repairRequestRow = page
    .getByTestId("repair-requests-list")
    .locator("article")
    .filter({ hasText: "Browser smoke repair request." })
    .first();
  await repairRequestRow.waitFor();
  await repairRequestRow.locator(".record-title-line .state-tag", { hasText: "created" }).waitFor();
  const repairRequestId = (await repairRequestRow.locator(".eyebrow").first().textContent())?.trim();
  assert.ok(repairRequestId, "repair request id should be visible");

  const repairWorkOrderRow = page.getByTestId("work-orders-list").locator("article").filter({ hasText: `Repair: ${workOrderTitle}` }).first();
  await repairWorkOrderRow.waitFor();
  await repairWorkOrderRow.locator(".record-title-line .state-tag", { hasText: "ready" }).waitFor();
  await repairWorkOrderRow.getByText("developer_codex").waitFor();
  const repairWorkOrderId = (await repairWorkOrderRow.locator(".eyebrow").first().textContent())?.trim();
  assert.ok(repairWorkOrderId, "repair work-order id should be visible");

  const repairReadinessPanel = repairRequestRow.locator(`[data-testid="repair-qa-readiness-${repairRequestId}"]`);
  await repairReadinessPanel.getByText("Warning: no repair Developer/Codex result captured.").waitFor();
  await repairReadinessPanel.locator(`[data-testid="check-repair-qa-readiness-${repairRequestId}"]`).click();
  await repairReadinessPanel.locator(".state-tag", { hasText: "warning" }).first().waitFor();
  await repairReadinessPanel.getByText("No submitted Developer/Codex result").first().waitFor();
  await repairReadinessPanel.getByText("Policy enforced; enforcement on").waitFor();

  await savePolicy(page, { mode: "enforced", requireOriginal: true, requireRepair: true, allowOverride: true });
  await repairReadinessPanel.getByText("Blocked: Developer/Codex result is required by current QA handoff policy.").waitFor();
  await repairReadinessPanel.locator(`[data-testid="check-repair-qa-readiness-${repairRequestId}"]`).click();
  await repairReadinessPanel.locator(".state-tag", { hasText: "blocked" }).first().waitFor();
  await repairReadinessPanel.getByText("Developer/Codex result is required by current QA handoff policy.").first().waitFor();
  await repairReadinessPanel.getByText("Policy enforced; enforcement on; warning promoted to blocker").waitFor();
  await repairReadinessPanel.getByText("Override available for this handoff request").waitFor();
  const repairOverrideAction = repairRequestRow.getByTestId(`repair-override-action-${repairRequestId}`);
  await repairOverrideAction.waitFor();
  assert.equal(
    await repairRequestRow.getByTestId(`handoff-repair-to-qa-${repairRequestId}`).isDisabled(),
    true,
    "enforced repair QA policy should keep the normal repair handoff disabled while blocked"
  );
  assert.equal(
    await repairOverrideAction.getByRole("button", { name: "Handoff Repair to QA with Override" }).isDisabled(),
    true,
    "repair override handoff button should require a non-empty reason"
  );

  const repairOverrideReason = "Browser smoke operator override for repair QA without repair Developer/Codex result.";
  await repairOverrideAction.locator(`[data-testid="repair-override-reason-${repairRequestId}"]`).fill(repairOverrideReason);
  await repairOverrideAction.getByRole("button", { name: "Handoff Repair to QA with Override" }).click();
  const repairHandoffRow = page
    .getByTestId("handoffs-panel")
    .locator("article")
    .filter({ hasText: repairWorkOrderId })
    .filter({ hasText: "repair_qa" })
    .first();
  await repairHandoffRow.waitFor();
  await repairHandoffRow.locator(".state-tag", { hasText: "proposed" }).waitFor();
  await repairHandoffRow.locator('[data-testid^="handoff-policy-override-"]').getByText(repairOverrideReason).waitFor();
  await repairHandoffRow.getByText("No developer result captured; handoff was operator override-approved").waitFor();
  const repairOverrideMatch = /R19-POLICY-OVERRIDE-\d+/.exec(await repairHandoffRow.textContent());
  assert.ok(repairOverrideMatch, "repair handoff should show policy override id");
  const repairOverrideId = repairOverrideMatch[0];
  const repairOverrideRow = page.getByTestId("policy-overrides-list").locator("article").filter({ hasText: repairOverrideId }).first();
  await repairOverrideRow.waitFor();
  await repairOverrideRow.getByText("repair_qa_handoff").waitFor();
  await repairOverrideRow.getByText(repairOverrideReason).waitFor();

  await repairHandoffRow.locator('[data-testid^="handoff-reason-"]').fill("Browser smoke accepts the repair QA handoff.");
  await repairHandoffRow.getByRole("button", { name: "Accept" }).click();
  await repairHandoffRow.locator(".state-tag", { hasText: "accepted" }).waitFor();

  await repairHandoffRow.locator('[data-testid^="qa-result-form-"]').waitFor();
  await repairHandoffRow.locator('[data-testid^="qa-result-select-"]').selectOption("passed");
  await repairHandoffRow.locator('[data-testid^="qa-result-summary-"]').fill("Browser smoke repair QA passed.");
  await repairHandoffRow.locator('[data-testid^="qa-result-findings-"]').fill("The repair work order is ready to complete.");
  await repairHandoffRow
    .locator('[data-testid^="qa-result-next-action-"]')
    .fill("Complete the repair work order.");
  await repairHandoffRow.getByRole("button", { name: "Record QA Result" }).click();
  await repairHandoffRow.getByText("QA result recorded: passed").waitFor();
  await repairWorkOrderRow.locator(".record-title-line .state-tag", { hasText: "completed" }).waitFor();

  const originalIterationRow = page.getByTestId(`workflow-iteration-${workOrderId}`);
  await originalIterationRow.waitFor();
  await originalIterationRow.locator(".state-tag", { hasText: "failed" }).waitFor();
  const repairIterationRow = page.getByTestId(`workflow-iteration-${repairWorkOrderId}`);
  await repairIterationRow.waitFor();
  await repairIterationRow.locator(".state-tag", { hasText: "passed" }).waitFor();

  await page.getByTestId("events-list").getByText("handoff_accepted").first().waitFor();
  await page.getByTestId("events-list").getByText("qa_result_recorded").first().waitFor();
  await page.getByTestId("events-list").getByText("work_order_blocked_from_qa").waitFor();
  await page.getByTestId("events-list").getByText("repair_request_created").waitFor();
  await page.getByTestId("events-list").getByText("repair_work_order_created").waitFor();
  await page.getByTestId("events-list").getByText("repair_handoff_created").waitFor();
  await page.getByTestId("events-list").getByText("policy_settings_updated").first().waitFor();
  await page.getByTestId("events-list").getByText("policy_override_recorded").first().waitFor();
  await page.getByTestId("events-list").getByText("repair_qa_result_recorded").waitFor();
  await page.getByTestId("events-list").getByText("repair_iteration_passed").waitFor();
  await page.getByTestId("evidence-list").getByText("handoff_decision").first().waitFor();
  await page.getByTestId("evidence-list").getByText("policy_settings", { exact: true }).first().waitFor();
  await page.getByTestId("evidence-list").getByText("policy_override", { exact: true }).first().waitFor();
  await page.getByTestId("evidence-list").getByText("qa_result", { exact: true }).first().waitFor();
  await page.getByTestId("evidence-list").getByText("repair_request", { exact: true }).first().waitFor();
  await page.getByTestId("evidence-list").getByText("repair_work_order", { exact: true }).waitFor();
  await page.getByTestId("evidence-list").getByText("repair_handoff", { exact: true }).waitFor();
  await page.getByTestId("evidence-list").getByText("repair_qa_result", { exact: true }).waitFor();
  await page.getByTestId("evidence-list").getByText("workflow_iteration", { exact: true }).first().waitFor();
  await page.getByTestId("events-list").getByText("card_status_changed").waitFor();
  await page.getByTestId("evidence-list").getByText("status_transition").first().waitFor();

  const auditPanel = page.getByTestId("audit-review-panel");
  await auditPanel.waitFor();
  await auditPanel.getByTestId("audit-refresh").click();
  await waitForLocatorText(
    auditPanel.getByTestId("audit-summary-policy-overrides").locator("strong"),
    (text) => Number(text) >= 1,
    "audit policy override summary"
  );
  const auditExceptionsList = auditPanel.getByTestId("audit-exceptions-list");
  await auditExceptionsList.getByText("policy_override").first().waitFor();
  await auditExceptionsList.getByText("qa_failed").first().waitFor();
  await auditExceptionsList.getByText("repair_request_created").first().waitFor();

  await auditPanel.getByTestId("audit-filter-exception-type").selectOption("policy_override");
  await auditPanel.getByTestId("audit-apply-filters").click();
  await waitForLocatorText(
    auditExceptionsList,
    (text) => text.includes("policy_override") && text.includes(originalOverrideId) && !text.includes("qa_failed"),
    "policy override audit filter"
  );

  await auditPanel.getByTestId("audit-filter-q").fill(originalOverrideReason);
  await auditPanel.getByTestId("audit-apply-filters").click();
  await waitForLocatorText(
    auditExceptionsList,
    (text) => text.includes(originalOverrideId) && text.includes(originalOverrideReason),
    "audit text search filter"
  );

  const originalPolicyExceptionId = `audit-policy-override-${originalOverrideId}`;
  const policyExceptionRow = auditPanel.getByTestId(`audit-exception-${originalPolicyExceptionId}`);
  await policyExceptionRow.waitFor();
  await policyExceptionRow.getByTestId(`audit-review-status-${originalPolicyExceptionId}`).getByText("unreviewed").waitFor();
  await policyExceptionRow.getByTestId(`audit-review-status-select-${originalPolicyExceptionId}`).selectOption("acknowledged");
  await policyExceptionRow
    .getByTestId(`audit-review-reason-${originalPolicyExceptionId}`)
    .fill("Browser smoke acknowledged the policy override exception.");
  await policyExceptionRow.getByTestId(`audit-review-save-${originalPolicyExceptionId}`).click();
  await policyExceptionRow.getByTestId(`audit-review-status-${originalPolicyExceptionId}`).getByText("acknowledged").waitFor();

  await auditPanel.getByTestId("audit-filter-acknowledgement-status").selectOption("acknowledged");
  await auditPanel.getByTestId("audit-apply-filters").click();
  await waitForLocatorText(
    auditExceptionsList,
    (text) => text.includes(originalOverrideId) && text.includes("acknowledged"),
    "acknowledged audit filter"
  );

  await auditPanel.getByTestId("audit-filter-acknowledgement-status").selectOption("");
  await auditPanel.getByTestId("audit-apply-filters").click();
  await policyExceptionRow.waitFor();
  await policyExceptionRow.getByTestId(`audit-review-status-select-${originalPolicyExceptionId}`).selectOption("resolved");
  await policyExceptionRow
    .getByTestId(`audit-review-reason-${originalPolicyExceptionId}`)
    .fill("Browser smoke resolved the policy override exception.");
  await policyExceptionRow.getByTestId(`audit-review-save-${originalPolicyExceptionId}`).click();
  await policyExceptionRow.getByTestId(`audit-review-status-${originalPolicyExceptionId}`).getByText("resolved").waitFor();
  await waitForLocatorText(
    policyExceptionRow.getByTestId(`audit-history-count-${originalPolicyExceptionId}`),
    (text) => Number(text) >= 2,
    "audit acknowledgement history count"
  );
  await policyExceptionRow.getByTestId(`audit-history-toggle-${originalPolicyExceptionId}`).click();
  const policyHistoryList = policyExceptionRow.getByTestId(`audit-history-list-${originalPolicyExceptionId}`);
  await waitForLocatorText(
    policyHistoryList,
    (text) =>
      text.includes("none -> acknowledged") &&
      text.includes("acknowledged -> resolved") &&
      text.includes("Browser smoke acknowledged the policy override exception.") &&
      text.includes("Browser smoke resolved the policy override exception.") &&
      text.includes("operator at"),
    "audit acknowledgement history trail"
  );

  await auditPanel.getByTestId("audit-filter-acknowledgement-status").selectOption("resolved");
  await auditPanel.getByTestId("audit-apply-filters").click();
  await waitForLocatorText(
    auditExceptionsList,
    (text) => text.includes(originalOverrideId) && text.includes("resolved"),
    "resolved audit filter"
  );

  await auditPanel.getByTestId("audit-filter-acknowledgement-status").selectOption("none");
  await auditPanel.getByTestId("audit-apply-filters").click();
  await waitForLocatorText(
    auditExceptionsList,
    (text) => !text.includes(originalOverrideId),
    "unreviewed audit filter excludes resolved exception"
  );

  await auditPanel.getByTestId("audit-filter-acknowledgement-status").selectOption("resolved");
  await auditPanel.getByTestId("audit-apply-filters").click();
  await waitForLocatorText(
    auditExceptionsList,
    (text) => text.includes(originalOverrideId) && text.includes("resolved"),
    "resolved audit filter restored for export"
  );

  const auditExportOutput = auditPanel.getByTestId("audit-export-output");
  await auditPanel.getByTestId("audit-export-json").click();
  await waitForLocatorValue(
    auditExportOutput,
    (value) =>
      value.includes('"policy_override"') &&
      value.includes(originalOverrideId) &&
      value.includes('"acknowledgement_status"') &&
      value.includes('"resolved"') &&
      value.includes('"acknowledgement_reason"') &&
      !value.includes('"acknowledgement_history"'),
    "compact audit JSON export"
  );
  await auditPanel.getByTestId("audit-export-include-history").check();
  await auditPanel.getByTestId("audit-export-json").click();
  await waitForLocatorValue(
    auditExportOutput,
    (value) =>
      value.includes('"acknowledgement_history"') &&
      value.includes('"previous_status":null') &&
      value.includes('"new_status":"acknowledged"') &&
      value.includes('"previous_status":"acknowledged"') &&
      value.includes('"new_status":"resolved"') &&
      value.includes("Browser smoke resolved the policy override exception."),
    "history audit JSON export"
  );
  await auditPanel.getByTestId("audit-export-csv").click();
  await waitForLocatorValue(
    auditExportOutput,
    (value) =>
      value.includes("id,exception_type,severity,title,card_id,work_order_id,handoff_id") &&
      value.includes("acknowledgement_status,acknowledgement_reason") &&
      value.includes(originalOverrideId) &&
      value.includes("resolved") &&
      value.includes("Browser smoke resolved the policy override exception."),
    "audit CSV export"
  );
  await page.getByTestId("events-list").getByText("audit_exception_acknowledged").waitFor();
  await page.getByTestId("events-list").getByText("audit_exception_resolved").waitFor();
  await page.getByTestId("evidence-list").getByText("audit_acknowledgement", { exact: true }).first().waitFor();

  assert.deepEqual(consoleErrors, [], `Browser console errors were captured: ${consoleErrors.join("\n")}`);
  console.log(`Smoke passed against ${uiUrl} with temp state ${stateDir}`);
} finally {
  if (browser) {
    await browser.close();
  }
  await Promise.all(processes.reverse().map((child) => child.stop()));
  await rm(stateDir, { recursive: true, force: true });
}

async function copySeedFiles(fromDir, toDir) {
  const names = await readdir(fromDir);
  for (const name of names.filter((item) => item.endsWith(".seed.json"))) {
    await copyFile(path.join(fromDir, name), path.join(toDir, name));
  }
}

function resolvePython() {
  if (process.env.PYTHON) {
    return process.env.PYTHON;
  }

  const venvPython = path.join(apiDir, ".venv", "Scripts", "python.exe");
  return existsSync(venvPython) ? venvPython : "python";
}

function startProcess(command, args, options) {
  const output = [];
  const child = spawn(command, args, { ...options, stdio: ["ignore", "pipe", "pipe"] });
  child.stdout.on("data", (chunk) => output.push(chunk.toString()));
  child.stderr.on("data", (chunk) => output.push(chunk.toString()));

  return {
    output,
    stop: () =>
      new Promise((resolve) => {
        if (child.exitCode !== null || child.killed) {
          resolve();
          return;
        }
        child.once("exit", () => resolve());
        child.kill();
        setTimeout(resolve, 1500).unref();
      })
  };
}

async function waitForJson(url, label) {
  const response = await waitForResponse(url, label);
  await response.json();
}

async function waitForText(url, expectedText, label) {
  const response = await waitForResponse(url, label);
  const text = await response.text();
  if (!text.includes(expectedText)) {
    throw new Error(`${label} responded without expected text: ${expectedText}`);
  }
}

async function waitForResponse(url, label, timeoutMs = 30000) {
  const deadline = Date.now() + timeoutMs;
  let lastError;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(url);
      if (response.ok) {
        return response;
      }
      lastError = new Error(`${label} returned HTTP ${response.status}`);
    } catch (error) {
      lastError = error;
    }
    await sleep(400);
  }
  throw new Error(`Timed out waiting for ${label} at ${url}: ${lastError?.message ?? "no response"}`);
}

async function getFreePort() {
  return new Promise((resolve, reject) => {
    const server = createServer();
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      server.close(() => {
        if (address && typeof address === "object") {
          resolve(address.port);
        } else {
          reject(new Error("Could not allocate a TCP port"));
        }
      });
    });
    server.on("error", reject);
  });
}

async function launchChromium() {
  try {
    return await chromium.launch();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`Playwright Chromium launch failed. Run "npx playwright install chromium" from apps/operator-ui. ${message}`);
  }
}

async function assertVisible(locator, label) {
  assert.equal(await locator.isVisible(), true, `${label} should be visible`);
}

async function waitForLocatorText(locator, predicate, label, timeoutMs = 10000) {
  const deadline = Date.now() + timeoutMs;
  let lastText = "";
  while (Date.now() < deadline) {
    lastText = (await locator.textContent()) ?? "";
    if (predicate(lastText)) {
      return lastText;
    }
    await sleep(200);
  }
  throw new Error(`Timed out waiting for ${label}. Last text: ${lastText}`);
}

async function waitForLocatorValue(locator, predicate, label, timeoutMs = 10000) {
  const deadline = Date.now() + timeoutMs;
  let lastValue = "";
  while (Date.now() < deadline) {
    lastValue = await locator.inputValue();
    if (predicate(lastValue)) {
      return lastValue;
    }
    await sleep(200);
  }
  throw new Error(`Timed out waiting for ${label}. Last value: ${lastValue}`);
}

async function savePolicy(page, { mode, requireOriginal, requireRepair, allowOverride = false }) {
  const panel = page.getByTestId("policy-settings-panel");
  await panel.getByTestId("policy-mode-select").selectOption(mode);

  const originalCheckbox = panel.getByTestId("policy-require-original-result");
  if ((await originalCheckbox.isChecked()) !== requireOriginal) {
    if (requireOriginal) {
      await originalCheckbox.check();
    } else {
      await originalCheckbox.uncheck();
    }
  }

  const repairCheckbox = panel.getByTestId("policy-require-repair-result");
  if ((await repairCheckbox.isChecked()) !== requireRepair) {
    if (requireRepair) {
      await repairCheckbox.check();
    } else {
      await repairCheckbox.uncheck();
    }
  }

  const overrideCheckbox = panel.getByTestId("policy-allow-override");
  if ((await overrideCheckbox.isChecked()) !== allowOverride) {
    if (allowOverride) {
      await overrideCheckbox.check();
    } else {
      await overrideCheckbox.uncheck();
    }
  }

  const patchResponse = page.waitForResponse(
    (response) =>
      response.url() === `${apiBaseUrl}/policy-settings` &&
      response.request().method() === "PATCH"
  );
  await panel.getByTestId("policy-save").click();
  const response = await patchResponse;
  assert.equal(response.status(), 200, "policy settings PATCH should succeed");
  await panel.locator(".state-tag", { hasText: mode }).waitFor();
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
