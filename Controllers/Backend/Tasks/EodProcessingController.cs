using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using MixERP.Finance.DAL;
using MixERP.Finance.Models;
using Serilog;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class EodProcessingController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/eod-processing")]
        [MenuPolicy]
        public async Task<ActionResult> IndexAsync()
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            var model = await FiscalYears.GetFrequencyDatesAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);

            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/EOD/Index.cshtml", this.Tenant), model);
        }

        [Route("dashboard/finance/tasks/eod-processing/initialize")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/eod-processing")]
        public async Task<ActionResult> InitializeAsync()
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            try
            {
                await EodProcessing.InitializeAsync(this.Tenant, meta).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }


        [Route("dashboard/finance/tasks/eod-processing/start-new-day")]
        [HttpPut]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/eod-processing")]
        public async Task StartNewDayAsync()
        {
            try
            {
                var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
                await EodProcessing.StartNewDayAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);
            }
            catch (Exception ex)
            {
                Log.Warning("Could not start a new day. {Exception}", ex);
                throw;
            }
        }
    }
}