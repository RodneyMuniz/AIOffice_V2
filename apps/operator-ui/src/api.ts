import type {
  Agent,
  Approval,
  Card,
  CreateApprovalRequest,
  CreateCardRequest,
  CreateDeveloperResultRequest,
  CreateQaResultRequest,
  CreateRepairRequest,
  CreateWorkOrderRequest,
  DashboardData,
  DeveloperResult,
  EventEntry,
  EvidenceEntry,
  Handoff,
  HandoffDecisionRequest,
  HandoffOverrideRequest,
  PolicySettings,
  PolicyOverride,
  QaReadiness,
  QaResult,
  RepairRequest,
  RepairRequestDecisionRequest,
  StatusResponse,
  UpdatePolicySettingsRequest,
  UpdateStatusRequest,
  WorkOrder,
  WorkflowIteration
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
  const [
    status,
    policySettings,
    cards,
    workOrders,
    agents,
    events,
    evidence,
    approvals,
    handoffs,
    developerResults,
    qaResults,
    repairRequests,
    policyOverrides,
    workflowIterations
  ] = await Promise.all([
    requestJson<StatusResponse>("/status", { signal }),
    requestJson<PolicySettings>("/policy-settings", { signal }),
    requestJson<Card[]>("/cards", { signal }),
    requestJson<WorkOrder[]>("/work-orders", { signal }),
    requestJson<Agent[]>("/agents", { signal }),
    requestJson<EventEntry[]>("/events", { signal }),
    requestJson<EvidenceEntry[]>("/evidence", { signal }),
    requestJson<Approval[]>("/approvals", { signal }),
    requestJson<Handoff[]>("/handoffs", { signal }),
    requestJson<DeveloperResult[]>("/developer-results", { signal }),
    requestJson<QaResult[]>("/qa-results", { signal }),
    requestJson<RepairRequest[]>("/repair-requests", { signal }),
    requestJson<PolicyOverride[]>("/policy-overrides", { signal }),
    requestJson<WorkflowIteration[]>("/workflow-iterations", { signal })
  ]);

  return {
    status,
    policySettings,
    cards,
    workOrders,
    agents,
    events,
    evidence,
    approvals,
    handoffs,
    developerResults,
    qaResults,
    repairRequests,
    policyOverrides,
    workflowIterations
  };
}

export function getPolicySettings(): Promise<PolicySettings> {
  return requestJson<PolicySettings>("/policy-settings");
}

export function updatePolicySettings(payload: UpdatePolicySettingsRequest): Promise<PolicySettings> {
  return requestJson<PolicySettings>("/policy-settings", { method: "PATCH", body: payload });
}

export function createCard(payload: CreateCardRequest): Promise<Card> {
  return requestJson<Card>("/cards", { method: "POST", body: payload });
}

export function createWorkOrder(payload: CreateWorkOrderRequest): Promise<WorkOrder> {
  return requestJson<WorkOrder>("/work-orders", { method: "POST", body: payload });
}

export function createDeveloperResult(id: string, payload: CreateDeveloperResultRequest): Promise<DeveloperResult> {
  return requestJson<DeveloperResult>(`/work-orders/${id}/developer-result`, { method: "POST", body: payload });
}

export function getWorkOrderQaReadiness(id: string): Promise<QaReadiness> {
  return requestJson<QaReadiness>(`/work-orders/${id}/qa-readiness`);
}

export function getRepairRequestQaReadiness(id: string): Promise<QaReadiness> {
  return requestJson<QaReadiness>(`/repair-requests/${id}/qa-readiness`);
}

export function supersedeDeveloperResult(id: string): Promise<DeveloperResult> {
  return requestJson<DeveloperResult>(`/developer-results/${id}/supersede`, { method: "POST" });
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

export function handoffWorkOrderToQa(id: string, override?: HandoffOverrideRequest): Promise<Handoff> {
  return requestJson<Handoff>(`/work-orders/${id}/handoff-to-qa`, { method: "POST", body: override });
}

export function handoffRepairRequestToQa(id: string, override?: HandoffOverrideRequest): Promise<Handoff> {
  return requestJson<Handoff>(`/repair-requests/${id}/handoff-to-qa`, { method: "POST", body: override });
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

export function createRepairRequest(id: string, payload: CreateRepairRequest): Promise<RepairRequest> {
  return requestJson<RepairRequest>(`/qa-results/${id}/repair-request`, { method: "POST", body: payload });
}

export function completeRepairRequest(
  id: string,
  decision: RepairRequestDecisionRequest
): Promise<RepairRequest> {
  return requestJson<RepairRequest>(`/repair-requests/${id}/complete`, { method: "POST", body: decision });
}

export function cancelRepairRequest(id: string, decision: RepairRequestDecisionRequest): Promise<RepairRequest> {
  return requestJson<RepairRequest>(`/repair-requests/${id}/cancel`, { method: "POST", body: decision });
}
