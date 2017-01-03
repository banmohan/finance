using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class FrequencySetupController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/frequency-setups")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/FrequencySetups.cshtml", this.Tenant));
        }
    }
}