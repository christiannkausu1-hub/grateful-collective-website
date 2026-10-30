THE GRATEFUL COLLECTIVE — COMPANY ACCOUNTS PLATFORM

This is a Grateful Collective company website / online accounts management application. School operations are one business section, alongside rentals, shops, payroll, expenses, payables and reports. The product is not presented as a standalone school website.

THE GRATEFUL COLLECTIVE — DEPLOYMENT PACKAGE

Contents include the existing website and an additive Supabase migration. Existing app sections, design, and records are retained. Do not delete existing Supabase tables.

DEPLOY
1. Download and unzip the complete package.
2. Database migrations: back up the Supabase project first. If not already applied, run SUPABASE_MIGRATION.sql / GC_ENHANCEMENTS.sql as appropriate for your existing deployment. Then run GC_SHOPS_UPGRADE.sql if it has not already been applied. After that, run GC_SHOPS_ATOMIC_OPERATIONS.sql in Supabase Dashboard > SQL Editor. The atomic operations migration makes each shop sale, credit payment, cancellation and stock adjustment a single database transaction, including stock and accounting updates. Run GC_RESTORE_SEQUENCE_FIX.sql after the atomic operations file; the atomic operations file also installs the owner-checked audit-history restore RPC. Both migrations are additive and do not drop existing tables or records.
3. Commit/upload the package contents to the ROOT of the connected GitHub repository (replace the existing files when prompted). Cloudflare Pages should redeploy automatically.
4. Wait for the Cloudflare Pages deployment to finish, then open the website and sign in. If the PWA shows an old version, close it and reopen; service worker update checking is enabled.
5. Test each feature using a small test record before relying on it for bookkeeping.

NEW FEATURES
- Dashboard totals combine accounting transactions, rental receipts, school lunch/test receipts, paid payroll and supplier payments without adding unpaid supplier balances to cash movement.
- Reconciliation shows recorded movement, opening balance, actual balance and difference by Bank, Cash, Airtel Money and MTN MoMo.
- Transfers are recorded separately and adjust channel balances without being counted as income/expenses.
- Reports use the selected date range for accounting transactions, rent receipts, lunch/test receipts, payroll and supplier payments.
- Overdue rent periods and overdue supplier invoices are surfaced in the dashboard arrears panel. School fee balances remain in the pupil register using the configured grade fees and recorded amount paid.
- Database triggers record INSERT, UPDATE and DELETE events for supported existing and new tables. Audit rows contain old/new row values when available.
- Stock register supports separate TUCK SHOP, SALOON and GROCERY products, quantity, unit cost, selling price, sales, restocking and item-linked expenses. Shop sales, credit payments and cancellations use database RPC transactions so related stock, receipt, payment and accounting writes succeed or roll back together. Stock movements are separate from the existing accounting transaction list to avoid automatic double-counting.
- Export secure backup downloads JSON for supported tables. Restore JSON upserts records belonging to the signed-in user; it can overwrite matching IDs. Always export a fresh backup first.

RECOVERY
1. Keep JSON backups in private, access-controlled storage; they contain financial and personal data.
2. To recover, sign in to the same Supabase account, open Dashboard > Export secure backup first (safety copy), then choose Restore JSON backup and select the backup file.
3. Restore upserts table-by-table in dependency order. If an error occurs, some earlier tables may already have restored; check the named table and current records before retrying. Verify pupils, rentals, transactions, payables, stock, and balances afterwards.
4. For a full database disaster, restore the Supabase project/database from a Supabase-managed database backup or point-in-time recovery if enabled, then deploy these files and rerun the migration. A JSON export is an application-level backup, not a replacement for Supabase's database backup.

ACCOUNTING NOTES
- Reconciliation figures are only as accurate as the records and opening balances entered. Compare them with real bank/mobile-money statements and a physical cash count.
- A transfer must be entered only in the Transfers form, not again as income or expense.
- Stock profit uses the historical unit cost saved on each sale item and excludes cancelled sales; existing stock movement values remain dependent on accurate original entries. Stock movements do not create entries in the existing accounting transactions table automatically.
- Before live use, confirm that existing Supabase RLS policies isolate each user's records and that only authorized staff have accounts.

