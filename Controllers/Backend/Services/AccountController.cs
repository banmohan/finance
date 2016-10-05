using Frapid.ApplicationState.Cache;
using MixERP.Finance.DTO;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Mvc;

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
            var er = await DAL.Currencies.GetExchangeRateAsync(this.Tenant, user.OfficeId, currencyCode);
            return this.Ok(er);
        }
    }
    public class CashRepositoryController : FinanceDashboardController
    {
        [Route("dashboard/finance/cash-repository/check-balance/{cashRepositoryCode}/{currencyCode}/{amount}")]
        public async Task<ActionResult> Index(string cashRepositoryCode, string currencyCode, decimal amount)
        {
            if (string.IsNullOrWhiteSpace(cashRepositoryCode))
            {
                return this.AccessDenied();
            }

            if (string.IsNullOrWhiteSpace(currencyCode))
            {
                return this.AccessDenied();
            }

            if (amount <= 0)
            {
                return this.Ok(true);
            }

            var balance = await DAL.CashRepositories.GetBalanceAsync(this.Tenant, cashRepositoryCode, currencyCode);
            return this.Ok(balance >= amount);
        }
    }
    public class AccountController : FinanceDashboardController
    {
        [Route("dashboard/finance/chart-of-accounts/list")]
        public async Task<ActionResult> Index()
        {
            var user = await AppUsers.GetCurrentAsync();
            var accounts = new List<Account>();

            if (user.IsAdministrator)
            {
                accounts = await DAL.Accounts.GetAsync(this.Tenant);
            }
            else
            {
                accounts = await DAL.Accounts.GetNonConfidentialAsync(this.Tenant);
            }

            return this.Ok(accounts);
        }
    }
}