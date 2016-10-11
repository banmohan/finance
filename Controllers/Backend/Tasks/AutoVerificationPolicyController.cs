using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    public class AutoVerificationPolicyController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/verification-policy/auto")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/VerificationPolicy/Auto.cshtml", this.Tenant));
        }
    }
}