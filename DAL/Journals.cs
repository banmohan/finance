using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.Framework.Extensions;
using MixERP.Finance.DTO;
using MixERP.Finance.ViewModels;

namespace MixERP.Finance.DAL
{
    public static class Journals
    {
        public static async Task<List<JournalView>> GetJournalView(string tenant, JournalViewQuery query)
        {
            //Todo: The following query is incompatible with sql server
            const string sql =
                "SELECT * FROM finance.get_journal_view(@0::integer,@1::integer,@2::date,@3::date,@4::bigint,@5,@6,@7,@8,@9,@10,@11,@12,@13);";

            var awaiter = await
                Factory.GetAsync<JournalView>(tenant, sql, query.UserId, query.OfficeId, query.From, query.To,
                    query.TranId, query.TranCode.Or(""), query.Book.Or(""), query.ReferenceNumber.Or(""),
                    query.StatementReference.Or(""), query.PostedBy.Or(""), query.Office.Or(""), query.Status.Or(""),
                    query.VerifiedBy.Or(""), query.Reason.Or("")).ConfigureAwait(false);

            return awaiter.ToList();
        }
    }
}