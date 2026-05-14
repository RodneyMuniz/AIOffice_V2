import { useCallback, useEffect, useMemo, useState } from "react";
import type { FormEvent } from "react";
import {
  API_BASE_URL,
  acceptHandoff,
  approveApproval,
  cancelRepairRequest,
  completeRepairRequest,
  createApproval,
  createCard,
  createDeveloperResult,
  createQaResult,
  createRepairRequest,
  createWorkOrder,
  exportAudit,
  exportState,
  getRepairRequestQaReadiness,
  getWorkOrderQaReadiness,
  handoffRepairRequestToQa,
  handoffWorkOrderToQa,
  importState,
  loadAuditAcknowledgementHistoryForMarker,
  loadAuditExceptions,
  loadAuditSummary,
  loadDashboard,
  loadStateHealth,
  rejectApproval,
  rejectHandoff,
  resetDemoState,
  saveAuditAcknowledgement,
  updateAuditAcknowledgement,
  updateCardStatus,
  updatePolicySettings,
  updateWorkOrderStatus
} from "./api";
import {
  AUDIT_ACKNOWLEDGEMENT_STATUSES,
  AUDIT_EXCEPTION_TYPES,
  AUDIT_SEVERITIES,
  CARD_STATUSES,
  DEVELOPER_RESULT_TYPES,
  QA_HANDOFF_POLICY_MODES,
  QA_RESULT_VALUES,
  WORK_ORDER_STATUSES
} from "./types";
import type {
  Agent,
  Approval,
  AuditAcknowledgementHistoryEntry,
  AuditException,
  AuditExceptionFilters,
  AuditSummary,
  AuditAcknowledgementStatus,
  Card,
  DashboardData,
  DeveloperResult,
  DeveloperResultType,
  EventEntry,
  EvidenceEntry,
  Handoff,
  HandoffOverrideRequest,
  PolicySettings,
  PolicyOverride,
  QaHandoffPolicyMode,
  QaReadiness,
  QaReadinessLevel,
  QaResult,
  QaResultValue,
  RepairRequest,
  StateExportCollection,
  StateHealth,
  StatusResponse,
  UpdateStatusRequest,
  WorkOrder,
  WorkflowIteration
} from "./types";
import "./App.css";

export default function App() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [connectionError, setConnectionError] = useState<string | null>(null);

  const refreshDashboard = useCallback(async (signal?: AbortSignal, showInitialLoading = false) => {
    if (showInitialLoading) {
      setIsLoading(true);
    } else {
      setIsRefreshing(true);
    }

    try {
      const nextData = await loadDashboard(signal);
      setData(nextData);
      setConnectionError(null);
    } catch (error: unknown) {
      if (signal?.aborted) {
        return;
      }

      const message = errorMessage(error);
      setConnectionError(message);
      throw error;
    } finally {
      if (!signal?.aborted) {
        setIsLoading(false);
        setIsRefreshing(false);
      }
    }
  }, []);

  useEffect(() => {
    const controller = new AbortController();
    refreshDashboard(controller.signal, true).catch(() => undefined);
    return () => controller.abort();
  }, [refreshDashboard]);

  return (
    <main className="app-shell">
      <header className="topbar">
        <div>
          <h1>AIOffice Operator Console</h1>
          <p>R19 local UI/API slice. No OpenAI or Codex API invocation.</p>
        </div>
        <div className="api-pill">
          <span>API</span>
          <strong>{API_BASE_URL}</strong>
        </div>
      </header>

      {isLoading && !data && <LoadingPanel />}
      {!isLoading && !data && connectionError && <ConnectionError error={connectionError} />}
      {data && (
        <Dashboard
          connectionError={connectionError}
          data={data}
          isRefreshing={isRefreshing}
          onRefresh={() => refreshDashboard()}
        />
      )}
    </main>
  );
}

function Dashboard({
  connectionError,
  data,
  isRefreshing,
  onRefresh
}: {
  connectionError: string | null;
  data: DashboardData;
  isRefreshing: boolean;
  onRefresh: () => Promise<void>;
}) {
  const cardStatusOptions = data.status.allowed_card_statuses.length
    ? data.status.allowed_card_statuses
    : [...CARD_STATUSES];
  const workOrderStatusOptions = data.status.allowed_work_order_statuses.length
    ? data.status.allowed_work_order_statuses
    : [...WORK_ORDER_STATUSES];

  return (
    <>
      {(connectionError || isRefreshing) && (
        <div className={`notice-row ${connectionError ? "error" : ""}`} role="status">
          {connectionError ? `Connection issue: ${connectionError}` : "Refreshing operator state..."}
        </div>
      )}
      <div className="dashboard-grid">
        <StatusPanel status={data.status} />
        <PolicySettingsPanel onRefresh={onRefresh} policySettings={data.policySettings} />
        <LocalStatePanel onRefresh={onRefresh} />
        <CreateCardForm onRefresh={onRefresh} />
        <CreateWorkOrderForm agents={data.agents} cards={data.cards} onRefresh={onRefresh} />
        <CardsList
          allowedStatuses={cardStatusOptions}
          cards={data.cards}
          currentCardId={data.status.current_card_id}
          onRefresh={onRefresh}
        />
        <WorkOrdersList
          agents={data.agents}
          allowedStatuses={workOrderStatusOptions}
          currentWorkOrderId={data.status.current_work_order_id}
          developerResults={data.developerResults}
          handoffs={data.handoffs}
          onRefresh={onRefresh}
          policySettings={data.policySettings}
          qaResults={data.qaResults}
          workOrders={data.workOrders}
        />
        <DeveloperResultsPanel developerResults={data.developerResults} />
        <HandoffsPanel handoffs={data.handoffs} onRefresh={onRefresh} qaResults={data.qaResults} />
        <PolicyOverridesPanel policyOverrides={data.policyOverrides} />
        <AuditReviewPanel onRefresh={onRefresh} />
        <QaResultsPanel
          agents={data.agents}
          onRefresh={onRefresh}
          qaResults={data.qaResults}
          repairRequests={data.repairRequests}
        />
        <RepairRequestsPanel
          developerResults={data.developerResults}
          handoffs={data.handoffs}
          onRefresh={onRefresh}
          policySettings={data.policySettings}
          qaResults={data.qaResults}
          repairRequests={data.repairRequests}
          workOrders={data.workOrders}
        />
        <WorkflowIterationsPanel workflowIterations={data.workflowIterations} />
        <AgentsPanel agents={data.agents} />
        <ApprovalsPanel approvals={data.approvals} onRefresh={onRefresh} />
        <CreateApprovalForm cards={data.cards} onRefresh={onRefresh} workOrders={data.workOrders} />
        <EventsPanel events={data.events} />
        <EvidencePanel evidence={data.evidence} />
      </div>
    </>
  );
}

function LoadingPanel() {
  return (
    <section className="panel connection-panel">
      <h2>Connecting to orchestrator API</h2>
      <p>Loading current operator state from the backend.</p>
    </section>
  );
}

function ConnectionError({ error }: { error: string }) {
  return (
    <section className="panel connection-panel error-panel">
      <h2>Backend connection error</h2>
      <p>The operator console could not reach the orchestrator API at {API_BASE_URL}.</p>
      <pre>{error}</pre>
    </section>
  );
}

function StatusPanel({ status }: { status: StatusResponse }) {
  return (
    <section className="panel status-panel" data-testid="status-panel">
      <div className="panel-heading">
        <h2>Status</h2>
        <span className="state-tag">{status.posture}</span>
      </div>
      <dl className="status-list">
        <div>
          <dt>Product</dt>
          <dd>{status.product_name}</dd>
        </div>
        <div>
          <dt>Milestone</dt>
          <dd>{status.milestone}</dd>
        </div>
        <div>
          <dt>Repository</dt>
          <dd>{status.repo}</dd>
        </div>
        <div>
          <dt>Branch</dt>
          <dd>{status.branch}</dd>
        </div>
        <div>
          <dt>R18 posture</dt>
          <dd>{status.r18_posture}</dd>
        </div>
        <div>
          <dt>QA policy</dt>
          <dd>{status.qa_handoff_policy_mode}</dd>
        </div>
      </dl>
      <div className="metric-row">
        <Metric label="Cards" value={status.cards_count} />
        <Metric label="Work orders" value={status.work_orders_count} />
        <Metric label="Handoffs" value={status.handoffs_count} />
        <Metric label="Pending handoffs" value={status.pending_handoffs_count} />
        <Metric label="QA results" value={status.qa_results_count} />
        <Metric label="Failed QA" value={status.failed_qa_results_count} />
        <Metric label="Blocked QA" value={status.blocked_qa_results_count} />
        <Metric label="Repair requests" value={status.repair_requests_count} />
        <Metric label="Open repairs" value={status.open_repair_requests_count} />
        <Metric label="Completed repairs" value={status.completed_repair_requests_count} />
        <Metric label="Workflow iterations" value={status.workflow_iterations_count} />
        <Metric label="Repair QA handoffs" value={status.repair_qa_handoffs_count} />
        <Metric label="Repair QA results" value={status.repair_qa_results_count} />
        <Metric label="Developer results" value={status.developer_results_count} />
        <Metric label="Submitted dev results" value={status.submitted_developer_results_count} />
        <Metric label="WO with dev results" value={status.work_orders_with_developer_results_count} />
        <Metric label="QA policy enforced" value={status.qa_policy_enforced ? 1 : 0} />
        <Metric label="Original result required" value={status.require_developer_result_for_qa ? 1 : 0} />
        <Metric label="Repair result required" value={status.require_developer_result_for_repair_qa ? 1 : 0} />
        {typeof status.readiness_warnings_count === "number" && (
          <Metric label="Readiness warnings" value={status.readiness_warnings_count} />
        )}
        {typeof status.readiness_blockers_count === "number" && (
        <Metric label="Readiness blockers" value={status.readiness_blockers_count} />
        )}
        {typeof status.policy_overrides_count === "number" && (
          <Metric label="Policy overrides" value={status.policy_overrides_count} />
        )}
        {typeof status.qa_handoffs_with_override_count === "number" && (
          <Metric label="Override handoffs" value={status.qa_handoffs_with_override_count} />
        )}
        <Metric label="Pending approvals" value={status.pending_approvals_count} />
        <Metric label="Events" value={status.events_count} />
        <Metric label="Evidence" value={status.evidence_count} />
      </div>
      <ul className="non-claims">
        {status.non_claims.map((claim) => (
          <li key={claim}>{claim}</li>
        ))}
      </ul>
    </section>
  );
}

