const { createClient } = window.supabase;
import { SUPABASE_URL, SUPABASE_ANON } from "./config.js";
export const sb = createClient(SUPABASE_URL, SUPABASE_ANON, { auth: { persistSession: false } });

// Un set est gagné : 6 jeux avec 2 d'écart, 7 jeux (tie-break), ou super tie-break (10+ avec 2 d'écart)
export function gagnantSet(a, b, idx) {
  if (idx === 2 && Math.max(a, b) >= 10) return Math.abs(a - b) >= 2 ? (a > b ? 0 : 1) : -1;
  if ((a >= 6 && a - b >= 2) || (a === 7 && b <= 6)) return 0;
  if ((b >= 6 && b - a >= 2) || (b === 7 && a <= 6)) return 1;
  return -1;
}
export function setsGagnes(sets) {
  const r = [0, 0];
  sets.forEach(([a, b], i) => { const g = gagnantSet(a, b, i); if (g >= 0) r[g]++; });
  return r;
}
export function gagnantMatch(court) {
  const [c, v] = setsGagnes(court.sets);
  if (court.statut !== "termine") return c >= 2 ? 0 : v >= 2 ? 1 : -1;
  return c > v ? 0 : v > c ? 1 : -1;
}
export function esc(s) { return String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]); }
export function ilYa(iso) {
  const s = Math.max(0, (Date.now() - new Date(iso).getTime()) / 1000);
  if (s < 60) return "à l'instant";
  if (s < 3600) return `il y a ${Math.floor(s / 60)} min`;
  return new Date(iso).toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" });
}
