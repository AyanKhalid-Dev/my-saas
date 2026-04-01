"use server";

import { redirect } from "next/navigation";
import { createServerClient } from "@/lib/supabase-server";

export async function login(formData: FormData) {
  const email = String(formData.get("email") ?? "").trim();
  const supabase = await createServerClient();

  await supabase.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: `${process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"}/dashboard`
    }
  });

  redirect("/login?sent=1");
}
