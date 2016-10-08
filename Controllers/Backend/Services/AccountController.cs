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
        public async Task<ActionResult> Index()
        {
            var user = await AppUsers.GetCurrentAsync();
            List<Account> accounts;

            if (user.IsAdministrator)
            {
                accounts = await DAL.Accounts.GetAsync(this.Tenant);
            }
            else
            {
                accounts = await DAL.Accounts.GetNonConfidentialAsync(this.Tenant);
            }

            return this.Ok(accounts);
        }
    }
}