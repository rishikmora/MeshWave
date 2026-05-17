create extension if not exists pgcrypto;

create table public.mesh_users (
  id uuid primary key default gen_random_uuid(),
  node_id text not null unique,
  nickname text not null,
  agreement_public_key text not null,
  signing_public_key text not null,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz
);

create table public.mesh_devices (
  id uuid primary key default gen_random_uuid(),
  owner_node_id text not null references public.mesh_users(node_id) on delete cascade,
  device_id text not null unique,
  callsign text not null,
  hardware text not null,
  firmware_version text not null,
  region_plan text not null default 'US915',
  battery_percent numeric(5,2) not null default 1.0,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz
);

create table public.mesh_nodes (
  node_id text primary key,
  callsign text not null,
  roles text[] not null default '{}',
  rssi integer,
  snr numeric(6,2),
  battery_percent numeric(5,2),
  firmware_version text,
  latitude double precision,
  longitude double precision,
  last_seen_at timestamptz not null default now()
);

create table public.mesh_routes (
  id uuid primary key default gen_random_uuid(),
  source_node_id text not null,
  destination_node_id text not null,
  hops text[] not null,
  cost numeric(12,4) not null,
  expires_at timestamptz not null,
  computed_at timestamptz not null default now()
);

create table public.mesh_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id text not null,
  sender_node_id text not null,
  recipient_node_id text not null,
  priority text not null check (priority in ('background','normal','high','emergency')),
  state text not null check (state in ('queued','sent','relayed','delivered','failed')),
  sequence bigint not null,
  hop_count integer not null default 0,
  created_at timestamptz not null default now(),
  delivered_at timestamptz
);

create table public.encrypted_payloads (
  message_id uuid primary key references public.mesh_messages(id) on delete cascade,
  algorithm text not null,
  nonce text not null,
  mac text not null,
  cipher_text text not null,
  aad text not null,
  created_at timestamptz not null default now()
);

create table public.relay_history (
  id uuid primary key default gen_random_uuid(),
  message_id uuid references public.mesh_messages(id) on delete cascade,
  relay_node_id text not null,
  previous_hop text,
  next_hop text,
  rssi integer,
  snr numeric(6,2),
  latency_ms integer,
  relayed_at timestamptz not null default now()
);

create table public.emergency_events (
  id uuid primary key default gen_random_uuid(),
  origin_node_id text not null,
  event_type text not null,
  severity integer not null check (severity between 1 and 5),
  latitude double precision,
  longitude double precision,
  encrypted_summary text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create table public.diagnostics (
  id uuid primary key default gen_random_uuid(),
  node_id text not null,
  rssi integer,
  snr numeric(6,2),
  battery_percent numeric(5,2),
  queue_depth integer,
  delivery_ratio numeric(5,4),
  memory_free_bytes integer,
  temperature_c numeric(6,2),
  recorded_at timestamptz not null default now()
);

create table public.firmware_versions (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  target_hardware text not null,
  sha256 text not null,
  signature text not null,
  release_notes text not null,
  mandatory boolean not null default false,
  created_at timestamptz not null default now()
);

create index mesh_messages_conversation_idx on public.mesh_messages(conversation_id, created_at desc);
create index diagnostics_node_time_idx on public.diagnostics(node_id, recorded_at desc);
create index relay_history_message_idx on public.relay_history(message_id, relayed_at);
create index mesh_routes_lookup_idx on public.mesh_routes(source_node_id, destination_node_id, expires_at);

alter table public.mesh_users enable row level security;
alter table public.mesh_devices enable row level security;
alter table public.mesh_nodes enable row level security;
alter table public.mesh_routes enable row level security;
alter table public.mesh_messages enable row level security;
alter table public.encrypted_payloads enable row level security;
alter table public.relay_history enable row level security;
alter table public.emergency_events enable row level security;
alter table public.diagnostics enable row level security;
alter table public.firmware_versions enable row level security;

create policy "read own mesh identity" on public.mesh_users
  for select using (auth.uid() is not null);

create policy "insert own mesh identity" on public.mesh_users
  for insert with check (auth.uid() is not null);

create policy "mesh cloud backup read" on public.mesh_messages
  for select using (auth.uid() is not null);

create policy "mesh cloud backup insert" on public.mesh_messages
  for insert with check (auth.uid() is not null);

create policy "encrypted payload read" on public.encrypted_payloads
  for select using (auth.uid() is not null);

create policy "encrypted payload insert" on public.encrypted_payloads
  for insert with check (auth.uid() is not null);

create policy "diagnostics read" on public.diagnostics
  for select using (auth.uid() is not null);

create policy "diagnostics insert" on public.diagnostics
  for insert with check (auth.uid() is not null);

create policy "firmware public read" on public.firmware_versions
  for select using (true);
