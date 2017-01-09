using System;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.QueryModels
{
    public sealed class PlAccountQueryModel
    {
        [Required]
        public DateTime From { get; set; }
        [Required]
        public DateTime To { get; set; }
        [Required]
        public int Factor { get; set; }
        [Required]
        public bool Compact { get; set; }
        public int OfficeId { get; set; }
        public int UserId { get; set; }
    }
}