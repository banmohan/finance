using System;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.ViewModels
{
    public sealed class ReconciliationViewModel
    {
        [Required]
        public long TransactionDetailId { get; set; }
        [Required]
        public DateTime NewBookDate { get; set; }
        public string Memo { get; set; }
    }
}