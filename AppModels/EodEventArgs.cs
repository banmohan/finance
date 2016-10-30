using System;

namespace MixERP.Finance.AppModels
{
    public class EodEventArgs : EventArgs
    {
        public readonly string Message;
        public readonly string Condition;

        public EodEventArgs(string message, string condition)
        {
            this.Message = message;
            this.Condition = condition;
        }
    }
}