IMPORTANT TRANSFER DISTINCTION
The existing Pupils section uses category “Transfer” for a school pupil-transfer/payment record; those existing records remain valid school receipts and are not suppressed. The new Dashboard “Record a transfer” form is specifically for moving funds between Bank, Cash, Airtel Money and MTN MoMo. Use that form for channel-to-channel movements; these are stored separately and never added to income or expenses.

MOBILE UX UPDATE (2026-10-24)
- Added a role-aware mobile bottom navigation bar for Home, Records, Add/quick access and Menu.
- Added a dimmed backdrop for the slide-out menu, tap-outside dismissal, Escape-key dismissal and expanded-state accessibility labels.
- Tables rendered through the shared table helper now include column labels and display as stacked, readable record cards on narrow phone screens; desktop tables remain tables.
- Improved phone visibility for payment-channel cards, pupil summary cards and class-count tiles.
- Simplified mobile form actions, expanded touch targets, preserved visible keyboard focus, supported reduced-motion preferences and respected phone safe-area insets.
- Clarified dashboard labels from “Total positive/negative” to “Total income/expenses”.
- This UI-only update does not change the database schema, Supabase data logic or role permissions. No new SQL migration is required for these mobile changes.
- Test with administrator, school_staff and shop_manager accounts on a narrow screen before deployment. Confirm that each role only sees its permitted sections and that Add/Records shortcuts behave as expected.


SECTION CONNECTIVITY UPDATE (2026-10-24)
- Preserved the existing blue brand palette.
- Added a responsive Connected Sections strip to each workspace section with shortcuts to related permitted sections.
- Shortcuts are role-aware and update after sign-in/role navigation; they use the existing page navigation and do not alter records or database schema.
- Inline JavaScript syntax checks and ZIP integrity checks passed. Real-device/browser interaction testing and live deployment have not been performed.


CONNECTED SECTION NAVIGATION UPDATE (2026-10-24)
- Added contextual related-section shortcuts to Dashboard, Pupils, Lunch payments, Tests, Workers & payroll, Expenses, Rentals, Shops, Trade payables, Reports, and User management.
- Shortcuts use the existing page navigation and are filtered by the signed-in user's allowed sections.
- Styling retains the existing blue palette and adapts to small screens.
- No database schema or stored records were changed.
- Test the updated build in your staging/deployment environment before relying on it for live records.


CONSOLIDATED USABILITY PACKAGE (2026-10-24)
- Combines the phone navigation, responsive layouts, table-to-card presentation on narrow screens, clearer dashboard financial summaries, accessibility improvements, and contextual connected-section shortcuts in one build.
- Keeps the existing blue palette, existing app features, Supabase configuration placeholders, and role-based page permissions.
- Consolidates section connectivity to one implementation to avoid duplicate shortcut strips.
- Bumped the service-worker cache version so a new deployment can replace previously cached static files.
- No database schema changes are required for these UI/navigation refinements.
- This package has been syntax-checked and archive-checked; real-device/browser testing and live deployment are still required.


SCHOOL EXPENSES + MOBILE NAV UPDATE (2026-10-24)
- Removed the generated “Go to related section” shortcut panels.
- Mobile bottom navigation now contains only Home and Menu; Add and Records are removed.
- Added School > School expenses with categories for teaching materials, stationery, art supplies, cleaning supplies, utilities, repairs, transport, first aid/hygiene, furniture/equipment, water/sanitation and other costs.
- School expenses are stored as regular transactions with area=School and type=Expense, so they reduce net balance and are included in period expense totals without a separate database table.
- Added a school-expenses total in Reports and listed expenses in the school operations detail table as negative amounts.
- Improved the mobile pupils-per-class grid to use wider tiles for clearer class labels.
- Service-worker cache version bumped to v5 to help browsers update.
- Please deploy the complete extracted package. This package has not been tested against your live Supabase project; verify permissions and test with a small sample transaction before normal use.


MERGED MOBILE + RELATED SECTION UPDATE (2026-10-24)
- Restores the “GO TO RELATED SECTION” panel contextually on relevant pages.
- Removes the stray “connected section shortcuts: keep related workflows one tap away” message from the page bottom.
- Bottom mobile navigation remains simplified to Home and Menu; Add and Records are not restored.
- Widens the pupil class-count area on mobile, using three columns on typical phones and two on very narrow screens.
- Service-worker cache version bumped to v6 to help browsers load this deployment.


