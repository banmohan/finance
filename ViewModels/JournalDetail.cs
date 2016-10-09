using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.ViewModels
{
    public class JournalDetail
    {
        [Required]
        public string Account { get; set; }
        [Required]
        public string AccountNumber { get; set; }
        public string CashRepositoryCode { get; set; }
        [Required]
        public decimal Credit { get; set; }
        [Required]
        public string CurrencyCode { get; set; }
        [Required]
        public decimal Debit { get; set; }
        [Required]
        public decimal ExchangeRate { get; set; }
        [Required]
        public decimal LocalCurrencyCredit { get; set; }
        [Required]
        public decimal LocalCurrencyDebit { get; set; }
        public string StatementReference { get; set; }
    }
}