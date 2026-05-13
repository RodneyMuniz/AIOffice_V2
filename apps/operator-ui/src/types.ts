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

export type CardStatus = (typeof CARD_STATUSES)[number];
export type WorkOrderStatus = (typeof WORK_ORDER_STATUSES)[number];

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
  created_at?: string;
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

export type UpdateStatusRequest = {
  status: string;
  reason?: string;
  requested_by: string;
};
