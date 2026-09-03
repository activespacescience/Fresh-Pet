# plate-read

Reads the serial off a plate photograph so the phone can refuse a report that is
about the wrong machine.

Deployed to the Supabase project (`plate-read`, verify_jwt on). Source of record
is the deployed function; this note exists so the requirement is not invisible.

**Needs `ANTHROPIC_API_KEY` in the Supabase project's edge-function secrets.**
Without it the function returns `{status:'unconfigured'}` and the app carries on
with the report flagged — it never blocks a technician on our configuration.

Two rules in the function are load-bearing and must survive any edit:

1. **The model never sees the serial we expect.** It reads the plate blind and
   the caller compares. Sending the expected value invites the exact failure
   this exists to catch.
2. **No fuzzy matching, anywhere.** The Petco #372 serials were 240761 and
   240766 — one character apart. Any edit-distance tolerance waves through the
   precise error being hunted. Exact match after case/punctuation stripping, or
   `confident: false`.
