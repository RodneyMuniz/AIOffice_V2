import { useCallback, useEffect, useMemo, useState } from "react";
import type { FormEvent } from "react";
import {
  API_BASE_URL,
  approveApproval,
  createApproval,
  createCard,
  createWorkOrder,
  loadDashboard,
  rejectApproval
} from "./api";
import type { Agent, Approval, Card, DashboardData, EventEntry, EvidenceEntry, StatusResponse, WorkOrder } from "./types";
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
        <CardsList cards={data.cards} currentCardId={data.status.current_card_id} />
        <WorkOrdersList currentWorkOrderId={data.status.current_work_order_id} workOrders={data.workOrders} />
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
    <section className="panel status-panel">
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

function CardsList({ cards, currentCardId }: { cards: Card[]; currentCardId: string | null }) {
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
          </article>
        ))}
      </div>
    </section>
  );
}

function WorkOrdersList({
  currentWorkOrderId,
  workOrders
}: {
  currentWorkOrderId: string | null;
  workOrders: WorkOrder[];
}) {
  const visibleWorkOrders = useMemo(() => [...workOrders].reverse(), [workOrders]);

  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Work Orders</h2>
        <span className="count-tag">{workOrders.length}</span>
      </div>
      <div className="record-list" data-testid="work-orders-list">
        {visibleWorkOrders.map((workOrder) => (
          <article className={`record-row ${workOrder.id === currentWorkOrderId ? "active" : ""}`} key={workOrder.id}>
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
              <span>Approval</span>
              <strong>{workOrder.approval_required ? "required" : "not required"}</strong>
            </div>
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
