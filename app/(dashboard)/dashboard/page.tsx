import { QuickActions } from "@/components/quick-actions";

const stats = [
  { label: "Today Sales / آج کی فروخت", value: "PKR 85,400" },
  { label: "Receivable / لینا ہے", value: "PKR 120,900" },
  { label: "Payable / دینا ہے", value: "PKR 54,200" },
  { label: "Low Stock / کم اسٹاک", value: "9 items" }
];

export default function DashboardPage() {
  return (
    <main className="container">
      <h1 style={{ marginBottom: 8 }}>Dashboard</h1>
      <p style={{ marginTop: 0, color: "#64748b" }}>One-screen business health summary.</p>

      <section className="grid grid-2" style={{ marginBottom: 14 }}>
        {stats.map((s) => (
          <article className="card" key={s.label}>
            <div style={{ color: "#64748b", fontSize: ".9rem" }}>{s.label}</div>
            <strong style={{ fontSize: "1.25rem" }}>{s.value}</strong>
          </article>
        ))}
      </section>

      <QuickActions />

      <section className="card" style={{ marginTop: 12 }}>
        <h3>Notifications / نوٹیفکیشنز</h3>
        <ul>
          <li>3 customers due today.</li>
          <li>USB-C Cable stock below threshold.</li>
          <li>Month-end summary ready.</li>
        </ul>
      </section>
    </main>
  );
}
