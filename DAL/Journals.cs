using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.Framework.Extensions;
using MixERP.Finance.DTO;
using MixERP.Finance.QueryModels;
using MixERP.Finance.ViewModels;

namespace MixERP.Finance.DAL
{
    public static class Journals
    {
        public static async Task<long> VerifyTransactionAsync(string tenant, Verification model)
        {
            //Todo: The following query is incompatible with sql server
            const string sql =
                "SELECT * FROM finance.verify_transaction(@0::bigint, @1::integer, @2::integer, @3::bigint, @4::smallint, @5::national character varying);";

            return await Factory.ScalarAsync<long>(tenant, sql, model.TranId, model.OfficeId, model.UserId, model.LoginId, model.VerificationStatusId,
                model.Reason).ConfigureAwait(false);
        }

        public static async Task<List<JournalView>> GetJournalViewAsync(string tenant, JournalViewQuery query)
        {
            //Todo: The following query is incompatible with sql server
            const string sql = "SELECT * FROM finance.get_journal_view(@0::integer,@1::integer,@2::date,@3::date,@4::bigint,@5,@6,@7,@8,@9,@10,@11,@12,@13);";

            var awaiter = await
                Factory.GetAsync<JournalView>(tenant, sql, query.UserId, query.OfficeId, query.From, query.To,
                    query.TranId, query.TranCode.Or(""), query.Book.Or(""), query.ReferenceNumber.Or(""),
                    query.StatementReference.Or(""), query.PostedBy.Or(""), query.Office.Or(""), query.Status.Or(""),
                    query.VerifiedBy.Or(""), query.Reason.Or("")).ConfigureAwait(false);

            return awaiter.OrderBy(x => x.TransactionMasterId).ToList();
        }
    }
}