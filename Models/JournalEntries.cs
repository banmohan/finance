using System;
using System.Linq;
using System.Threading.Tasks;
using Frapid.ApplicationState.Models;
using Frapid.i18n;
using MixERP.Finance.DAL;
using MixERP.Finance.ViewModels;

namespace MixERP.Finance.Models
{
    public static class JournalEntries
    {
        public static async Task<long> PostAsync(string tenant, TransactionPosting model, LoginView meta)
        {
            foreach (var item in model.Details)
            {
                if (item.Debit > 0 && item.Credit > 0)
                {
                    throw new InvalidOperationException(I18N.InvalidData);
                }

                if (item.Debit == 0 && item.Credit == 0)
                {
                    throw new InvalidOperationException(I18N.InvalidData);
                }

                if (item.Credit < 0 || item.Debit < 0)
                {
                    throw new InvalidOperationException(I18N.InvalidData);
                }

                if (item.Credit > 0)
                {
                    if (await Accounts.IsCashAccountAsync(tenant, item.AccountNumber).ConfigureAwait(true))
                    {
                        if (await CashRepositories.GetBalanceAsync(tenant, item.CashRepositoryCode, item.CurrencyCode).ConfigureAwait(true) < item.Credit)
                        {
                            throw new InvalidOperationException(I18N.InsufficientBalanceInCashRepository);
                        }
                    }
                }
            }

            decimal drTotal = (from detail in model.Details select detail.LocalCurrencyDebit).Sum();
            decimal crTotal = (from detail in model.Details select detail.LocalCurrencyCredit).Sum();

            if (drTotal != crTotal)
            {
                throw new InvalidOperationException(I18N.ReferencingSidesNotEqual);
            }

            int decimalPlaces = CultureManager.GetCurrencyDecimalPlaces();

            if ((from detail in model.Details
                where
                decimal.Round(detail.Credit * detail.ExchangeRate, decimalPlaces) !=
                decimal.Round(detail.LocalCurrencyCredit, decimalPlaces) ||
                decimal.Round(detail.Debit * detail.ExchangeRate, decimalPlaces) !=
                decimal.Round(detail.LocalCurrencyDebit, decimalPlaces)
                select detail).Any())
            {
                throw new InvalidOperationException(I18N.ReferencingSidesNotEqual);
            }


            long tranId = await TransactionPostings.AddAsync(tenant, meta, model).ConfigureAwait(true);
            return tranId;
        }
    }
}