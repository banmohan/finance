using System.Collections.Generic;
using System.Threading.Tasks;
using MixERP.Finance.QueryModels;

namespace MixERP.Finance.DAL.CashFlow
{
    public interface ICashFlow
    {
        Task<IEnumerable<dynamic>> GetAsync(string tenant, CashFlowStatementQueryModel query);
    }
}