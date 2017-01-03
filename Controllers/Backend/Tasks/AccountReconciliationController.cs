using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using MixERP.Finance.DAL;
using MixERP.Finance.QueryModels;
using MixERP.Finance.ViewModels;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class AccountReconciliationController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/account-reconciliation")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/AccountReconciliation/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/finance/tasks/account-reconciliation/statement")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/account-reconciliation")]
        [HttpPost]
        public async Task<ActionResult> GetStatementAsync(AccountStatementQueryModel model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(false);
            try
            {
                model.UserId = meta.UserId;
                model.OfficeId = meta.OfficeId;

                var result = await Reconciliations.GetAccountStatementAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/finance/tasks/account-reconciliation")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/account-reconciliation")]
        [HttpPut]
        public async Task<ActionResult> ReconcileAsync(ReconciliationViewModel model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(false);

            try
            {
                await Reconciliations.ReconcileAsync(this.Tenant, model, meta).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }


    }
}