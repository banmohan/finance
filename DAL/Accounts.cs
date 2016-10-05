using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using MixERP.Finance.DTO;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MixERP.Finance.DAL
{
    public static class CashRepositories
    {
        public static async Task<decimal> GetBalanceAsync(string tenant, string cashRepositoryCode, string currencyCode)
        {
            const string sql = "SELECT finance.get_cash_repository_balance(finance.get_cash_repository_id_by_cash_repository_code(@0), @1);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, cashRepositoryCode, currencyCode).ConfigureAwait(false);
        }
    }
    public static class Currencies
    {
        public static async Task<decimal> GetExchangeRateAsync(string tenant, int officeId, string currencyCode)
        {
            const string sql = "SELECT finance.get_exchange_rate(@0, @1);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, officeId, currencyCode).ConfigureAwait(false);
        }
    }

    public static class Accounts
    {
        public static async Task<List<Account>> GetAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var awaiter =
                    await
                        db.Query<Account>()
                            .Where(x => !x.Deleted).ToListAsync().ConfigureAwait(false);

                return awaiter;
            }
        }

        public static async Task<List<Account>> GetNonConfidentialAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var awaiter =
                    await
                        db.Query<Account>()
                            .Where(x => !x.Confidential && !x.Deleted).ToListAsync().ConfigureAwait(false);

                return awaiter;
            }
        }
    }
}