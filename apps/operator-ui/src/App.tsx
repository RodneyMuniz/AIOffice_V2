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
  handoffRepairRequestToQa,
  handoffWorkOrderToQa,
  loadDashboard,
  rejectApproval,
  rejectHandoff,
  updateCardStatus,
  updateWorkOrderStatus
} from "./api";
import { CARD_STATUSES, DEVELOPER_RESULT_TYPES, QA_RESULT_VALUES, WORK_ORDER_STATUSES } from "./types";
import type {
  Agent,
  Approval,
  Card,
  DashboardData,
  DeveloperResult,
  DeveloperResultType,
  EventEntry,
  EvidenceEntry,
  Handoff,
  QaResult,
  QaResultValue,
  RepairRequest,
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
          workOrders={data.workOrders}
        />
        <DeveloperResultsPanel developerResults={data.developerResults} />
        <HandoffsPanel handoffs={data.handoffs} onRefresh={onRefresh} qaResults={data.qaResults} />
        <QaResultsPanel
          agents={data.agents}
          onRefresh={onRefresh}
          qaResults={data.qaResults}
          repairRequests={data.repairRequests}
        />
        <RepairRequestsPanel handoffs={data.handoffs} onRefresh={onRefresh} repairRequests={data.repairRequests} />
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
  workOrders
}: {
  agents: Agent[];
  allowedStatuses: readonly string[];
  currentWorkOrderId: string | null;
  developerResults: DeveloperResult[];
  handoffs: Handoff[];
  onRefresh: () => Promise<void>;
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
  const [handoffWorkOrderId, setHandoffWorkOrderId] = useState<string | null>(null);
  const [handoffStatusById, setHandoffStatusById] = useState<Record<string, string>>({});

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
            <HandoffToQaAction
              isWorking={handoffWorkOrderId === workOrder.id}
              onDone={(message) => setHandoffStatusById((current) => ({ ...current, [workOrder.id]: message }))}
              onRefresh={onRefresh}
              onWorkingChange={(isWorking) => setHandoffWorkOrderId(isWorking ? workOrder.id : null)}
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
  statusMessage,
  workOrder
}: {
  isWorking: boolean;
  onDone: (message: string) => void;
  onRefresh: () => Promise<void>;
  onWorkingChange: (isWorking: boolean) => void;
  statusMessage: string | null;
  workOrder: WorkOrder;
}) {
  const [error, setError] = useState<string | null>(null);

  async function handleHandoff() {
    setError(null);
    onWorkingChange(true);

    try {
      const handoff = await handoffWorkOrderToQa(workOrder.id);
      await onRefresh();
      onDone(`Created ${handoff.id}`);
    } catch (handoffError: unknown) {
      setError(errorMessage(handoffError));
    } finally {
      onWorkingChange(false);
    }
  }

  return (
    <div className="inline-action-block">
      <button
        data-testid={`handoff-to-qa-${workOrder.id}`}
        disabled={isWorking}
        onClick={handleHandoff}
        type="button"
      >
        {isWorking ? "Handing off..." : "Handoff to QA"}
      </button>
      <FormStatus error={error} success={statusMessage} />
    </div>
  );
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
                {!handoff.developer_result_id && (
                  <p
                    className="form-status warning developer-result-warning"
                    data-testid={`handoff-developer-result-warning-${handoff.id}`}
                  >
                    No developer result captured before handoff
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
  handoffs,
  onRefresh,
  repairRequests
}: {
  handoffs: Handoff[];
  onRefresh: () => Promise<void>;
  repairRequests: RepairRequest[];
}) {
  const visibleRepairRequests = useMemo(() => [...repairRequests].reverse(), [repairRequests]);
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
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  async function handoffRepairToQa(repairRequest: RepairRequest) {
    setError(null);
    setSuccess(null);
    setHandoffRepairRequestId(repairRequest.id);

    try {
      const handoff = await handoffRepairRequestToQa(repairRequest.id);
      await onRefresh();
      setHandoffStatusById((current) => ({ ...current, [repairRequest.id]: `Created ${handoff.id}` }));
    } catch (handoffError: unknown) {
      setError(errorMessage(handoffError));
    } finally {
      setHandoffRepairRequestId(null);
    }
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
          const hasActiveRepairQaHandoff =
            repairQaHandoff?.status === "proposed" || repairQaHandoff?.status === "accepted";

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
              {repairRequest.repair_work_order_id && (
                <div className="inline-action-block">
                  <button
                    data-testid={`handoff-repair-to-qa-${repairRequest.id}`}
                    disabled={handoffRepairRequestId === repairRequest.id || hasActiveRepairQaHandoff}
                    onClick={() => handoffRepairToQa(repairRequest)}
                    type="button"
                  >
                    {handoffRepairRequestId === repairRequest.id ? "Handing off..." : "Handoff Repair to QA"}
                  </button>
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
