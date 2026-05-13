import type {
  Agent,
  Approval,
  Card,
  CreateApprovalRequest,
  CreateCardRequest,
  CreateQaResultRequest,
  CreateWorkOrderRequest,
  DashboardData,
  EventEntry,
  EvidenceEntry,
  Handoff,
  HandoffDecisionRequest,
  QaResult,
  StatusResponse,
  UpdateStatusRequest,
  WorkOrder
} from "./types";

export const API_BASE_URL = (import.meta.env.VITE_AIO_API_BASE_URL ?? "http://localhost:8000").replace(/\/$/, "");

type RequestOptions = {
  method?: "GET" | "POST" | "PATCH";
  body?: unknown;
  signal?: AbortSignal;
};

async function requestJson<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: options.method ?? "GET",
    headers: options.body ? { "Content-Type": "application/json" } : undefined,
    body: options.body ? JSON.stringify(options.body) : undefined,
    signal: options.signal
  });

  if (!response.ok) {
    throw new Error(await readApiError(path, response));
  }

  return response.json() as Promise<T>;
}

async function readApiError(path: string, response: Response): Promise<string> {
  try {
    const body = (await response.json()) as { detail?: unknown };
    if (typeof body.detail === "string") {
      return `${path} returned HTTP ${response.status}: ${body.detail}`;
    }
  } catch {
    // Fall through to the generic HTTP message when the response is not JSON.
  }

  return `${path} returned HTTP ${response.status}`;
}

export async function loadDashboard(signal?: AbortSignal): Promise<DashboardData> {
  const [status, cards, workOrders, agents, events, evidence, approvals, handoffs, qaResults] = await Promise.all([
    requestJson<StatusResponse>("/status", { signal }),
    requestJson<Card[]>("/cards", { signal }),
    requestJson<WorkOrder[]>("/work-orders", { signal }),
    requestJson<Agent[]>("/agents", { signal }),
    requestJson<EventEntry[]>("/events", { signal }),
    requestJson<EvidenceEntry[]>("/evidence", { signal }),
    requestJson<Approval[]>("/approvals", { signal }),
    requestJson<Handoff[]>("/handoffs", { signal }),
    requestJson<QaResult[]>("/qa-results", { signal })
  ]);

  return { status, cards, workOrders, agents, events, evidence, approvals, handoffs, qaResults };
}

export function createCard(payload: CreateCardRequest): Promise<Card> {
  return requestJson<Card>("/cards", { method: "POST", body: payload });
}

export function createWorkOrder(payload: CreateWorkOrderRequest): Promise<WorkOrder> {
  return requestJson<WorkOrder>("/work-orders", { method: "POST", body: payload });
}

export function updateCardStatus(id: string, payload: UpdateStatusRequest): Promise<Card> {
  return requestJson<Card>(`/cards/${id}/status`, { method: "PATCH", body: payload });
}

export function updateWorkOrderStatus(id: string, payload: UpdateStatusRequest): Promise<WorkOrder> {
  return requestJson<WorkOrder>(`/work-orders/${id}/status`, { method: "PATCH", body: payload });
}

export function createApproval(payload: CreateApprovalRequest): Promise<Approval> {
  return requestJson<Approval>("/approvals", { method: "POST", body: payload });
}

export function approveApproval(id: string, decisionReason: string): Promise<Approval> {
  return requestJson<Approval>(`/approvals/${id}/approve`, {
    method: "POST",
    body: { decision_reason: decisionReason, decided_by: "operator" }
  });
}

export function rejectApproval(id: string, decisionReason: string): Promise<Approval> {
  return requestJson<Approval>(`/approvals/${id}/reject`, {
    method: "POST",
    body: { decision_reason: decisionReason, decided_by: "operator" }
  });
}

export function handoffWorkOrderToQa(id: string): Promise<Handoff> {
  return requestJson<Handoff>(`/work-orders/${id}/handoff-to-qa`, { method: "POST" });
}

export function acceptHandoff(id: string, decision: HandoffDecisionRequest): Promise<Handoff> {
  return requestJson<Handoff>(`/handoffs/${id}/accept`, { method: "POST", body: decision });
}

export function rejectHandoff(id: string, decision: HandoffDecisionRequest): Promise<Handoff> {
  return requestJson<Handoff>(`/handoffs/${id}/reject`, { method: "POST", body: decision });
}

export function createQaResult(id: string, payload: CreateQaResultRequest): Promise<QaResult> {
  return requestJson<QaResult>(`/handoffs/${id}/qa-result`, { method: "POST", body: payload });
}
