using System.Threading.Tasks;
using Frapid.DataAccess;

namespace MixERP.Finance.DAL
{
    public static class Currencies
    {
        public static async Task<decimal> GetExchangeRateAsync(string tenant, int officeId, string currencyCode)
        {
            const string sql = "SELECT finance.get_exchange_rate(@0, @1);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, officeId, currencyCode).ConfigureAwait(false);
        }
    }
}