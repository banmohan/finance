using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Finance.DTO;

namespace MixERP.Finance.DAL
{
    public static class Currencies
    {
        public static async Task<decimal> GetExchangeRateAsync(string tenant, int officeId, string currencyCode)
        {
            const string sql = "SELECT finance.get_exchange_rate(@0, @1);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, officeId, currencyCode).ConfigureAwait(false);
        }

        public static async Task<IEnumerable<Currency>> GetCurrenciesAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM core.currencies");
                sql.Where("deleted=@0", false);

                return await db.SelectAsync<Currency>(sql).ConfigureAwait(false);
            }
        }
    }
}