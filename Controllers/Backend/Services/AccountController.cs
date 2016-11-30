using Frapid.ApplicationState.Cache;
using MixERP.Finance.DTO;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Services
{
    public class AccountController : FinanceDashboardController
    {
        [Route("dashboard/finance/chart-of-accounts/list")]
        public async Task<ActionResult> IndexAsync()
        {
            var user = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            IEnumerable<Account> accounts;

            if (user.IsAdministrator)
            {
                accounts = await DAL.Accounts.GetAsync(this.Tenant).ConfigureAwait(true);
            }
            else
            {
                accounts = await DAL.Accounts.GetNonConfidentialAsync(this.Tenant).ConfigureAwait(true);
            }

            return this.Ok(accounts);
        }
    }
}