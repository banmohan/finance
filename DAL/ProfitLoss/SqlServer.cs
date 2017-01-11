using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Finance.QueryModels;

namespace MixERP.Finance.DAL.ProfitLoss
{
    public sealed class SqlServer : IProfitLoss
    {
        public async Task<IEnumerable<dynamic>> GetAsync(string tenant, PlAccountQueryModel query)
        {
            string sql = "EXECUTE finance.get_profit_and_loss_statement @0,@1,@2,@3,@4,@5;";
            return await Factory.GetAsync<dynamic>(tenant, sql, query.From, query.To, query.UserId, query.OfficeId, query.Factor, query.Compact).ConfigureAwait(false);
        }
    }
}