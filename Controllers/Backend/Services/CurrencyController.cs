using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;

namespace MixERP.Finance.Controllers.Backend.Services
{
    public class CurrencyController : FinanceDashboardController
    {
        [Route("dashboard/finance/currency/exchange-rate/of/{currencyCode}")]
        public async Task<ActionResult> Index(string currencyCode)
        {
            if (string.IsNullOrWhiteSpace(currencyCode))
            {
                return this.AccessDenied();
            }

            var user = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            decimal er = await DAL.Currencies.GetExchangeRateAsync(this.Tenant, user.OfficeId, currencyCode);
            return this.Ok(er);
        }
    }
}