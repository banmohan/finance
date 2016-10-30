using Frapid.ApplicationState.Cache;
using Microsoft.AspNet.SignalR;

namespace MixERP.Finance.Hubs
{
    public class BaseHub : Hub
    {
        public void Terminate(int counter)
        {
            string tenant = AppUsers.GetTenant();
            this.Clients.All.terminate(counter, tenant);
        }
    }
}