using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Finance.QueryModels;
using Newtonsoft.Json;

namespace MixERP.Finance.DAL.ProfitLoss
{
    public sealed class PostgreSQL : IProfitLoss
    {
        public async Task<IEnumerable<dynamic>> GetAsync(string tenant, PlAccountQueryModel query)
        {
            string sql = "SELECT * FROM finance.get_profit_and_loss_statement(@0::date,@1::date,@2::integer,@3::integer,@4::integer,@5::boolean)";
            string json =  await Factory.ScalarAsync<string>(tenant, sql, query.From, query.To, query.UserId, query.OfficeId, query.Factor, query.Compact).ConfigureAwait(false);
            return JsonConvert.DeserializeObject< IEnumerable<dynamic>>(json);
        }
    }
}