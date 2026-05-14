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
export const DEVELOPER_RESULT_TYPES = ["implementation", "repair", "documentation", "validation", "other"] as const;
export const DEVELOPER_RESULT_STATUSES = ["draft", "submitted", "superseded"] as const;
export const QA_READINESS_LEVELS = ["ready", "warning", "blocked"] as const;
export const QA_READINESS_CHECK_STATUSES = ["passed", "warning", "blocked"] as const;
export const QA_HANDOFF_POLICY_MODES = ["advisory", "enforced"] as const;
export const AUDIT_EXCEPTION_TYPES = [
  "policy_override",
  "policy_settings_change",
  "qa_failed",
  "qa_blocked",
  "repair_request_created",
  "handoff_without_developer_result",
  "duplicate_handoff_blocked",
  "readiness_blocker"
] as const;
export const AUDIT_SEVERITIES = ["info", "warning", "blocker", "override"] as const;
export const AUDIT_ACKNOWLEDGEMENT_STATUSES = ["acknowledged", "resolved", "dismissed"] as const;
export const AUDIT_ACKNOWLEDGEMENT_FILTER_STATUSES = [
  "none",
  ...AUDIT_ACKNOWLEDGEMENT_STATUSES
] as const;

export type CardStatus = (typeof CARD_STATUSES)[number];
export type WorkOrderStatus = (typeof WORK_ORDER_STATUSES)[number];
export type HandoffStatus = (typeof HANDOFF_STATUSES)[number];
export type QaResultValue = (typeof QA_RESULT_VALUES)[number];
export type RepairRequestStatus = (typeof REPAIR_REQUEST_STATUSES)[number];
export type DeveloperResultType = (typeof DEVELOPER_RESULT_TYPES)[number];
export type DeveloperResultStatus = (typeof DEVELOPER_RESULT_STATUSES)[number];
export type QaReadinessLevel = (typeof QA_READINESS_LEVELS)[number];
export type QaReadinessCheckStatus = (typeof QA_READINESS_CHECK_STATUSES)[number];
export type QaHandoffPolicyMode = (typeof QA_HANDOFF_POLICY_MODES)[number];
export type AuditExceptionType = (typeof AUDIT_EXCEPTION_TYPES)[number];
export type AuditSeverity = (typeof AUDIT_SEVERITIES)[number];
export type AuditAcknowledgementStatus = (typeof AUDIT_ACKNOWLEDGEMENT_STATUSES)[number];
export type AuditAcknowledgementFilterStatus = (typeof AUDIT_ACKNOWLEDGEMENT_FILTER_STATUSES)[number];

export type AuditSummary = {
  total_policy_overrides: number;
  total_policy_override_handoffs: number;
  total_policy_settings_changes: number;
  total_qa_failures: number;
  total_qa_blocked_results: number;
  total_repair_requests: number;
  open_repair_requests: number;
  completed_repair_requests: number;
  total_hard_blocker_events: number;
  total_readiness_blockers: number;
  acknowledged_exceptions: number;
  resolved_exceptions: number;
  dismissed_exceptions: number;
  unreviewed_exceptions: number;
  generated_at: string;
};

export type AuditException = {
  id: string;
  exception_type: AuditExceptionType;
  severity: AuditSeverity;
  title: string;
  summary: string;
  card_id: string | null;
  work_order_id: string | null;
  handoff_id: string | null;
  qa_result_id: string | null;
  repair_request_id: string | null;
  policy_override_id: string | null;
  event_id: string | null;
  evidence_id: string | null;
  created_at: string;
  source_ref: string;
  acknowledgement_id: string | null;
  acknowledgement_status: AuditAcknowledgementStatus | null;
  acknowledgement_reason: string | null;
  acknowledged_by: string | null;
  acknowledged_at: string | null;
  resolved_at: string | null;
};

export type AuditExceptionFilters = {
  exception_type?: string;
  severity?: string;
  acknowledgement_status?: AuditAcknowledgementFilterStatus | "";
  card_id?: string;
  work_order_id?: string;
  handoff_id?: string;
  q?: string;
  limit?: number;
  offset?: number;
};

export type AuditAcknowledgement = {
  id: string;
  exception_id: string;
  exception_source_ref: string;
  exception_type: string;
  status: AuditAcknowledgementStatus;
  reason: string;
  acknowledged_by: string;
  created_at: string;
  updated_at: string;
  resolved_at: string | null;
  evidence_refs: string[];
};

export type CreateAuditAcknowledgementRequest = {
  exception_id?: string;
  exception_source_ref?: string;
  exception_type?: string;
  status: AuditAcknowledgementStatus;
  reason: string;
  acknowledged_by?: string;
};

export type UpdateAuditAcknowledgementRequest = {
  status: AuditAcknowledgementStatus;
  reason: string;
  acknowledged_by?: string;
};

export type PolicySettings = {
  qa_handoff_policy_mode: QaHandoffPolicyMode;
  require_developer_result_for_qa: boolean;
  require_developer_result_for_repair_qa: boolean;
  allow_operator_override: boolean;
  updated_at: string;
  updated_by: string;
};

