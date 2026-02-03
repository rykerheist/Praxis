
-- 4. Storage Buckets & Policies
-- Note: You might need to Create 'contracts' and 'session_recordings' buckets manually in Supabase Dashboard -> Storage
-- if you don't have permissions to run these inserts directly.

insert into storage.buckets (id, name, public) 
values ('contracts', 'contracts', false) 
on conflict (id) do nothing;

insert into storage.buckets (id, name, public) 
values ('session_recordings', 'session_recordings', false)
on conflict (id) do nothing;

-- Policies for Contracts
create policy "Authenticated can upload contracts"
  on storage.objects for insert
  to authenticated
  with check ( bucket_id = 'contracts' );

create policy "Authenticated can read contracts"
  on storage.objects for select
  to authenticated
  using ( bucket_id = 'contracts' );

-- Policies for Recordings
create policy "Authenticated can upload recordings"
  on storage.objects for insert
  to authenticated
  with check ( bucket_id = 'session_recordings' );

create policy "Authenticated can read recordings"
  on storage.objects for select
  to authenticated
  using ( bucket_id = 'session_recordings' );
