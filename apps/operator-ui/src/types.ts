export const CARD_STATUSES = ["intake", "planned", "in_progress", "blocked", "done", "archived"] as const;
export const WORK_ORDER_STATUSES = [
  "draft",
  "ready",
  "running",
  "waiting_approval",
  "approved",
  "rejected",
  "completed",
  "blocked",
  "cancelled"
] as const;
export const HANDOFF_STATUSES = ["proposed", "accepted", "rejected", "completed", "blocked"] as const;
export const QA_RESULT_VALUES = ["passed", "failed", "blocked"] as const;
export const REPAIR_REQUEST_STATUSES = ["proposed", "created", "in_progress", "completed", "cancelled"] as const;

export type CardStatus = (typeof CARD_STATUSES)[number];
export type WorkOrderStatus = (typeof WORK_ORDER_STATUSES)[number];
export type HandoffStatus = (typeof HANDOFF_STATUSES)[number];
export type QaResultValue = (typeof QA_RESULT_VALUES)[number];
export type RepairRequestStatus = (typeof REPAIR_REQUEST_STATUSES)[number];

export type StatusResponse = {
  product_name: string;
  milestone: string;
  repo: string;
  branch: string;
  posture: string;
  r18_posture: string;
  current_card_id: string | null;
  current_work_order_id: string | null;
  current_agent_id: string | null;
  cards_count: number;
  work_orders_count: number;
  approvals_count: number;
  pending_approvals_count: number;
  handoffs_count: number;
  pending_handoffs_count: number;
  qa_results_count: number;
  failed_qa_results_count: number;
  blocked_qa_results_count: number;
  repair_requests_count: number;
  open_repair_requests_count: number;
  completed_repair_requests_count: number;
  events_count: number;
  evidence_count: number;
  allowed_card_statuses: CardStatus[];
  allowed_work_order_statuses: WorkOrderStatus[];
  non_claims: string[];
};

export type Card = {
  id: string;
  title: string;
  summary: string;
  status: CardStatus;
  owner_agent_id: string;
  owner_role?: string;
  priority: string;
  acceptance_focus?: string[];
  created_at?: string;
};

export type WorkOrder = {
  id: string;
  card_id: string;
  title: string;
  summary: string;
  status: WorkOrderStatus;
  requested_by_agent_id: string;
  assigned_agent_id: string;
  approval_required: boolean;
  request_requires_approval?: boolean;
  handoff_target_agent_id?: string;
  evidence_refs?: string[];
  source_work_order_id?: string;
  qa_result_id?: string;
  repair_request_id?: string;
  created_at?: string;
  updated_at?: string;
};

export type ApprovalStatus = "pending" | "approved" | "rejected";

export type Approval = {
  id: string;
  title: string;
  description: string;
  related_card_id: string;
  related_work_order_id?: string | null;
  status: ApprovalStatus;
  requested_by: string;
  created_at: string;
  decided_at?: string | null;
  decision_reason?: string | null;
};

export type Handoff = {
  id: string;
  source_agent_id: string;
  target_agent_id: string;
  source_role: string;
  target_role: string;
  card_id: string;
  work_order_id: string;
  title: string;
  summary: string;
  status: HandoffStatus;
  payload_summary: string;
  validation_summary: string;
  created_at: string;
  updated_at: string;
  decided_at?: string | null;
  decision_reason?: string | null;
  evidence_refs: string[];
};

export type QaResult = {
  id: string;
  handoff_id: string;
  card_id: string;
  work_order_id: string;
  qa_agent_id: string;
  result: QaResultValue;
  summary: string;
  findings: string;
  recommended_next_action: string;
  created_at: string;
  updated_at: string;
  evidence_refs: string[];
};

export type RepairRequest = {
  id: string;
  qa_result_id: string;
  handoff_id: string;
  card_id: string;
  source_work_order_id: string;
  repair_work_order_id: string;
  requested_by: string;
  assigned_agent_id: string;
  status: RepairRequestStatus;
  summary: string;
  repair_instructions: string;
  created_at: string;
  updated_at: string;
  completed_at: string | null;
  evidence_refs: string[];
};

export type Agent = {
  id: string;
  display_name: string;
  role: string;
  status: string;
  approval_scope: string;
  api_invocation_enabled: boolean;
};

export type EventEntry = {
  id: string;
  timestamp: string;
  type: string;
  summary: string;
  actor_agent_id: string;
  related_card_id?: string;
  related_work_order_id?: string;
  related_approval_id?: string;
  related_handoff_id?: string;
  related_repair_request_id?: string;
};

export type EvidenceEntry = {
  id: string;
  title: string;
  kind: string;
  summary: string;
  path: string;
  related_card_id: string;
  related_work_order_id?: string;
  related_approval_id?: string;
  related_handoff_id?: string;
  related_repair_request_id?: string;
  created_at?: string;
};

export type DashboardData = {
  status: StatusResponse;
  cards: Card[];
  workOrders: WorkOrder[];
  agents: Agent[];
  events: EventEntry[];
  evidence: EvidenceEntry[];
  approvals: Approval[];
  handoffs: Handoff[];
  qaResults: QaResult[];
  repairRequests: RepairRequest[];
};

export type CreateCardRequest = {
  title: string;
  description: string;
  priority: string;
  owner_role: string;
};

export type CreateWorkOrderRequest = {
  card_id: string;
  title: string;
  description: string;
  assigned_agent_id: string;
  request_requires_approval: boolean;
};

export type CreateApprovalRequest = {
  title: string;
  description: string;
  related_card_id: string;
  related_work_order_id?: string | null;
};

export type HandoffDecisionRequest = {
  decision_reason: string;
  decided_by: string;
};

export type CreateQaResultRequest = {
  result: QaResultValue;
  summary: string;
  findings: string;
  recommended_next_action: string;
  qa_agent_id: string;
};

export type CreateRepairRequest = {
  summary: string;
  repair_instructions: string;
  requested_by: string;
  assigned_agent_id: string;
};

export type RepairRequestDecisionRequest = {
  decision_reason: string;
  decided_by: string;
};

export type UpdateStatusRequest = {
  status: string;
  reason?: string;
  requested_by: string;
};
