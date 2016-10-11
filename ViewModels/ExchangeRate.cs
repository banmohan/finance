using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.ViewModels
{
    public class ExchangeRateViewModel
    {
        [Required]
        public string CurrencyCode { get; set; }
        [Required]
        public decimal Rate { get; set; }
    }
}