import Link from "next/link";

export default function HomePage() {
  return (
    <main className="container" style={{ paddingTop: 40 }}>
      <div className="card">
        <h1>Karobar OS</h1>
        <p>Inventory + Billing + Khata. Simple for shopkeepers.</p>
        <div className="grid grid-2">
          <Link href="/login"><button className="btn btn-primary">Login / لاگ اِن</button></Link>
          <Link href="/dashboard"><button className="btn btn-muted">View Demo Dashboard</button></Link>
        </div>
      </div>
    </main>
  );
}
