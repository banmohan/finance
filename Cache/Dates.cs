using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.ApplicationState.CacheFactory;
using MixERP.Finance.AppModels;
using MixERP.Finance.DAL;
using MixERP.Finance.DTO;

namespace MixERP.Finance.Cache
{
    public static class Dates
    {
        private const string AppDatesKey = "ApplicationDates";

        public static FrequencyDates GetFrequencyDates(string tenant, int officeId)
        {
            var cache = new DefaultCacheFactory();
            var item = cache.Get<List<FrequencyDates>>(tenant + AppDatesKey);

            return item.FirstOrDefault(x => x.OfficeId == officeId);
        }

        public static List<FrequencyDates> GetFrequencyDates(string tenant)
        {
            var cache = new DefaultCacheFactory();
            return cache.Get<List<FrequencyDates>>(tenant + AppDatesKey);
        }

        public static void SetApplicationDates(string catalog, List<FrequencyDates> applicationDates)
        {
            var cache = new DefaultCacheFactory();
            cache.Add(catalog + AppDatesKey, applicationDates, DateTimeOffset.UtcNow.AddHours(1));
        }

        public static async Task<FrequencyDates> GetFrequencyDatesAsync(string tenant, int officeId)
        {
            var applicationDates = GetFrequencyDates(tenant);
            bool persist = false;

            if (applicationDates == null || applicationDates.Count.Equals(0))
            {
                applicationDates = (await FiscalYears.GetFrequencyDatesAsync(tenant).ConfigureAwait(false)).ToList();
                persist = true;
            }
            else
            {
                for (int i = 0; i < applicationDates.Count; i++)
                {
                    if (applicationDates[i].NewDayStarted)
                    {
                        int officeIdToRefresh = applicationDates[i].OfficeId;

                        applicationDates.Remove(applicationDates[i]);
                        applicationDates.Add(await FiscalYears.GetFrequencyDatesAsync(tenant, officeIdToRefresh).ConfigureAwait(false));
                        persist = true;
                    }
                }
            }

            if (persist)
            {
                SetApplicationDates(tenant, applicationDates);
            }

            return applicationDates.FirstOrDefault(c => c.OfficeId.Equals(officeId));
        }
    }
}