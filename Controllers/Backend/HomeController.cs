using Frapid.Dashboard;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend
{
    public class HomeController:FinanceDashboardController
    {
        [Route("dashboard/finance/home")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Home.cshtml", this.Tenant));
        }
    }
}