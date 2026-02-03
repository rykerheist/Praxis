-- 1. Tenants (The Coach)
create table tenants (
  id uuid references auth.users not null primary key,
  branding_json jsonb,
  ai_preferences_json jsonb
);

-- 2. Clients (The Executives)
create table clients (
  id uuid default uuid_generate_v4() primary key,
  tenant_id uuid references tenants(id) not null,
  full_name text not null,
  organization text,
  timezone text default 'UTC',
  psychometrics_json jsonb, -- DISC/Hogan results
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 3. Sessions (The Work)
create table sessions (
  id uuid default uuid_generate_v4() primary key,
  client_id uuid references clients(id) not null,
  scheduled_at timestamp with time zone,
  briefing_note_md text, -- AI Generated Pre-read
  transcript_text text,
  summary_pdf_url text,
  status text check (status in ('scheduled', 'completed', 'cancelled'))
);

-- Enable RLS (Row Level Security) immediately
alter table clients enable row level security;
create policy "Tenants can only see their own clients"
  on clients for all
  using (auth.uid() = tenant_id);
