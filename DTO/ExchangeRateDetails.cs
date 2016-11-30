using Frapid.DataAccess;
using Frapid.Mapper.Decorators;


namespace MixERP.Finance.DTO
{
    [PrimaryKey("exchange_rate_detail_id", AutoIncrement = true)]
    [TableName("finance.exchange_rate_details")]
    public sealed class ExchangeRateDetail : IPoco
    {
        public long ExchangeRateDetailId { get; set; }
        public long ExchangeRateId { get; set; }
        public string LocalCurrencyCode { get; set; }
        public string ForeignCurrencyCode { get; set; }
        public int Unit { get; set; }
        public decimal ExchangeRate { get; set; }
    }
}