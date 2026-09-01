-- A completed re-shoot must clear the finding that ordered it.
--
-- fn_close_revisit stamped revisit_done_at and stopped there, so the ORIGINAL
-- report kept needs_review=true and its audit_flag forever. The stop had been
-- re-photographed and signed, and it still sat on the Report Issues board with
-- nothing left to do about it -- the board could never empty, which is the same
-- failure as a permanent amber light: nobody reads a list that is always full.
--
-- What a re-shoot does and does not answer:
--   needs_plate_photo / reused_photo  -> ANSWERED. The unit has been
--       photographed again, on its own plate, on a fresh visit.
--   asset_list_confirm / credit_review -> NOT answered. Those are questions for
--       Freshpet (a serial that is not on their asset list; a billing credit).
--       Driving a tech back out changes nothing about either, so they stay open.
create or replace function public.fn_close_revisit(p_original_id bigint, p_reshoot_id bigint)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_is_admin boolean;
  v_reshoot public.completed_pms%rowtype;
  v_original public.completed_pms%rowtype;
begin
  if v_uid is null then
    raise exception 'fn_close_revisit: not authenticated';
  end if;

  select exists (
    select 1 from public.tech_profiles tp
    where tp.email = (auth.jwt() ->> 'email') and tp.role = 'admin'
  ) into v_is_admin;

  select * into v_reshoot from public.completed_pms where id = p_reshoot_id;
  if not found then
    raise exception 'fn_close_revisit: replacement report % not found', p_reshoot_id;
  end if;
  if v_reshoot.visit_type not in ('reshoot', 'exception') or v_reshoot.revisit_of is distinct from p_original_id then
    raise exception 'fn_close_revisit: report % does not answer the re-visit on %', p_reshoot_id, p_original_id;
  end if;
  if v_reshoot.tech_user_id is distinct from v_uid and not v_is_admin then
    raise exception 'fn_close_revisit: only the tech who filed the replacement (or an admin) may close it';
  end if;

  select * into v_original from public.completed_pms where id = p_original_id;
  if not found then
    raise exception 'fn_close_revisit: original report % not found', p_original_id;
  end if;
  if v_original.revisit_requested_at is null then
    raise exception 'fn_close_revisit: report % has no re-visit open', p_original_id;
  end if;
  if v_original.revisit_done_at is not null then
    return;  -- already closed by an earlier attempt; not an error
  end if;

  update public.completed_pms
     set revisit_done_at = coalesce(v_reshoot.signed_at, now()),
         revisit_done_pm_id = p_reshoot_id,
         needs_review = case
           when v_original.audit_flag in ('asset_list_confirm', 'credit_review')
             then v_original.needs_review
           else false end,
         audit_flag = case
           when v_original.audit_flag in ('asset_list_confirm', 'credit_review')
             then v_original.audit_flag
           when v_original.audit_flag is null then null
           else 'resolved' end
   where id = p_original_id;
end;
$function$;
