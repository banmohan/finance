using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.CSRF;
using MixERP.Finance.Models;
using MixERP.Finance.ViewModels;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class JournalWithdrawalController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/journal/withdraw")]
        [HttpPut]
        public async Task<ActionResult> WithdrawAsync(WithdrawalViewModel model)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            try
            {
                await JournalWithadrawals.WithdrawAsync(this.Tenant, model.Reason, model.TranId, meta).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}