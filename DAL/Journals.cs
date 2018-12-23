using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Framework.Extensions;
using Frapid.Mapper.Database;
using MixERP.Finance.DTO;
using MixERP.Finance.QueryModels;
using MixERP.Finance.ViewModels;

namespace MixERP.Finance.DAL
{
    public static class Journals
    {
        public static async Task<long> VerifyTransactionAsync(string tenant, Verification model)
        {
            string sql = "SELECT * FROM finance.verify_transaction(@0::bigint, @1::integer, @2::integer, @3::bigint, @4::smallint, @5::national character varying);";

            if (DbProvider.GetDbType(DbProvider.GetProviderName(tenant)) == DatabaseType.SqlServer)
            {
                sql = "EXECUTE finance.verify_transaction @0, @1, @2, @3, @4, @5;";
            }

            return await Factory.ScalarAsync<long>(tenant, sql, model.TranId, model.OfficeId, model.UserId, model.LoginId, model.VerificationStatusId,
                model.Reason).ConfigureAwait(false);
        }

        public static async Task<List<JournalView>> GetJournalViewAsync(string tenant, JournalViewQuery query)
        {
            string sql = "SELECT * FROM finance.get_journal_view(@0::integer,@1::integer,@2::date,@3::date,@4::bigint,@5::national character varying(50),@6::national character varying(50),@7::national character varying(50),@8::numeric(30, 6),@9::national character varying(50),@10::national character varying(50),@11::national character varying(50),@12::national character varying(12),@13::national character varying(50),@14::national character varying(128));";

            if (DbProvider.GetDbType(DbProvider.GetProviderName(tenant)) == DatabaseType.SqlServer)
            {
                sql = "SELECT * FROM finance.get_journal_view(@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15);";
            }

            var awaiter = await
                Factory.GetAsync<JournalView>(tenant, sql, query.UserId, query.OfficeId, query.From, query.To,
                    query.TranId, query.TranCode.Or(""), query.Book.Or(""), query.ReferenceNumber.Or(""), query.Amount,
                    query.StatementReference.Or(""), query.PostedBy.Or(""), query.Office.Or(""), query.Status.Or(""),
                    query.VerifiedBy.Or(""), query.Reason.Or(""), query.AccountId).ConfigureAwait(false);

            return awaiter.OrderBy(x => x.TransactionMasterId).ToList();
        }
    }
}