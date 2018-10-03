using Frapid.ApplicationState.Cache;
using Frapid.DataAccess;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Reports
{
    public class BalanceSheetController : FinanceDashboardController
    {
        [Route("dashboard/finance/reports/balance-sheet")]
        public async Task<ActionResult> GetBalanceSheetAsync()
        {
            var user = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            var officeId = user.OfficeId;

            if (!string.IsNullOrWhiteSpace(Request.QueryString["OfficeId"]))
                officeId = int.Parse(Request.QueryString["OfficeId"]);

            var toDate = DateTime.Parse(Request.QueryString["Date"]);
            var factor = int.Parse(Request.QueryString["Factor"]);
            var compact = bool.Parse(Request.QueryString["Compact"]);
            if (factor <= 0) factor = 1;

            var model = await Factory.GetAsync<Models.BalanceSheetItem>(Tenant,
                "SELECT * FROM finance.get_balance_sheet2(@0, @1, @2) ORDER BY normally_debit, account_master_id",
                    officeId, toDate, compact).ConfigureAwait(true);
            foreach(var item in model)
            {
                item.Debit = (item.Debit / factor);
                item.Credit = (item.Credit / factor);
            }

            var masters = new List<Models.Master>();
            foreach (var item in model)
            {
                if (!masters.Any(x => x.MasterId == item.AccountMasterId))
                {
                    masters.Add(new Models.Master
                    {
                        MasterId = item.AccountMasterId,
                        AccountName = item.AccountMasterName,
                        IsDr = item.NormallyDebit
                    });
                }
            }

            return View(GetRazorView<AreaRegistration>("BalanceSheet/GetBalanceSheetAsync.cshtml", Tenant),
                new Models.BalanceSheet { Meta = user, Data = model.Where(x => x.Debit - x.Credit != 0),
                    Date = Request.QueryString["Date"], Masters = masters });
            //return View(new Models.BalanceSheet { Meta= user, Data = model});
        }
    }
}