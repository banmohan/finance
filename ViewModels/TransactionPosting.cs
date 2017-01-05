using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.ViewModels
{
    public class TransactionPosting
    {
        [Required]
        public DateTime ValueDate { get; set; }

        [Required]
        public DateTime BookDate { get; set; }

        public string ReferenceNumber { get; set; }

        [Required]
        public int CostCenterId { get; set; }

        [Required]
        public List<JournalDetail> Details { get; set; }

        public List<Document> Attachements { get; set; }
    }
}