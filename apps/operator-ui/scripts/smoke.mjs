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

  await cardRow.locator('[data-testid^="card-status-"][data-testid$="-select"]').selectOption("planned");
  await cardRow.locator('[data-testid^="card-status-"][data-testid$="-reason"]').fill("Browser smoke planned the card.");
  await cardRow.locator('[data-testid^="card-status-"][data-testid$="-submit"]').click();
  await cardRow.locator(".state-tag", { hasText: "planned" }).waitFor();

  await workOrderRow.locator('[data-testid^="work-order-status-"][data-testid$="-select"]').selectOption("running");
  await workOrderRow.locator('[data-testid^="work-order-status-"][data-testid$="-reason"]').fill("Browser smoke started the work order.");
  await workOrderRow.locator('[data-testid^="work-order-status-"][data-testid$="-submit"]').click();
  await workOrderRow.locator(".state-tag", { hasText: "running" }).waitFor();

  await workOrderRow.getByRole("button", { name: "Handoff to QA" }).click();
  const handoffRow = page.getByTestId("handoffs-panel").locator("article").filter({ hasText: workOrderId }).first();
  await handoffRow.waitFor();
  await handoffRow.locator(".state-tag", { hasText: "proposed" }).waitFor();

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
  await workOrderRow.locator(".state-tag", { hasText: "blocked" }).waitFor();

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
  await repairRequestRow.locator(".state-tag", { hasText: "created" }).waitFor();

  const repairWorkOrderRow = page.getByTestId("work-orders-list").locator("article").filter({ hasText: `Repair: ${workOrderTitle}` }).first();
  await repairWorkOrderRow.waitFor();
  await repairWorkOrderRow.locator(".state-tag", { hasText: "ready" }).waitFor();
  await repairWorkOrderRow.getByText("developer_codex").waitFor();
  const repairWorkOrderId = (await repairWorkOrderRow.locator(".eyebrow").first().textContent())?.trim();
  assert.ok(repairWorkOrderId, "repair work-order id should be visible");

  await repairRequestRow.getByRole("button", { name: "Handoff Repair to QA" }).click();
  const repairHandoffRow = page
    .getByTestId("handoffs-panel")
    .locator("article")
    .filter({ hasText: repairWorkOrderId })
    .filter({ hasText: "repair_qa" })
    .first();
  await repairHandoffRow.waitFor();
  await repairHandoffRow.locator(".state-tag", { hasText: "proposed" }).waitFor();

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
  await repairWorkOrderRow.locator(".state-tag", { hasText: "completed" }).waitFor();

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
  await page.getByTestId("events-list").getByText("repair_qa_result_recorded").waitFor();
  await page.getByTestId("events-list").getByText("repair_iteration_passed").waitFor();
  await page.getByTestId("evidence-list").getByText("handoff_decision").first().waitFor();
  await page.getByTestId("evidence-list").getByText("qa_result", { exact: true }).first().waitFor();
  await page.getByTestId("evidence-list").getByText("repair_request", { exact: true }).first().waitFor();
  await page.getByTestId("evidence-list").getByText("repair_work_order", { exact: true }).waitFor();
  await page.getByTestId("evidence-list").getByText("repair_handoff", { exact: true }).waitFor();
  await page.getByTestId("evidence-list").getByText("repair_qa_result", { exact: true }).waitFor();
  await page.getByTestId("evidence-list").getByText("workflow_iteration", { exact: true }).first().waitFor();
  await page.getByTestId("events-list").getByText("card_status_changed").waitFor();
  await page.getByTestId("evidence-list").getByText("status_transition").first().waitFor();

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

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