PUPIL MANAGEMENT ADDITIONS (2026-10-24)
- Extended pupil profiles with admission number, date of birth, guardian name/email, address, emergency contacts and restricted welfare notes.
- Added attendance register with per-date Present/Absent/Late/Excused status.
- Added CSV pupil import preview; only new valid rows are inserted.
- Added pupil fee statement summary and CSV export based on existing records.
- IMPORTANT: run the updated SUPABASE_MIGRATION.sql in Supabase SQL Editor before using new profile columns or attendance. Back up first and verify RLS policies.
- Academic marks/report cards and class capacity controls are intentionally not added, following the requested exclusions.
- CSV import is basic comma-separated format; test with a small file first. No guardian portal or file upload storage is enabled in this update.

REPORTS ENHANCEMENTS (2026-10-24)
- Reports includes searchable/filterable company transaction analysis by date range, business area and transaction type.
- Shows filtered income, expenses and net, expense-category breakdown, detailed transactions, CSV export and print support.
- These totals are explicitly limited to the filtered transactions list; separate rent/lunch/test/payroll records remain in their dedicated report summaries to avoid double-counting.
- Verify financial totals against source records after deployment; this package has not been tested against the live database.


SHOPS MANAGEMENT UPGRADE (2026-10-24)
- Treats TUCK SHOP, SALOON and GROCERY as separate shop entities with shop-specific stock and sales filters.
- Product register includes SKU/product code, barcode, category, supplier, unit cost, selling price, stock quantity and low-stock threshold; search, shop/status filters, edit basics and CSV stock export are included.
- Low-stock and out-of-stock alerts; damage/expiry quantity adjustments are recorded and reduce stock. Stock purchase/restock notes can include the supplier; supplier invoices/payments remain in Trade payables to avoid double-counting.
- Sales entry supports discounts, payment methods, customer details, partial payments/credit, receipt numbers, printable receipts, sales search and CSV export. Stock reduces when a sale is saved.
- Customer register, credit-sale balances and credit-payment records are included. Amounts actually received from sales and credit payments are posted to company Shop income transactions; outstanding credit is not treated as cash received. Cancelled sales restore stock and attempt to post a refund expense for the amount recorded as paid. Verify the actual refund/payment channel.
- Shop sales, stock movements and company accounting transactions remain distinct records. Check for duplicate manual entries before use; never record the same receipt a second time through the generic transaction form.
- Apply GC_SHOPS_UPGRADE.sql after backing up the database. Test with a small sale, credit payment, cancellation and stock adjustment before live use. This package has not been tested against your live Supabase database or payment workflows.


PAYROLL MANAGEMENT UPDATE (2026-10-24)
- Expanded employee profiles with department/business area, employment type, pay frequency, contact details, start date and optional payment-provider/account fields. Includes the three separate shop entities TUCK SHOP, SALOON and GROCERY.
- Payroll preparation now records overtime, bonuses, commission, gross pay, manual PAYE/NAPSA/NHIMA values, advance deductions, other deductions, payment date/reference and approval timestamp. Net pay is calculated from the entered values. Statutory amounts are NOT auto-certified; verify current Zambian requirements before approval.
- Added payroll status progression Pending Review -> Approved -> Paid, printable payslips, enriched CSV export and payroll audit fields.
- Added staff advance/loan register with repayment tracking, leave request register with approve/reject actions, and attendance/hours/overtime register. These use separate tables and do not automatically change payroll; apply approved deductions and attendance adjustments to the relevant payroll run.
- IMPORTANT: Back up Supabase first, then run the updated SUPABASE_MIGRATION.sql. It adds columns and tables without dropping existing records. Confirm RLS policies and test with sample employee, payroll, advance, leave and attendance records before live use.
- Payroll includes sensitive employee data. Restrict account access, avoid sharing exports, and confirm your deployment's role policies before storing bank/payment details.
- Validation performed: ZIP archive integrity and targeted JavaScript syntax checks. No live Supabase/browser end-to-end test has been performed.

