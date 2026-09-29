import { authClient } from "../lib/auth-client";

export function DashboardPage({ session }: { session: { user: { email: string } } }) {
  return (
    <div className="dashboard">
      <header className="dashboard__header">
        <div className="dashboard__header-left">
          <h1 className="dashboard__wordmark">SetupNooK</h1>
          <span className="dashboard__account">{session.user.email}</span>
        </div>
        <div className="dashboard__header-actions">
          {/* Not wired up yet — the add-item/search flow is step 4. */}
          <button className="dashboard__add-item" type="button" disabled aria-disabled="true">
            + Add item
          </button>
          <button
            className="dashboard__settings"
            type="button"
            disabled
            aria-disabled="true"
            aria-label="Settings"
          >
            ⚙
          </button>
          <button className="dashboard__logout" type="button" onClick={() => authClient.signOut({})}>
            Log out
          </button>
        </div>
      </header>
      <div className="dashboard__filter-bar">
        <input
          className="dashboard__filter-input"
          type="search"
          placeholder="Search your wishlist"
          disabled
          aria-disabled="true"
        />
      </div>
      <main className="dashboard__ledger">
        <p className="dashboard__empty-row">
          You have no items yet. Add one to start tracking its landed cost.
        </p>
      </main>
    </div>
  );
}
