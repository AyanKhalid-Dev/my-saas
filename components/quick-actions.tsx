const actions = [
  "Quick Sale / تیز بل",
  "Khata Entry / کھاتہ اندراج",
  "Add Product / پروڈکٹ شامل کریں",
  "Receive Payment / ادائیگی وصول"
];

export function QuickActions() {
  return (
    <section className="card">
      <h3 style={{ marginTop: 0 }}>Quick Actions</h3>
      <div className="grid grid-2">
        {actions.map((action) => (
          <button key={action} className="btn btn-primary" type="button">
            {action}
          </button>
        ))}
      </div>
    </section>
  );
}