TRADE PAYABLES UPGRADE (2026-10-24)
- Added supplier opening balances and active/inactive supplier status.
- Invoice records now support business-area tagging (Administration, School, TUCK SHOP, SALOON, GROCERY, Rentals, Other), subtotal, discount, tax, credit terms and an optional invoice/statement URL reference.
- Invoice total is calculated from subtotal minus discount plus tax. The app warns about duplicate invoice numbers for the same supplier before saving.
- Added due-in-seven-days and paid-this-month dashboard cards, filters by business area/status, and ageing buckets (Current, 1–30, 31–60, 61–90 and 90+ days) with CSV export.
- Payment entries remain allocated to their invoice and the app keeps the existing policy of not automatically creating duplicate accounting expenses. Opening balances are supplier-level balances and do not have individual due dates or payment allocations.
- IMPORTANT: back up your database, then run GC_PAYABLES_UPGRADE.sql in Supabase SQL Editor before using the new supplier/invoice fields. Test with sample records first and confirm supplier balances against source documents. No live Supabase/browser end-to-end test has been performed.


EXPENSES MANAGEMENT UPGRADE (October 2026)
-----------------------------------------
The Expenses page now includes a company-wide expense management centre: pending/approved/rejected/paid workflow, business-area and category tagging, private receipt/invoice attachments, invoice-reference duplicate checks, recurring templates with manual generation of due items, petty cash book, department/category monthly budgets, CSV export, print view and date/area report filters. Approved expenses are posted once to the existing transactions table and linked by transaction id; approval status changes do not create a second posting when a transaction id is already stored. Dashboard cards show month-to-date approved, pending, overdue and paid totals.

DATABASE SETUP
1. Back up your Supabase database.
2. Apply the existing migrations in the documented order, then run GC_EXPENSES_UPGRADE.sql in the Supabase SQL Editor. This creates four additive tables, owner-scoped row-level security policies, an audit trigger where the existing audit function is installed, and a private storage bucket for attachments.
3. Reload the website and sign in as an administrator. Test with sample records before entering real financial data.

Recurring templates are deliberately not auto-posted; a user must click Generate due items, review the generated pending items and approve them. Attachments are private and opened using a short-lived signed URL. Payroll and Trade Payables remain in their dedicated modules; avoid recording the same supplier invoice again in the general expense register. Payroll is included as a separate report source and is not automatically duplicated into expense entries.

Validation note: archive integrity and JavaScript syntax can be checked locally, but live Supabase/browser behavior must be verified in the user's project after the migration is applied.

FIXED ASSETS UPDATE (October 2026)
----------------------------------
The update adds an administrator-only Fixed assets section to the existing app. It records asset name, category, purchase date, purchase cost, quantity, condition, location and notes, and supports search, viewing, deletion and CSV export.

IMPORTANT DATABASE STEP
Before using Fixed assets, open Supabase Dashboard -> SQL Editor and run the separate file GC_FIXED_ASSETS.sql from this package. It creates only the new gc_fixed_assets table and administrator-only Row Level Security policies. It does not alter or delete existing pupil, payroll, shop, expense, rental or other records. The policy expects the existing public.gc_user_roles table and its role values (administrator, school_staff, shop_manager), matching this app's current role setup. Do not put a Supabase service-role key in browser code.

PUPIL / LUNCH CHANGES
- The lunch summary heading reads “LUNCH FOR TODAY”.
- Medical / welfare notes remain optional.
- Newcomer document checkboxes are kept in their own NEWCOMER REQUIREMENTS slot in the Add pupil form.
- The Pupil Register shows a green tick only when every required item is present in the saved requirements_checklist; otherwise it shows a red X for newcomers. The register no longer displays a second editable checklist.

PUBLISHING
1. Back up the current site and database before publishing.
2. Run GC_FIXED_ASSETS.sql in Supabase SQL Editor and confirm it completes successfully.
3. Upload the contents of this ZIP to the existing GitHub repository, preserving the repository's current folder structure. Commit and push the changes so the existing Netlify/Cloudflare deployment builds from GitHub.
4. Sign in with an administrator account, open Fixed assets, and save a small test asset. Confirm it appears in the register and can be searched/exported.
5. Confirm school staff and shop manager accounts cannot open Fixed assets. Keep existing Supabase URL and publishable/anon key settings unchanged.


PUPIL YEAR FIELD: The updated Add Pupil form saves school_year. Run the updated SUPABASE_MIGRATION.sql in the Supabase SQL Editor before deploying this version. The pupil and grade-fee forms now retain entered values when Supabase returns an error and only clear after a successful save.


