using Frapid.ApplicationState.Models;
using System.Collections.Generic;

namespace MixERP.Finance.Models
{
    public class BalanceSheet
    {
        public LoginView Meta { get; set; }
        public string Date { get; set; }
        public List<Master> Masters { get; set; }
        public IEnumerable<BalanceSheetItem> Data { get; set; }
    }

    public class Master
    {
        public int MasterId { get; set; }
        public string AccountName { get; set; }
        public bool IsDr { get; set; }
    }

    public class BalanceSheetItem
    {
        public string AccountName { get; set; }
        public int AccountMasterId { get; set; }
        public string AccountMasterName { get; set; }
        public bool NormallyDebit { get; set; }
        public decimal Debit { get; set; }
        public decimal Credit { get; set; }
    }
}