-- Karobar OS multi-tenant schema for Supabase Postgres
create extension if not exists "pgcrypto";

create type public.app_role as enum ('owner', 'staff', 'accountant');
create type public.party_type as enum ('customer', 'supplier');
create type public.ledger_mode as enum ('bill_based', 'running_balance');
create type public.invoice_status as enum ('draft', 'posted', 'void');
create type public.payment_direction as enum ('in', 'out');
create type public.reminder_channel as enum ('whatsapp', 'sms', 'in_app');

create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  business_name text not null,
  phone text,
  city text,
  locale text not null default 'en-PK',
  currency text not null default 'PKR',
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  full_name text not null,
  role public.app_role not null default 'staff',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique(id, tenant_id)
);

create table if not exists public.warehouses (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  address text,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  name_ur text,
  sku text,
  barcode text,
  category text,
  unit text not null default 'pcs',
  purchase_price numeric(12,2) not null default 0,
  selling_price numeric(12,2) not null default 0,
  reorder_level numeric(12,2) not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists products_tenant_sku_unique
  on public.products(tenant_id, sku) where sku is not null;
create index if not exists products_search_idx on public.products(tenant_id, name, barcode);

create table if not exists public.inventory_batches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  qty numeric(12,2) not null,
  avg_cost numeric(12,2) not null default 0,
  updated_at timestamptz not null default now(),
  unique(tenant_id, product_id, warehouse_id)
);

create table if not exists public.parties (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  party_type public.party_type not null,
  name text not null,
  phone text not null,
  email text,
  address text,
  notes text,
  ledger_mode public.ledger_mode not null default 'bill_based',
  opening_balance numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  unique(tenant_id, party_type, phone)
);

create index if not exists parties_search_idx on public.parties(tenant_id, party_type, name, phone);

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  invoice_number text not null,
  customer_id uuid references public.parties(id),
  warehouse_id uuid references public.warehouses(id),
  status public.invoice_status not null default 'draft',
  issue_date date not null default current_date,
  due_date date,
  subtotal numeric(12,2) not null default 0,
  discount numeric(12,2) not null default 0,
  tax numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  paid_amount numeric(12,2) not null default 0,
  balance_due numeric(12,2) not null default 0,
  notes text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(tenant_id, invoice_number)
);

create table if not exists public.invoice_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  product_id uuid not null references public.products(id),
  qty numeric(12,2) not null,
  unit_price numeric(12,2) not null,
  discount numeric(12,2) not null default 0,
  line_total numeric(12,2) not null
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  party_id uuid not null references public.parties(id),
  invoice_id uuid references public.invoices(id),
  direction public.payment_direction not null,
  amount numeric(12,2) not null check (amount > 0),
  payment_date date not null default current_date,
  method text not null default 'cash',
  reference text,
  note text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.ledger_entries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  party_id uuid not null references public.parties(id),
  invoice_id uuid references public.invoices(id),
  payment_id uuid references public.payments(id),
  entry_date date not null default current_date,
  description text not null,
  debit numeric(12,2) not null default 0,
  credit numeric(12,2) not null default 0,
  running_balance numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.reminders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  party_id uuid not null references public.parties(id),
  due_date date not null,
  amount numeric(12,2) not null,
  channel public.reminder_channel not null default 'in_app',
  message text not null,
  is_sent boolean not null default false,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.activity_logs (
  id bigint generated always as identity primary key,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  actor_id uuid references public.profiles(id),
  event_type text not null,
  entity text not null,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.bulk_import_jobs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  uploaded_by uuid references public.profiles(id),
  source_file text not null,
  status text not null default 'queued',
  row_count integer not null default 0,
  success_count integer not null default 0,
  failed_count integer not null default 0,
  errors jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger products_set_updated_at
before update on public.products
for each row execute procedure public.set_updated_at();

create trigger invoices_set_updated_at
before update on public.invoices
for each row execute procedure public.set_updated_at();

create trigger import_set_updated_at
before update on public.bulk_import_jobs
for each row execute procedure public.set_updated_at();

create or replace function public.current_tenant_id()
returns uuid
language sql
stable
as $$
  select tenant_id
  from public.profiles
  where id = auth.uid()
  limit 1;
$$;

create or replace function public.is_owner()
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'owner' and is_active = true
  );
$$;

alter table public.tenants enable row level security;
alter table public.profiles enable row level security;
alter table public.warehouses enable row level security;
alter table public.products enable row level security;
alter table public.inventory_batches enable row level security;
alter table public.parties enable row level security;
alter table public.invoices enable row level security;
alter table public.invoice_items enable row level security;
alter table public.payments enable row level security;
alter table public.ledger_entries enable row level security;
alter table public.reminders enable row level security;
alter table public.activity_logs enable row level security;
alter table public.bulk_import_jobs enable row level security;

create policy tenant_select on public.products
for select using (tenant_id = public.current_tenant_id());
create policy tenant_modify_owner_staff on public.products
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id() and exists (
  select 1 from public.profiles p where p.id = auth.uid() and p.role in ('owner', 'staff')
));

create policy tenant_all_parties on public.parties
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_invoices on public.invoices
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_invoice_items on public.invoice_items
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_payments on public.payments
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_ledger on public.ledger_entries
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_reminders on public.reminders
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_warehouse on public.warehouses
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_inventory_batches on public.inventory_batches
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_logs on public.activity_logs
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_all_imports on public.bulk_import_jobs
for all using (tenant_id = public.current_tenant_id())
with check (tenant_id = public.current_tenant_id());

create policy tenant_profiles_read on public.profiles
for select using (tenant_id = public.current_tenant_id());

create policy owner_manage_profiles on public.profiles
for all using (tenant_id = public.current_tenant_id() and public.is_owner())
with check (tenant_id = public.current_tenant_id() and public.is_owner());

create policy tenant_read_tenant on public.tenants
for select using (id = public.current_tenant_id());
create policy owner_update_tenant on public.tenants
for update using (id = public.current_tenant_id() and public.is_owner())
with check (id = public.current_tenant_id() and public.is_owner());

-- Helpful views for dashboard/reporting
create or replace view public.v_daily_sales as
select tenant_id, issue_date, sum(total) as total_sales
from public.invoices
where status = 'posted'
group by tenant_id, issue_date;

create or replace view public.v_low_stock as
select p.tenant_id, p.id as product_id, p.name, coalesce(sum(ib.qty), 0) as qty, p.reorder_level
from public.products p
left join public.inventory_batches ib on ib.product_id = p.id and ib.tenant_id = p.tenant_id
group by p.tenant_id, p.id
having coalesce(sum(ib.qty), 0) <= max(p.reorder_level);
