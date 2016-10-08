using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class CashFlowHeadingController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cash-flow/headings")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CashFlowHeadings.cshtml", this.Tenant));
        }
    }
}