using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    public sealed class ConsoleController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/console")]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Console/Index.cshtml", this.Tenant));
        }
    }
}