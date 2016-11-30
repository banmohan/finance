using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.Finance.DTO
{
    [PrimaryKey("transaction_master_id", AutoIncrement = true)]
    [TableName("finance.transaction_master")]
    public sealed class TransactionMaster : IPoco
    {
        public long TransactionMasterId { get; set; }
        public int TransactionCounter { get; set; }
        public string TransactionCode { get; set; }
        public string Book { get; set; }
        public DateTime ValueDate { get; set; }
        public DateTime BookDate { get; set; }
        public DateTimeOffset TransactionTs { get; set; } = DateTimeOffset.UtcNow;
        public long LoginId { get; set; }
        public int UserId { get; set; }
        public int OfficeId { get; set; }
        public int? CostCenterId { get; set; }
        public string ReferenceNumber { get; set; }
        public string StatementReference { get; set; }
        public DateTime? LastVerifiedOn { get; set; }
        public int? VerifiedByUserId { get; set; }
        public short VerificationStatusId { get; set; }
        public string VerificationReason { get; set; }
        public int AuditUserId { get; set; }
        public DateTimeOffset AuditTs { get; set; } = DateTimeOffset.UtcNow;
        public bool Deleted { get; set; }
    }
}