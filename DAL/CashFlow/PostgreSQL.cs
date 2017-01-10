using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Finance.QueryModels;
using Newtonsoft.Json;

namespace MixERP.Finance.DAL.CashFlow
{
    public sealed class PostgreSQL : ICashFlow
    {
        public async Task<IEnumerable<dynamic>> GetAsync(string tenant, CashFlowStatementQueryModel query)
        {
            string sql = "SELECT * FROM finance.get_cash_flow_statement(@0::date,@1::date,@2::integer,@3::integer,@4::integer)";
            string json =  await Factory.ScalarAsync<string>(tenant, sql, query.From, query.To, query.UserId, query.OfficeId, query.Factor).ConfigureAwait(false);
            return JsonConvert.DeserializeObject< IEnumerable<dynamic>>(json);
        }
    }
}