using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class FiscalYearController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/fiscal-years")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/FiscalYears.cshtml", this.Tenant));
        }
    }
}