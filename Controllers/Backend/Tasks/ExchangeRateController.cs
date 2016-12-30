using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Finance.DAL;
using MixERP.Finance.ViewModels;
using Frapid.Areas.CSRF;

namespace MixERP.Finance.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class ExchangeRateController : FinanceDashboardController
    {
        [Route("dashboard/finance/tasks/exchange-rates")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/ExchangeRates/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/finance/tasks/exchange-rates")]
        [HttpPost]
        public async Task<ActionResult> SaveAsync(List<ExchangeRateViewModel> exchangeRates)
        {
            if (!ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            if (exchangeRates == null || exchangeRates.Count().Equals(0))
            {
                return this.InvalidModelState(this.ModelState);
            }

           

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            int officeId = meta.OfficeId;
            string baseCurrency = meta.CurrencyCode;


            
            long id = await ExchangeRates.SaveAsync(this.Tenant, officeId, baseCurrency, exchangeRates).ConfigureAwait(false);
            return this.Ok(id);
        }

        [Route("dashboard/finance/tasks/exchange-rates/currency-list")]
        public async Task<ActionResult> GetCurrenciesAsync()
        {
            var currencies = await Currencies.GetCurrenciesAsync(this.Tenant).ConfigureAwait(true);
            string currencyCode = (await AppUsers.GetCurrentAsync().ConfigureAwait(true)).CurrencyCode;

            var model = currencies.Where(x => x.CurrencyCode != currencyCode).ToList();

            return this.Ok(model);
        }
    }
}