function LocalStatePanel({ onRefresh }: { onRefresh: () => Promise<void> }) {
  const [health, setHealth] = useState<StateHealth | null>(null);
  const [isHealthLoading, setIsHealthLoading] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [isImporting, setIsImporting] = useState(false);
  const [isResetting, setIsResetting] = useState(false);
  const [exportText, setExportText] = useState("");
  const [importText, setImportText] = useState("");
  const [importReason, setImportReason] = useState("Restoring local demo state");
  const [resetReason, setResetReason] = useState("Resetting local demo state");
  const [resetConfirm, setResetConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const refreshStateHealth = useCallback(async (signal?: AbortSignal) => {
    setIsHealthLoading(true);
    try {
      const nextHealth = await loadStateHealth(signal);
      setHealth(nextHealth);
      setError(null);
      setSuccess("State health refreshed.");
    } catch (healthError: unknown) {
      if (!signal?.aborted) {
        setError(errorMessage(healthError));
      }
    } finally {
      if (!signal?.aborted) {
        setIsHealthLoading(false);
      }
    }
  }, []);

  useEffect(() => {
    const controller = new AbortController();
    refreshStateHealth(controller.signal).catch(() => undefined);
    return () => controller.abort();
  }, [refreshStateHealth]);

  async function handleExport() {
    setError(null);
    setSuccess(null);
    setIsExporting(true);
    try {
      const exported = await exportState();
      setExportText(JSON.stringify(exported, null, 2));
      setSuccess(`Exported ${exported.collections.length} local state collections.`);
    } catch (exportError: unknown) {
      setError(errorMessage(exportError));
    } finally {
      setIsExporting(false);
    }
  }

  async function copyExportText() {
    if (!exportText) {
      return;
    }
    try {
      await navigator.clipboard.writeText(exportText);
      setSuccess("Export JSON copied.");
    } catch {
      setSuccess("Export JSON is ready to select and copy.");
    }
  }

  async function handleImport(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsImporting(true);
    try {
      const collections = parseImportCollections(importText);
      const summary = await importState({
        collections,
        import_reason: importReason.trim(),
        requested_by: "operator"
      });
      await Promise.all([onRefresh(), refreshStateHealth()]);
      setSuccess(`Imported ${summary.imported_collections.length} collection(s).`);
    } catch (importError: unknown) {
      setError(errorMessage(importError));
    } finally {
      setIsImporting(false);
    }
  }

  async function handleReset(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsResetting(true);
    try {
      const summary = await resetDemoState({
        reset_reason: resetReason.trim(),
        requested_by: "operator",
        confirm: resetConfirm.trim()
      });
      setResetConfirm("");
      await Promise.all([onRefresh(), refreshStateHealth()]);
      setSuccess(`Reset ${summary.reset_collections.length} persistent collection(s).`);
    } catch (resetError: unknown) {
      setError(errorMessage(resetError));
    } finally {
      setIsResetting(false);
    }
  }

  const importDisabled = isImporting || !importText.trim() || !importReason.trim();
  const resetDisabled =
    isResetting || !resetReason.trim() || resetConfirm.trim() !== "RESET_R19_DEMO_STATE";

  return (
    <section className="panel local-state-panel" data-testid="local-state-panel">
      <div className="panel-heading">
        <h2>Local State</h2>
        <span
          className={`state-tag ${
            health?.blockers.length ? "danger" : health?.warnings.length ? "warn" : ""
          }`}
          data-testid="state-health-safe"
        >
          {health ? (health.safe_to_reset ? "safe to reset" : "blocked") : "loading"}
        </span>
      </div>

      {health && (
        <>
          <dl className="status-list state-health-summary" data-testid="state-health-summary">
            <div>
              <dt>Persistence</dt>
              <dd>{health.persistence_mode}</dd>
            </div>
            <div>
              <dt>State directory</dt>
              <dd>{health.state_dir}</dd>
            </div>
            <div>
              <dt>Total collections</dt>
              <dd>{health.totals.collections}</dd>
            </div>
            <div>
              <dt>Warnings</dt>
              <dd>{health.totals.warnings}</dd>
            </div>
            <div>
              <dt>Blockers</dt>
              <dd>{health.totals.blockers}</dd>
            </div>
            <div>
              <dt>Safe to reset</dt>
              <dd>{formatBoolean(health.safe_to_reset)}</dd>
            </div>
          </dl>

          <div className="state-collection-table-wrap">
            <table className="state-collection-table" data-testid="state-health-collections">
              <thead>
                <tr>
                  <th>Collection</th>
                  <th>Seed</th>
                  <th>Persistent</th>
                  <th>Records</th>
                  <th>JSON</th>
                  <th>Warning / blocker</th>
                </tr>
              </thead>
              <tbody>
                {health.collections.map((collection) => (
                  <tr key={collection.name} data-testid={`state-collection-${collection.name}`}>
                    <td>{collection.name}</td>
                    <td>{formatBoolean(collection.seed_exists)}</td>
                    <td>{formatBoolean(collection.persistent_exists)}</td>
                    <td>{collection.record_count}</td>
                    <td>{collection.json_valid ? "valid" : "invalid"}</td>
                    <td>{collection.blocker ?? collection.warning ?? "ok"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      <div className="state-action-row">
        <button data-testid="state-refresh" disabled={isHealthLoading} onClick={() => refreshStateHealth()} type="button">
          {isHealthLoading ? "Refreshing..." : "Refresh State Health"}
        </button>
        <button data-testid="state-export" disabled={isExporting} onClick={handleExport} type="button">
          {isExporting ? "Exporting..." : "Export State JSON"}
        </button>
        <button className="secondary" data-testid="state-copy-export" disabled={!exportText} onClick={copyExportText} type="button">
          Copy Export
        </button>
      </div>

      <label className="state-textarea-label">
        Export JSON
        <textarea
          aria-label="State export JSON"
          data-testid="state-export-output"
          onChange={(event) => setExportText(event.target.value)}
          placeholder="Exported local state JSON appears here."
          value={exportText}
        />
      </label>

      <div className="state-forms-grid">
        <form className="form-grid" onSubmit={handleImport}>
          <h3>Import State JSON</h3>
          <label>
            Import reason
            <input
              data-testid="state-import-reason"
              onChange={(event) => setImportReason(event.target.value)}
              required
              value={importReason}
            />
          </label>
          <label>
            JSON input
            <textarea
              data-testid="state-import-input"
              onChange={(event) => setImportText(event.target.value)}
              placeholder="Paste a state export or a collections object."
              value={importText}
            />
          </label>
          <button data-testid="state-import-submit" disabled={importDisabled} type="submit">
            {isImporting ? "Importing..." : "Import State"}
          </button>
        </form>

        <form className="form-grid" onSubmit={handleReset}>
          <h3>Reset Demo State</h3>
          <p className="form-status warning">This resets local demo JSON state only.</p>
          <label>
            Reset reason
            <input
              data-testid="state-reset-reason"
              onChange={(event) => setResetReason(event.target.value)}
              required
              value={resetReason}
            />
          </label>
          <label>
            Confirmation
            <input
              data-testid="state-reset-confirm"
              onChange={(event) => setResetConfirm(event.target.value)}
              placeholder="RESET_R19_DEMO_STATE"
              value={resetConfirm}
            />
          </label>
          <button className="danger" data-testid="state-reset-submit" disabled={resetDisabled} type="submit">
            {isResetting ? "Resetting..." : "Reset Demo State"}
          </button>
        </form>
      </div>

      <FormStatus error={error} success={success} />
    </section>
  );
}

function PolicySettingsPanel({
  onRefresh,
  policySettings
}: {
  onRefresh: () => Promise<void>;
  policySettings: PolicySettings;
}) {
  const [mode, setMode] = useState<QaHandoffPolicyMode>(policySettings.qa_handoff_policy_mode);
  const [requireOriginalResult, setRequireOriginalResult] = useState(policySettings.require_developer_result_for_qa);
  const [requireRepairResult, setRequireRepairResult] = useState(
    policySettings.require_developer_result_for_repair_qa
  );
  const [allowOperatorOverride, setAllowOperatorOverride] = useState(policySettings.allow_operator_override);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    setMode(policySettings.qa_handoff_policy_mode);
    setRequireOriginalResult(policySettings.require_developer_result_for_qa);
    setRequireRepairResult(policySettings.require_developer_result_for_repair_qa);
    setAllowOperatorOverride(policySettings.allow_operator_override);
  }, [policySettings]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSaving(true);

    try {
      const savedSettings = await updatePolicySettings({
        qa_handoff_policy_mode: mode,
        require_developer_result_for_qa: requireOriginalResult,
        require_developer_result_for_repair_qa: requireRepairResult,
        allow_operator_override: allowOperatorOverride,
        updated_by: "operator"
      });
      await onRefresh();
      setSuccess(`Saved ${savedSettings.qa_handoff_policy_mode} QA handoff policy`);
    } catch (saveError: unknown) {
      setError(errorMessage(saveError));
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <section className="panel policy-settings-panel" data-testid="policy-settings-panel">
      <div className="panel-heading">
        <h2>Policy Settings</h2>
        <span className={`state-tag ${mode === "enforced" ? "danger" : "warn"}`}>{mode}</span>
      </div>
      <form className="form-grid" onSubmit={handleSubmit}>
        <label>
          QA handoff policy mode
          <select
            data-testid="policy-mode-select"
            onChange={(event) => setMode(event.target.value as QaHandoffPolicyMode)}
            value={mode}
          >
            {QA_HANDOFF_POLICY_MODES.map((policyMode) => (
              <option key={policyMode} value={policyMode}>
                {policyMode}
              </option>
            ))}
          </select>
        </label>
        <label className="checkbox-field">
          <input
            checked={requireOriginalResult}
            data-testid="policy-require-original-result"
            onChange={(event) => setRequireOriginalResult(event.target.checked)}
            type="checkbox"
          />
          Require Developer/Codex result for original QA
        </label>
        <label className="checkbox-field">
          <input
            checked={requireRepairResult}
            data-testid="policy-require-repair-result"
            onChange={(event) => setRequireRepairResult(event.target.checked)}
            type="checkbox"
          />
          Require Developer/Codex result for repair QA
        </label>
        <label className="checkbox-field">
          <input
            checked={allowOperatorOverride}
            data-testid="policy-allow-override"
            onChange={(event) => setAllowOperatorOverride(event.target.checked)}
            type="checkbox"
          />
          Allow operator override for policy-promoted readiness blockers
        </label>
        <p className="form-status warning policy-override-note">
          Overrides are limited to missing Developer/Codex result blockers promoted by enforced policy. Hard system blockers stay blocked.
        </p>
        <div className="policy-meta" data-testid="policy-settings-meta">
          <span>Updated</span>
          <strong>{policySettings.updated_at || "not recorded"}</strong>
          <span>By</span>
          <strong>{policySettings.updated_by || "unknown"}</strong>
        </div>
        <button data-testid="policy-save" disabled={isSaving} type="submit">
          {isSaving ? "Saving..." : "Save Policy"}
        </button>
        <FormStatus error={error} success={success} />
      </form>
    </section>
  );
}

function CreateCardForm({ onRefresh }: { onRefresh: () => Promise<void> }) {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [priority, setPriority] = useState("medium");
  const [ownerRole, setOwnerRole] = useState("operator");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSubmitting(true);

    try {
      const card = await createCard({
        title: title.trim(),
        description: description.trim(),
        priority,
        owner_role: ownerRole.trim()
      });
      await onRefresh();
      setTitle("");
      setDescription("");
      setSuccess(`Created ${card.id}`);
    } catch (submitError: unknown) {
      setError(errorMessage(submitError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <section className="panel form-panel" data-testid="create-card-panel">
      <div className="panel-heading">
        <h2>Create Card</h2>
      </div>
      <form className="form-grid" onSubmit={handleSubmit}>
        <label>
          Title
          <input
            data-testid="create-card-title"
            onChange={(event) => setTitle(event.target.value)}
            required
            value={title}
          />
        </label>
        <label>
          Description
          <textarea
            data-testid="create-card-description"
            onChange={(event) => setDescription(event.target.value)}
            rows={4}
            value={description}
          />
        </label>
        <div className="two-column-fields">
          <label>
            Priority
            <select
              data-testid="create-card-priority"
              onChange={(event) => setPriority(event.target.value)}
              value={priority}
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </label>
          <label>
            Owner role
            <input onChange={(event) => setOwnerRole(event.target.value)} value={ownerRole} />
          </label>
        </div>
        <button data-testid="create-card-submit" disabled={isSubmitting || !title.trim()} type="submit">
          {isSubmitting ? "Creating..." : "Create Card"}
        </button>
        <FormStatus error={error} success={success} />
      </form>
    </section>
  );
}

function CreateWorkOrderForm({
  agents,
  cards,
  onRefresh
}: {
  agents: Agent[];
  cards: Card[];
  onRefresh: () => Promise<void>;
}) {
  const [cardId, setCardId] = useState(cards[0]?.id ?? "");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [assignedAgentId, setAssignedAgentId] = useState(
    agents.find((agent) => agent.id === "developer_codex")?.id ?? agents[0]?.id ?? ""
  );
  const [requestRequiresApproval, setRequestRequiresApproval] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    if (!cardId || !cards.some((card) => card.id === cardId)) {
      setCardId(cards[0]?.id ?? "");
    }
  }, [cardId, cards]);

  useEffect(() => {
    if (!assignedAgentId || !agents.some((agent) => agent.id === assignedAgentId)) {
      setAssignedAgentId(agents.find((agent) => agent.id === "developer_codex")?.id ?? agents[0]?.id ?? "");
    }
  }, [agents, assignedAgentId]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSubmitting(true);

    try {
      const workOrder = await createWorkOrder({
        card_id: cardId,
        title: title.trim(),
        description: description.trim(),
        assigned_agent_id: assignedAgentId,
        request_requires_approval: requestRequiresApproval
      });
      await onRefresh();
      setTitle("");
      setDescription("");
      setSuccess(`Created ${workOrder.id}`);
    } catch (submitError: unknown) {
      setError(errorMessage(submitError));
    } finally {
      setIsSubmitting(false);
    }
  }

  const disabled = isSubmitting || !cards.length || !agents.length || !cardId || !assignedAgentId || !title.trim();

  return (
    <section className="panel form-panel" data-testid="create-work-order-panel">
      <div className="panel-heading">
        <h2>Create Work Order</h2>
      </div>
      <form className="form-grid" onSubmit={handleSubmit}>
        <label>
          Card
          <select data-testid="create-work-order-card" onChange={(event) => setCardId(event.target.value)} value={cardId}>
            {cards.map((card) => (
              <option key={card.id} value={card.id}>
                {card.id} - {card.title}
              </option>
            ))}
          </select>
        </label>
        <label>
          Title
          <input
            data-testid="create-work-order-title"
            onChange={(event) => setTitle(event.target.value)}
            required
            value={title}
          />
        </label>
        <label>
          Description
          <textarea
            data-testid="create-work-order-description"
            onChange={(event) => setDescription(event.target.value)}
            rows={4}
            value={description}
          />
        </label>
        <label>
          Assigned agent
          <select
            data-testid="create-work-order-agent"
            onChange={(event) => setAssignedAgentId(event.target.value)}
            value={assignedAgentId}
          >
            {agents.map((agent) => (
              <option key={agent.id} value={agent.id}>
                {agent.display_name}
              </option>
            ))}
          </select>
        </label>
        <label className="checkbox-field">
          <input
            checked={requestRequiresApproval}
            data-testid="create-work-order-approval"
            onChange={(event) => setRequestRequiresApproval(event.target.checked)}
            type="checkbox"
          />
          Request approval
        </label>
        <button data-testid="create-work-order-submit" disabled={disabled} type="submit">
          {isSubmitting ? "Creating..." : "Create Work Order"}
        </button>
        <FormStatus error={error} success={success} />
      </form>
    </section>
  );
}

function CreateApprovalForm({
  cards,
  onRefresh,
  workOrders
}: {
  cards: Card[];
  onRefresh: () => Promise<void>;
  workOrders: WorkOrder[];
}) {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [cardId, setCardId] = useState(cards[0]?.id ?? "");
  const [workOrderId, setWorkOrderId] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const selectedWorkOrder = useMemo(
    () => workOrders.find((workOrder) => workOrder.id === workOrderId),
    [workOrderId, workOrders]
  );

  useEffect(() => {
    if (!cardId || !cards.some((card) => card.id === cardId)) {
      setCardId(cards[0]?.id ?? "");
    }
  }, [cardId, cards]);

  useEffect(() => {
    if (workOrderId && !workOrders.some((workOrder) => workOrder.id === workOrderId)) {
      setWorkOrderId("");
    }
  }, [workOrderId, workOrders]);

  useEffect(() => {
    if (selectedWorkOrder) {
      setCardId(selectedWorkOrder.card_id);
    }
  }, [selectedWorkOrder]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSubmitting(true);

    try {
      const approval = await createApproval({
        title: title.trim(),
        description: description.trim(),
        related_card_id: cardId,
        related_work_order_id: workOrderId || null
      });
      await onRefresh();
      setTitle("");
      setDescription("");
      setSuccess(`Created ${approval.id}`);
    } catch (submitError: unknown) {
      setError(errorMessage(submitError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <section className="panel form-panel" data-testid="create-approval-panel">
      <div className="panel-heading">
        <h2>Create Approval Request</h2>
      </div>
      <form className="form-grid" onSubmit={handleSubmit}>
        <label>
          Title
          <input data-testid="create-approval-title" onChange={(event) => setTitle(event.target.value)} required value={title} />
        </label>
        <label>
          Description
          <textarea
            data-testid="create-approval-description"
            onChange={(event) => setDescription(event.target.value)}
            rows={3}
            value={description}
          />
        </label>
        <label>
          Related work order
          <select data-testid="create-approval-work-order" onChange={(event) => setWorkOrderId(event.target.value)} value={workOrderId}>
            <option value="">No linked work order</option>
            {workOrders.map((workOrder) => (
              <option key={workOrder.id} value={workOrder.id}>
                {workOrder.id} - {workOrder.title}
              </option>
            ))}
          </select>
        </label>
        <label>
          Related card
          <select
            data-testid="create-approval-card"
            disabled={Boolean(selectedWorkOrder)}
            onChange={(event) => setCardId(event.target.value)}
            value={cardId}
          >
            {cards.map((card) => (
              <option key={card.id} value={card.id}>
                {card.id} - {card.title}
              </option>
            ))}
          </select>
        </label>
        <button data-testid="create-approval-submit" disabled={isSubmitting || !title.trim() || !cardId} type="submit">
          {isSubmitting ? "Requesting..." : "Request Approval"}
        </button>
        <FormStatus error={error} success={success} />
      </form>
    </section>
  );
}

function CardsList({
  allowedStatuses,
  cards,
  currentCardId,
  onRefresh
}: {
  allowedStatuses: readonly string[];
  cards: Card[];
  currentCardId: string | null;
  onRefresh: () => Promise<void>;
}) {
  const visibleCards = useMemo(() => [...cards].reverse(), [cards]);

  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Cards</h2>
        <span className="count-tag">{cards.length}</span>
      </div>
      <div className="record-list" data-testid="cards-list">
        {visibleCards.map((card) => (
          <article className={`record-row ${card.id === currentCardId ? "active" : ""}`} key={card.id}>
            <div className="record-title-line">
              <p className="eyebrow">{card.id}</p>
              <span className="state-tag">{card.status}</span>
            </div>
            <h3>{card.title}</h3>
            <p>{card.summary}</p>
            <div className="detail-grid">
              <span>Owner</span>
              <strong>{card.owner_role ?? card.owner_agent_id}</strong>
              <span>Priority</span>
              <strong>{card.priority}</strong>
            </div>
            <StatusTransitionForm
              allowedStatuses={allowedStatuses}
              currentStatus={card.status}
              label="Update status"
              onRefresh={onRefresh}
              onUpdate={updateCardStatus}
              recordId={card.id}
              testIdPrefix="card-status"
            />
          </article>
        ))}
      </div>
    </section>
  );
}

function WorkOrdersList({
  agents,
  allowedStatuses,
  currentWorkOrderId,
  developerResults,
  handoffs,
  onRefresh,
  policySettings,
  qaResults,
  workOrders
}: {
  agents: Agent[];
  allowedStatuses: readonly string[];
  currentWorkOrderId: string | null;
  developerResults: DeveloperResult[];
  handoffs: Handoff[];
  onRefresh: () => Promise<void>;
  policySettings: PolicySettings;
  qaResults: QaResult[];
  workOrders: WorkOrder[];
}) {
  const visibleWorkOrders = useMemo(() => [...workOrders].reverse(), [workOrders]);
  const developerResultsByWorkOrderId = useMemo(() => {
    const grouped = new Map<string, DeveloperResult[]>();
    for (const result of developerResults) {
      const results = grouped.get(result.work_order_id) ?? [];
      results.push(result);
      grouped.set(result.work_order_id, results);
    }
    return grouped;
  }, [developerResults]);
  const qaResultByHandoffId = useMemo(
    () => new Map(qaResults.map((qaResult) => [qaResult.handoff_id, qaResult])),
    [qaResults]
  );
  const [handoffWorkOrderId, setHandoffWorkOrderId] = useState<string | null>(null);
  const [handoffStatusById, setHandoffStatusById] = useState<Record<string, string>>({});
  const [readinessByWorkOrderId, setReadinessByWorkOrderId] = useState<Record<string, QaReadiness>>({});
  const [readinessErrorById, setReadinessErrorById] = useState<Record<string, string>>({});
  const [checkingReadinessId, setCheckingReadinessId] = useState<string | null>(null);

  useEffect(() => {
    setReadinessByWorkOrderId({});
    setReadinessErrorById({});
  }, [developerResults, handoffs, policySettings, qaResults, workOrders]);

  async function checkWorkOrderReadiness(workOrderId: string) {
    setCheckingReadinessId(workOrderId);
    setReadinessErrorById((current) => ({ ...current, [workOrderId]: "" }));

    try {
      const readiness = await getWorkOrderQaReadiness(workOrderId);
      setReadinessByWorkOrderId((current) => ({ ...current, [workOrderId]: readiness }));
    } catch (readinessError: unknown) {
      setReadinessErrorById((current) => ({ ...current, [workOrderId]: errorMessage(readinessError) }));
    } finally {
      setCheckingReadinessId(null);
    }
  }

  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Work Orders</h2>
        <span className="count-tag">{workOrders.length}</span>
      </div>
      <div className="record-list" data-testid="work-orders-list">
        {visibleWorkOrders.map((workOrder) => {
          const workOrderDeveloperResults = developerResultsByWorkOrderId.get(workOrder.id) ?? [];
          const latestSubmittedDeveloperResult = latestDeveloperResult(workOrderDeveloperResults);
          const handoffContext = displayWorkOrderType(workOrder) === "repair" ? "repair_qa" : "initial_qa";
          const activeQaHandoff = latestActiveQaHandoffForWorkOrder(
            workOrder.id,
            handoffContext,
            handoffs,
            qaResultByHandoffId
          );
          const loadedReadiness = readinessByWorkOrderId[workOrder.id] ?? null;
          const requireDeveloperResultForContext =
            policySettings.qa_handoff_policy_mode === "enforced" &&
            (handoffContext === "repair_qa"
              ? policySettings.require_developer_result_for_repair_qa
              : policySettings.require_developer_result_for_qa);
          const derivedReadinessLevel: QaReadinessLevel = activeQaHandoff
            ? "blocked"
            : latestSubmittedDeveloperResult
              ? "ready"
              : requireDeveloperResultForContext
                ? "blocked"
                : "warning";
          const effectiveReadinessLevel: QaReadinessLevel = activeQaHandoff
            ? "blocked"
            : loadedReadiness?.readiness_level ?? derivedReadinessLevel;
          const readinessSummary = activeQaHandoff
            ? `Blocked: active QA handoff ${activeQaHandoff.id} is ${activeQaHandoff.status}.`
            : latestSubmittedDeveloperResult
              ? `Ready: latest submitted Developer/Codex result ${latestSubmittedDeveloperResult.id} exists.`
              : requireDeveloperResultForContext
                ? "Blocked: Developer/Codex result is required by current QA handoff policy."
                : "Warning: no Developer/Codex result captured.";

          return (
            <article
              className={`record-row ${workOrder.id === currentWorkOrderId ? "active" : ""} ${
                displayWorkOrderType(workOrder) === "repair" ? "repair-row" : ""
              }`}
              key={workOrder.id}
            >
            <div className="record-title-line">
              <p className="eyebrow">{workOrder.id}</p>
              <span className={`state-tag ${workOrder.approval_required ? "warn" : ""}`}>{workOrder.status}</span>
            </div>
            <h3>{workOrder.title}</h3>
            <p>{workOrder.summary}</p>
            <div className="detail-grid">
              <span>Card</span>
              <strong>{workOrder.card_id}</strong>
              <span>Assigned</span>
              <strong>{workOrder.assigned_agent_id}</strong>
              <span>Type</span>
              <strong>{displayWorkOrderType(workOrder)}</strong>
              <span>Iteration</span>
              <strong>{workOrder.iteration_number ?? (displayWorkOrderType(workOrder) === "repair" ? 2 : 1)}</strong>
              <span>QA handoffs</span>
              <strong>{handoffs.filter((handoff) => handoff.work_order_id === workOrder.id).length}</strong>
              <span>Developer results</span>
              <strong>
                {workOrderDeveloperResults.length}
                {latestSubmittedDeveloperResult ? `, latest ${latestSubmittedDeveloperResult.id}` : ""}
              </strong>
              <span>Approval</span>
              <strong>{workOrder.approval_required ? "required" : "not required"}</strong>
              {workOrder.source_work_order_id && (
                <>
                  <span>Source work order</span>
                  <strong>{workOrder.source_work_order_id}</strong>
                </>
              )}
              {workOrder.qa_result_id && (
                <>
                  <span>QA result</span>
                  <strong>{workOrder.qa_result_id}</strong>
                </>
              )}
              {workOrder.repair_request_id && (
                <>
                  <span>Repair request</span>
                  <strong>{workOrder.repair_request_id}</strong>
                </>
              )}
            </div>
            <DeveloperResultForm agents={agents} onRefresh={onRefresh} workOrder={workOrder} />
            <QaReadinessPanel
              buttonTestId={`check-qa-readiness-${workOrder.id}`}
              error={readinessErrorById[workOrder.id] || null}
              fallbackLevel={derivedReadinessLevel}
              fallbackMessage={readinessSummary}
              isChecking={checkingReadinessId === workOrder.id}
              label="QA readiness"
              onCheck={() => checkWorkOrderReadiness(workOrder.id)}
              policySettings={policySettings}
              readiness={loadedReadiness}
              testId={`qa-readiness-${workOrder.id}`}
            />
            <HandoffToQaAction
              isWorking={handoffWorkOrderId === workOrder.id}
              onDone={(message) => setHandoffStatusById((current) => ({ ...current, [workOrder.id]: message }))}
              onRefresh={onRefresh}
              onWorkingChange={(isWorking) => setHandoffWorkOrderId(isWorking ? workOrder.id : null)}
              readiness={loadedReadiness}
              readinessLevel={effectiveReadinessLevel}
              statusMessage={handoffStatusById[workOrder.id] ?? null}
              workOrder={workOrder}
            />
            <StatusTransitionForm
              allowedStatuses={allowedStatuses}
              currentStatus={workOrder.status}
              label="Update status"
              onRefresh={onRefresh}
              onUpdate={updateWorkOrderStatus}
              recordId={workOrder.id}
              testIdPrefix="work-order-status"
            />
          </article>
          );
        })}
      </div>
    </section>
  );
}

function DeveloperResultForm({
  agents,
  onRefresh,
  workOrder
}: {
  agents: Agent[];
  onRefresh: () => Promise<void>;
  workOrder: WorkOrder;
}) {
  const defaultResultType = displayWorkOrderType(workOrder) === "repair" ? "repair" : "implementation";
  const defaultAgentId = agents.find((agent) => agent.id === "developer_codex")?.id ?? agents[0]?.id ?? "developer_codex";
  const [resultType, setResultType] = useState<DeveloperResultType>(defaultResultType);
  const [summary, setSummary] = useState("");
  const [changedPaths, setChangedPaths] = useState("");
  const [notes, setNotes] = useState("");
  const [agentId, setAgentId] = useState(defaultAgentId);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    setResultType(defaultResultType);
  }, [defaultResultType, workOrder.id]);

  useEffect(() => {
    if (!agentId || (agents.length && !agents.some((agent) => agent.id === agentId))) {
      setAgentId(defaultAgentId);
    }
  }, [agentId, agents, defaultAgentId]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSubmitting(true);

    try {
      const developerResult = await createDeveloperResult(workOrder.id, {
        result_type: resultType,
        summary: summary.trim(),
        changed_paths: parseChangedPaths(changedPaths),
        notes: notes.trim(),
        agent_id: agentId
      });
      await onRefresh();
      setSummary("");
      setChangedPaths("");
      setNotes("");
      setSuccess(`Recorded ${developerResult.id}`);
    } catch (submitError: unknown) {
      setError(errorMessage(submitError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="developer-result-form" data-testid={`developer-result-form-${workOrder.id}`} onSubmit={handleSubmit}>
      <div className="two-column-fields">
        <label>
          Result type
          <select
            data-testid={`developer-result-type-${workOrder.id}`}
            onChange={(event) => setResultType(event.target.value as DeveloperResultType)}
            value={resultType}
          >
            {DEVELOPER_RESULT_TYPES.map((type) => (
              <option key={type} value={type}>
                {type}
              </option>
            ))}
          </select>
        </label>
        <label>
          Agent
          <select
            data-testid={`developer-result-agent-${workOrder.id}`}
            onChange={(event) => setAgentId(event.target.value)}
            value={agentId}
          >
            {agents.length === 0 && <option value="developer_codex">developer_codex</option>}
            {agents.map((agent) => (
              <option key={agent.id} value={agent.id}>
                {agent.display_name}
              </option>
            ))}
          </select>
        </label>
      </div>
      <label>
        Summary
        <input
          data-testid={`developer-result-summary-${workOrder.id}`}
          onChange={(event) => setSummary(event.target.value)}
          required
          value={summary}
        />
      </label>
      <label>
        Changed paths
        <textarea
          data-testid={`developer-result-paths-${workOrder.id}`}
          onChange={(event) => setChangedPaths(event.target.value)}
          placeholder="apps/operator-ui/src/App.tsx"
          rows={3}
          value={changedPaths}
        />
      </label>
      <label>
        Notes
        <textarea
          data-testid={`developer-result-notes-${workOrder.id}`}
          onChange={(event) => setNotes(event.target.value)}
          rows={2}
          value={notes}
        />
      </label>
      <button
        data-testid={`developer-result-submit-${workOrder.id}`}
        disabled={isSubmitting || !summary.trim() || !agentId}
        type="submit"
      >
        {isSubmitting ? "Recording..." : "Record Developer Result"}
      </button>
      <FormStatus error={error} success={success} />
    </form>
  );
}

function HandoffToQaAction({
  isWorking,
  onDone,
  onRefresh,
  onWorkingChange,
  readiness,
  readinessLevel,
  statusMessage,
  workOrder
}: {
  isWorking: boolean;
  onDone: (message: string) => void;
  onRefresh: () => Promise<void>;
  onWorkingChange: (isWorking: boolean) => void;
  readiness: QaReadiness | null;
  readinessLevel: QaReadinessLevel;
  statusMessage: string | null;
  workOrder: WorkOrder;
}) {
  const [overrideReason, setOverrideReason] = useState("");
  const [error, setError] = useState<string | null>(null);
  const isBlocked = readinessLevel === "blocked";
  const overrideAvailable = isBlocked && Boolean(readiness?.override_available);
  const overrideUnavailableReason = readiness
    ? overrideUnavailableMessage(readiness)
    : "Check readiness to see whether a policy override is available.";

  async function handleHandoff(override?: HandoffOverrideRequest) {
    setError(null);
    onWorkingChange(true);

    try {
      const handoff = await handoffWorkOrderToQa(workOrder.id, override);
      await onRefresh();
      setOverrideReason("");
      onDone(
        handoff.policy_override_id
          ? `Created ${handoff.id} with override ${handoff.policy_override_id}`
          : `Created ${handoff.id}`
      );
    } catch (handoffError: unknown) {
      setError(errorMessage(handoffError));
    } finally {
      onWorkingChange(false);
    }
  }

  function handleOverrideHandoff() {
    const reason = overrideReason.trim();
    if (!reason) {
      setError("Override reason is required.");
      return;
    }
    void handleHandoff({
      override_policy: true,
      override_reason: reason,
      requested_by: "operator"
    });
  }

  return (
    <div className="inline-action-block">
      <button
        data-testid={`handoff-to-qa-${workOrder.id}`}
        disabled={isWorking || isBlocked}
        onClick={() => handleHandoff()}
        type="button"
        title={isBlocked ? "QA readiness is blocked for this work order." : undefined}
      >
        {isWorking ? "Handing off..." : "Handoff to QA"}
      </button>
      {isBlocked && overrideAvailable && (
        <div className="override-action-block" data-testid={`override-action-${workOrder.id}`}>
          <label>
            Override reason
            <textarea
              data-testid={`override-reason-${workOrder.id}`}
              onChange={(event) => setOverrideReason(event.target.value)}
              rows={3}
              value={overrideReason}
            />
          </label>
          <button
            className="danger"
            data-testid={`handoff-to-qa-override-${workOrder.id}`}
            disabled={isWorking || !overrideReason.trim()}
            onClick={handleOverrideHandoff}
            type="button"
          >
            {isWorking ? "Handing off..." : "Handoff to QA with Override"}
          </button>
        </div>
      )}
      {isBlocked && !overrideAvailable && (
        <p className="form-status warning" data-testid={`override-unavailable-${workOrder.id}`}>
          Override unavailable: {overrideUnavailableReason}
        </p>
      )}
      <FormStatus error={error} success={statusMessage} />
    </div>
  );
}

function QaReadinessPanel({
  buttonTestId,
  error,
  fallbackLevel,
  fallbackMessage,
  isChecking,
  label,
  onCheck,
  policySettings,
  readiness,
  testId
}: {
  buttonTestId: string;
  error: string | null;
  fallbackLevel: QaReadinessLevel;
  fallbackMessage: string;
  isChecking: boolean;
  label: string;
  onCheck: () => void;
  policySettings: PolicySettings;
  readiness: QaReadiness | null;
  testId: string;
}) {
  const level = readiness?.readiness_level ?? fallbackLevel;
  const generatedAt = readiness?.generated_at;
  const policyMode = readiness?.policy_mode ?? policySettings.qa_handoff_policy_mode;
  const policyEnforced = readiness?.policy_enforced ?? policyMode === "enforced";
  const warningsPromoted = readiness?.advisory_warnings_promoted_to_blockers ?? false;

  return (
    <div className={`qa-readiness-block ${readinessLevelClass(level)}`} data-testid={testId}>
      <div className="readiness-heading">
        <div>
          <p className="eyebrow">{label}</p>
          <strong>{readiness ? readinessHeadline(readiness) : fallbackMessage}</strong>
        </div>
        <span className={`state-tag ${readinessLevelClass(level)}`}>{level}</span>
      </div>
      <small data-testid={`${testId}-policy`}>
        Policy {policyMode}; enforcement {policyEnforced ? "on" : "off"}
        {warningsPromoted ? "; warning promoted to blocker" : ""}
      </small>
      {generatedAt && <small>Checked {generatedAt}</small>}
      {readiness && readiness.overridable_blockers.length > 0 && (
        <div className="readiness-classification" data-testid={`${testId}-overridable`}>
          <p className="eyebrow">Policy-overridable blockers</p>
          {readiness.overridable_blockers.map((blocker) => (
            <p key={blocker}>{blocker}</p>
          ))}
        </div>
      )}
      {readiness && readiness.non_overridable_blockers.length > 0 && (
        <div className="readiness-classification" data-testid={`${testId}-non-overridable`}>
          <p className="eyebrow">Non-overridable blockers</p>
          {readiness.non_overridable_blockers.map((blocker) => (
            <p key={blocker}>{blocker}</p>
          ))}
        </div>
      )}
      {readiness && (
        <p className={`form-status ${readiness.override_available ? "warning" : ""}`}>
          Override {readiness.override_available ? "available for this handoff request" : "not available"}
        </p>
      )}
      {readiness && (
        <div className="readiness-checks">
          {readiness.checks.map((check) => (
            <div className="readiness-check-row" key={check.id}>
              <span className={`state-tag ${readinessLevelClass(check.status)}`}>{check.status}</span>
              <div>
                <strong>{check.label}</strong>
                <p>{check.detail}</p>
              </div>
            </div>
          ))}
        </div>
      )}
      <button className="secondary" data-testid={buttonTestId} disabled={isChecking} onClick={onCheck} type="button">
        {isChecking ? "Checking..." : label.includes("Repair") ? "Check Repair QA readiness" : "Check QA readiness"}
      </button>
      <FormStatus error={error} success={null} />
    </div>
  );
}

function readinessHeadline(readiness: QaReadiness): string {
  if (readiness.readiness_level === "blocked") {
    return readiness.blockers[0] ?? "Blocked: QA handoff has blocking readiness gaps.";
  }
  if (readiness.readiness_level === "warning") {
    return readiness.warnings[0] ?? "Warning: QA handoff has advisory readiness gaps.";
  }
  return readiness.latest_developer_result_id
    ? `Ready: latest submitted Developer/Codex result ${readiness.latest_developer_result_id} exists.`
    : "Ready: advisory checks passed.";
}

function overrideUnavailableMessage(readiness: QaReadiness): string {
  if (readiness.policy_mode !== "enforced") {
    return "policy mode is advisory, so an override is not needed.";
  }
  if (readiness.non_overridable_blockers.length > 0) {
    return readiness.non_overridable_blockers[0];
  }
  if (readiness.overridable_blockers.length === 0) {
    return "no policy-promoted missing Developer/Codex result blocker is present.";
  }
  return "operator override is disabled in Policy Settings.";
}

function DeveloperResultsPanel({ developerResults }: { developerResults: DeveloperResult[] }) {
  const visibleDeveloperResults = useMemo(() => [...developerResults].reverse(), [developerResults]);

  return (
    <section className="panel developer-results-panel" data-testid="developer-results-panel">
      <div className="panel-heading">
        <h2>Developer Results</h2>
        <span className="count-tag">{developerResults.length}</span>
      </div>
      <div className="record-list" data-testid="developer-results-list">
        {visibleDeveloperResults.length === 0 && <p>No Developer/Codex results recorded yet.</p>}
        {visibleDeveloperResults.map((developerResult) => (
          <article className="record-row" data-testid={`developer-result-${developerResult.id}`} key={developerResult.id}>
            <div className="record-title-line">
              <p className="eyebrow">{developerResult.id}</p>
              <span className={`state-tag ${developerResult.status === "superseded" ? "warn" : ""}`}>
                {developerResult.status}
              </span>
            </div>
            <div className="detail-grid handoff-detail-grid">
              <span>Work order</span>
              <strong>{developerResult.work_order_id}</strong>
              <span>Card</span>
              <strong>{developerResult.card_id}</strong>
              <span>Agent</span>
              <strong>{developerResult.agent_id}</strong>
              <span>Type</span>
              <strong>{developerResult.result_type}</strong>
              <span>Created</span>
              <strong>{developerResult.created_at}</strong>
              <span>Updated</span>
              <strong>{developerResult.updated_at}</strong>
            </div>
            <div className="summary-stack">
              <div>
                <p className="eyebrow">Summary</p>
                <p>{developerResult.summary}</p>
              </div>
              <div>
                <p className="eyebrow">Changed paths</p>
                <div className="code-list">
                  {developerResult.changed_paths.length === 0 && <code>none recorded</code>}
                  {developerResult.changed_paths.map((changedPath) => (
                    <code key={changedPath}>{changedPath}</code>
                  ))}
                </div>
              </div>
              <div>
                <p className="eyebrow">Notes</p>
                <p>{developerResult.notes || "No additional notes recorded."}</p>
              </div>
              <div>
                <p className="eyebrow">Evidence refs</p>
                <div className="code-list">
                  {developerResult.evidence_refs.map((ref) => (
                    <code key={ref}>{ref}</code>
                  ))}
                </div>
              </div>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

function HandoffsPanel({
  handoffs,
  onRefresh,
  qaResults
}: {
  handoffs: Handoff[];
  onRefresh: () => Promise<void>;
  qaResults: QaResult[];
}) {
  const visibleHandoffs = useMemo(() => [...handoffs].reverse(), [handoffs]);
  const qaResultByHandoffId = useMemo(
    () => new Map(qaResults.map((qaResult) => [qaResult.handoff_id, qaResult])),
    [qaResults]
  );
  const [reasonById, setReasonById] = useState<Record<string, string>>({});
  const [workingHandoffId, setWorkingHandoffId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  async function decideHandoff(handoff: Handoff, decision: "accept" | "reject") {
    const decidedStatus = decision === "accept" ? "accepted" : "rejected";
    const reason = reasonById[handoff.id]?.trim() || `Operator ${decidedStatus} ${handoff.id}.`;
    setError(null);
    setSuccess(null);
    setWorkingHandoffId(handoff.id);

    try {
      if (decision === "accept") {
        await acceptHandoff(handoff.id, { decision_reason: reason, decided_by: "operator" });
      } else {
        await rejectHandoff(handoff.id, { decision_reason: reason, decided_by: "operator" });
      }
      await onRefresh();
      setReasonById((current) => ({ ...current, [handoff.id]: "" }));
      setSuccess(`${handoff.id} ${decidedStatus}`);
    } catch (decisionError: unknown) {
      setError(errorMessage(decisionError));
    } finally {
      setWorkingHandoffId(null);
    }
  }

  return (
    <section className="panel handoffs-panel" data-testid="handoffs-panel">
      <div className="panel-heading">
        <h2>Handoffs</h2>
        <span className="count-tag">{handoffs.length}</span>
      </div>
      <div className="record-list">
        {visibleHandoffs.length === 0 && <p>No handoffs yet.</p>}
        {visibleHandoffs.map((handoff) => {
          const qaResult = qaResultByHandoffId.get(handoff.id);

          return (
            <article
              className={`record-row ${handoff.status === "proposed" ? "pending" : ""}`}
              data-testid={`handoff-${handoff.id}`}
              key={handoff.id}
            >
              <div className="record-title-line">
                <p className="eyebrow">{handoff.id}</p>
                <span className={`state-tag ${handoffStatusClass(handoff.status)}`}>{handoff.status}</span>
              </div>
              <h3>{handoff.title}</h3>
              {handoff.summary && <p>{handoff.summary}</p>}
              <div className="detail-grid handoff-detail-grid">
                <span>Source agent</span>
                <strong>{handoff.source_agent_id}</strong>
                <span>Target agent</span>
                <strong>{handoff.target_agent_id}</strong>
                <span>Source role</span>
                <strong>{handoff.source_role}</strong>
                <span>Target role</span>
                <strong>{handoff.target_role}</strong>
                <span>Card</span>
                <strong>{handoff.card_id}</strong>
                <span>Work order</span>
                <strong>{handoff.work_order_id}</strong>
                <span>Purpose</span>
                <strong>{handoff.handoff_purpose ?? "initial_qa"}</strong>
                <span>Iteration</span>
                <strong>{handoff.iteration_number ?? 1}</strong>
                <span>Developer result</span>
                <strong>{handoff.developer_result_id ?? "none"}</strong>
                <span>Policy override</span>
                <strong>{handoff.policy_override_id ?? "none"}</strong>
                {handoff.repair_request_id && (
                  <>
                    <span>Repair request</span>
                    <strong>{handoff.repair_request_id}</strong>
                  </>
                )}
                {handoff.qa_result_id && (
                  <>
                    <span>Source QA result</span>
                    <strong>{handoff.qa_result_id}</strong>
                  </>
                )}
                <span>Created</span>
                <strong>{handoff.created_at}</strong>
                <span>Updated</span>
                <strong>{handoff.updated_at}</strong>
                <span>Decided</span>
                <strong>{handoff.decided_at ?? "pending"}</strong>
              </div>
              <div className="summary-stack">
                <div>
                  <p className="eyebrow">Payload summary</p>
                  <p>{handoff.payload_summary}</p>
                </div>
                <div>
                  <p className="eyebrow">Validation summary</p>
                  <p>{handoff.validation_summary}</p>
                </div>
                {handoff.developer_result_id && (
                  <div>
                    <p className="eyebrow">Developer result summary</p>
                    <p>{handoff.developer_result_summary || "No developer result summary recorded."}</p>
                  </div>
                )}
                {handoff.policy_override_id && (
                  <div className="override-summary" data-testid={`handoff-policy-override-${handoff.id}`}>
                    <p className="eyebrow">Policy override reason</p>
                    <p>
                      <strong>{handoff.policy_override_id}</strong>:{" "}
                      {handoff.policy_override_reason || "No override reason recorded."}
                    </p>
                  </div>
                )}
                {!handoff.developer_result_id && (
                  <p
                    className="form-status warning developer-result-warning"
                    data-testid={`handoff-developer-result-warning-${handoff.id}`}
                  >
                    {handoff.policy_override_id
                      ? "No developer result captured; handoff was operator override-approved"
                      : "No developer result captured before handoff"}
                  </p>
                )}
                {handoff.decision_reason && (
                  <div>
                    <p className="eyebrow">Decision reason</p>
                    <p>{handoff.decision_reason}</p>
                  </div>
                )}
              </div>
              {handoff.status === "proposed" && (
                <div className="decision-row">
                  <label>
                    Decision reason
                    <input
                      data-testid={`handoff-reason-${handoff.id}`}
                      onChange={(event) =>
                        setReasonById((current) => ({ ...current, [handoff.id]: event.target.value }))
                      }
                      value={reasonById[handoff.id] ?? ""}
                    />
                  </label>
                  <div className="button-row">
                    <button
                      data-testid={`accept-handoff-${handoff.id}`}
                      disabled={workingHandoffId === handoff.id}
                      onClick={() => decideHandoff(handoff, "accept")}
                      type="button"
                    >
                      Accept
                    </button>
                    <button
                      className="secondary danger"
                      data-testid={`reject-handoff-${handoff.id}`}
                      disabled={workingHandoffId === handoff.id}
                      onClick={() => decideHandoff(handoff, "reject")}
                      type="button"
                    >
                      Reject
                    </button>
                  </div>
                </div>
              )}
              {handoff.status === "accepted" && (
                qaResult ? (
                  <p
                    className="form-status success qa-result-recorded"
                    data-testid={`qa-result-recorded-${handoff.id}`}
                  >
                    QA result recorded: {qaResult.result}
                  </p>
                ) : (
                  <QaResultForm handoff={handoff} onRefresh={onRefresh} />
                )
              )}
            </article>
          );
        })}
      </div>
      <FormStatus error={error} success={success} />
    </section>
  );
}

function QaResultForm({ handoff, onRefresh }: { handoff: Handoff; onRefresh: () => Promise<void> }) {
  const [result, setResult] = useState<QaResultValue>("passed");
  const [summary, setSummary] = useState("");
  const [findings, setFindings] = useState("");
  const [recommendedNextAction, setRecommendedNextAction] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSubmitting(true);

    try {
      const qaResult = await createQaResult(handoff.id, {
        result,
        summary: summary.trim(),
        findings: findings.trim(),
        recommended_next_action: recommendedNextAction.trim(),
        qa_agent_id: handoff.target_agent_id || "qa_test"
      });
      await onRefresh();
      setSummary("");
      setFindings("");
      setRecommendedNextAction("");
      setSuccess(`Recorded ${qaResult.id}`);
    } catch (submitError: unknown) {
      setError(errorMessage(submitError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="qa-result-form" data-testid={`qa-result-form-${handoff.id}`} onSubmit={handleSubmit}>
      <div className="two-column-fields">
        <label>
          Result
          <select
            data-testid={`qa-result-select-${handoff.id}`}
            onChange={(event) => setResult(event.target.value as QaResultValue)}
            value={result}
          >
            {QA_RESULT_VALUES.map((value) => (
              <option key={value} value={value}>
                {value}
              </option>
            ))}
          </select>
        </label>
        <label>
          Recommended next action
          <input
            data-testid={`qa-result-next-action-${handoff.id}`}
            onChange={(event) => setRecommendedNextAction(event.target.value)}
            placeholder="Complete work order / repair / block"
            value={recommendedNextAction}
          />
        </label>
      </div>
      <label>
        Summary
        <input
          data-testid={`qa-result-summary-${handoff.id}`}
          onChange={(event) => setSummary(event.target.value)}
          required
          value={summary}
        />
      </label>
      <label>
        Findings
        <textarea
          data-testid={`qa-result-findings-${handoff.id}`}
          onChange={(event) => setFindings(event.target.value)}
          rows={3}
          value={findings}
        />
      </label>
      <button data-testid={`qa-result-submit-${handoff.id}`} disabled={isSubmitting || !summary.trim()} type="submit">
        {isSubmitting ? "Recording..." : "Record QA Result"}
      </button>
      <FormStatus error={error} success={success} />
    </form>
  );
}

function PolicyOverridesPanel({ policyOverrides }: { policyOverrides: PolicyOverride[] }) {
  const visibleOverrides = useMemo(() => [...policyOverrides].reverse(), [policyOverrides]);

  return (
    <section className="panel policy-overrides-panel" data-testid="policy-overrides-panel">
      <div className="panel-heading">
        <h2>Policy Overrides</h2>
        <span className="count-tag">{policyOverrides.length}</span>
      </div>
      <div className="record-list" data-testid="policy-overrides-list">
        {visibleOverrides.length === 0 && <p>No policy overrides recorded yet.</p>}
        {visibleOverrides.map((override) => (
          <article className="record-row" data-testid={`policy-override-${override.id}`} key={override.id}>
            <div className="record-title-line">
              <p className="eyebrow">{override.id}</p>
              <span className="state-tag warn">{override.policy_mode}</span>
            </div>
            <div className="detail-grid handoff-detail-grid">
              <span>Target type</span>
              <strong>{override.target_type}</strong>
              <span>Target id</span>
              <strong>{override.target_id}</strong>
              <span>Work order</span>
              <strong>{override.work_order_id}</strong>
              <span>Repair request</span>
              <strong>{override.repair_request_id ?? "none"}</strong>
              <span>Card</span>
              <strong>{override.card_id}</strong>
              <span>Requested by</span>
              <strong>{override.requested_by}</strong>
              <span>Created</span>
              <strong>{override.created_at}</strong>
            </div>
            <div className="summary-stack">
              <div>
                <p className="eyebrow">Reason</p>
                <p>{override.reason}</p>
              </div>
              <div>
                <p className="eyebrow">Overridden blockers</p>
                <div className="code-list">
                  {override.overridden_blockers.map((blocker) => (
                    <code key={blocker}>{blocker}</code>
                  ))}
                </div>
              </div>
              <div>
                <p className="eyebrow">Non-overridable blockers at request time</p>
                <div className="code-list">
                  {override.non_overridable_blockers.length === 0 && <code>none</code>}
                  {override.non_overridable_blockers.map((blocker) => (
                    <code key={blocker}>{blocker}</code>
                  ))}
                </div>
              </div>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

type AuditFilterDraft = {
  exception_type: string;
  severity: string;
  acknowledgement_status: string;
  q: string;
  work_order_id: string;
  card_id: string;
};

const DEFAULT_AUDIT_FILTERS: AuditFilterDraft = {
  exception_type: "",
  severity: "",
  acknowledgement_status: "",
  q: "",
  work_order_id: "",
  card_id: ""
};

function AuditReviewPanel({ onRefresh }: { onRefresh: () => Promise<void> }) {
  const [summary, setSummary] = useState<AuditSummary | null>(null);
  const [exceptions, setExceptions] = useState<AuditException[]>([]);
  const [draftFilters, setDraftFilters] = useState<AuditFilterDraft>(DEFAULT_AUDIT_FILTERS);
  const [activeFilters, setActiveFilters] = useState<AuditFilterDraft>(DEFAULT_AUDIT_FILTERS);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [exportText, setExportText] = useState("");
  const [exportStatus, setExportStatus] = useState<string | null>(null);
  const [reviewStatusById, setReviewStatusById] = useState<Record<string, AuditAcknowledgementStatus>>({});
  const [reviewReasonById, setReviewReasonById] = useState<Record<string, string>>({});
  const [savingReviewId, setSavingReviewId] = useState<string | null>(null);
  const [reviewStatus, setReviewStatus] = useState<string | null>(null);
  const [includeHistoryInJsonExport, setIncludeHistoryInJsonExport] = useState(false);
  const [expandedHistoryById, setExpandedHistoryById] = useState<Record<string, boolean>>({});
  const [historyByAcknowledgementId, setHistoryByAcknowledgementId] = useState<
    Record<string, AuditAcknowledgementHistoryEntry[]>
  >({});
  const [loadingHistoryForId, setLoadingHistoryForId] = useState<string | null>(null);

  const activeAuditFilters = useMemo(() => toAuditFilters(activeFilters), [activeFilters]);

  const refreshAudit = useCallback(
    async (signal?: AbortSignal) => {
      setIsLoading(true);
      setError(null);
      try {
        const [nextSummary, nextExceptions] = await Promise.all([
          loadAuditSummary(signal),
          loadAuditExceptions(activeAuditFilters, signal)
        ]);
        setSummary(nextSummary);
        setExceptions(nextExceptions);
      } catch (auditError: unknown) {
        if (signal?.aborted) {
          return;
        }
        setError(errorMessage(auditError));
      } finally {
        if (!signal?.aborted) {
          setIsLoading(false);
        }
      }
    },
    [activeAuditFilters]
  );

  useEffect(() => {
    const controller = new AbortController();
    refreshAudit(controller.signal).catch(() => undefined);
    return () => controller.abort();
  }, [refreshAudit]);

  function updateDraftFilter(field: keyof AuditFilterDraft, value: string) {
    setDraftFilters((current) => ({ ...current, [field]: value }));
  }

  function applyFilters(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setExportText("");
    setExportStatus(null);
    setReviewStatus(null);
    setActiveFilters({ ...draftFilters });
  }

  function clearFilters() {
    setDraftFilters({ ...DEFAULT_AUDIT_FILTERS });
    setActiveFilters({ ...DEFAULT_AUDIT_FILTERS });
    setExportText("");
    setExportStatus(null);
    setReviewStatus(null);
  }

  async function runExport(format: "json" | "csv") {
    setError(null);
    setExportStatus(null);
    setReviewStatus(null);
    try {
      const exported = await exportAudit(format, {
        ...activeAuditFilters,
        include_history: format === "json" && includeHistoryInJsonExport ? true : undefined
      });
      setExportText(exported);
      setExportStatus(`Exported ${format.toUpperCase()} review data`);
    } catch (exportError: unknown) {
      setError(errorMessage(exportError));
    }
  }

  async function toggleHistory(entry: AuditException) {
    const acknowledgementId = entry.acknowledgement_id;
    if (!acknowledgementId) {
      return;
    }

    const willExpand = !expandedHistoryById[entry.id];
    setExpandedHistoryById((current) => ({ ...current, [entry.id]: willExpand }));
    if (!willExpand || historyByAcknowledgementId[acknowledgementId]) {
      return;
    }

    setLoadingHistoryForId(entry.id);
    setError(null);
    try {
      const history = await loadAuditAcknowledgementHistoryForMarker(acknowledgementId);
      setHistoryByAcknowledgementId((current) => ({ ...current, [acknowledgementId]: history }));
    } catch (historyError: unknown) {
      setError(errorMessage(historyError));
    } finally {
      setLoadingHistoryForId(null);
    }
  }

  async function saveReview(entry: AuditException, event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const selectedStatus = reviewStatusById[entry.id] ?? entry.acknowledgement_status ?? "acknowledged";
    const reason = (reviewReasonById[entry.id] ?? entry.acknowledgement_reason ?? "").trim();
    if (!reason) {
      setError("Audit review reason is required.");
      return;
    }

    setSavingReviewId(entry.id);
    setError(null);
    setExportStatus(null);
    setReviewStatus(null);
    try {
      const savedAcknowledgement = entry.acknowledgement_id
        ? await updateAuditAcknowledgement(entry.acknowledgement_id, {
            status: selectedStatus,
            reason,
            acknowledged_by: "operator"
          })
        : await saveAuditAcknowledgement({
            exception_id: entry.id,
            exception_source_ref: entry.source_ref,
            exception_type: entry.exception_type,
            status: selectedStatus,
            reason,
            acknowledged_by: "operator"
          });

      if (entry.acknowledgement_id) {
        setHistoryByAcknowledgementId((current) => {
          const next = { ...current };
          delete next[entry.acknowledgement_id as string];
          return next;
        });
      }

      if (expandedHistoryById[entry.id]) {
        const history = await loadAuditAcknowledgementHistoryForMarker(savedAcknowledgement.id);
        setHistoryByAcknowledgementId((current) => ({ ...current, [savedAcknowledgement.id]: history }));
      }
      setReviewReasonById((current) => ({ ...current, [entry.id]: reason }));
      setReviewStatusById((current) => ({ ...current, [entry.id]: selectedStatus }));
      setReviewStatus(`${entry.id} marked ${selectedStatus}`);
      await Promise.all([refreshAudit(), onRefresh()]);
    } catch (reviewError: unknown) {
      setError(errorMessage(reviewError));
    } finally {
      setSavingReviewId(null);
    }
  }

  return (
    <section className="panel audit-review-panel" data-testid="audit-review-panel">
      <div className="panel-heading">
        <h2>Audit Review</h2>
        <div className="button-row compact-actions">
          <span className="count-tag">{exceptions.length}</span>
          <button data-testid="audit-refresh" disabled={isLoading} onClick={() => refreshAudit()} type="button">
            {isLoading ? "Refreshing..." : "Refresh Audit"}
          </button>
        </div>
      </div>
      <div className="metric-row audit-summary-grid">
        <AuditMetric label="Policy overrides" testId="audit-summary-policy-overrides" value={summary?.total_policy_overrides ?? 0} />
        <AuditMetric label="QA failures" testId="audit-summary-qa-failures" value={summary?.total_qa_failures ?? 0} />
        <AuditMetric label="QA blocked" testId="audit-summary-qa-blocked" value={summary?.total_qa_blocked_results ?? 0} />
        <AuditMetric label="Repair requests" testId="audit-summary-repair-requests" value={summary?.total_repair_requests ?? 0} />
        <AuditMetric label="Open repairs" testId="audit-summary-open-repairs" value={summary?.open_repair_requests ?? 0} />
        <AuditMetric label="Policy changes" testId="audit-summary-policy-changes" value={summary?.total_policy_settings_changes ?? 0} />
        <AuditMetric label="Unreviewed" testId="audit-summary-unreviewed" value={summary?.unreviewed_exceptions ?? 0} />
        <AuditMetric label="Acknowledged" testId="audit-summary-acknowledged" value={summary?.acknowledged_exceptions ?? 0} />
        <AuditMetric label="Resolved" testId="audit-summary-resolved" value={summary?.resolved_exceptions ?? 0} />
        <AuditMetric label="Dismissed" testId="audit-summary-dismissed" value={summary?.dismissed_exceptions ?? 0} />
        <AuditMetric label="History entries" testId="audit-summary-history-entries" value={summary?.audit_acknowledgement_history_entries ?? 0} />
        <AuditMetric label="Markers with history" testId="audit-summary-markers-with-history" value={summary?.audit_acknowledgements_with_history ?? 0} />
      </div>

      <form className="audit-filter-grid" onSubmit={applyFilters}>
        <label>
          Exception type
          <select
            data-testid="audit-filter-exception-type"
            onChange={(event) => updateDraftFilter("exception_type", event.target.value)}
            value={draftFilters.exception_type}
          >
            <option value="">All types</option>
            {AUDIT_EXCEPTION_TYPES.map((exceptionType) => (
              <option key={exceptionType} value={exceptionType}>
                {exceptionType}
              </option>
            ))}
          </select>
        </label>
        <label>
          Severity
          <select
            data-testid="audit-filter-severity"
            onChange={(event) => updateDraftFilter("severity", event.target.value)}
            value={draftFilters.severity}
          >
            <option value="">All severities</option>
            {AUDIT_SEVERITIES.map((severity) => (
              <option key={severity} value={severity}>
                {severity}
              </option>
            ))}
          </select>
        </label>
        <label>
          Review status
          <select
            data-testid="audit-filter-acknowledgement-status"
            onChange={(event) => updateDraftFilter("acknowledgement_status", event.target.value)}
            value={draftFilters.acknowledgement_status}
          >
            <option value="">All</option>
            <option value="none">Unreviewed</option>
            <option value="acknowledged">Acknowledged</option>
            <option value="resolved">Resolved</option>
            <option value="dismissed">Dismissed</option>
          </select>
        </label>
        <label>
          Search
          <input
            data-testid="audit-filter-q"
            onChange={(event) => updateDraftFilter("q", event.target.value)}
            value={draftFilters.q}
          />
        </label>
        <label>
          Work order id
          <input
            data-testid="audit-filter-work-order-id"
            onChange={(event) => updateDraftFilter("work_order_id", event.target.value)}
            value={draftFilters.work_order_id}
          />
        </label>
        <label>
          Card id
          <input
            data-testid="audit-filter-card-id"
            onChange={(event) => updateDraftFilter("card_id", event.target.value)}
            value={draftFilters.card_id}
          />
        </label>
        <div className="button-row audit-filter-actions">
          <button data-testid="audit-apply-filters" type="submit">
            Apply Filters
          </button>
          <button className="secondary" data-testid="audit-clear-filters" onClick={clearFilters} type="button">
            Clear Filters
          </button>
        </div>
      </form>

      <div className="audit-export-row">
        <label className="audit-history-export-toggle">
          <input
            checked={includeHistoryInJsonExport}
            data-testid="audit-export-include-history"
            onChange={(event) => setIncludeHistoryInJsonExport(event.target.checked)}
            type="checkbox"
          />
          Include history in JSON export
        </label>
        <div className="button-row">
          <button data-testid="audit-export-json" onClick={() => runExport("json")} type="button">
            Export JSON
          </button>
          <button className="secondary" data-testid="audit-export-csv" onClick={() => runExport("csv")} type="button">
            Export CSV
          </button>
        </div>
        <textarea
          aria-label="Audit export output"
          data-testid="audit-export-output"
          readOnly
          rows={6}
          value={exportText}
        />
      </div>
      <FormStatus error={error} success={reviewStatus ?? exportStatus} />

      <div className="record-list audit-exceptions-list" data-testid="audit-exceptions-list">
        {exceptions.length === 0 && <p>No audit exceptions match the current filters.</p>}
        {exceptions.map((entry) => {
          const currentReviewStatus = entry.acknowledgement_status ?? "unreviewed";
          const selectedReviewStatus =
            reviewStatusById[entry.id] ?? entry.acknowledgement_status ?? "acknowledged";
          const reviewReason = reviewReasonById[entry.id] ?? entry.acknowledgement_reason ?? "";
          const isHistoryExpanded = Boolean(expandedHistoryById[entry.id]);
          const historyEntries = entry.acknowledgement_id
            ? historyByAcknowledgementId[entry.acknowledgement_id] ?? []
            : [];
          const isHistoryLoading = loadingHistoryForId === entry.id;

          return (
            <article className="record-row" data-testid={`audit-exception-${entry.id}`} key={entry.id}>
              <div className="record-title-line">
                <p className="eyebrow">{entry.exception_type}</p>
                <span className={`state-tag ${auditSeverityClass(entry.severity)}`}>{entry.severity}</span>
              </div>
              <div className="record-title-line audit-review-title-line">
                <h3>{entry.title}</h3>
                <span
                  className={`state-tag ${auditAcknowledgementClass(currentReviewStatus)}`}
                  data-testid={`audit-review-status-${entry.id}`}
                >
                  {currentReviewStatus}
                </span>
              </div>
              <p>{entry.summary}</p>
              <div className="detail-grid handoff-detail-grid">
                <span>Card</span>
                <strong>{entry.card_id ?? "none"}</strong>
                <span>Work order</span>
                <strong>{entry.work_order_id ?? "none"}</strong>
                <span>Handoff</span>
                <strong>{entry.handoff_id ?? "none"}</strong>
                <span>QA result</span>
                <strong>{entry.qa_result_id ?? "none"}</strong>
                <span>Repair request</span>
                <strong>{entry.repair_request_id ?? "none"}</strong>
                <span>Policy override</span>
                <strong>{entry.policy_override_id ?? "none"}</strong>
                <span>Review reason</span>
                <strong>{entry.acknowledgement_reason ?? "none"}</strong>
                <span>Reviewed by</span>
                <strong>{entry.acknowledged_by ?? "none"}</strong>
                <span>Reviewed at</span>
                <strong>{entry.acknowledged_at ?? "none"}</strong>
                <span>Resolved at</span>
                <strong>{entry.resolved_at ?? "none"}</strong>
                <span>History</span>
                <strong data-testid={`audit-history-count-${entry.id}`}>
                  {entry.acknowledgement_id ? entry.acknowledgement_history_count : 0}
                </strong>
                <span>Latest change</span>
                <strong data-testid={`audit-history-latest-${entry.id}`}>
                  {entry.latest_acknowledgement_change_at ?? "none"}
                </strong>
                <span>Event</span>
                <strong>{entry.event_id ?? "none"}</strong>
                <span>Evidence</span>
                <strong>{entry.evidence_id ?? "none"}</strong>
                <span>Created</span>
                <strong>{entry.created_at || "unknown"}</strong>
              </div>
              <form
                className="audit-triage-form"
                data-testid={`audit-review-form-${entry.id}`}
                onSubmit={(event) => saveReview(entry, event)}
              >
                <label>
                  Review status
                  <select
                    data-testid={`audit-review-status-select-${entry.id}`}
                    onChange={(event) =>
                      setReviewStatusById((current) => ({
                        ...current,
                        [entry.id]: event.target.value as AuditAcknowledgementStatus
                      }))
                    }
                    value={selectedReviewStatus}
                  >
                    {AUDIT_ACKNOWLEDGEMENT_STATUSES.map((status) => (
                      <option key={status} value={status}>
                        {status}
                      </option>
                    ))}
                  </select>
                </label>
                <label>
                  Reason
                  <input
                    data-testid={`audit-review-reason-${entry.id}`}
                    onChange={(event) =>
                      setReviewReasonById((current) => ({
                        ...current,
                        [entry.id]: event.target.value
                      }))
                    }
                    required
                    value={reviewReason}
                  />
                </label>
                <button
                  data-testid={`audit-review-save-${entry.id}`}
                  disabled={savingReviewId === entry.id || !reviewReason.trim()}
                  type="submit"
                >
                  {savingReviewId === entry.id ? "Saving..." : "Save Review"}
                </button>
              </form>
              {entry.acknowledgement_id && (
                <div className="audit-history-block" data-testid={`audit-history-block-${entry.id}`}>
                  <button
                    className="secondary"
                    data-testid={`audit-history-toggle-${entry.id}`}
                    disabled={isHistoryLoading}
                    onClick={() => toggleHistory(entry)}
                    type="button"
                  >
                    {isHistoryLoading ? "Loading History..." : isHistoryExpanded ? "Hide History" : "Show History"}
                  </button>
                  {isHistoryExpanded && (
                    <div className="audit-history-list" data-testid={`audit-history-list-${entry.id}`}>
                      {historyEntries.length === 0 && !isHistoryLoading && <p>No history entries recorded.</p>}
                      {historyEntries.map((historyEntry) => (
                        <div className="audit-history-row" key={historyEntry.id}>
                          <strong>
                            {historyEntry.previous_status ?? "none"} -&gt; {historyEntry.new_status}
                          </strong>
                          <span>{historyEntry.reason}</span>
                          <small>
                            {historyEntry.changed_by} at {historyEntry.changed_at}
                          </small>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}
              <div className="code-list">
                <code>{entry.source_ref}</code>
              </div>
            </article>
          );
        })}
      </div>
    </section>
  );
}

function AuditMetric({ label, testId, value }: { label: string; testId: string; value: number }) {
  return (
    <div className="metric" data-testid={testId}>
      <strong>{value}</strong>
      <span>{label}</span>
    </div>
  );
}

function toAuditFilters(filters: AuditFilterDraft): AuditExceptionFilters {
  return {
    exception_type: filters.exception_type.trim(),
    severity: filters.severity.trim(),
    acknowledgement_status: filters.acknowledgement_status.trim() as AuditExceptionFilters["acknowledgement_status"],
    q: filters.q.trim(),
    work_order_id: filters.work_order_id.trim(),
    card_id: filters.card_id.trim(),
    limit: 100,
    offset: 0
  };
}

function QaResultsPanel({
  agents,
  onRefresh,
  qaResults,
  repairRequests
}: {
  agents: Agent[];
  onRefresh: () => Promise<void>;
  qaResults: QaResult[];
  repairRequests: RepairRequest[];
}) {
  const visibleQaResults = useMemo(() => [...qaResults].reverse(), [qaResults]);
  const repairRequestByQaResultId = useMemo(
    () => new Map(repairRequests.map((repairRequest) => [repairRequest.qa_result_id, repairRequest])),
    [repairRequests]
  );

  return (
    <section className="panel qa-results-panel" data-testid="qa-results-panel">
      <div className="panel-heading">
        <h2>QA Results</h2>
        <span className="count-tag">{qaResults.length}</span>
      </div>
      <div className="record-list" data-testid="qa-results-list">
        {visibleQaResults.length === 0 && <p>No QA results recorded yet.</p>}
        {visibleQaResults.map((qaResult) => {
          const repairRequest = repairRequestByQaResultId.get(qaResult.id);
          const canCreateRepairRequest = qaResult.result !== "passed" && !repairRequest;

          return (
            <article className="record-row" data-testid={`qa-result-${qaResult.id}`} key={qaResult.id}>
              <div className="record-title-line">
                <p className="eyebrow">{qaResult.id}</p>
                <span className={`state-tag ${qaResultStatusClass(qaResult.result)}`}>{qaResult.result}</span>
              </div>
              <div className="detail-grid">
                <span>Handoff</span>
                <strong>{qaResult.handoff_id}</strong>
                <span>Card</span>
                <strong>{qaResult.card_id}</strong>
                <span>Work order</span>
                <strong>{qaResult.work_order_id}</strong>
                <span>QA agent</span>
                <strong>{qaResult.qa_agent_id}</strong>
                <span>Iteration</span>
                <strong>{qaResult.iteration_number ?? 1}</strong>
                {qaResult.repair_request_id && (
                  <>
                    <span>Repair request</span>
                    <strong>{qaResult.repair_request_id}</strong>
                  </>
                )}
                {qaResult.source_qa_result_id && (
                  <>
                    <span>Source QA result</span>
                    <strong>{qaResult.source_qa_result_id}</strong>
                  </>
                )}
                <span>Created</span>
                <strong>{qaResult.created_at}</strong>
              </div>
              <div className="summary-stack">
                <div>
                  <p className="eyebrow">Summary</p>
                  <p>{qaResult.summary}</p>
                </div>
                <div>
                  <p className="eyebrow">Findings</p>
                  <p>{qaResult.findings || "No detailed findings recorded."}</p>
                </div>
                <div>
                  <p className="eyebrow">Recommended next action</p>
                  <p>{qaResult.recommended_next_action || "No recommendation recorded."}</p>
                </div>
              </div>
              {canCreateRepairRequest && (
                <RepairRequestForm agents={agents} onRefresh={onRefresh} qaResult={qaResult} />
              )}
              {repairRequest && (
                <p
                  className="form-status success repair-created"
                  data-testid={`repair-created-${qaResult.id}`}
                >
                  Repair request created: {repairRequest.id} to {repairRequest.repair_work_order_id}
                </p>
              )}
            </article>
          );
        })}
      </div>
    </section>
  );
}

function RepairRequestForm({
  agents,
  onRefresh,
  qaResult
}: {
  agents: Agent[];
  onRefresh: () => Promise<void>;
  qaResult: QaResult;
}) {
  const [summary, setSummary] = useState("");
  const [repairInstructions, setRepairInstructions] = useState("");
  const [assignedAgentId, setAssignedAgentId] = useState(
    agents.find((agent) => agent.id === "developer_codex")?.id ?? agents[0]?.id ?? "developer_codex"
  );
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    if (!assignedAgentId || (agents.length && !agents.some((agent) => agent.id === assignedAgentId))) {
      setAssignedAgentId(agents.find((agent) => agent.id === "developer_codex")?.id ?? agents[0]?.id ?? "developer_codex");
    }
  }, [agents, assignedAgentId]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSubmitting(true);

    try {
      const repairRequest = await createRepairRequest(qaResult.id, {
        summary: summary.trim(),
        repair_instructions: repairInstructions.trim(),
        requested_by: "operator",
        assigned_agent_id: assignedAgentId
      });
      await onRefresh();
      setSummary("");
      setRepairInstructions("");
      setSuccess(`Created ${repairRequest.repair_work_order_id}`);
    } catch (submitError: unknown) {
      setError(errorMessage(submitError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="repair-request-form" data-testid={`repair-request-form-${qaResult.id}`} onSubmit={handleSubmit}>
      <label>
        Summary
        <input
          data-testid={`repair-summary-${qaResult.id}`}
          onChange={(event) => setSummary(event.target.value)}
          required
          value={summary}
        />
      </label>
      <label>
        Repair instructions
        <textarea
          data-testid={`repair-instructions-${qaResult.id}`}
          onChange={(event) => setRepairInstructions(event.target.value)}
          required
          rows={3}
          value={repairInstructions}
        />
      </label>
      <label>
        Assigned agent
        <select
          data-testid={`repair-agent-${qaResult.id}`}
          onChange={(event) => setAssignedAgentId(event.target.value)}
          value={assignedAgentId}
        >
          {agents.length === 0 && <option value="developer_codex">developer_codex</option>}
          {agents.map((agent) => (
            <option key={agent.id} value={agent.id}>
              {agent.display_name}
            </option>
          ))}
        </select>
      </label>
      <button
        data-testid={`repair-submit-${qaResult.id}`}
        disabled={isSubmitting || !summary.trim() || !repairInstructions.trim() || !assignedAgentId}
        type="submit"
      >
        {isSubmitting ? "Creating..." : "Create Repair Work Order"}
      </button>
      <FormStatus error={error} success={success} />
    </form>
  );
}

function RepairRequestsPanel({
  developerResults,
  handoffs,
  onRefresh,
  policySettings,
  qaResults,
  repairRequests,
  workOrders
}: {
  developerResults: DeveloperResult[];
  handoffs: Handoff[];
  onRefresh: () => Promise<void>;
  policySettings: PolicySettings;
  qaResults: QaResult[];
  repairRequests: RepairRequest[];
  workOrders: WorkOrder[];
}) {
  const visibleRepairRequests = useMemo(() => [...repairRequests].reverse(), [repairRequests]);
  const workOrderById = useMemo(
    () => new Map(workOrders.map((workOrder) => [workOrder.id, workOrder])),
    [workOrders]
  );
  const developerResultsByWorkOrderId = useMemo(() => {
    const grouped = new Map<string, DeveloperResult[]>();
    for (const result of developerResults) {
      const results = grouped.get(result.work_order_id) ?? [];
      results.push(result);
      grouped.set(result.work_order_id, results);
    }
    return grouped;
  }, [developerResults]);
  const qaResultByHandoffId = useMemo(
    () => new Map(qaResults.map((qaResult) => [qaResult.handoff_id, qaResult])),
    [qaResults]
  );
  const repairQaHandoffByRepairRequestId = useMemo(() => {
    const entries = handoffs
      .filter((handoff) => handoff.handoff_purpose === "repair_qa" && handoff.repair_request_id)
      .map((handoff) => [handoff.repair_request_id as string, handoff] as const);
    return new Map(entries);
  }, [handoffs]);
  const [reasonById, setReasonById] = useState<Record<string, string>>({});
  const [workingRepairRequestId, setWorkingRepairRequestId] = useState<string | null>(null);
  const [handoffRepairRequestId, setHandoffRepairRequestId] = useState<string | null>(null);
  const [handoffStatusById, setHandoffStatusById] = useState<Record<string, string>>({});
  const [overrideReasonById, setOverrideReasonById] = useState<Record<string, string>>({});
  const [readinessByRepairRequestId, setReadinessByRepairRequestId] = useState<Record<string, QaReadiness>>({});
  const [readinessErrorById, setReadinessErrorById] = useState<Record<string, string>>({});
  const [checkingReadinessId, setCheckingReadinessId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    setReadinessByRepairRequestId({});
    setReadinessErrorById({});
  }, [developerResults, handoffs, policySettings, qaResults, repairRequests, workOrders]);

  async function checkRepairReadiness(repairRequestId: string) {
    setCheckingReadinessId(repairRequestId);
    setReadinessErrorById((current) => ({ ...current, [repairRequestId]: "" }));

    try {
      const readiness = await getRepairRequestQaReadiness(repairRequestId);
      setReadinessByRepairRequestId((current) => ({ ...current, [repairRequestId]: readiness }));
    } catch (readinessError: unknown) {
      setReadinessErrorById((current) => ({
        ...current,
        [repairRequestId]: errorMessage(readinessError)
      }));
    } finally {
      setCheckingReadinessId(null);
    }
  }

  async function handoffRepairToQa(repairRequest: RepairRequest, override?: HandoffOverrideRequest) {
    setError(null);
    setSuccess(null);
    setHandoffRepairRequestId(repairRequest.id);

    try {
      const handoff = await handoffRepairRequestToQa(repairRequest.id, override);
      await onRefresh();
      setOverrideReasonById((current) => ({ ...current, [repairRequest.id]: "" }));
      setHandoffStatusById((current) => ({
        ...current,
        [repairRequest.id]: handoff.policy_override_id
          ? `Created ${handoff.id} with override ${handoff.policy_override_id}`
          : `Created ${handoff.id}`
      }));
    } catch (handoffError: unknown) {
      setError(errorMessage(handoffError));
    } finally {
      setHandoffRepairRequestId(null);
    }
  }

  function handoffRepairToQaWithOverride(repairRequest: RepairRequest) {
    const reason = (overrideReasonById[repairRequest.id] ?? "").trim();
    if (!reason) {
      setError("Override reason is required.");
      return;
    }
    void handoffRepairToQa(repairRequest, {
      override_policy: true,
      override_reason: reason,
      requested_by: "operator"
    });
  }

  async function decideRepairRequest(repairRequest: RepairRequest, decision: "complete" | "cancel") {
    const nextStatus = decision === "complete" ? "completed" : "cancelled";
    const reason = reasonById[repairRequest.id]?.trim() || `Operator marked ${repairRequest.id} ${nextStatus}.`;
    setError(null);
    setSuccess(null);
    setWorkingRepairRequestId(repairRequest.id);

    try {
      if (decision === "complete") {
        await completeRepairRequest(repairRequest.id, { decision_reason: reason, decided_by: "operator" });
      } else {
        await cancelRepairRequest(repairRequest.id, { decision_reason: reason, decided_by: "operator" });
      }
      await onRefresh();
      setReasonById((current) => ({ ...current, [repairRequest.id]: "" }));
      setSuccess(`${repairRequest.id} ${nextStatus}`);
    } catch (decisionError: unknown) {
      setError(errorMessage(decisionError));
    } finally {
      setWorkingRepairRequestId(null);
    }
  }

  return (
    <section className="panel repair-requests-panel" data-testid="repair-requests-panel">
      <div className="panel-heading">
        <h2>Repair Requests</h2>
        <span className="count-tag">{repairRequests.length}</span>
      </div>
      <div className="record-list" data-testid="repair-requests-list">
        {visibleRepairRequests.length === 0 && <p>No repair requests created yet.</p>}
        {visibleRepairRequests.map((repairRequest) => {
          const canDecide = repairRequest.status === "created" || repairRequest.status === "in_progress";
          const repairQaHandoff = repairQaHandoffByRepairRequestId.get(repairRequest.id);
          const repairWorkOrder = workOrderById.get(repairRequest.repair_work_order_id);
          const repairDeveloperResults = developerResultsByWorkOrderId.get(repairRequest.repair_work_order_id) ?? [];
          const latestRepairDeveloperResult = latestDeveloperResult(repairDeveloperResults);
          const activeRepairQaHandoff = latestActiveQaHandoffForWorkOrder(
            repairRequest.repair_work_order_id,
            "repair_qa",
            handoffs,
            qaResultByHandoffId
          );
          const loadedReadiness = readinessByRepairRequestId[repairRequest.id] ?? null;
          const repairDeveloperResultRequired =
            policySettings.qa_handoff_policy_mode === "enforced" &&
            policySettings.require_developer_result_for_repair_qa;
          const derivedReadinessLevel: QaReadinessLevel = activeRepairQaHandoff
            ? "blocked"
            : latestRepairDeveloperResult
              ? "ready"
              : repairDeveloperResultRequired
                ? "blocked"
                : "warning";
          const effectiveReadinessLevel: QaReadinessLevel = activeRepairQaHandoff
            ? "blocked"
            : loadedReadiness?.readiness_level ?? derivedReadinessLevel;
          const repairOverrideAvailable = effectiveReadinessLevel === "blocked" && Boolean(loadedReadiness?.override_available);
          const repairOverrideUnavailableReason =
            effectiveReadinessLevel === "blocked"
              ? loadedReadiness
                ? overrideUnavailableMessage(loadedReadiness)
                : "Check readiness to see whether a policy override is available."
              : "";
          const readinessSummary = activeRepairQaHandoff
            ? `Blocked: active repair QA handoff ${activeRepairQaHandoff.id} is ${activeRepairQaHandoff.status}.`
            : latestRepairDeveloperResult
              ? `Ready: latest submitted repair Developer/Codex result ${latestRepairDeveloperResult.id} exists.`
              : repairWorkOrder
                ? repairDeveloperResultRequired
                  ? "Blocked: Developer/Codex result is required by current QA handoff policy."
                  : "Warning: no repair Developer/Codex result captured."
                : "Blocked: linked repair work order is missing from the dashboard data.";

          return (
            <article className="record-row" data-testid={`repair-request-${repairRequest.id}`} key={repairRequest.id}>
              <div className="record-title-line">
                <p className="eyebrow">{repairRequest.id}</p>
                <span className={`state-tag ${repairRequestStatusClass(repairRequest.status)}`}>
                  {repairRequest.status}
                </span>
              </div>
              <h3>{repairRequest.summary}</h3>
              <div className="detail-grid handoff-detail-grid">
                <span>QA result</span>
                <strong>{repairRequest.qa_result_id}</strong>
                <span>Handoff</span>
                <strong>{repairRequest.handoff_id}</strong>
                <span>Card</span>
                <strong>{repairRequest.card_id}</strong>
                <span>Source work order</span>
                <strong>{repairRequest.source_work_order_id}</strong>
                <span>Repair work order</span>
                <strong>{repairRequest.repair_work_order_id}</strong>
                <span>Repair QA handoff</span>
                <strong>
                  {repairQaHandoff
                    ? `${repairQaHandoff.id} (${repairQaHandoff.status})`
                    : "none"}
                </strong>
                <span>Assigned</span>
                <strong>{repairRequest.assigned_agent_id}</strong>
                <span>Requested by</span>
                <strong>{repairRequest.requested_by}</strong>
                <span>Created</span>
                <strong>{repairRequest.created_at}</strong>
                <span>Updated</span>
                <strong>{repairRequest.updated_at}</strong>
                <span>Completed</span>
                <strong>{repairRequest.completed_at ?? "pending"}</strong>
              </div>
              <div className="summary-stack">
                <div>
                  <p className="eyebrow">Repair instructions</p>
                  <p>{repairRequest.repair_instructions}</p>
                </div>
                <div>
                  <p className="eyebrow">Evidence refs</p>
                  <div className="code-list">
                    {repairRequest.evidence_refs.map((ref) => (
                      <code key={ref}>{ref}</code>
                    ))}
                  </div>
                </div>
              </div>
              <QaReadinessPanel
                buttonTestId={`check-repair-qa-readiness-${repairRequest.id}`}
                error={readinessErrorById[repairRequest.id] || null}
                fallbackLevel={repairWorkOrder ? derivedReadinessLevel : "blocked"}
                fallbackMessage={readinessSummary}
                isChecking={checkingReadinessId === repairRequest.id}
                label="Repair QA readiness"
                onCheck={() => checkRepairReadiness(repairRequest.id)}
                policySettings={policySettings}
                readiness={loadedReadiness}
                testId={`repair-qa-readiness-${repairRequest.id}`}
              />
              {repairRequest.repair_work_order_id && (
                <div className="inline-action-block">
                  <button
                    data-testid={`handoff-repair-to-qa-${repairRequest.id}`}
                    disabled={handoffRepairRequestId === repairRequest.id || effectiveReadinessLevel === "blocked"}
                    onClick={() => handoffRepairToQa(repairRequest)}
                    type="button"
                    title={
                      effectiveReadinessLevel === "blocked"
                        ? "Repair QA readiness is blocked for this repair request."
                        : undefined
                    }
                  >
                    {handoffRepairRequestId === repairRequest.id ? "Handing off..." : "Handoff Repair to QA"}
                  </button>
                  {effectiveReadinessLevel === "blocked" && repairOverrideAvailable && (
                    <div className="override-action-block" data-testid={`repair-override-action-${repairRequest.id}`}>
                      <label>
                        Override reason
                        <textarea
                          data-testid={`repair-override-reason-${repairRequest.id}`}
                          onChange={(event) =>
                            setOverrideReasonById((current) => ({
                              ...current,
                              [repairRequest.id]: event.target.value
                            }))
                          }
                          rows={3}
                          value={overrideReasonById[repairRequest.id] ?? ""}
                        />
                      </label>
                      <button
                        className="danger"
                        data-testid={`handoff-repair-to-qa-override-${repairRequest.id}`}
                        disabled={
                          handoffRepairRequestId === repairRequest.id ||
                          !(overrideReasonById[repairRequest.id] ?? "").trim()
                        }
                        onClick={() => handoffRepairToQaWithOverride(repairRequest)}
                        type="button"
                      >
                        {handoffRepairRequestId === repairRequest.id
                          ? "Handing off..."
                          : "Handoff Repair to QA with Override"}
                      </button>
                    </div>
                  )}
                  {effectiveReadinessLevel === "blocked" && !repairOverrideAvailable && (
                    <p className="form-status warning" data-testid={`repair-override-unavailable-${repairRequest.id}`}>
                      Override unavailable: {repairOverrideUnavailableReason}
                    </p>
                  )}
                  <FormStatus
                    error={null}
                    success={
                      handoffStatusById[repairRequest.id] ??
                      (repairQaHandoff
                        ? `Repair QA handoff ${repairQaHandoff.id} is ${repairQaHandoff.status}`
                        : null)
                    }
                  />
                </div>
              )}
              {canDecide && (
                <div className="decision-row">
                  <label>
                    Decision reason
                    <input
                      data-testid={`repair-reason-${repairRequest.id}`}
                      onChange={(event) =>
                        setReasonById((current) => ({ ...current, [repairRequest.id]: event.target.value }))
                      }
                      placeholder="Optional short reason"
                      value={reasonById[repairRequest.id] ?? ""}
                    />
                  </label>
                  <div className="button-row">
                    <button
                      data-testid={`complete-repair-${repairRequest.id}`}
                      disabled={workingRepairRequestId === repairRequest.id}
                      onClick={() => decideRepairRequest(repairRequest, "complete")}
                      type="button"
                    >
                      Complete
                    </button>
                    <button
                      className="secondary danger"
                      data-testid={`cancel-repair-${repairRequest.id}`}
                      disabled={workingRepairRequestId === repairRequest.id}
                      onClick={() => decideRepairRequest(repairRequest, "cancel")}
                      type="button"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              )}
            </article>
          );
        })}
      </div>
      <FormStatus error={error} success={success} />
    </section>
  );
}

function handoffStatusClass(status: Handoff["status"]): string {
  if (status === "proposed") {
    return "warn";
  }
  if (status === "rejected" || status === "blocked") {
    return "danger";
  }
  return "";
}

function qaResultStatusClass(result: QaResult["result"]): string {
  if (result === "failed") {
    return "danger";
  }
  if (result === "blocked") {
    return "warn";
  }
  return "";
}

function repairRequestStatusClass(status: RepairRequest["status"]): string {
  if (status === "cancelled") {
    return "danger";
  }
  if (status === "proposed" || status === "created" || status === "in_progress") {
    return "warn";
  }
  return "";
}

function readinessLevelClass(status: string): string {
  if (status === "warning") {
    return "warn";
  }
  if (status === "blocked") {
    return "danger";
  }
  return "";
}

function auditSeverityClass(severity: string): string {
  if (severity === "blocker") {
    return "danger";
  }
  if (severity === "warning" || severity === "override") {
    return "warn";
  }
  return "";
}

function auditAcknowledgementClass(status: string): string {
  if (status === "unreviewed" || status === "acknowledged") {
    return "warn";
  }
  if (status === "dismissed") {
    return "danger";
  }
  return "";
}

function displayWorkOrderType(workOrder: WorkOrder): "original" | "repair" {
  return workOrder.work_order_type ?? (workOrder.repair_request_id || workOrder.source_work_order_id ? "repair" : "original");
}

function latestDeveloperResult(results: DeveloperResult[]): DeveloperResult | null {
  const submittedResults = results.filter((result) => result.status === "submitted");
  if (submittedResults.length === 0) {
    return null;
  }
  return [...submittedResults].sort((left, right) => {
    const leftTimestamp = left.updated_at || left.created_at || "";
    const rightTimestamp = right.updated_at || right.created_at || "";
    return rightTimestamp.localeCompare(leftTimestamp);
  })[0];
}

function latestActiveQaHandoffForWorkOrder(
  workOrderId: string,
  handoffContext: "initial_qa" | "repair_qa",
  handoffs: Handoff[],
  qaResultByHandoffId: Map<string, QaResult>
): Handoff | null {
  const activeHandoffs = handoffs.filter(
    (handoff) =>
      handoff.work_order_id === workOrderId &&
      (handoff.handoff_purpose ?? (handoff.repair_request_id ? "repair_qa" : "initial_qa")) === handoffContext &&
      (handoff.status === "proposed" || handoff.status === "accepted") &&
      !qaResultByHandoffId.has(handoff.id)
  );
  if (activeHandoffs.length === 0) {
    return null;
  }
  return [...activeHandoffs].sort((left, right) => {
    const leftTimestamp = left.updated_at || left.created_at || "";
    const rightTimestamp = right.updated_at || right.created_at || "";
    return rightTimestamp.localeCompare(leftTimestamp);
  })[0];
}

function parseChangedPaths(value: string): string[] {
  return value
    .split(/[\n,]+/)
    .map((item) => item.trim())
    .filter(Boolean);
}

function StatusTransitionForm({
  allowedStatuses,
  currentStatus,
  label,
  onRefresh,
  onUpdate,
  recordId,
  testIdPrefix
}: {
  allowedStatuses: readonly string[];
  currentStatus: string;
  label: string;
  onRefresh: () => Promise<void>;
  onUpdate: (id: string, payload: UpdateStatusRequest) => Promise<unknown>;
  recordId: string;
  testIdPrefix: string;
}) {
  const [selectedStatus, setSelectedStatus] = useState(currentStatus);
  const [reason, setReason] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    setSelectedStatus(currentStatus);
  }, [currentStatus]);

  const statusOptions = useMemo(() => {
    const options = new Set([currentStatus, ...allowedStatuses].filter(Boolean));
    return [...options];
  }, [allowedStatuses, currentStatus]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    setIsSubmitting(true);

    try {
      await onUpdate(recordId, {
        status: selectedStatus,
        reason: reason.trim(),
        requested_by: "operator"
      });
      await onRefresh();
      setReason("");
      setSuccess(`${recordId} moved to ${selectedStatus}`);
    } catch (submitError: unknown) {
      setError(errorMessage(submitError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="status-transition-form" data-testid={`${testIdPrefix}-${recordId}-form`} onSubmit={handleSubmit}>
      <label>
        Status
        <select
          data-testid={`${testIdPrefix}-${recordId}-select`}
          onChange={(event) => setSelectedStatus(event.target.value)}
          value={selectedStatus}
        >
          {statusOptions.map((status) => (
            <option key={status} value={status}>
              {status}
            </option>
          ))}
        </select>
      </label>
      <label>
        Reason
        <input
          data-testid={`${testIdPrefix}-${recordId}-reason`}
          onChange={(event) => setReason(event.target.value)}
          placeholder="Optional short reason"
          value={reason}
        />
      </label>
      <button data-testid={`${testIdPrefix}-${recordId}-submit`} disabled={isSubmitting || !selectedStatus} type="submit">
        {isSubmitting ? "Updating..." : label}
      </button>
      <FormStatus error={error} success={success} />
    </form>
  );
}

function WorkflowIterationsPanel({ workflowIterations }: { workflowIterations: WorkflowIteration[] }) {
  const visibleWorkflowIterations = useMemo(() => [...workflowIterations].reverse(), [workflowIterations]);

  return (
    <section className="panel workflow-iterations-panel" data-testid="workflow-iterations-panel">
      <div className="panel-heading">
        <h2>Workflow Iterations</h2>
        <span className="count-tag">{workflowIterations.length}</span>
      </div>
      <div className="record-list compact" data-testid="workflow-iterations-list">
        {visibleWorkflowIterations.length === 0 && <p>No workflow iterations derived yet.</p>}
        {visibleWorkflowIterations.map((iteration) => (
          <article
            className={`record-row ${iteration.work_order_type === "repair" ? "repair-row" : ""}`}
            data-testid={`workflow-iteration-${iteration.work_order_id}`}
            key={`${iteration.work_order_id}-${iteration.iteration_number}`}
          >
            <div className="record-title-line">
              <p className="eyebrow">
                Iteration {iteration.iteration_number} - {iteration.work_order_type}
              </p>
              <span className={`state-tag ${iteration.latest_result ? qaResultStatusClass(iteration.latest_result) : ""}`}>
                {iteration.latest_result ?? "pending QA"}
              </span>
            </div>
            <div className="detail-grid handoff-detail-grid">
              <span>Original work order</span>
              <strong>{iteration.original_work_order_id}</strong>
              <span>Work order</span>
              <strong>{iteration.work_order_id}</strong>
              <span>Repair request</span>
              <strong>{iteration.repair_request_id ?? "none"}</strong>
              <span>Handoff</span>
              <strong>{iteration.handoff_id ?? "none"}</strong>
              <span>QA result</span>
              <strong>{iteration.qa_result_id ?? "none"}</strong>
              <span>Source QA result</span>
              <strong>{iteration.source_qa_result_id ?? "none"}</strong>
            </div>
            <p>{iteration.status_summary}</p>
          </article>
        ))}
      </div>
    </section>
  );
}

function AgentsPanel({ agents }: { agents: Agent[] }) {
  return (
    <section className="panel agents-panel">
      <div className="panel-heading">
        <h2>Agents</h2>
        <span className="count-tag">{agents.length}</span>
      </div>
      <div className="agent-list">
        {agents.map((agent) => (
          <article className="agent-row" key={agent.id}>
            <div>
              <h3>{agent.display_name}</h3>
              <p>{agent.role}</p>
              <small>{agent.approval_scope}</small>
            </div>
            <span className="state-tag">{agent.status}</span>
          </article>
        ))}
      </div>
    </section>
  );
}

function ApprovalsPanel({ approvals, onRefresh }: { approvals: Approval[]; onRefresh: () => Promise<void> }) {
  const [reasonById, setReasonById] = useState<Record<string, string>>({});
  const [workingApprovalId, setWorkingApprovalId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const pendingApprovals = useMemo(() => approvals.filter((approval) => approval.status === "pending"), [approvals]);
  const decidedApprovals = useMemo(() => approvals.filter((approval) => approval.status !== "pending"), [approvals]);

  async function decideApproval(approval: Approval, decision: "approve" | "reject") {
    const decidedStatus = decision === "approve" ? "approved" : "rejected";
    const reason = reasonById[approval.id]?.trim() || `Operator ${decidedStatus} ${approval.id}.`;
    setError(null);
    setSuccess(null);
    setWorkingApprovalId(approval.id);

    try {
      if (decision === "approve") {
        await approveApproval(approval.id, reason);
      } else {
        await rejectApproval(approval.id, reason);
      }
      await onRefresh();
      setReasonById((current) => ({ ...current, [approval.id]: "" }));
      setSuccess(`${approval.id} ${decidedStatus}`);
    } catch (decisionError: unknown) {
      setError(errorMessage(decisionError));
    } finally {
      setWorkingApprovalId(null);
    }
  }

  return (
    <section className="panel approvals-panel" data-testid="approvals-panel">
      <div className="panel-heading">
        <h2>Approvals</h2>
        <span className="count-tag">{approvals.length}</span>
      </div>
      <div className="approval-stack">
        <div>
          <h3 className="section-label">Pending</h3>
          <div className="record-list">
            {pendingApprovals.length === 0 && <p>No pending approvals.</p>}
            {pendingApprovals.map((approval) => (
              <article className="record-row pending" key={approval.id}>
                <div className="record-title-line">
                  <p className="eyebrow">{approval.id}</p>
                  <span className="state-tag warn">{approval.status}</span>
                </div>
                <h3>{approval.title}</h3>
                <p>{approval.description}</p>
                <div className="detail-grid">
                  <span>Card</span>
                  <strong>{approval.related_card_id}</strong>
                  <span>Work order</span>
                  <strong>{approval.related_work_order_id ?? "none"}</strong>
                </div>
                <label>
                  Decision reason
                  <input
                    onChange={(event) =>
                      setReasonById((current) => ({ ...current, [approval.id]: event.target.value }))
                    }
                    value={reasonById[approval.id] ?? ""}
                  />
                </label>
                <div className="button-row">
                  <button
                    data-testid={`approve-${approval.id}`}
                    disabled={workingApprovalId === approval.id}
                    onClick={() => decideApproval(approval, "approve")}
                    type="button"
                  >
                    Approve
                  </button>
                  <button
                    className="secondary danger"
                    data-testid={`reject-${approval.id}`}
                    disabled={workingApprovalId === approval.id}
                    onClick={() => decideApproval(approval, "reject")}
                    type="button"
                  >
                    Reject
                  </button>
                </div>
              </article>
            ))}
          </div>
        </div>
        <div>
          <h3 className="section-label">History</h3>
          <div className="record-list compact">
            {decidedApprovals.length === 0 && <p>No approval decisions yet.</p>}
            {decidedApprovals.map((approval) => (
              <article className="record-row" key={approval.id}>
                <div className="record-title-line">
                  <p className="eyebrow">{approval.id}</p>
                  <span className={`state-tag ${approval.status === "rejected" ? "danger" : ""}`}>
                    {approval.status}
                  </span>
                </div>
                <h3>{approval.title}</h3>
                {approval.decision_reason && <p>{approval.decision_reason}</p>}
              </article>
            ))}
          </div>
        </div>
      </div>
      <FormStatus error={error} success={success} />
    </section>
  );
}

function EventsPanel({ events }: { events: EventEntry[] }) {
  const visibleEvents = useMemo(() => [...events].reverse(), [events]);

  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Events</h2>
        <span className="count-tag">{events.length}</span>
      </div>
      <ol className="timeline" data-testid="events-list">
        {visibleEvents.map((event) => (
          <li key={event.id}>
            <time>{event.timestamp}</time>
            <strong>{event.type}</strong>
            <p>{event.summary}</p>
          </li>
        ))}
      </ol>
    </section>
  );
}

function EvidencePanel({ evidence }: { evidence: EvidenceEntry[] }) {
  const visibleEvidence = useMemo(() => [...evidence].reverse(), [evidence]);

  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Evidence</h2>
        <span className="count-tag">{evidence.length}</span>
      </div>
      <div className="evidence-list" data-testid="evidence-list">
        {visibleEvidence.map((entry) => (
          <article key={entry.id}>
            <p className="eyebrow">{entry.kind}</p>
            <h3>{entry.title}</h3>
            <p>{entry.summary}</p>
            <code>{entry.path}</code>
          </article>
        ))}
      </div>
    </section>
  );
}

function Metric({ label, value }: { label: string; value: number }) {
  return (
    <div className="metric">
      <strong>{value}</strong>
      <span>{label}</span>
    </div>
  );
}

function FormStatus({ error, success }: { error: string | null; success: string | null }) {
  if (!error && !success) {
    return null;
  }

  return (
    <p className={`form-status ${error ? "error" : "success"}`} role="status">
      {error ?? success}
    </p>
  );
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Unknown API error";
}

function formatBoolean(value: boolean): string {
  return value ? "yes" : "no";
}

function parseImportCollections(text: string): Record<string, unknown> | StateExportCollection[] {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw new Error("Import JSON is not valid JSON.");
  }

  if (Array.isArray(parsed)) {
    return parsed as StateExportCollection[];
  }

  if (!isRecord(parsed)) {
    throw new Error("Import JSON must be an object or exported collection array.");
  }

  if ("collections" in parsed) {
    const collections = parsed.collections;
    if (Array.isArray(collections)) {
      return collections as StateExportCollection[];
    }
    if (isRecord(collections)) {
      return collections;
    }
    throw new Error("Import JSON collections must be an object or array.");
  }

  return parsed;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
