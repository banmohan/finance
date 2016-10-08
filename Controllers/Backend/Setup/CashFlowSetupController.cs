using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class CashFlowSetupController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cash-flow/setup")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CashFlowSetups.cshtml", this.Tenant));
        }
    }
}