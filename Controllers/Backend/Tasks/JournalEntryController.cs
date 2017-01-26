using System;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using Frapid.i18n;
using MixERP.Finance.DAL;
using MixERP.Finance.QueryModels;
using MixERP.Finance.ViewModels;
using Frapid.Areas.CSRF;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class JournalEntryController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/journal/entry")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/JournalEntry/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/finance/tasks/journal/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/journal/entry")]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/JournalEntry/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/finance/tasks/journal/view")]
        [HttpPost]
        public async Task<ActionResult> GetAsync(JournalViewQuery query)
        {
            var appUser = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            query.OfficeId = appUser.OfficeId;
            query.UserId = appUser.UserId;

            var model = await Journals.GetJournalViewAsync(this.Tenant, query).ConfigureAwait(true);
            return this.Ok(model);
        }


        [Route("dashboard/finance/tasks/journal/entry/new")]
        [MenuPolicy(OverridePath = "/dashboard/finance/tasks/journal/entry")]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/JournalEntry/New.cshtml", this.Tenant));
        }

        [Route("dashboard/finance/tasks/journal/entry/new")]
        [HttpPost]
        public async Task<ActionResult> PostAsync(TransactionPosting model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

           

            foreach (var item in model.Details)
            {
                if (item.Debit > 0 && item.Credit > 0)
                {
                    throw new InvalidOperationException(I18N.InvalidData);
                }

                if (item.Debit == 0 && item.Credit == 0)
                {
                    throw new InvalidOperationException(I18N.InvalidData);
                }

                if (item.Credit < 0 || item.Debit < 0)
                {
                    throw new InvalidOperationException(I18N.InvalidData);
                }

                if (item.Credit > 0)
                {
                    if (await Accounts.IsCashAccountAsync(this.Tenant, item.AccountNumber).ConfigureAwait(true))
                    {
                        if (
                            await CashRepositories.GetBalanceAsync(this.Tenant, item.CashRepositoryCode,
                                item.CurrencyCode).ConfigureAwait(true) < item.Credit)
                        {
                            throw new InvalidOperationException(I18N.InsufficientBalanceInCashRepository);
                        }
                    }
                }
            }

            decimal drTotal = (from detail in model.Details select detail.LocalCurrencyDebit).Sum();
            decimal crTotal = (from detail in model.Details select detail.LocalCurrencyCredit).Sum();

            if (drTotal != crTotal)
            {
                throw new InvalidOperationException(I18N.ReferencingSidesNotEqual);
            }

            int decimalPlaces = CultureManager.GetCurrencyDecimalPlaces();

            if ((from detail in model.Details
                where
                    decimal.Round(detail.Credit*detail.ExchangeRate, decimalPlaces) !=
                    decimal.Round(detail.LocalCurrencyCredit, decimalPlaces) ||
                    decimal.Round(detail.Debit*detail.ExchangeRate, decimalPlaces) !=
                    decimal.Round(detail.LocalCurrencyDebit, decimalPlaces)
                select detail).Any())
            {
                throw new InvalidOperationException(I18N.ReferencingSidesNotEqual);
            }

            var user = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            try
            {
                long tranId = await TransacitonPostings.AddAsync(this.Tenant, user, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}