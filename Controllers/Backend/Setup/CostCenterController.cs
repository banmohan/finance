using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class CostCenterController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cost-centers")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CostCenters.cshtml", this.Tenant));
        }
    }
}