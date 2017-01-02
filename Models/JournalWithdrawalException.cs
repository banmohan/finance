using System;
using System.Runtime.Serialization;

namespace MixERP.Finance.Models
{
    [Serializable]
    public sealed class JournalWithdrawalException : Exception
    {
        public JournalWithdrawalException()
        {
        }

        public JournalWithdrawalException(string message) : base(message)
        {
        }

        public JournalWithdrawalException(string message, Exception innerException) : base(message, innerException)
        {
        }

        public JournalWithdrawalException(SerializationInfo info, StreamingContext context) : base(info, context)
        {
        }
    }
}