-- Incident log: a durable record of what went wrong, what caused it, what was done,
-- and what stops it recurring. Kept inside the app so the record lives with the data
-- it describes rather than in a folder somebody has to go find.
-- Applied live 2026-08-28 via the Supabase MCP.
create table if not exists public.incidents (
  id              bigserial primary key,
  ref             text unique,
  title           text not null,
  status          text not null default 'open'
                  check (status in ('open','investigating','remediating','monitoring','closed')),
  severity        text not null default 'medium'
                  check (severity in ('low','medium','high','critical')),
  category        text,
  opened_at       timestamptz not null default now(),
  closed_at       timestamptz,
  reported_by     text,
  owner           text,
  summary         text,
  root_cause      text,
  impact          text,
  corrective      text,
  preventive      text,
  customer_facing boolean not null default false,
  reports_affected integer,
  financial_impact numeric(12,2),
  evidence        text,
  created_by      text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create table if not exists public.incident_entries (
  id          bigserial primary key,
  incident_id bigint not null references public.incidents(id) on delete cascade,
  entry_at    timestamptz not null default now(),
  author      text,
  kind        text default 'note'
              check (kind in ('note','finding','action','decision','communication')),
  body        text not null,
  created_at  timestamptz not null default now()
);

create index if not exists incident_entries_incident_idx on public.incident_entries (incident_id, entry_at);
create index if not exists incidents_status_idx on public.incidents (status, opened_at desc);

alter table public.incidents enable row level security;
alter table public.incident_entries enable row level security;

-- Internal record: signed-in staff only, never the anon key.
drop policy if exists incidents_staff_all on public.incidents;
create policy incidents_staff_all on public.incidents
  for all to authenticated using (true) with check (true);
drop policy if exists incident_entries_staff_all on public.incident_entries;
create policy incident_entries_staff_all on public.incident_entries
  for all to authenticated using (true) with check (true);

grant select, insert, update on public.incidents to authenticated;
grant select, insert, update on public.incident_entries to authenticated;
grant usage, select on sequence public.incidents_id_seq to authenticated;
grant usage, select on sequence public.incident_entries_id_seq to authenticated;
