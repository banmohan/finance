using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class CurrencyController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/currencies")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Currencies.cshtml", this.Tenant));
        }
    }
}