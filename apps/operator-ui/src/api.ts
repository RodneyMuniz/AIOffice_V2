import type { Agent, Card, DashboardData, EventEntry, EvidenceEntry, StatusResponse, WorkOrder } from "./types";

export const API_BASE_URL = (import.meta.env.VITE_AIO_API_BASE_URL ?? "http://localhost:8000").replace(/\/$/, "");

async function getJson<T>(path: string, signal: AbortSignal): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, { signal });

  if (!response.ok) {
    throw new Error(`${path} returned HTTP ${response.status}`);
  }

  return response.json() as Promise<T>;
}

export async function loadDashboard(signal: AbortSignal): Promise<DashboardData> {
  const [status, cards, workOrders, agents, events, evidence] = await Promise.all([
    getJson<StatusResponse>("/status", signal),
    getJson<Card[]>("/cards", signal),
    getJson<WorkOrder[]>("/work-orders", signal),
    getJson<Agent[]>("/agents", signal),
    getJson<EventEntry[]>("/events", signal),
    getJson<EvidenceEntry[]>("/evidence", signal)
  ]);

  return { status, cards, workOrders, agents, events, evidence };
}
