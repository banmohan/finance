using System;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper.Database;
using MixERP.Finance.AppModels;

namespace MixERP.Finance.DAL
{
    public static class DayEnd
    {
        public static async Task<EodStatus> GetStatusAsync(string tenant, int officeId)
        {
            string sql = "SELECT finance.get_value_date(@0::integer) AS value_date, finance.is_eod_initialized(@0::integer, finance.get_value_date(@0::integer)::date) AS is_initialized;";

            if (DbProvider.GetDbType(DbProvider.GetProviderName(tenant)) == DatabaseType.SqlServer)
            {
                sql = "SELECT finance.get_value_date(@0) AS value_date, finance.is_eod_initialized(@0, finance.get_value_date(@0)) AS is_initialized;";
            }

            var awaiter = await Factory.GetAsync<EodStatus>(tenant, sql, officeId).ConfigureAwait(false);
            return awaiter.FirstOrDefault();
        }

        public static async Task InitializeAsync(string tenant, int userId, int officeId)
        {
            string sql = "SELECT * FROM finance.initialize_eod_operation(@0::integer, @1::integer, finance.get_value_date(@1::integer)::date);";

            if (DbProvider.GetDbType(DbProvider.GetProviderName(tenant)) == DatabaseType.SqlServer)
            {
                sql = @"DECLARE @value_date date = finance.get_value_date(@0);
                        EXECUTE finance.initialize_eod_operation @1, @2, @value_date;";

                await Factory.NonQueryAsync(tenant, sql, officeId, userId, officeId).ConfigureAwait(false);
                return;
            }

            await Factory.NonQueryAsync(tenant, sql, userId, officeId).ConfigureAwait(false);
        }
    }
}