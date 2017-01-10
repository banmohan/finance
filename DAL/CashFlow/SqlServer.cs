using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Finance.QueryModels;

namespace MixERP.Finance.DAL.CashFlow
{
    public sealed class SqlServer : ICashFlow
    {
        public async Task<IEnumerable<dynamic>> GetAsync(string tenant, CashFlowStatementQueryModel query)
        {
            string sql = "EXECUTE finance.get_cash_flow_statement @0,@1,@2,@3,@4;";
            return await Factory.GetAsync<dynamic>(tenant, sql, query.From, query.To, query.UserId, query.OfficeId, query.Factor).ConfigureAwait(false);
        }
    }
}