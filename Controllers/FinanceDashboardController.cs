using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Configuration;
using Frapid.Dashboard.Controllers;
using MixERP.Finance.AppModels;
using MixERP.Finance.Cache;
using MixERP.Finance.DTO;

namespace MixERP.Finance.Controllers
{
    public class FinanceDashboardController : DashboardController
    {
        public FinanceDashboardController()
        {
            this.ViewBag.FinanceLayoutPath = this.GetLayoutPath();
        }

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            string tenant = TenantConvention.GetTenant();
            var meta = AppUsers.GetCurrent(tenant);
            this.FrequencyDates = Dates.GetFrequencyDatesAsync(tenant, meta.OfficeId).GetAwaiter().GetResult();

            base.OnActionExecuting(filterContext);
        }

        public FrequencyDates FrequencyDates { get; set; }

        private string GetLayoutPath()
        {
            return this.GetRazorView<AreaRegistration>("Layout.cshtml", this.Tenant);
        }
    }
}