using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;


namespace MixERP.Finance.DTO
{
    [PrimaryKey("transaction_detail_id", AutoIncrement = true)]
    [TableName("finance.transaction_details")]
    public sealed class TransactionDetail : IPoco
    {
        public long TransactionDetailId { get; set; }
        public long TransactionMasterId { get; set; }
        public DateTime ValueDate { get; set; }
        public DateTime BookDate { get; set; }
        public string TranType { get; set; }
        public int AccountId { get; set; }
        public int OfficeId { get; set; }
        public string StatementReference { get; set; }
        public int? CashRepositoryId { get; set; }
        public string CurrencyCode { get; set; }
        public decimal AmountInCurrency { get; set; }
        public string LocalCurrencyCode { get; set; }
        public decimal Er { get; set; }
        public decimal AmountInLocalCurrency { get; set; }
        public int AuditUserId { get; set; }
        public DateTimeOffset AuditTs { get; set; }= DateTimeOffset.UtcNow;
    }
}