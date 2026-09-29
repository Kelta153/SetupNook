import { authClient } from "./lib/auth-client";
import { LoginPage } from "./components/LoginPage";
import { DashboardPage } from "./components/DashboardPage";

export function App() {
  const { data: session, isPending } = authClient.useSession();

  if (isPending) return <p>Loading…</p>;
  if (!session) return <LoginPage />;
  return <DashboardPage session={session} />;
}
