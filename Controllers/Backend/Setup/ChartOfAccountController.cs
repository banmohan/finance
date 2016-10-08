using Frapid.Dashboard;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class ChartOfAccountController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/chart-of-accounts")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/ChartOfAccounts.cshtml", this.Tenant));
        }
    }
}