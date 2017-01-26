using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.ApplicationState.Models;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper.Database;
using Frapid.Mapper.Query.NonQuery;
using Frapid.Mapper.Query.Select;
using MixERP.Finance.QueryModels;
using MixERP.Finance.ViewModels;

namespace MixERP.Finance.DAL
{
    public static class Reconciliations
    {
        public static async Task ReconcileAsync(string tenant, ReconciliationViewModel model, LoginView meta)
        {
            if (string.IsNullOrWhiteSpace(model.Memo))
            {
                model.Memo = string.Format(I18N.ReconciledByName, meta.Name);
            }

            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                string sql = "SELECT * FROM finance.reconcile_account(@0::bigint, @1::integer, @2::date, @3::text);";

                if (db.DatabaseType == DatabaseType.SqlServer)
                {
                    sql = "EXECUTE finance.reconcile_account @0, @1, @2, @3;";
                }

                await db.NonQueryAsync(sql, model.TransactionDetailId, meta.UserId, model.NewBookDate, model.Memo).ConfigureAwait(false);
            }
        }

        public static async Task<IEnumerable<dynamic>> GetAccountStatementAsync(string tenant, AccountStatementQueryModel model)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                string sql = "SELECT * FROM finance.get_account_statement(@0::date, @1::date, @2::integer, finance.get_account_id_by_account_number(@3), @4::integer) ORDER BY id;";

                if (db.DatabaseType == DatabaseType.SqlServer)
                {
                    sql = "SELECT * FROM finance.get_account_statement(@0, @1, @2, finance.get_account_id_by_account_number(@3), @4) ORDER BY id;";
                }

                return await db.SelectAsync<dynamic>(sql, model.From, model.To, model.UserId, model.AccountNumber, model.OfficeId).ConfigureAwait(false);
            }
        }
    }
}