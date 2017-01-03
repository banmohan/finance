using System;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.QueryModels
{
    public sealed class AccountStatementQueryModel
    {
        [Required]
        public DateTime From { get; set; }
        [Required]
        public DateTime To { get; set; }
        [Required]
        public string AccountNumber { get; set; }

        public int UserId { get; set; }
        public int OfficeId { get; set; }
    }
}