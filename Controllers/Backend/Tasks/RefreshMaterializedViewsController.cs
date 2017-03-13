using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using MixERP.Finance.DAL;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class RefreshMaterializedViewsController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/refresh-materialized-views")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/RefreshMaterializedViews/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/finance/tasks/refresh-materialized-views/do")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/refresh-materialized-views")]
        [HttpPost]
        public async Task<ActionResult> RefreshAsync()
        {
            return await this.RefreshAsync(false).ConfigureAwait(true);
        }

        [Route("dashboard/finance/tasks/refresh-materialized-views/do/concurrently")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/refresh-materialized-views")]
        [HttpPost]
        public async Task<ActionResult> ConcurrentlyAsync()
        {
            return await this.RefreshAsync(true).ConfigureAwait(true);
        }

        private async Task<ActionResult> RefreshAsync(bool concurrently)
        {
            try
            {
                await RefreshMaterializedViews.RefreshAsync(this.Tenant, concurrently).ConfigureAwait(false);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}