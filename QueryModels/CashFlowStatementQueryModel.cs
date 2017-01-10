using System;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.QueryModels
{
    public sealed class CashFlowStatementQueryModel
    {
        [Required]
        public DateTime From { get; set; }
        [Required]
        public DateTime To { get; set; }
        [Required]
        public int Factor { get; set; }
        public int OfficeId { get; set; }
        public int UserId { get; set; }
    }
}