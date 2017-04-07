using System.Threading.Tasks;
using Frapid.ApplicationState.Models;
using MixERP.Finance.DAL;

namespace MixERP.Finance.Models
{
    public static class JournalWithadrawals
    {
        public static async Task<bool> IsRestrictedTransactionModeAsync(string tenant, int officeId)
        {
            await Task.Delay(0).ConfigureAwait(false);
            return false;
        }

        public static async Task WithdrawAsync(string tenant, string reason, long tranId, LoginView meta)
        {
            bool isRestrictedTransactionMode = await IsRestrictedTransactionModeAsync(tenant, meta.OfficeId).ConfigureAwait(false);

            if (isRestrictedTransactionMode)
            {
                throw new JournalWithdrawalException(I18N.CannotWithdrawTransactionDuringRestrictedTransactionMode);
            }

            var status = await Verifications.GetVerificationStatusAsync(tenant, tranId, meta.OfficeId).ConfigureAwait(false);

            if (status.UserId != meta.UserId)
            {
                throw new JournalWithdrawalException(I18N.AccessDeniedCannotWithdrawSomeoneElseTransaction);
            }

            if (
                status.VerificationStatusId.Equals(0) //Awaiting verification
                ||
                status.VerificationStatusId.Equals(1) //Automatically Approved by Workflow
            )
            {
                await TransactionPostings.WithdrawAsync(tenant, reason, meta.UserId, tranId, meta.OfficeId).ConfigureAwait(false);
                return;
            }

            throw new JournalWithdrawalException(I18N.AccessIsDenied);
        }
    }
}