using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.Mapper;
using MixERP.Finance.DTO;

namespace MixERP.Finance.DAL
{
    public static class Verifications
    {
        public static async Task<TransactionVerificationStatusView> GetVerificationStatusAsync(string tenant, long transactinMasterId, int officeId)
        {
            var sql = new Sql("SELECT * FROM finance.transaction_verification_status_view");
            sql.Where("transaction_master_id=@0", transactinMasterId);
            sql.And("office_id=@0", officeId);

            var awaiter = await Factory.GetAsync<TransactionVerificationStatusView>(tenant, sql).ConfigureAwait(false);
            return awaiter.FirstOrDefault();
        }
    }
}