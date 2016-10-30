using System;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Finance.AppModels;

namespace MixERP.Finance.DAL
{
    public static class DayEnd
    {
        public static async Task<EodStatus> GetStatusAsync(string tenant, int officeId)
        {
            const string sql = "SELECT finance.get_value_date(@0::integer) AS value_date, finance.is_eod_initialized(@0::integer, finance.get_value_date(@0::integer)::date) AS is_initialized;";
            var awaiter = await Factory.GetAsync<EodStatus>(tenant, sql, officeId).ConfigureAwait(false);
            return awaiter.FirstOrDefault();
        }

        public static async Task InitializeAsync(string tenant, int userId, int officeId)
        {
            const string sql = "SELECT * FROM finance.initialize_eod_operation(@0::integer, @1::integer, finance.get_value_date(@1::integer)::date);";
            await Factory.NonQueryAsync(tenant, sql, userId, officeId).ConfigureAwait(false);
        }

        public static async Task InitializeAsync(string tenant, int userId, int officeId, DateTime valueDate)
        {
            const string sql = "SELECT * FROM finance.initialize_eod_operation(@0::integer, @1::integer, @2::date);";
            await Factory.NonQueryAsync(tenant, sql, userId, officeId, valueDate).ConfigureAwait(false);
        }
    }
}