using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using MixERP.Finance.AppModels;
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
                var awaiter = await db.Query<FrequencyDates>().Where(x => x.OfficeId == officeId).FirstOrDefaultAsync().ConfigureAwait(false);
                return awaiter;
            }
        }

        public static async Task<List<FrequencyDates>> GetFrequencyDatesAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var awaiter = await db.Query<FrequencyDates>().ToListAsync().ConfigureAwait(false);

                return awaiter;
            }
        }
    }
}