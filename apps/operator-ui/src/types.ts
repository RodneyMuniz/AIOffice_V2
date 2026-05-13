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
  pending_approvals_count: number;
  events_count: number;
  evidence_count: number;
  non_claims: string[];
};

export type Card = {
  id: string;
  title: string;
  summary: string;
  status: string;
  owner_agent_id: string;
  priority: string;
  acceptance_focus?: string[];
  created_at?: string;
};

export type WorkOrder = {
  id: string;
  card_id: string;
  title: string;
  summary: string;
  status: string;
  requested_by_agent_id: string;
  assigned_agent_id: string;
  approval_required: boolean;
  handoff_target_agent_id?: string;
  evidence_refs?: string[];
  created_at?: string;
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
};

export type EvidenceEntry = {
  id: string;
  title: string;
  kind: string;
  summary: string;
  path: string;
  related_card_id: string;
};

export type DashboardData = {
  status: StatusResponse;
  cards: Card[];
  workOrders: WorkOrder[];
  agents: Agent[];
  events: EventEntry[];
  evidence: EvidenceEntry[];
};
