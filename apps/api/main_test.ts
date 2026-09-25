import { assertEquals } from "jsr:@std/assert";

Deno.test("Deno.serve is available", () => {
  assertEquals(typeof Deno.serve, "function");
});
