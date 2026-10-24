THE GRATEFUL COLLECTIVE — DEPLOYMENT PACKAGE

Contents include the existing website and an additive Supabase migration. Existing app sections, design, and records are retained. Do not delete existing Supabase tables.

DEPLOY
1. Download and unzip the complete package.
2. In Supabase Dashboard > SQL Editor, run SUPABASE_MIGRATION.sql once. It adds missing pupil fields and the new audit, reconciliation, transfer, and shop-stock tables. It does not drop existing records.
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
- Stock register supports separate TUCK SHOP, SALOON and GROCERY products, quantity, unit cost, selling price, sales, restocking and item-linked expenses. Stock movements are separate from the existing accounting transaction list to avoid automatic double-counting.
- Export secure backup downloads JSON for supported tables. Restore JSON upserts records belonging to the signed-in user; it can overwrite matching IDs. Always export a fresh backup first.

RECOVERY
1. Keep JSON backups in private, access-controlled storage; they contain financial and personal data.
2. To recover, sign in to the same Supabase account, open Dashboard > Export secure backup first (safety copy), then choose Restore JSON backup and select the backup file.
3. Restore upserts table-by-table in dependency order. If an error occurs, some earlier tables may already have restored; check the named table and current records before retrying. Verify pupils, rentals, transactions, payables, stock, and balances afterwards.
4. For a full database disaster, restore the Supabase project/database from a Supabase-managed database backup or point-in-time recovery if enabled, then deploy these files and rerun the migration. A JSON export is an application-level backup, not a replacement for Supabase's database backup.

ACCOUNTING NOTES
- Reconciliation figures are only as accurate as the records and opening balances entered. Compare them with real bank/mobile-money statements and a physical cash count.
- A transfer must be entered only in the Transfers form, not again as income or expense.
- Stock profit is an estimate based on current product unit cost and recorded sales; update unit costs when purchase costs change. Stock movements do not create entries in the existing accounting transactions table automatically.
- Before live use, confirm that existing Supabase RLS policies isolate each user's records and that only authorized staff have accounts.

IMPORTANT TRANSFER DISTINCTION
The existing Pupils section uses category “Transfer” for a school pupil-transfer/payment record; those existing records remain valid school receipts and are not suppressed. The new Dashboard “Record a transfer” form is specifically for moving funds between Bank, Cash, Airtel Money and MTN MoMo. Use that form for channel-to-channel movements; these are stored separately and never added to income or expenses.
