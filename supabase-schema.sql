-- Gridwork database schema for Supabase.
-- Run this once in your Supabase project: Dashboard -> SQL Editor -> New query -> paste -> Run.

create extension if not exists pgcrypto;

create table if not exists datasets (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  columns jsonb not null default '[]',
  rows jsonb not null default '[]',
  row_count integer not null default 0,
  truncated boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists dashboards (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  card_ids jsonb not null default '[]',
  created_at timestamptz not null default now()
);

create table if not exists cards (
  id uuid primary key default gen_random_uuid(),
  dashboard_id uuid references dashboards(id) on delete cascade,
  dataset_id uuid references datasets(id) on delete cascade,
  type text not null,
  title text not null,
  x_field text,
  y_field text,
  agg text,
  created_at timestamptz not null default now()
);

-- Row-level security: required by Supabase before the anon key can read/write.
alter table datasets enable row level security;
alter table dashboards enable row level security;
alter table cards enable row level security;

-- NOTE: these policies allow anyone with your Supabase URL + anon key to read
-- and write every row. That's fine for a private/internal tool where the URL
-- isn't shared publicly, but it is NOT the same as real per-user access
-- control. If you want to restrict who can edit data, add Supabase Auth and
-- tighten these policies to check auth.uid() -- ask me and I can help with that.

create policy "public read datasets" on datasets for select using (true);
create policy "public insert datasets" on datasets for insert with check (true);
create policy "public update datasets" on datasets for update using (true);
create policy "public delete datasets" on datasets for delete using (true);

create policy "public read dashboards" on dashboards for select using (true);
create policy "public insert dashboards" on dashboards for insert with check (true);
create policy "public update dashboards" on dashboards for update using (true);
create policy "public delete dashboards" on dashboards for delete using (true);

create policy "public read cards" on cards for select using (true);
create policy "public insert cards" on cards for insert with check (true);
create policy "public update cards" on cards for update using (true);
create policy "public delete cards" on cards for delete using (true);

-- Enable realtime updates (live sync across devices) for all three tables.
alter publication supabase_realtime add table datasets;
alter publication supabase_realtime add table dashboards;
alter publication supabase_realtime add table cards;
