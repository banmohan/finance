using Frapid.Dashboard.Controllers;

namespace MixERP.Finance.Controllers
{
    public class FinanceDashboardController : DashboardController
    {
        public FinanceDashboardController()
        {
            ViewBag.FinanceLayoutPath = this.GetLayoutPath();
        }

        private string GetLayoutPath()
        {
            return this.GetRazorView<AreaRegistration>("Layout.cshtml", this.Tenant);
        }
    }
}