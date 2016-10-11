using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    public class VerificationPolicyController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/verification-policy")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/VerificationPolicy/Index.cshtml", this.Tenant));
        }
    }
}