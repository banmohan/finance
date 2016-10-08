using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class BankAccountController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/bank-accounts")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/BankAccounts.cshtml", this.Tenant));
        }
    }
}