export type UpdatePolicySettingsRequest = {
  qa_handoff_policy_mode?: QaHandoffPolicyMode;
  require_developer_result_for_qa?: boolean;
  require_developer_result_for_repair_qa?: boolean;
  allow_operator_override?: boolean;
  updated_by?: string;
};

export type StatusResponse = {
  product_name: string;
  milestone: string;
  repo: string;
  branch: string;
  posture: string;
  r18_posture: string;
  qa_handoff_policy_mode: QaHandoffPolicyMode;
  qa_policy_enforced: boolean;
  require_developer_result_for_qa: boolean;
  require_developer_result_for_repair_qa: boolean;
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
  workflow_iterations_count: number;
  repair_qa_handoffs_count: number;
  repair_qa_results_count: number;
  developer_results_count: number;
  submitted_developer_results_count: number;
  work_orders_with_developer_results_count: number;
  readiness_warnings_count?: number;
  readiness_blockers_count?: number;
  policy_overrides_count?: number;
  qa_handoffs_with_override_count?: number;
  events_count: number;
  evidence_count: number;
  allowed_card_statuses: CardStatus[];
  allowed_work_order_statuses: WorkOrderStatus[];
  non_claims: string[];
};

export type QaReadinessCheck = {
  id: string;
  label: string;
  status: QaReadinessCheckStatus;
  detail: string;
};

export type QaReadiness = {
  work_order_id: string;
  card_id: string;
  ready_for_qa: boolean;
  readiness_level: QaReadinessLevel;
  policy_mode: QaHandoffPolicyMode;
  policy_enforced: boolean;
  advisory_warnings_promoted_to_blockers: boolean;
  checks: QaReadinessCheck[];
  warnings: string[];
  blockers: string[];
  overridable_blockers: string[];
  non_overridable_blockers: string[];
  override_available: boolean;
  latest_developer_result_id: string | null;
  latest_developer_result_summary: string | null;
  latest_developer_result_status: DeveloperResultStatus | null;
  work_order_status: WorkOrderStatus | null;
  handoff_context: "initial_qa" | "repair_qa";
  repair_request_id?: string;
  generated_at: string;
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
  developer_result_ids?: string[];
  latest_developer_result_id?: string;
  iteration_number?: number;
  work_order_type?: "original" | "repair";
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
  repair_request_id?: string;
  qa_result_id?: string;
  developer_result_id?: string;
  developer_result_summary?: string;
  policy_override_id?: string;
  policy_override_reason?: string;
  iteration_number?: number;
  handoff_purpose?: "initial_qa" | "repair_qa";
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
  repair_request_id?: string;
  source_qa_result_id?: string;
  iteration_number?: number;
  created_at: string;
  updated_at: string;
  evidence_refs: string[];
};

export type DeveloperResult = {
  id: string;
  card_id: string;
  work_order_id: string;
  agent_id: string;
  result_type: DeveloperResultType;
  status: DeveloperResultStatus;
  summary: string;
  changed_paths: string[];
  notes: string;
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

export type PolicyOverride = {
  id: string;
  target_type: "work_order_qa_handoff" | "repair_qa_handoff";
  target_id: string;
  work_order_id: string;
  repair_request_id?: string;
  card_id: string;
  policy_mode: QaHandoffPolicyMode;
  overridden_blockers: string[];
  non_overridable_blockers: string[];
  reason: string;
  requested_by: string;
  created_at: string;
  evidence_refs: string[];
};

export type WorkflowIteration = {
  card_id: string;
  original_work_order_id: string;
  work_order_id: string;
  work_order_type: "original" | "repair";
  repair_request_id?: string | null;
  handoff_id?: string | null;
  qa_result_id?: string | null;
  source_qa_result_id?: string | null;
  iteration_number: number;
  status_summary: string;
  latest_result?: QaResultValue | null;
  created_at?: string | null;
  updated_at?: string | null;
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
  related_developer_result_id?: string;
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
  related_developer_result_id?: string;
  created_at?: string;
};

export type DashboardData = {
  status: StatusResponse;
  policySettings: PolicySettings;
  cards: Card[];
  workOrders: WorkOrder[];
  agents: Agent[];
  events: EventEntry[];
  evidence: EvidenceEntry[];
  approvals: Approval[];
  handoffs: Handoff[];
  developerResults: DeveloperResult[];
  qaResults: QaResult[];
  repairRequests: RepairRequest[];
  policyOverrides: PolicyOverride[];
  workflowIterations: WorkflowIteration[];
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

export type HandoffOverrideRequest = {
  override_policy: boolean;
  override_reason: string;
  requested_by: string;
};

export type CreateQaResultRequest = {
  result: QaResultValue;
  summary: string;
  findings: string;
  recommended_next_action: string;
  qa_agent_id: string;
};

export type CreateDeveloperResultRequest = {
  result_type: DeveloperResultType;
  summary: string;
  changed_paths: string[];
  notes: string;
  agent_id: string;
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
