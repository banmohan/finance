using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;


namespace MixERP.Finance.DTO
{
    [PrimaryKey("exchange_rate_id", AutoIncrement = true)]
    [TableName("finance.exchange_rates")]
    public sealed class ExchangeRate : IPoco
    {
        public long ExchangeRateId { get; set; }
        public DateTimeOffset UpdatedOn { get; set; } = DateTimeOffset.UtcNow;
        public int OfficeId { get; set; }
        public bool Status { get; set; }
    }
}