using System.Threading;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.Authorization.Helpers;
using Microsoft.AspNet.SignalR;
using MixERP.Finance.AppModels;
using MixERP.Finance.DAL;
using MixERP.Finance.DAL.Eod;

namespace MixERP.Finance.Hubs
{
    public class DayOperationHub : Hub
    {
        public void PerformEod()
        {
            if (!this.IsValidRequest())
            {
                this.Clients.Caller.getNotification("Access is denied", "Access is denied");
                return;
            }


            var operation = new EodPerformer();
            operation.NotificationReceived += this.EOD_NotificationReceived;

            string tenant = AppUsers.GetTenant();
            long loginId = HubAuthorizationManger.GetLoginIdAsync(tenant, this.Context).Result;

            operation.Perform(tenant, loginId);
        }

        private void EOD_NotificationReceived(object sender, EodEventArgs e)
        {
            this.Clients.Caller.getNotification(e.Message, e.Condition);
        }

        private bool IsValidRequest()
        {
            Thread.Sleep(2000);

            if (this.Context == null)
            {
                this.Clients.Caller.getNotification("Access is denied");
                return false;
            }

            string tenant = AppUsers.GetTenant();
            long loginId = HubAuthorizationManger.GetLoginIdAsync(tenant, this.Context).Result;
            var meta = AppUsers.GetCurrent(tenant, loginId);

            if (loginId <= 0)
            {
                this.Clients.Caller.getNotification("Access is denied");
                return false;
            }

            if (!meta.IsAdministrator)
            {
                return false;
            }

            return true;
        }
    }
}