-- A hold on the amounts in dispute.
--
-- 197 reports (189 units) have been sent back out because the documentation we
-- filed against them will not stand up. 178 of them are already on an invoice
-- Freshpet has been sent -- $5,340 at the flat $30 PM rate, $3,540 on #170015
-- and $1,800 on #172825. The other 19 are not invoiced yet and must not be.
--
-- A HOLD IS NOT A CREDIT, and this is the whole point of modelling it
-- separately. It does not touch `billed`, `bill_amount`, `invoice_doc_number`
-- or anything else about what was sent -- rewriting an issued invoice in our
-- own database is not a correction, it is losing the record of what we charged.
-- The hold is our STATEMENT about those lines: we are not standing behind them
-- pending re-documentation, so they should not be paid yet.
--
-- A hold has exactly two exits, and both are recorded on the row:
--   RELEASED -- the unit was re-documented and the charge stands.
--   CREDITED -- we are not charging for it. `credit_amount` carries what we
--               agreed to give back, which is NOT assumed to equal bill_amount:
--               a negotiated credit is a commercial decision, not arithmetic.
-- Neither exit deletes the hold. "There was a hold on this line and here is how
-- it ended" is the answer to the only question anyone will ask later.

alter table public.completed_pms
  add column if not exists billing_hold_at        timestamptz,
  add column if not exists billing_hold_by        text,
  add column if not exists billing_hold_reason    text,
  add column if not exists billing_hold_outcome   text,
  add column if not exists billing_hold_closed_at timestamptz,
  add column if not exists billing_hold_closed_by text,
  add column if not exists credit_amount          numeric;

do $$ begin
  alter table public.completed_pms
    add constraint completed_pms_billing_hold_outcome_check
    check (billing_hold_outcome is null or billing_hold_outcome in ('released','credited'));
exception when duplicate_object then null; end $$;

-- An outcome without a hold is meaningless, and a closed hold has to say when.
do $$ begin
  alter table public.completed_pms
    add constraint completed_pms_billing_hold_shape_check
    check (
      (billing_hold_outcome is null and billing_hold_closed_at is null)
      or (billing_hold_at is not null and billing_hold_outcome is not null
          and billing_hold_closed_at is not null)
    );
exception when duplicate_object then null; end $$;

create index if not exists completed_pms_billing_hold_open_idx
  on public.completed_pms (billing_hold_at)
  where billing_hold_at is not null and billing_hold_outcome is null;

comment on column public.completed_pms.billing_hold_at is
  'Set when this line is placed in dispute. Never changes what was invoiced -- see 20260901p.';
comment on column public.completed_pms.credit_amount is
  'What we agreed to credit. Deliberately independent of bill_amount: a negotiated credit is not arithmetic.';

-- What is on hold, for the portal and the admin console. One row per invoice
-- plus a null-invoice row for work that has not been billed at all, which is
-- held for the opposite reason: it must not go OUT until it is re-documented.
create or replace view public.v_billing_holds as
  select
    invoice_doc_number,
    count(*)::int                                              as reports,
    count(distinct serial)::int                                as units,
    coalesce(sum(bill_amount) filter (where billed), 0)::numeric(12,2) as amount_held,
    count(*) filter (where revisit_done_at is not null)::int    as re_documented,
    count(*) filter (where revisit_done_at is null)::int        as awaiting_revisit,
    min(billing_hold_at)                                        as held_since
  from public.completed_pms
  where billing_hold_at is not null
    and billing_hold_outcome is null
  group by invoice_doc_number;

alter view public.v_billing_holds set (security_invoker = on);
grant select on public.v_billing_holds to authenticated;
