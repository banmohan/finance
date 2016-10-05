using Frapid.Dashboard;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    public class JournalEntryController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/journal/entry")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/JournalEntry/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/finance/tasks/journal/entry/new")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/journal/entry")]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/JournalEntry/New.cshtml", this.Tenant));
        }
    }
}