using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Frapid.ApplicationState.Models;
using Frapid.Framework.Extensions;
using MixERP.Finance.Cache;
using MixERP.Finance.DAL;
using MixERP.Finance.DTO;
using MixERP.Finance.Routines;
using MixERP.Social.Helpers;

namespace MixERP.Finance.Models
{
    public static class EodProcessing
    {
        private static void RevokeLogins(string tenant, int revokedBy)
        {
            ThreadPool.QueueUserWorkItem(async delegate
            {
                await Task.Delay(new TimeSpan(0, 2, 0)).ConfigureAwait(true);
                await Logins.RevokeLoginsAsync(tenant, revokedBy).ConfigureAwait(true);
            }, null);
        }

        public static async Task<bool> StartNewDayAsync(string tenant, int officeId)
        {
            SuggestDateReload(tenant, officeId);

            var type = typeof(IDayEndRoutine);
            var routines = type.GetTypeMembersNotAbstract<IDayEndRoutine>().OrderBy(x => x.SequenceId);

            foreach (var routine in routines)
            {
                await routine.PerformAsync(tenant, officeId).ConfigureAwait(false);
            }

            return true;
        }

        public static void SuggestDateReload(string tenant, int officeId)
        {
            var applicationDates = Dates.GetFrequencyDates(tenant);

            var model = applicationDates?.FirstOrDefault(c => c.OfficeId.Equals(officeId));

            if (model != null)
            {
                var item = model.Clone() as FrequencyDates;

                if (item != null)
                {
                    item.NewDayStarted = true;

                    applicationDates.Add(item);
                    applicationDates.Remove(model);
                }


                Dates.SetApplicationDates(tenant, applicationDates);
            }
        }

        public static async Task InitializeAsync(string tenant, LoginView meta)
        {
            await DayEnd.InitializeAsync(tenant, meta.UserId, meta.OfficeId).ConfigureAwait(true);
            RevokeLogins(tenant, meta.UserId);
            await SendNotificationAsync(tenant, meta).ConfigureAwait(false);
        }

        private static async Task SendNotificationAsync(string tenant, LoginView meta)
        {
            string message = I18N.EODOperationBegunNow;
            await FeedHelper.CreateNotificationFeedAsync(tenant, meta.OfficeId, message, "MixERP.Finance", meta).ConfigureAwait(false);
        }
    }
}