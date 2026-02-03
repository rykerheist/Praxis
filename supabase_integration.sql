-- Phase 6.3: Final Backend Integration Schema
-- Run this in your Supabase Dashboard -> SQL Editor
-- This ensures the Database matches both the Flutter App and the Edge Function.

-- 1. Tenants Table (For Multi-tenancy/Auth)
create table if not exists public.tenants (
  id uuid references auth.users(id) primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Clients Table
create table if not exists public.clients (
  id uuid default gen_random_uuid() primary key,
  tenant_id uuid references public.tenants(id) not null,
  full_name text not null,
  organization text,
  psychometrics_json jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Sessions Table
create table if not exists public.sessions (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references public.clients(id) not null,
  scheduled_at timestamp with time zone,
  briefing_note_md text,
  
  -- The fields filled by "process-session" function
  transcript_text text,
  ai_analysis jsonb,
  
  status text default 'scheduled', -- 'scheduled', 'completed', 'cancelled'
  summary_pdf_url text,
  
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Enable Row Level Security (RLS)
alter table public.tenants enable row level security;
alter table public.clients enable row level security;
alter table public.sessions enable row level security;

-- 5. Policies
-- Simple policy: Users can only see data where they are the tenant
create policy "Users can view own tenant" on public.tenants
  for select using (auth.uid() = id);

create policy "Users can insert own tenant" on public.tenants
  for insert with check (auth.uid() = id);

create policy "Users can view own clients" on public.clients
  for all using (auth.uid() = tenant_id);

create policy "Users can view own sessions" on public.sessions
  for all using (
    exists (
      select 1 from public.clients
      where clients.id = sessions.client_id
      and clients.tenant_id = auth.uid()
    )
  );
