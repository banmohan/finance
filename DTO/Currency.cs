using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.Finance.DTO
{
    [PrimaryKey("currency_code", AutoIncrement = true)]
    [TableName("core.currencies")]
    public sealed class Currency : IPoco
    {
        public int CurrencyId { get; set; }
        public string CurrencyCode { get; set; }
        public string CurrencySymbol { get; set; }
        public string CurrencyName { get; set; }
        public string HundredthName { get; set; }
        public int? AuditUserId { get; set; }
        public DateTime? AuditTs { get; set; }
        public bool Deleted { get; set; }
    }
}