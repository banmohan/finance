using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class CashRepositoryController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cash-repositories")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CashRepositories.cshtml", this.Tenant));
        }
    }
}