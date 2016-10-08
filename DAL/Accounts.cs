using Frapid.Configuration;
using Frapid.Configuration.Db;
using MixERP.Finance.DTO;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MixERP.Finance.DAL
{
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