import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { App } from "./App";

vi.mock("./lib/auth-client", () => ({
  authClient: { useSession: vi.fn(), signOut: vi.fn() },
}));

import { authClient } from "./lib/auth-client";

describe("App", () => {
  it("shows the login form when there is no session", () => {
    vi.mocked(authClient.useSession).mockReturnValue({ data: null, isPending: false } as never);
    render(<App />);
    expect(screen.getByRole("button", { name: /sign in/i })).toBeInTheDocument();
  });

  it("shows the dashboard placeholder when a session exists", () => {
    vi.mocked(authClient.useSession).mockReturnValue({
      data: { user: { email: "sam@example.com" } },
      isPending: false,
    } as never);
    render(<App />);
    expect(screen.getByText("sam@example.com")).toBeInTheDocument();
    expect(screen.getByText(/no items yet/i)).toBeInTheDocument();
  });
});
