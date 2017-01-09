using System.Collections.Generic;
using System.Threading.Tasks;
using MixERP.Finance.QueryModels;

namespace MixERP.Finance.DAL.PlStatement
{
    public interface IPlStatement
    {
        Task<IEnumerable<dynamic>> GetAsync(string tenant, PlAccountQueryModel query);
    }
}