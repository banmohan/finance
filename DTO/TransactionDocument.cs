using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;


namespace MixERP.Finance.DTO
{
    [PrimaryKey("transaction_master_id", AutoIncrement = true)]
    [TableName("finance.transaction_master")]
    public sealed class TransactionDocument : IPoco
    {
        public long DocumentId { get; set; }
        public long TransactionMasterId { get; set; }
        public string OriginalFileName { get; set; }
        public string FileExtension { get; set; }
        public string FilePath { get; set; }
        public string Memo { get; set; }
        public int AuditUserId { get; set; }
        public DateTimeOffset AuditTs { get; set; } = DateTimeOffset.UtcNow;
        public bool Deleted { get; set; }
    }
}