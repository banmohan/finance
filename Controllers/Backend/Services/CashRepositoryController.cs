using System.Threading.Tasks;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Services
{
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

            decimal balance = await DAL.CashRepositories.GetBalanceAsync(this.Tenant, cashRepositoryCode, currencyCode);
            return this.Ok(balance >= amount);
        }
    }
}