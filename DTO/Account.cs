using Frapid.DataAccess;

using System;
using Frapid.Mapper.Decorators;

namespace MixERP.Finance.DTO
{
    [PrimaryKey("account_id", AutoIncrement = true)]
    [TableName("finance.accounts")]
    public sealed class Account : IPoco
    {
        public int AccountId { get; set; }
        public short AccountMasterId { get; set; }
        public string AccountNumber { get; set; }
        public string ExternalCode { get; set; }
        public string CurrencyCode { get; set; }
        public string AccountName { get; set; }
        public string Description { get; set; }
        public bool Confidential { get; set; }
        public bool IsTransactionNode { get; set; }
        public bool SysType { get; set; }
        public long? ParentAccountId { get; set; }
        public int? AuditUserId { get; set; }
        public DateTime? AuditTs { get; set; }
        public bool Deleted { get; set; }
    }
}