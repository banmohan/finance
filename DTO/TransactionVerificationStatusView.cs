using System;
using Frapid.Mapper.Decorators;

namespace MixERP.Finance.DTO
{
    [TableName("finance.transaction_verification_status_view")]
    public class TransactionVerificationStatusView
    {
        public long TransactionMasterId { get; set; }
        public int UserId { get; set; }
        public int OfficeId { get; set; }
        public short VerificationStatusId { get; set; }
        public string VerificationReason { get; set; }
        public string VerifierName { get; set; }
        public int VerifiedByUserId { get; set; }
        public DateTimeOffset LastVerifiedOn { get; set; }
    }
}