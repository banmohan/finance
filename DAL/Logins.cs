using System;
using System.Threading.Tasks;
using Frapid.DataAccess;

namespace MixERP.Finance.DAL
{
    public static class Logins
    {
        public static async Task RevokeLoginsAsync(string tenant, int revokedBy)
        {
            const string sql = "UPDATE account.access_tokens SET revoked = @0, revoked_on = @1, revoked_by=@2;";
            await Factory.NonQueryAsync(tenant, sql, true, DateTimeOffset.UtcNow, revokedBy).ConfigureAwait(false);
        }
    }
}