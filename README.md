# Karobar OS (Next.js + Supabase)

A mobile-first SaaS starter for Pakistani retail/wholesale businesses with:
- Inventory management
- Fast billing
- Khata/ledger tracking
- Multi-tenant access control
- Role-based security

## Why this design works for shopkeepers
- Urdu + English microcopy and large tap targets.
- Dashboard focused on 4 numbers only.
- Quick action buttons for daily tasks.
- Phone number centric customer/supplier records.
- Editable records: invoices, products, khata entries, and payments all support update workflows in the schema.

## Stack
- Next.js App Router
- Supabase (Auth + Postgres + RLS)
- TypeScript

## MVP Feature Map
### Phase 1 (included in current foundation)
- Authentication (email OTP)
- Protected dashboard route
- Schema for Inventory, Billing, Khata
- Multi-tenant + role model (Owner/Staff/Accountant)

### Phase 2+ (schema-ready)
- Reporting views
- Supplier/payable tracking
- Reminder queue
- Staff audit trail
- Bulk import job tracking for Excel inventory uploads

## Setup
1. Copy `.env.example` to `.env.local`.
2. Fill Supabase variables.
3. Run schema in Supabase SQL editor using `supabase/schema.sql`.
4. Install and run:

```bash
npm install
npm run dev
```

## Supabase security checklist
- Row-level security enabled on tenant data tables.
- `current_tenant_id()` helper prevents cross-tenant access.
- Owner-only policy for profile/tenant management.
- App roles (`owner`, `staff`, `accountant`) enforced by policies.

## Data safety and backups
- Use Supabase daily backups + point-in-time recovery.
- Keep `activity_logs` immutable from UI except owner tools.
- Export options to build next:
  - PDF invoice print endpoint.
  - CSV/Excel export for products, ledgers, and sales.

## Printing and search strategy
- Printing: add printable invoice template route (`/print/invoice/[id]`) and use browser print.
- Search: indexes added on products and parties for fast mobile search.

## Next implementation tasks
1. Billing editor (calculator layout + draft autosave).
2. Inventory stock in/out forms with barcode scan.
3. Khata timeline UI with due reminder action.
4. Excel import parser for products into `bulk_import_jobs`.
5. WhatsApp deep-link reminder button.
