import { useEffect, useMemo, useState } from "react";
import { API_BASE_URL, loadDashboard } from "./api";
import type { Agent, Card, DashboardData, EventEntry, EvidenceEntry, StatusResponse, WorkOrder } from "./types";
import "./App.css";

type LoadState =
  | { state: "loading"; data: null; error: null }
  | { state: "ready"; data: DashboardData; error: null }
  | { state: "error"; data: null; error: string };

const initialLoadState: LoadState = { state: "loading", data: null, error: null };

export default function App() {
  const [loadState, setLoadState] = useState<LoadState>(initialLoadState);

  useEffect(() => {
    const controller = new AbortController();

    loadDashboard(controller.signal)
      .then((data) => setLoadState({ state: "ready", data, error: null }))
      .catch((error: unknown) => {
        if (controller.signal.aborted) {
          return;
        }

        const message = error instanceof Error ? error.message : "Unknown backend connection error";
        setLoadState({ state: "error", data: null, error: message });
      });

    return () => controller.abort();
  }, []);

  return (
    <main className="app-shell">
      <header className="topbar">
        <div>
          <h1>AIOffice Operator Console</h1>
          <p>R19 product reset active. This slice proves UI to API connectivity only.</p>
        </div>
        <div className="api-pill">
          <span>API</span>
          <strong>{API_BASE_URL}</strong>
        </div>
      </header>

      {loadState.state === "loading" && <LoadingPanel />}
      {loadState.state === "error" && <ConnectionError error={loadState.error} />}
      {loadState.state === "ready" && <Dashboard data={loadState.data} />}
    </main>
  );
}

function Dashboard({ data }: { data: DashboardData }) {
  const activeCard = useMemo(
    () => data.cards.find((card) => card.id === data.status.current_card_id) ?? data.cards[0],
    [data.cards, data.status.current_card_id]
  );

  const activeWorkOrder = useMemo(
    () =>
      data.workOrders.find((workOrder) => workOrder.id === data.status.current_work_order_id) ?? data.workOrders[0],
    [data.status.current_work_order_id, data.workOrders]
  );

  return (
    <div className="dashboard-grid">
      <StatusPanel status={data.status} />
      <ActiveCardPanel card={activeCard} />
      <WorkOrderPanel workOrder={activeWorkOrder} />
      <AgentsPanel agents={data.agents} />
      <EventsPanel events={data.events} />
      <EvidencePanel evidence={data.evidence} />
    </div>
  );
}

function LoadingPanel() {
  return (
    <section className="panel connection-panel">
      <h2>Connecting to orchestrator API</h2>
      <p>Loading `/status`, cards, work orders, agents, events, and evidence from the backend.</p>
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

function ActiveCardPanel({ card }: { card?: Card }) {
  if (!card) {
    return <EmptyPanel title="Active Card" message="No cards returned by the API." />;
  }

  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Active Card</h2>
        <span className="state-tag">{card.status}</span>
      </div>
      <p className="eyebrow">{card.id}</p>
      <h3>{card.title}</h3>
      <p>{card.summary}</p>
      <div className="detail-line">
        <span>Owner</span>
        <strong>{card.owner_agent_id}</strong>
      </div>
      <div className="detail-line">
        <span>Priority</span>
        <strong>{card.priority}</strong>
      </div>
      {card.acceptance_focus && (
        <ul className="compact-list">
          {card.acceptance_focus.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      )}
    </section>
  );
}

function WorkOrderPanel({ workOrder }: { workOrder?: WorkOrder }) {
  if (!workOrder) {
    return <EmptyPanel title="Work Order" message="No work orders returned by the API." />;
  }

  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Work Order</h2>
        <span className="state-tag warn">{workOrder.status}</span>
      </div>
      <p className="eyebrow">{workOrder.id}</p>
      <h3>{workOrder.title}</h3>
      <p>{workOrder.summary}</p>
      <div className="detail-line">
        <span>Card</span>
        <strong>{workOrder.card_id}</strong>
      </div>
      <div className="detail-line">
        <span>Assigned</span>
        <strong>{workOrder.assigned_agent_id}</strong>
      </div>
      <div className="detail-line">
        <span>Approval gate</span>
        <strong>{workOrder.approval_required ? "required" : "not required"}</strong>
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
            </div>
            <span className="state-tag">{agent.status}</span>
          </article>
        ))}
      </div>
    </section>
  );
}

function EventsPanel({ events }: { events: EventEntry[] }) {
  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Events</h2>
        <span className="count-tag">{events.length}</span>
      </div>
      <ol className="timeline">
        {events.map((event) => (
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
  return (
    <section className="panel">
      <div className="panel-heading">
        <h2>Evidence</h2>
        <span className="count-tag">{evidence.length}</span>
      </div>
      <div className="evidence-list">
        {evidence.map((entry) => (
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

function EmptyPanel({ title, message }: { title: string; message: string }) {
  return (
    <section className="panel">
      <h2>{title}</h2>
      <p>{message}</p>
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
