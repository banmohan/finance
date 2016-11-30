using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Finance.DTO;

namespace MixERP.Finance.DAL
{
    public static class FiscalYears
    {
        public static async Task<DateTime> GetValueDateAsync(string tenant, int officeId)
        {
            var dates = await GetFrequencyDatesAsync(tenant, officeId).ConfigureAwait(false);
            return dates.Today;
        }

        public static async Task<FrequencyDates> GetFrequencyDatesAsync(string tenant, int officeId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM finance.frequency_date_view");
                sql.Where("office_id=@0", officeId);

                var awaiter = await db.SelectAsync<FrequencyDates>(sql).ConfigureAwait(false);
                return awaiter.FirstOrDefault();
            }
        }

        public static async Task<IEnumerable<FrequencyDates>> GetFrequencyDatesAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM finance.frequency_date_view");
                return await db.SelectAsync<FrequencyDates>(sql).ConfigureAwait(false);
            }
        }
    }
}