LATEST SCHOOL / PAYROLL UPDATE
Run the updated SUPABASE_MIGRATION.sql in Supabase SQL Editor before deploying. This adds the pupil payment_method field. The pupil register now supports editing existing pupil profiles. PAYE and NHIMA input fields have been removed from the payroll form; new payroll records save those fields as zero for compatibility with existing database columns.

RENTAL REGISTER / RENT DUE FIX
If the rental register does not save new units or the rent due/payment tables are empty, open Supabase Dashboard -> SQL Editor and run GC_RENTALS_FIX.sql from this package once. It only adds missing rental columns and backfills missing start dates; it does not delete existing rental records or payments. Then publish the updated website files.


FOLLOW-UP REQUIRED SUPABASE MIGRATIONS
Run GC_ATOMIC_RENT_PAYMENT.sql in Supabase SQL Editor before using the updated rent-payment form. It records rental_payments and transactions atomically in one PostgreSQL transaction.
GC_TEACHER_NAPSA_RETURN.sql creates the separate teacher return table and owner-only RLS policies. Run it if the teacher return register is required and has not already been installed.


LATEST AUDIT REPAIR NOTES (30 OCTOBER 2026)
- Shop sales and credit-payment SQL validate required dates, payment methods and two-decimal money values. Credit sales cannot silently record an initial payment against an unknown channel.
- Credit payments preserve the original sale payment method; cancellation refunds initial and later credit payments separately using the recorded payment channels (initial credit-sale payments must be recorded through the credit-payment form).
- Sale cancellation now fails atomically if the original stock movement cannot be found or stock/sale updates fail.
- Shop, stock and backup table reads use paginated range queries instead of fixed 1,000/1,500 row caps. A failed read is surfaced rather than displayed as an empty table.
- Backup format version 2 includes fixed assets, teacher NAPSA returns, payroll advances, leave and attendance, and the existing expense ledgers.
- Restore now includes those tables and calls GC_RESTORE_SEQUENCE_FIX.sql to resynchronise identity sequences after explicit-ID upserts.
- Channel balances use the transactions ledger plus transfers only, avoiding duplicate counting of payments that already create transaction rows.

SQL ORDER
1. Run GC_ENHANCEMENTS.sql.
2. Run GC_SHOPS_UPGRADE.sql.
3. Run GC_SHOPS_ATOMIC_OPERATIONS.sql.
4. Run GC_RESTORE_SEQUENCE_FIX.sql (needed for the restore sequence-repair RPC).
5. Run other module migrations only if their corresponding modules are used: GC_EXPENSES_UPGRADE.sql, GC_FIXED_ASSETS.sql, GC_TEACHER_NAPSA_RETURN.sql, GC_RENTALS_FIX.sql, GC_PAYABLES_UPGRADE.sql and SUPABASE_MIGRATION.sql. Apply prerequisites documented at the top of each SQL file.


LATEST SHOP / BACKUP HARDENING (30 OCTOBER 2026)
- The shop upgrade only replaces the original autogenerated movement-type check; custom check constraints are preserved and the migration is safe to re-run.
- Stock restock, damage and expiry movements use one owner-scoped RPC so movement and quantity updates commit together. Manual sales/expenses are disabled; sales use the atomic receipt workflow, and damage/expiry create matching expense transactions.
- Customer duplicates are blocked in the form and by a normalized unique index when no historical duplicates exist. If duplicates already exist, the migration preserves them and the form still blocks ordinary duplicate submissions.
- Receipts print every line item and historical cost of goods sold uses each sale item's saved unit cost. Cancelled sales are excluded.
- Cancellation asks for the actual refund channel; later credit repayments are refunded using their recorded payment channels.
- Sales, movement and audit views no longer truncate at fixed display counts; their underlying reads are paginated.
- Backup JSON is validated before download and records app/format version metadata. Restore validates the format and table arrays, previews record counts, restores audit history through an owner-checked RPC, repairs identity sequences, refreshes affected sections and reports counts per table.
- Restore remains table-by-table, not one database-wide transaction. If interrupted, earlier tables may already have been restored; retrying the same backup is idempotent for matching IDs.
- Apply SQL in this order: GC_ENHANCEMENTS.sql, GC_SHOPS_UPGRADE.sql, GC_SHOPS_ATOMIC_OPERATIONS.sql, GC_RESTORE_SEQUENCE_FIX.sql.
- Static JavaScript and ZIP checks are performed on this package. No live Supabase execution, RLS test or real-browser workflow test is claimed.


