import { login } from "./server-actions";

export default function LoginPage() {
  return (
    <main className="container" style={{ paddingTop: 32 }}>
      <form action={login} className="card" style={{ maxWidth: 480, margin: "0 auto" }}>
        <h2>Welcome / خوش آمدید</h2>
        <p style={{ color: "#64748b" }}>Use email OTP for easy login.</p>

        <label className="label" htmlFor="email">Email</label>
        <input className="input" id="email" name="email" type="email" required />
        <br /><br />
        <button className="btn btn-primary" type="submit">Send OTP / کوڈ بھیجیں</button>
      </form>
    </main>
  );
}
