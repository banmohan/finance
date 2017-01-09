using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Finance.DAL;
using MixERP.Finance.QueryModels;

namespace MixERP.Finance.Controllers.Backend.Reports
{
    public class PlAccountController : FinanceDashboardController
    {
        [Route("dashboard/finance/reports/pl-account")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Reports/PlAccount.cshtml", this.Tenant));
        }

        [Route("dashboard/finance/reports/pl-account")]
        [MenuPolicy]
        [HttpPost]
        public async Task<ActionResult> GetPlAccountAsync(PlAccountQueryModel model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }


            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            model.OfficeId = meta.OfficeId;
            model.UserId = meta.UserId;

            try
            {
                var result = await ProfitLossStatement.GetAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}