using System.Threading.Tasks;
using Frapid.DataAccess;

namespace MixERP.Finance.DAL
{
    public static class CashRepositories
    {
        public static async Task<int?> GetCashRepositoryIdByCashRepositoryCodeAsync(string tenant, string cashRepositoryCode)
        {
            if (string.IsNullOrWhiteSpace(cashRepositoryCode))
            {
                return null;
            }

            const string sql = "SELECT finance.get_cash_repository_id_by_cash_repository_code(@0)";
            return await Factory.ScalarAsync<int>(tenant, sql, cashRepositoryCode).ConfigureAwait(false);
        }

        public static async Task<decimal> GetBalanceAsync(string tenant, string cashRepositoryCode, string currencyCode)
        {
            const string sql = "SELECT finance.get_cash_repository_balance(finance.get_cash_repository_id_by_cash_repository_code(@0), @1);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, cashRepositoryCode, currencyCode).ConfigureAwait(false);
        }
    }
}