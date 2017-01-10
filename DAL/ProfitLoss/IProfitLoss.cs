using System.Collections.Generic;
using System.Threading.Tasks;
using MixERP.Finance.QueryModels;

namespace MixERP.Finance.DAL.ProfitLoss
{
    public interface IProfitLoss
    {
        Task<IEnumerable<dynamic>> GetAsync(string tenant, PlAccountQueryModel query);
    }
}