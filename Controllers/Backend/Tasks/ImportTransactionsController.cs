using System.Web.Mvc;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class ImportTransactionsController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/import-transactions")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/ImportTransactions/Index.cshtml", this.Tenant));
        }
    }
}