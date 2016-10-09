using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using MixERP.Finance.DTO;

namespace MixERP.Finance.DAL
{
    public static class Accounts
    {
        public static async Task<long> GetAccountIdByAccountNumberAsync(string tenant, string accountNumber)
        {
            const string sql = "SELECT finance.get_account_id_by_account_number(@0)";
            return await Factory.ScalarAsync<long>(tenant, sql, accountNumber).ConfigureAwait(false);
        }

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

        public static async Task<bool> IsCashAccountAsync(string tenant, string accountNumber)
        {
            const string sql = "SELECT * FROM finance.accounts WHERE account_master_id=10101 AND account_number=@0;";
            var awaiter = await Factory.GetAsync<Account>(tenant, sql, accountNumber).ConfigureAwait(false);
            return awaiter.Count().Equals(1);
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