ADDITIONAL SHOP VALIDATION UPDATE (30 OCTOBER 2026)
- Credit sales are recorded with zero initial payment; later payments are entered separately so their channels are captured. Non-credit sales must be paid in full.
- Cancelled credit sales refund all later credit repayments, including sales with zero initial payment.
- Product creation records opening stock movement atomically; inactive products cannot be sold.
- Product names, product codes and barcodes are protected against new duplicates when historical data permits safe unique indexes.
- Stock movement value/quantity precision and amount calculations are validated.
- Shop revenue and profit are based on completed receipts and saved historical item costs, with damage/expiry losses shown separately.
- Reconciliation date/value validation and shop-credit arrears have been improved.
- Pupil fee waivers are not inferred because no verified fee-adjustment schema/rules exist in the supplied project files. Supplier restocks still need supplier invoices/payables recorded through Trade Payables.

LATEST AUDIT REPAIRS
The package includes additional fixes for CSV parsing/validation, pupil attendance marking, teacher-return refresh resilience, receipt printing, product edit validation, normalized customer phone matching, sale financial consistency and idempotent audit restore. Apply the updated GC_SHOPS_ATOMIC_OPERATIONS.sql again after GC_ENHANCEMENTS.sql and GC_SHOPS_UPGRADE.sql; it is designed to be re-runnable. Run GC_RESTORE_SEQUENCE_FIX.sql for restore sequence repair. Back up the live Supabase project before applying migrations.

LATEST AUDIT REPAIR NOTES (30 OCT 2026)
The current package includes direct sale-to-stock-movement links, reasoned sale cancellation, original-channel credit refunds, historical opening-stock dates, product cost history, stronger backup validation/preview, movement date filtering, and administrator-only identity sequence repair. The updated SQL is included in the package. Do not run migrations until the package updates are complete and the user explicitly confirms this is the final ZIP update.


LATEST ADDITIONAL AUDIT REPAIRS (2026-10-30)
- Payroll cannot be marked Paid without an actual payment date; payment dates cannot predate the pay period.
- Teacher NAPSA return account, year and month are visible and editable rather than silently hardcoded; return period and gross wage are validated. Contribution-rate rules remain unchanged and should be checked against the employer's official NAPSA guidance before use.
- Backup format version 3 records unavailable optional tables explicitly, still requires core tables, and restore accepts legacy version 2 backups. Restore produces a per-table result report and skips optional tables that were not included. Restore remains sequential, not database-wide atomic.
- Shop sale items retain original selling price and flag manual price overrides. Credit payments store their accounting transaction reference and remaining balance.
- A dedicated shop refund ledger records each refund against its source sale/payment, channel, date, reason and accounting transaction. Cancellation is blocked when the sale has missing item/product links or the refund date predates a payment.
- Stock movements now retain before/after quantities; future-dated manual movements and restocking archived products are rejected.
- Audit restore batches are limited to 5,000 entries. Identity-sequence repair includes the refund ledger.
- These changes are static package updates only. No Supabase SQL has been executed and no live RLS/database/browser test is claimed.


LATEST AUDIT REPAIR UPDATE (30 OCTOBER 2026)
- Teacher NAPSA employer account number is no longer prefilled with a hardcoded account value. Each return requires the account number to be entered.
- Teacher return employer and employee contribution rates are separately editable per return and saved with the record. The application does not certify statutory compliance; confirm applicable rates, caps and wage definitions with NAPSA before filing.
- Teacher return RLS now requires administrator role and a worker owned by the same account whose job title is Teacher or Owner.
- Administrator data refresh now retains the last successfully loaded module data when an individual query fails, rather than replacing that module's data with an empty list. Failed refreshes are logged.
- Dashboard payroll movements now use actual payment_date when available and avoid adding a payroll row that already has a linked transaction_id.
- Service-worker cache advanced to v14 so deployed clients request the updated application shell.
- Identity sequence repair now reports individual table failures as database warnings and fails clearly when the role table needed for administrator verification is absent.
- No SQL was run. Live schema compatibility, RLS behaviour and browser workflows remain unverified.
