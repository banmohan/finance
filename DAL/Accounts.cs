using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Finance.DTO;

namespace MixERP.Finance.DAL
{
    public static class Accounts
    {
        public static async Task<int> GetAccountIdByAccountNumberAsync(string tenant, string accountNumber)
        {
            const string sql = "SELECT finance.get_account_id_by_account_number(@0)";
            return await Factory.ScalarAsync<int>(tenant, sql, accountNumber).ConfigureAwait(false);
        }

        public static async Task<IEnumerable<Account>> GetAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM finance.accounts");
                sql.Where("deleted = @0", false);
                sql.And("is_transaction_node = @0", true);

                return await db.SelectAsync<Account>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<bool> IsCashAccountAsync(string tenant, string accountNumber)
        {
            const string sql = "SELECT * FROM finance.accounts WHERE account_master_id=10101 AND account_number=@0 AND deleted = @1;";
            var awaiter = await Factory.GetAsync<Account>(tenant, sql, accountNumber, false).ConfigureAwait(false);
            return awaiter.Count().Equals(1);
        }


        public static async Task<IEnumerable<Account>> GetNonConfidentialAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM finance.accounts");
                sql.Where("deleted = @0", false);
                sql.And("confidential = @0", false);
                sql.And("is_transaction_node = @0", true);

                return await db.SelectAsync<Account>(sql).ConfigureAwait(false);
            }
        }
    }
}