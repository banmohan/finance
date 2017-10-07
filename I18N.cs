using System.Collections.Generic;
using System.Globalization;
using Frapid.Configuration;
using Frapid.i18n;

namespace MixERP.Finance
{
	public sealed class Localize : ILocalize
	{
		public Dictionary<string, string> GetResources(CultureInfo culture)
		{
			string resourceDirectory = I18N.ResourceDirectory;
			return I18NResource.GetResources(resourceDirectory, culture);
		}
	}

	public static class I18N
	{
		public static string ResourceDirectory { get; }

		static I18N()
		{
			ResourceDirectory = PathMapper.MapPath("/Areas/MixERP.Finance/i18n");
		}

		/// <summary>
		///Finance
		/// </summary>
		public static string Finance => I18NResource.GetString(ResourceDirectory, "Finance");

		/// <summary>
		///Account
		/// </summary>
		public static string Account => I18NResource.GetString(ResourceDirectory, "Account");

		/// <summary>
		///Account Code
		/// </summary>
		public static string AccountCode => I18NResource.GetString(ResourceDirectory, "AccountCode");

		/// <summary>
		///Account Id
		/// </summary>
		public static string AccountId => I18NResource.GetString(ResourceDirectory, "AccountId");

		/// <summary>
		///Account Master
		/// </summary>
		public static string AccountMaster => I18NResource.GetString(ResourceDirectory, "AccountMaster");

		/// <summary>
		///Account Master Code
		/// </summary>
		public static string AccountMasterCode => I18NResource.GetString(ResourceDirectory, "AccountMasterCode");

		/// <summary>
		///Account Master Id
		/// </summary>
		public static string AccountMasterId => I18NResource.GetString(ResourceDirectory, "AccountMasterId");

		/// <summary>
		///Account Master Name
		/// </summary>
		public static string AccountMasterName => I18NResource.GetString(ResourceDirectory, "AccountMasterName");

		/// <summary>
		///Account Name
		/// </summary>
		public static string AccountName => I18NResource.GetString(ResourceDirectory, "AccountName");

		/// <summary>
		///Account Number
		/// </summary>
		public static string AccountNumber => I18NResource.GetString(ResourceDirectory, "AccountNumber");

		/// <summary>
		///Amount In Currency
		/// </summary>
		public static string AmountInCurrency => I18NResource.GetString(ResourceDirectory, "AmountInCurrency");

		/// <summary>
		///Amount In Local Currency
		/// </summary>
		public static string AmountInLocalCurrency => I18NResource.GetString(ResourceDirectory, "AmountInLocalCurrency");

		/// <summary>
		///Asset Id
		/// </summary>
		public static string AssetId => I18NResource.GetString(ResourceDirectory, "AssetId");

		/// <summary>
		///Asset Name
		/// </summary>
		public static string AssetName => I18NResource.GetString(ResourceDirectory, "AssetName");

		/// <summary>
		///Audit Ts
		/// </summary>
		public static string AuditTs => I18NResource.GetString(ResourceDirectory, "AuditTs");

		/// <summary>
		///Audit User Id
		/// </summary>
		public static string AuditUserId => I18NResource.GetString(ResourceDirectory, "AuditUserId");

		/// <summary>
		///Auto Verification Policy Id
		/// </summary>
		public static string AutoVerificationPolicyId => I18NResource.GetString(ResourceDirectory, "AutoVerificationPolicyId");

		/// <summary>
		///Bank Account Id
		/// </summary>
		public static string BankAccountId => I18NResource.GetString(ResourceDirectory, "BankAccountId");

		/// <summary>
		///Bank Account Name
		/// </summary>
		public static string BankAccountName => I18NResource.GetString(ResourceDirectory, "BankAccountName");

		/// <summary>
		///Bank Account Number
		/// </summary>
		public static string BankAccountNumber => I18NResource.GetString(ResourceDirectory, "BankAccountNumber");

		/// <summary>
		///Bank Account Type
		/// </summary>
		public static string BankAccountType => I18NResource.GetString(ResourceDirectory, "BankAccountType");

		/// <summary>
		///Bank Branch
		/// </summary>
		public static string BankBranch => I18NResource.GetString(ResourceDirectory, "BankBranch");

		/// <summary>
		///Bank Contact Number
		/// </summary>
		public static string BankContactNumber => I18NResource.GetString(ResourceDirectory, "BankContactNumber");

		/// <summary>
		///Bank Name
		/// </summary>
		public static string BankName => I18NResource.GetString(ResourceDirectory, "BankName");

		/// <summary>
		///Bank Type Id
		/// </summary>
		public static string BankTypeId => I18NResource.GetString(ResourceDirectory, "BankTypeId");

		/// <summary>
		///Bank Type Name
		/// </summary>
		public static string BankTypeName => I18NResource.GetString(ResourceDirectory, "BankTypeName");

		/// <summary>
		///Book
		/// </summary>
		public static string Book => I18NResource.GetString(ResourceDirectory, "Book");

		/// <summary>
		///Book Date
		/// </summary>
		public static string BookDate => I18NResource.GetString(ResourceDirectory, "BookDate");

		/// <summary>
		///Can Self Verify
		/// </summary>
		public static string CanSelfVerify => I18NResource.GetString(ResourceDirectory, "CanSelfVerify");

		/// <summary>
		///Can Verify
		/// </summary>
		public static string CanVerify => I18NResource.GetString(ResourceDirectory, "CanVerify");

		/// <summary>
		///Card Type
		/// </summary>
		public static string CardType => I18NResource.GetString(ResourceDirectory, "CardType");

		/// <summary>
		///Card Type Code
		/// </summary>
		public static string CardTypeCode => I18NResource.GetString(ResourceDirectory, "CardTypeCode");

		/// <summary>
		///Card Type Id
		/// </summary>
		public static string CardTypeId => I18NResource.GetString(ResourceDirectory, "CardTypeId");

		/// <summary>
		///Card Type Name
		/// </summary>
		public static string CardTypeName => I18NResource.GetString(ResourceDirectory, "CardTypeName");

		/// <summary>
		///Cascading Tran Id
		/// </summary>
		public static string CascadingTranId => I18NResource.GetString(ResourceDirectory, "CascadingTranId");

		/// <summary>
		///Cash Account Id
		/// </summary>
		public static string CashAccountId => I18NResource.GetString(ResourceDirectory, "CashAccountId");

		/// <summary>
		///Cash Account Name
		/// </summary>
		public static string CashAccountName => I18NResource.GetString(ResourceDirectory, "CashAccountName");

		/// <summary>
		///Cash Flow Heading
		/// </summary>
		public static string CashFlowHeading => I18NResource.GetString(ResourceDirectory, "CashFlowHeading");

		/// <summary>
		///Cash Flow Heading Code
		/// </summary>
		public static string CashFlowHeadingCode => I18NResource.GetString(ResourceDirectory, "CashFlowHeadingCode");

		/// <summary>
		///Cash Flow Heading Id
		/// </summary>
		public static string CashFlowHeadingId => I18NResource.GetString(ResourceDirectory, "CashFlowHeadingId");

		/// <summary>
		///Cash Flow Heading Name
		/// </summary>
		public static string CashFlowHeadingName => I18NResource.GetString(ResourceDirectory, "CashFlowHeadingName");

		/// <summary>
		///Cash Flow Heading Type
		/// </summary>
		public static string CashFlowHeadingType => I18NResource.GetString(ResourceDirectory, "CashFlowHeadingType");

		/// <summary>
		///Cash Flow Setup Id
		/// </summary>
		public static string CashFlowSetupId => I18NResource.GetString(ResourceDirectory, "CashFlowSetupId");

		/// <summary>
		///Cash Repository Code
		/// </summary>
		public static string CashRepositoryCode => I18NResource.GetString(ResourceDirectory, "CashRepositoryCode");

		/// <summary>
		///Cash Repository Id
		/// </summary>
		public static string CashRepositoryId => I18NResource.GetString(ResourceDirectory, "CashRepositoryId");

		/// <summary>
		///Cash Repository Name
		/// </summary>
		public static string CashRepositoryName => I18NResource.GetString(ResourceDirectory, "CashRepositoryName");

		/// <summary>
		///Cell
		/// </summary>
		public static string Cell => I18NResource.GetString(ResourceDirectory, "Cell");

		/// <summary>
		///City
		/// </summary>
		public static string City => I18NResource.GetString(ResourceDirectory, "City");

		/// <summary>
		///Completed
		/// </summary>
		public static string Completed => I18NResource.GetString(ResourceDirectory, "Completed");

		/// <summary>
		///Completed By
		/// </summary>
		public static string CompletedBy => I18NResource.GetString(ResourceDirectory, "CompletedBy");

		/// <summary>
		///Completed On
		/// </summary>
		public static string CompletedOn => I18NResource.GetString(ResourceDirectory, "CompletedOn");

		/// <summary>
		///Confidential
		/// </summary>
		public static string Confidential => I18NResource.GetString(ResourceDirectory, "Confidential");

		/// <summary>
		///Cost Center Code
		/// </summary>
		public static string CostCenterCode => I18NResource.GetString(ResourceDirectory, "CostCenterCode");

		/// <summary>
		///Cost Center Id
		/// </summary>
		public static string CostCenterId => I18NResource.GetString(ResourceDirectory, "CostCenterId");

		/// <summary>
		///Cost Center Name
		/// </summary>
		public static string CostCenterName => I18NResource.GetString(ResourceDirectory, "CostCenterName");

		/// <summary>
		///Cost Of Sale Id
		/// </summary>
		public static string CostOfSaleId => I18NResource.GetString(ResourceDirectory, "CostOfSaleId");

		/// <summary>
		///Cost Of Sale Name
		/// </summary>
		public static string CostOfSaleName => I18NResource.GetString(ResourceDirectory, "CostOfSaleName");

		/// <summary>
		///Country
		/// </summary>
		public static string Country => I18NResource.GetString(ResourceDirectory, "Country");

		/// <summary>
		///Currency
		/// </summary>
		public static string Currency => I18NResource.GetString(ResourceDirectory, "Currency");

		/// <summary>
		///Currency Code
		/// </summary>
		public static string CurrencyCode => I18NResource.GetString(ResourceDirectory, "CurrencyCode");

		/// <summary>
		///Current Asset Id
		/// </summary>
		public static string CurrentAssetId => I18NResource.GetString(ResourceDirectory, "CurrentAssetId");

		/// <summary>
		///Current Asset Name
		/// </summary>
		public static string CurrentAssetName => I18NResource.GetString(ResourceDirectory, "CurrentAssetName");

		/// <summary>
		///Current Liability Id
		/// </summary>
		public static string CurrentLiabilityId => I18NResource.GetString(ResourceDirectory, "CurrentLiabilityId");

		/// <summary>
		///Current Liability Name
		/// </summary>
		public static string CurrentLiabilityName => I18NResource.GetString(ResourceDirectory, "CurrentLiabilityName");

		/// <summary>
		///Customer Pays Fee
		/// </summary>
		public static string CustomerPaysFee => I18NResource.GetString(ResourceDirectory, "CustomerPaysFee");

		/// <summary>
		///Day Id
		/// </summary>
		public static string DayId => I18NResource.GetString(ResourceDirectory, "DayId");

		/// <summary>
		///Day Operation Routine Id
		/// </summary>
		public static string DayOperationRoutineId => I18NResource.GetString(ResourceDirectory, "DayOperationRoutineId");

		/// <summary>
		///Deleted
		/// </summary>
		public static string Deleted => I18NResource.GetString(ResourceDirectory, "Deleted");

		/// <summary>
		///Description
		/// </summary>
		public static string Description => I18NResource.GetString(ResourceDirectory, "Description");

		/// <summary>
		///Direct Cost Id
		/// </summary>
		public static string DirectCostId => I18NResource.GetString(ResourceDirectory, "DirectCostId");

		/// <summary>
		///Direct Cost Name
		/// </summary>
		public static string DirectCostName => I18NResource.GetString(ResourceDirectory, "DirectCostName");

		/// <summary>
		///Dividends Paid Id
		/// </summary>
		public static string DividendsPaidId => I18NResource.GetString(ResourceDirectory, "DividendsPaidId");

		/// <summary>
		///Dividends Paid Name
		/// </summary>
		public static string DividendsPaidName => I18NResource.GetString(ResourceDirectory, "DividendsPaidName");

		/// <summary>
		///Dividends Received Id
		/// </summary>
		public static string DividendsReceivedId => I18NResource.GetString(ResourceDirectory, "DividendsReceivedId");

		/// <summary>
		///Dividends Received Name
		/// </summary>
		public static string DividendsReceivedName => I18NResource.GetString(ResourceDirectory, "DividendsReceivedName");

		/// <summary>
		///Document Id
		/// </summary>
		public static string DocumentId => I18NResource.GetString(ResourceDirectory, "DocumentId");

		/// <summary>
		///Effective From
		/// </summary>
		public static string EffectiveFrom => I18NResource.GetString(ResourceDirectory, "EffectiveFrom");

		/// <summary>
		///Ends On
		/// </summary>
		public static string EndsOn => I18NResource.GetString(ResourceDirectory, "EndsOn");

		/// <summary>
		///Eod Required
		/// </summary>
		public static string EodRequired => I18NResource.GetString(ResourceDirectory, "EodRequired");

		/// <summary>
		///Er
		/// </summary>
		public static string Er => I18NResource.GetString(ResourceDirectory, "Er");

		/// <summary>
		///Exchange Rate
		/// </summary>
		public static string ExchangeRate => I18NResource.GetString(ResourceDirectory, "ExchangeRate");

		/// <summary>
		///Exchange Rate Detail Id
		/// </summary>
		public static string ExchangeRateDetailId => I18NResource.GetString(ResourceDirectory, "ExchangeRateDetailId");

		/// <summary>
		///Exchange Rate Id
		/// </summary>
		public static string ExchangeRateId => I18NResource.GetString(ResourceDirectory, "ExchangeRateId");

		/// <summary>
		///Expense Id
		/// </summary>
		public static string ExpenseId => I18NResource.GetString(ResourceDirectory, "ExpenseId");

		/// <summary>
		///Expense Name
		/// </summary>
		public static string ExpenseName => I18NResource.GetString(ResourceDirectory, "ExpenseName");

		/// <summary>
		///External Code
		/// </summary>
		public static string ExternalCode => I18NResource.GetString(ResourceDirectory, "ExternalCode");

		/// <summary>
		///Fax
		/// </summary>
		public static string Fax => I18NResource.GetString(ResourceDirectory, "Fax");

		/// <summary>
		///File Extension
		/// </summary>
		public static string FileExtension => I18NResource.GetString(ResourceDirectory, "FileExtension");

		/// <summary>
		///File Path
		/// </summary>
		public static string FilePath => I18NResource.GetString(ResourceDirectory, "FilePath");

		/// <summary>
		///Financial Expense Id
		/// </summary>
		public static string FinancialExpenseId => I18NResource.GetString(ResourceDirectory, "FinancialExpenseId");

		/// <summary>
		///Financial Expense Name
		/// </summary>
		public static string FinancialExpenseName => I18NResource.GetString(ResourceDirectory, "FinancialExpenseName");

		/// <summary>
		///Financial Income Id
		/// </summary>
		public static string FinancialIncomeId => I18NResource.GetString(ResourceDirectory, "FinancialIncomeId");

		/// <summary>
		///Financial Income Name
		/// </summary>
		public static string FinancialIncomeName => I18NResource.GetString(ResourceDirectory, "FinancialIncomeName");

		/// <summary>
		///Fiscal Half End Date
		/// </summary>
		public static string FiscalHalfEndDate => I18NResource.GetString(ResourceDirectory, "FiscalHalfEndDate");

		/// <summary>
		///Fiscal Half Start Date
		/// </summary>
		public static string FiscalHalfStartDate => I18NResource.GetString(ResourceDirectory, "FiscalHalfStartDate");

		/// <summary>
		///Fiscal Year Code
		/// </summary>
		public static string FiscalYearCode => I18NResource.GetString(ResourceDirectory, "FiscalYearCode");

		/// <summary>
		///Fiscal Year End Date
		/// </summary>
		public static string FiscalYearEndDate => I18NResource.GetString(ResourceDirectory, "FiscalYearEndDate");

		/// <summary>
		///Fiscal Year Id
		/// </summary>
		public static string FiscalYearId => I18NResource.GetString(ResourceDirectory, "FiscalYearId");

		/// <summary>
		///Fiscal Year Name
		/// </summary>
		public static string FiscalYearName => I18NResource.GetString(ResourceDirectory, "FiscalYearName");

		/// <summary>
		///Fiscal Year Start Date
		/// </summary>
		public static string FiscalYearStartDate => I18NResource.GetString(ResourceDirectory, "FiscalYearStartDate");

		/// <summary>
		///Fixed Asset Id
		/// </summary>
		public static string FixedAssetId => I18NResource.GetString(ResourceDirectory, "FixedAssetId");

		/// <summary>
		///Fixed Asset Name
		/// </summary>
		public static string FixedAssetName => I18NResource.GetString(ResourceDirectory, "FixedAssetName");

		/// <summary>
		///Foreign Currency Code
		/// </summary>
		public static string ForeignCurrencyCode => I18NResource.GetString(ResourceDirectory, "ForeignCurrencyCode");

		/// <summary>
		///Frequency Code
		/// </summary>
		public static string FrequencyCode => I18NResource.GetString(ResourceDirectory, "FrequencyCode");

		/// <summary>
		///Frequency Id
		/// </summary>
		public static string FrequencyId => I18NResource.GetString(ResourceDirectory, "FrequencyId");

		/// <summary>
		///Frequency Name
		/// </summary>
		public static string FrequencyName => I18NResource.GetString(ResourceDirectory, "FrequencyName");

		/// <summary>
		///Frequency Setup Code
		/// </summary>
		public static string FrequencySetupCode => I18NResource.GetString(ResourceDirectory, "FrequencySetupCode");

		/// <summary>
		///Frequency Setup Id
		/// </summary>
		public static string FrequencySetupId => I18NResource.GetString(ResourceDirectory, "FrequencySetupId");

		/// <summary>
		///Has Child
		/// </summary>
		public static string HasChild => I18NResource.GetString(ResourceDirectory, "HasChild");

		/// <summary>
		///Income Id
		/// </summary>
		public static string IncomeId => I18NResource.GetString(ResourceDirectory, "IncomeId");

		/// <summary>
		///Income Name
		/// </summary>
		public static string IncomeName => I18NResource.GetString(ResourceDirectory, "IncomeName");

		/// <summary>
		///Income Tax Account Id
		/// </summary>
		public static string IncomeTaxAccountId => I18NResource.GetString(ResourceDirectory, "IncomeTaxAccountId");

		/// <summary>
		///Income Tax Expense Id
		/// </summary>
		public static string IncomeTaxExpenseId => I18NResource.GetString(ResourceDirectory, "IncomeTaxExpenseId");

		/// <summary>
		///Income Tax Expense Name
		/// </summary>
		public static string IncomeTaxExpenseName => I18NResource.GetString(ResourceDirectory, "IncomeTaxExpenseName");

		/// <summary>
		///Income Tax Rate
		/// </summary>
		public static string IncomeTaxRate => I18NResource.GetString(ResourceDirectory, "IncomeTaxRate");

		/// <summary>
		///Interest Expense Id
		/// </summary>
		public static string InterestExpenseId => I18NResource.GetString(ResourceDirectory, "InterestExpenseId");

		/// <summary>
		///Interest Expense Name
		/// </summary>
		public static string InterestExpenseName => I18NResource.GetString(ResourceDirectory, "InterestExpenseName");

		/// <summary>
		///Is Active
		/// </summary>
		public static string IsActive => I18NResource.GetString(ResourceDirectory, "IsActive");

		/// <summary>
		///Is Debit
		/// </summary>
		public static string IsDebit => I18NResource.GetString(ResourceDirectory, "IsDebit");

		/// <summary>
		///Is Merchant Account
		/// </summary>
		public static string IsMerchantAccount => I18NResource.GetString(ResourceDirectory, "IsMerchantAccount");

		/// <summary>
		///Is Purchase
		/// </summary>
		public static string IsPurchase => I18NResource.GetString(ResourceDirectory, "IsPurchase");

		/// <summary>
		///Is Sales
		/// </summary>
		public static string IsSales => I18NResource.GetString(ResourceDirectory, "IsSales");

		/// <summary>
		///Is Transaction Node
		/// </summary>
		public static string IsTransactionNode => I18NResource.GetString(ResourceDirectory, "IsTransactionNode");

		/// <summary>
		///Journal Verification Policy Id
		/// </summary>
		public static string JournalVerificationPolicyId => I18NResource.GetString(ResourceDirectory, "JournalVerificationPolicyId");

		/// <summary>
		///Last Verified On
		/// </summary>
		public static string LastVerifiedOn => I18NResource.GetString(ResourceDirectory, "LastVerifiedOn");

		/// <summary>
		///Liability Id
		/// </summary>
		public static string LiabilityId => I18NResource.GetString(ResourceDirectory, "LiabilityId");

		/// <summary>
		///Liability Name
		/// </summary>
		public static string LiabilityName => I18NResource.GetString(ResourceDirectory, "LiabilityName");

		/// <summary>
		///Local Currency Code
		/// </summary>
		public static string LocalCurrencyCode => I18NResource.GetString(ResourceDirectory, "LocalCurrencyCode");

		/// <summary>
		///Login Id
		/// </summary>
		public static string LoginId => I18NResource.GetString(ResourceDirectory, "LoginId");

		/// <summary>
		///Long Term Liability Id
		/// </summary>
		public static string LongTermLiabilityId => I18NResource.GetString(ResourceDirectory, "LongTermLiabilityId");

		/// <summary>
		///Long Term Liability Name
		/// </summary>
		public static string LongTermLiabilityName => I18NResource.GetString(ResourceDirectory, "LongTermLiabilityName");

		/// <summary>
		///Maintained By
		/// </summary>
		public static string MaintainedBy => I18NResource.GetString(ResourceDirectory, "MaintainedBy");

		/// <summary>
		///Maintained By User Id
		/// </summary>
		public static string MaintainedByUserId => I18NResource.GetString(ResourceDirectory, "MaintainedByUserId");

		/// <summary>
		///Master Statement Reference
		/// </summary>
		public static string MasterStatementReference => I18NResource.GetString(ResourceDirectory, "MasterStatementReference");

		/// <summary>
		///Memo
		/// </summary>
		public static string Memo => I18NResource.GetString(ResourceDirectory, "Memo");

		/// <summary>
		///Merchant Account
		/// </summary>
		public static string MerchantAccount => I18NResource.GetString(ResourceDirectory, "MerchantAccount");

		/// <summary>
		///Merchant Account Id
		/// </summary>
		public static string MerchantAccountId => I18NResource.GetString(ResourceDirectory, "MerchantAccountId");

		/// <summary>
		///Merchant Fee Setup Id
		/// </summary>
		public static string MerchantFeeSetupId => I18NResource.GetString(ResourceDirectory, "MerchantFeeSetupId");

		/// <summary>
		///Month End Date
		/// </summary>
		public static string MonthEndDate => I18NResource.GetString(ResourceDirectory, "MonthEndDate");

		/// <summary>
		///Month Start Date
		/// </summary>
		public static string MonthStartDate => I18NResource.GetString(ResourceDirectory, "MonthStartDate");

		/// <summary>
		///New Day Started
		/// </summary>
		public static string NewDayStarted => I18NResource.GetString(ResourceDirectory, "NewDayStarted");

		/// <summary>
		///Non Operating Income Id
		/// </summary>
		public static string NonOperatingIncomeId => I18NResource.GetString(ResourceDirectory, "NonOperatingIncomeId");

		/// <summary>
		///Non Operating Income Name
		/// </summary>
		public static string NonOperatingIncomeName => I18NResource.GetString(ResourceDirectory, "NonOperatingIncomeName");

		/// <summary>
		///Normally Debit
		/// </summary>
		public static string NormallyDebit => I18NResource.GetString(ResourceDirectory, "NormallyDebit");

		/// <summary>
		///Office
		/// </summary>
		public static string Office => I18NResource.GetString(ResourceDirectory, "Office");

		/// <summary>
		///Office Id
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///Office Name
		/// </summary>
		public static string OfficeName => I18NResource.GetString(ResourceDirectory, "OfficeName");

		/// <summary>
		///Operating Expense Id
		/// </summary>
		public static string OperatingExpenseId => I18NResource.GetString(ResourceDirectory, "OperatingExpenseId");

		/// <summary>
		///Operating Expense Name
		/// </summary>
		public static string OperatingExpenseName => I18NResource.GetString(ResourceDirectory, "OperatingExpenseName");

		/// <summary>
		///Order
		/// </summary>
		public static string Order => I18NResource.GetString(ResourceDirectory, "Order");

		/// <summary>
		///Original File Name
		/// </summary>
		public static string OriginalFileName => I18NResource.GetString(ResourceDirectory, "OriginalFileName");

		/// <summary>
		///Other Asset Id
		/// </summary>
		public static string OtherAssetId => I18NResource.GetString(ResourceDirectory, "OtherAssetId");

		/// <summary>
		///Other Asset Name
		/// </summary>
		public static string OtherAssetName => I18NResource.GetString(ResourceDirectory, "OtherAssetName");

		/// <summary>
		///Parent
		/// </summary>
		public static string Parent => I18NResource.GetString(ResourceDirectory, "Parent");

		/// <summary>
		///Parent Account
		/// </summary>
		public static string ParentAccount => I18NResource.GetString(ResourceDirectory, "ParentAccount");

		/// <summary>
		///Parent Account Id
		/// </summary>
		public static string ParentAccountId => I18NResource.GetString(ResourceDirectory, "ParentAccountId");

		/// <summary>
		///Parent Account Master Id
		/// </summary>
		public static string ParentAccountMasterId => I18NResource.GetString(ResourceDirectory, "ParentAccountMasterId");

		/// <summary>
		///Parent Account Name
		/// </summary>
		public static string ParentAccountName => I18NResource.GetString(ResourceDirectory, "ParentAccountName");

		/// <summary>
		///Parent Account Number
		/// </summary>
		public static string ParentAccountNumber => I18NResource.GetString(ResourceDirectory, "ParentAccountNumber");

		/// <summary>
		///Parent Cash Repository
		/// </summary>
		public static string ParentCashRepository => I18NResource.GetString(ResourceDirectory, "ParentCashRepository");

		/// <summary>
		///Parent Cash Repository Id
		/// </summary>
		public static string ParentCashRepositoryId => I18NResource.GetString(ResourceDirectory, "ParentCashRepositoryId");

		/// <summary>
		///Payable Account Id
		/// </summary>
		public static string PayableAccountId => I18NResource.GetString(ResourceDirectory, "PayableAccountId");

		/// <summary>
		///Payable Account Name
		/// </summary>
		public static string PayableAccountName => I18NResource.GetString(ResourceDirectory, "PayableAccountName");

		/// <summary>
		///Payment Card
		/// </summary>
		public static string PaymentCard => I18NResource.GetString(ResourceDirectory, "PaymentCard");

		/// <summary>
		///Payment Card Code
		/// </summary>
		public static string PaymentCardCode => I18NResource.GetString(ResourceDirectory, "PaymentCardCode");

		/// <summary>
		///Payment Card Id
		/// </summary>
		public static string PaymentCardId => I18NResource.GetString(ResourceDirectory, "PaymentCardId");

		/// <summary>
		///Payment Card Name
		/// </summary>
		public static string PaymentCardName => I18NResource.GetString(ResourceDirectory, "PaymentCardName");

		/// <summary>
		///Phone
		/// </summary>
		public static string Phone => I18NResource.GetString(ResourceDirectory, "Phone");

		/// <summary>
		///Property Plant Equipment Id
		/// </summary>
		public static string PropertyPlantEquipmentId => I18NResource.GetString(ResourceDirectory, "PropertyPlantEquipmentId");

		/// <summary>
		///Property Plant Equipment Name
		/// </summary>
		public static string PropertyPlantEquipmentName => I18NResource.GetString(ResourceDirectory, "PropertyPlantEquipmentName");

		/// <summary>
		///Quarter End Date
		/// </summary>
		public static string QuarterEndDate => I18NResource.GetString(ResourceDirectory, "QuarterEndDate");

		/// <summary>
		///Quarter Start Date
		/// </summary>
		public static string QuarterStartDate => I18NResource.GetString(ResourceDirectory, "QuarterStartDate");

		/// <summary>
		///Rate
		/// </summary>
		public static string Rate => I18NResource.GetString(ResourceDirectory, "Rate");

		/// <summary>
		///Receivable Account Id
		/// </summary>
		public static string ReceivableAccountId => I18NResource.GetString(ResourceDirectory, "ReceivableAccountId");

		/// <summary>
		///Receivable Account Name
		/// </summary>
		public static string ReceivableAccountName => I18NResource.GetString(ResourceDirectory, "ReceivableAccountName");

		/// <summary>
		///Reconciliation Memo
		/// </summary>
		public static string ReconciliationMemo => I18NResource.GetString(ResourceDirectory, "ReconciliationMemo");

		/// <summary>
		///Reference Number
		/// </summary>
		public static string ReferenceNumber => I18NResource.GetString(ResourceDirectory, "ReferenceNumber");

		/// <summary>
		///Relationship Officer Contact Number
		/// </summary>
		public static string RelationshipOfficerContactNumber => I18NResource.GetString(ResourceDirectory, "RelationshipOfficerContactNumber");

		/// <summary>
		///Relationship Officer Name
		/// </summary>
		public static string RelationshipOfficerName => I18NResource.GetString(ResourceDirectory, "RelationshipOfficerName");

		/// <summary>
		///Retained Earning Id
		/// </summary>
		public static string RetainedEarningId => I18NResource.GetString(ResourceDirectory, "RetainedEarningId");

		/// <summary>
		///Retained Earning Name
		/// </summary>
		public static string RetainedEarningName => I18NResource.GetString(ResourceDirectory, "RetainedEarningName");

		/// <summary>
		///Revenue Id
		/// </summary>
		public static string RevenueId => I18NResource.GetString(ResourceDirectory, "RevenueId");

		/// <summary>
		///Revenue Name
		/// </summary>
		public static string RevenueName => I18NResource.GetString(ResourceDirectory, "RevenueName");

		/// <summary>
		///Routine Code
		/// </summary>
		public static string RoutineCode => I18NResource.GetString(ResourceDirectory, "RoutineCode");

		/// <summary>
		///Routine Id
		/// </summary>
		public static string RoutineId => I18NResource.GetString(ResourceDirectory, "RoutineId");

		/// <summary>
		///Routine Name
		/// </summary>
		public static string RoutineName => I18NResource.GetString(ResourceDirectory, "RoutineName");

		/// <summary>
		///Salary Payable Id
		/// </summary>
		public static string SalaryPayableId => I18NResource.GetString(ResourceDirectory, "SalaryPayableId");

		/// <summary>
		///Salary Payable Name
		/// </summary>
		public static string SalaryPayableName => I18NResource.GetString(ResourceDirectory, "SalaryPayableName");

		/// <summary>
		///Sales Tax Account Id
		/// </summary>
		public static string SalesTaxAccountId => I18NResource.GetString(ResourceDirectory, "SalesTaxAccountId");

		/// <summary>
		///Sales Tax Rate
		/// </summary>
		public static string SalesTaxRate => I18NResource.GetString(ResourceDirectory, "SalesTaxRate");

		/// <summary>
		///Self Verification Limit
		/// </summary>
		public static string SelfVerificationLimit => I18NResource.GetString(ResourceDirectory, "SelfVerificationLimit");

		/// <summary>
		///Shareholders Equity Id
		/// </summary>
		public static string ShareholdersEquityId => I18NResource.GetString(ResourceDirectory, "ShareholdersEquityId");

		/// <summary>
		///Shareholders Equity Name
		/// </summary>
		public static string ShareholdersEquityName => I18NResource.GetString(ResourceDirectory, "ShareholdersEquityName");

		/// <summary>
		///Started By
		/// </summary>
		public static string StartedBy => I18NResource.GetString(ResourceDirectory, "StartedBy");

		/// <summary>
		///Started On
		/// </summary>
		public static string StartedOn => I18NResource.GetString(ResourceDirectory, "StartedOn");

		/// <summary>
		///Starts From
		/// </summary>
		public static string StartsFrom => I18NResource.GetString(ResourceDirectory, "StartsFrom");

		/// <summary>
		///State
		/// </summary>
		public static string State => I18NResource.GetString(ResourceDirectory, "State");

		/// <summary>
		///Statement Reference
		/// </summary>
		public static string StatementReference => I18NResource.GetString(ResourceDirectory, "StatementReference");

		/// <summary>
		///Status
		/// </summary>
		public static string Status => I18NResource.GetString(ResourceDirectory, "Status");

		/// <summary>
		///Street
		/// </summary>
		public static string Street => I18NResource.GetString(ResourceDirectory, "Street");

		/// <summary>
		///Sys Type
		/// </summary>
		public static string SysType => I18NResource.GetString(ResourceDirectory, "SysType");

		/// <summary>
		///Tax Setup Id
		/// </summary>
		public static string TaxSetupId => I18NResource.GetString(ResourceDirectory, "TaxSetupId");

		/// <summary>
		///Today
		/// </summary>
		public static string Today => I18NResource.GetString(ResourceDirectory, "Today");

		/// <summary>
		///Tran Type
		/// </summary>
		public static string TranType => I18NResource.GetString(ResourceDirectory, "TranType");

		/// <summary>
		///Transaction Code
		/// </summary>
		public static string TransactionCode => I18NResource.GetString(ResourceDirectory, "TransactionCode");

		/// <summary>
		///Transaction Counter
		/// </summary>
		public static string TransactionCounter => I18NResource.GetString(ResourceDirectory, "TransactionCounter");

		/// <summary>
		///Transaction Detail Id
		/// </summary>
		public static string TransactionDetailId => I18NResource.GetString(ResourceDirectory, "TransactionDetailId");

		/// <summary>
		///Transaction Master Id
		/// </summary>
		public static string TransactionMasterId => I18NResource.GetString(ResourceDirectory, "TransactionMasterId");

		/// <summary>
		///Transaction Ts
		/// </summary>
		public static string TransactionTs => I18NResource.GetString(ResourceDirectory, "TransactionTs");

		/// <summary>
		///Transaction Type Code
		/// </summary>
		public static string TransactionTypeCode => I18NResource.GetString(ResourceDirectory, "TransactionTypeCode");

		/// <summary>
		///Transaction Type Id
		/// </summary>
		public static string TransactionTypeId => I18NResource.GetString(ResourceDirectory, "TransactionTypeId");

		/// <summary>
		///Transaction Type Name
		/// </summary>
		public static string TransactionTypeName => I18NResource.GetString(ResourceDirectory, "TransactionTypeName");

		/// <summary>
		///Unit
		/// </summary>
		public static string Unit => I18NResource.GetString(ResourceDirectory, "Unit");

		/// <summary>
		///Updated On
		/// </summary>
		public static string UpdatedOn => I18NResource.GetString(ResourceDirectory, "UpdatedOn");

		/// <summary>
		///User
		/// </summary>
		public static string User => I18NResource.GetString(ResourceDirectory, "User");

		/// <summary>
		///User Id
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///Value Date
		/// </summary>
		public static string ValueDate => I18NResource.GetString(ResourceDirectory, "ValueDate");

		/// <summary>
		///Verification Limit
		/// </summary>
		public static string VerificationLimit => I18NResource.GetString(ResourceDirectory, "VerificationLimit");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Verification Status Id
		/// </summary>
		public static string VerificationStatusId => I18NResource.GetString(ResourceDirectory, "VerificationStatusId");

		/// <summary>
		///Verified By User Id
		/// </summary>
		public static string VerifiedByUserId => I18NResource.GetString(ResourceDirectory, "VerifiedByUserId");

		/// <summary>
		///Verifier Name
		/// </summary>
		public static string VerifierName => I18NResource.GetString(ResourceDirectory, "VerifierName");

		/// <summary>
		///Tasks
		/// </summary>
		public static string Tasks => I18NResource.GetString(ResourceDirectory, "Tasks");

		/// <summary>
		///Journal Entry
		/// </summary>
		public static string JournalEntry => I18NResource.GetString(ResourceDirectory, "JournalEntry");

		/// <summary>
		///Exchange Rates
		/// </summary>
		public static string ExchangeRates => I18NResource.GetString(ResourceDirectory, "ExchangeRates");

		/// <summary>
		///Journal Verification
		/// </summary>
		public static string JournalVerification => I18NResource.GetString(ResourceDirectory, "JournalVerification");

		/// <summary>
		///Verification Policy
		/// </summary>
		public static string VerificationPolicy => I18NResource.GetString(ResourceDirectory, "VerificationPolicy");

		/// <summary>
		///Auto Verification Policy
		/// </summary>
		public static string AutoVerificationPolicy => I18NResource.GetString(ResourceDirectory, "AutoVerificationPolicy");

		/// <summary>
		///Account Reconciliation
		/// </summary>
		public static string AccountReconciliation => I18NResource.GetString(ResourceDirectory, "AccountReconciliation");

		/// <summary>
		///EOD Processing
		/// </summary>
		public static string EODProcessing => I18NResource.GetString(ResourceDirectory, "EODProcessing");

		/// <summary>
		///Refresh Materialized Views
		/// </summary>
		public static string RefreshMaterializedViews => I18NResource.GetString(ResourceDirectory, "RefreshMaterializedViews");

		/// <summary>
		///Import Transactions
		/// </summary>
		public static string ImportTransactions => I18NResource.GetString(ResourceDirectory, "ImportTransactions");

		/// <summary>
		///Setup
		/// </summary>
		public static string Setup => I18NResource.GetString(ResourceDirectory, "Setup");

		/// <summary>
		///Chart of Accounts
		/// </summary>
		public static string ChartOfAccounts => I18NResource.GetString(ResourceDirectory, "ChartOfAccounts");

		/// <summary>
		///Currencies
		/// </summary>
		public static string Currencies => I18NResource.GetString(ResourceDirectory, "Currencies");

		/// <summary>
		///Bank Accounts
		/// </summary>
		public static string BankAccounts => I18NResource.GetString(ResourceDirectory, "BankAccounts");

		/// <summary>
		///Cash Flow Headings
		/// </summary>
		public static string CashFlowHeadings => I18NResource.GetString(ResourceDirectory, "CashFlowHeadings");

		/// <summary>
		///Cash Flow Setup
		/// </summary>
		public static string CashFlowSetup => I18NResource.GetString(ResourceDirectory, "CashFlowSetup");

		/// <summary>
		///Cost Centers
		/// </summary>
		public static string CostCenters => I18NResource.GetString(ResourceDirectory, "CostCenters");

		/// <summary>
		///Cash Repositories
		/// </summary>
		public static string CashRepositories => I18NResource.GetString(ResourceDirectory, "CashRepositories");

		/// <summary>
		///Fiscal Years
		/// </summary>
		public static string FiscalYears => I18NResource.GetString(ResourceDirectory, "FiscalYears");

		/// <summary>
		///Frequency Setups
		/// </summary>
		public static string FrequencySetups => I18NResource.GetString(ResourceDirectory, "FrequencySetups");

		/// <summary>
		///Reports
		/// </summary>
		public static string Reports => I18NResource.GetString(ResourceDirectory, "Reports");

		/// <summary>
		///Account Statement
		/// </summary>
		public static string AccountStatement => I18NResource.GetString(ResourceDirectory, "AccountStatement");

		/// <summary>
		///Trial Balance
		/// </summary>
		public static string TrialBalance => I18NResource.GetString(ResourceDirectory, "TrialBalance");

		/// <summary>
		///Transaction Summary
		/// </summary>
		public static string TransactionSummary => I18NResource.GetString(ResourceDirectory, "TransactionSummary");

		/// <summary>
		///Profit & Loss Account
		/// </summary>
		public static string ProfitAndLossAccount => I18NResource.GetString(ResourceDirectory, "ProfitAndLossAccount");

		/// <summary>
		///Retained Earnings Statement
		/// </summary>
		public static string RetainedEarningsStatement => I18NResource.GetString(ResourceDirectory, "RetainedEarningsStatement");

		/// <summary>
		///Balance Sheet
		/// </summary>
		public static string BalanceSheet => I18NResource.GetString(ResourceDirectory, "BalanceSheet");

		/// <summary>
		///Cash Flow
		/// </summary>
		public static string CashFlow => I18NResource.GetString(ResourceDirectory, "CashFlow");

		/// <summary>
		///Exchange Rate Report
		/// </summary>
		public static string ExchangeRateReport => I18NResource.GetString(ResourceDirectory, "ExchangeRateReport");

		/// <summary>
		///Access is denied. You cannot withdraw someone else's transaction.
		/// </summary>
		public static string AccessDeniedCannotWithdrawSomeoneElseTransaction => I18NResource.GetString(ResourceDirectory, "AccessDeniedCannotWithdrawSomeoneElseTransaction");

		/// <summary>
		///Access is denied.
		/// </summary>
		public static string AccessIsDenied => I18NResource.GetString(ResourceDirectory, "AccessIsDenied");

		/// <summary>
		///Accountant Report
		/// </summary>
		public static string AccountantSummary => I18NResource.GetString(ResourceDirectory, "AccountantSummary");

		/// <summary>
		///Account Payable Vendor Report
		/// </summary>
		public static string AccountPayableVendor => I18NResource.GetString(ResourceDirectory, "AccountPayableVendor");

		/// <summary>
		///Account Receivable By Customer Report
		/// </summary>
		public static string AccountReceivableByCustomer => I18NResource.GetString(ResourceDirectory, "AccountReceivableByCustomer");

		/// <summary>
		///Action
		/// </summary>
		public static string Action => I18NResource.GetString(ResourceDirectory, "Action");

		/// <summary>
		///Actions
		/// </summary>
		public static string Actions => I18NResource.GetString(ResourceDirectory, "Actions");

		/// <summary>
		///Add
		/// </summary>
		public static string Add => I18NResource.GetString(ResourceDirectory, "Add");

		/// <summary>
		///Add New
		/// </summary>
		public static string AddNew => I18NResource.GetString(ResourceDirectory, "AddNew");

		/// <summary>
		///Add a New Journal Entry
		/// </summary>
		public static string AddNewJournalEntry => I18NResource.GetString(ResourceDirectory, "AddNewJournalEntry");

		/// <summary>
		///Add Note
		/// </summary>
		public static string AddNote => I18NResource.GetString(ResourceDirectory, "AddNote");

		/// <summary>
		///Advice
		/// </summary>
		public static string Advice => I18NResource.GetString(ResourceDirectory, "Advice");

		/// <summary>
		///Approved By
		/// </summary>
		public static string ApprovedBy => I18NResource.GetString(ResourceDirectory, "ApprovedBy");

		/// <summary>
		///Are you sure?
		/// </summary>
		public static string AreYouSure => I18NResource.GetString(ResourceDirectory, "AreYouSure");

		/// <summary>
		///Attach All Documents
		/// </summary>
		public static string AttachAllDocuments => I18NResource.GetString(ResourceDirectory, "AttachAllDocuments");

		/// <summary>
		///Balance
		/// </summary>
		public static string Balance => I18NResource.GetString(ResourceDirectory, "Balance");

		/// <summary>
		///Base Currency
		/// </summary>
		public static string BaseCurrency => I18NResource.GetString(ResourceDirectory, "BaseCurrency");

		/// <summary>
		///Cancel
		/// </summary>
		public static string Cancel => I18NResource.GetString(ResourceDirectory, "Cancel");

		/// <summary>
		///Cancel/Withdraw Transaction
		/// </summary>
		public static string CancelWithdrawTransaction => I18NResource.GetString(ResourceDirectory, "CancelWithdrawTransaction");

		/// <summary>
		///Cannot Validate Your File
		/// </summary>
		public static string CannotValidateYourFile => I18NResource.GetString(ResourceDirectory, "CannotValidateYourFile");

		/// <summary>
		///Cannot withdraw transaction during restricted transaction mode.
		/// </summary>
		public static string CannotWithdrawTransactionDuringRestrictedTransactionMode => I18NResource.GetString(ResourceDirectory, "CannotWithdrawTransactionDuringRestrictedTransactionMode");

		/// <summary>
		///Cash Flow Setups
		/// </summary>
		public static string CashFlowSetups => I18NResource.GetString(ResourceDirectory, "CashFlowSetups");

		/// <summary>
		///Cash Flow Statement
		/// </summary>
		public static string CashFlowStatement => I18NResource.GetString(ResourceDirectory, "CashFlowStatement");

		/// <summary>
		///Cash Repository
		/// </summary>
		public static string CashRepository => I18NResource.GetString(ResourceDirectory, "CashRepository");

		/// <summary>
		///Checklist
		/// </summary>
		public static string Checklist => I18NResource.GetString(ResourceDirectory, "Checklist");

		/// <summary>
		///Checklist Window
		/// </summary>
		public static string ChecklistWindow => I18NResource.GetString(ResourceDirectory, "ChecklistWindow");

		/// <summary>
		///Closed Out Report
		/// </summary>
		public static string ClosedOut => I18NResource.GetString(ResourceDirectory, "ClosedOut");

		/// <summary>
		///Cost Center
		/// </summary>
		public static string CostCenter => I18NResource.GetString(ResourceDirectory, "CostCenter");

		/// <summary>
		///Create a New Reminder
		/// </summary>
		public static string CreateNewReminder => I18NResource.GetString(ResourceDirectory, "CreateNewReminder");

		/// <summary>
		///Credit
		/// </summary>
		public static string Credit => I18NResource.GetString(ResourceDirectory, "Credit");

		/// <summary>
		///Credit Total
		/// </summary>
		public static string CreditTotal => I18NResource.GetString(ResourceDirectory, "CreditTotal");

		/// <summary>
		///Ctrl + Alt + A
		/// </summary>
		public static string CtrlAltA => I18NResource.GetString(ResourceDirectory, "CtrlAltA");

		/// <summary>
		///Ctrl + Alt + C
		/// </summary>
		public static string CtrlAltC => I18NResource.GetString(ResourceDirectory, "CtrlAltC");

		/// <summary>
		///Ctrl + Alt + D
		/// </summary>
		public static string CtrlAltD => I18NResource.GetString(ResourceDirectory, "CtrlAltD");

		/// <summary>
		///Ctrl + Alt +S
		/// </summary>
		public static string CtrlAltS => I18NResource.GetString(ResourceDirectory, "CtrlAltS");

		/// <summary>
		///Ctrl + Alt + T
		/// </summary>
		public static string CtrlAltT => I18NResource.GetString(ResourceDirectory, "CtrlAltT");

		/// <summary>
		///Ctrl + Return
		/// </summary>
		public static string CtrlReturn => I18NResource.GetString(ResourceDirectory, "CtrlReturn");

		/// <summary>
		///Currency Name
		/// </summary>
		public static string CurrencyName => I18NResource.GetString(ResourceDirectory, "CurrencyName");

		/// <summary>
		///Day
		/// </summary>
		public static string Day => I18NResource.GetString(ResourceDirectory, "Day");

		/// <summary>
		///days
		/// </summary>
		public static string Days => I18NResource.GetString(ResourceDirectory, "Days");

		/// <summary>
		///Debit
		/// </summary>
		public static string Debit => I18NResource.GetString(ResourceDirectory, "Debit");

		/// <summary>
		///Debit Total
		/// </summary>
		public static string DebitTotal => I18NResource.GetString(ResourceDirectory, "DebitTotal");

		/// <summary>
		///Details
		/// </summary>
		public static string Details => I18NResource.GetString(ResourceDirectory, "Details");

		/// <summary>
		///Display This Reminder to Other Users
		/// </summary>
		public static string DisplayReminderOtherUsers => I18NResource.GetString(ResourceDirectory, "DisplayReminderOtherUsers");

		/// <summary>
		///Documents
		/// </summary>
		public static string Documents => I18NResource.GetString(ResourceDirectory, "Documents");

		/// <summary>
		///Duplicate entry.
		/// </summary>
		public static string DuplicateEntry => I18NResource.GetString(ResourceDirectory, "DuplicateEntry");

		/// <summary>
		///Email Me This Document
		/// </summary>
		public static string EmailMeDocument => I18NResource.GetString(ResourceDirectory, "EmailMeDocument");

		/// <summary>
		///Enter Description for Reminder
		/// </summary>
		public static string EnterDescriptionReminder => I18NResource.GetString(ResourceDirectory, "EnterDescriptionReminder");

		/// <summary>
		///Enter New Book Date
		/// </summary>
		public static string EnterNewBookDate => I18NResource.GetString(ResourceDirectory, "EnterNewBookDate");

		/// <summary>
		///<p>Please close this window and save your existing work before you will be signed off automatically.</p>
		/// </summary>
		public static string EODBegunSaveYourWork => I18NResource.GetString(ResourceDirectory, "EODBegunSaveYourWork");

		/// <summary>
		///EOD Console
		/// </summary>
		public static string EODConsole => I18NResource.GetString(ResourceDirectory, "EODConsole");

		/// <summary>
		///EOD operation has begun now.
		/// </summary>
		public static string EODOperationBegunNow => I18NResource.GetString(ResourceDirectory, "EODOperationBegunNow");

		/// <summary>
		///EOD Processing Has Begun
		/// </summary>
		public static string EODProcessingBegun => I18NResource.GetString(ResourceDirectory, "EODProcessingBegun");

		/// <summary>
		///Export
		/// </summary>
		public static string Export => I18NResource.GetString(ResourceDirectory, "Export");

		/// <summary>
		///Export This Document
		/// </summary>
		public static string ExportThisDocument => I18NResource.GetString(ResourceDirectory, "ExportThisDocument");

		/// <summary>
		///Export to Doc
		/// </summary>
		public static string ExportToDoc => I18NResource.GetString(ResourceDirectory, "ExportToDoc");

		/// <summary>
		///Export to Excel
		/// </summary>
		public static string ExportToExcel => I18NResource.GetString(ResourceDirectory, "ExportToExcel");

		/// <summary>
		///Export to PDF
		/// </summary>
		public static string ExportToPDF => I18NResource.GetString(ResourceDirectory, "ExportToPDF");

		/// <summary>
		///Factor
		/// </summary>
		public static string Factor => I18NResource.GetString(ResourceDirectory, "Factor");

		/// <summary>
		///From
		/// </summary>
		public static string From => I18NResource.GetString(ResourceDirectory, "From");

		/// <summary>
		///Grand Total
		/// </summary>
		public static string GrandTotal => I18NResource.GetString(ResourceDirectory, "GrandTotal");

		/// <summary>
		///Gridview is empty.
		/// </summary>
		public static string GridViewEmpty => I18NResource.GetString(ResourceDirectory, "GridViewEmpty");

		/// <summary>
		///Hour
		/// </summary>
		public static string Hour => I18NResource.GetString(ResourceDirectory, "Hour");

		/// <summary>
		///hours
		/// </summary>
		public static string Hours => I18NResource.GetString(ResourceDirectory, "Hours");

		/// <summary>
		///hours before the schedule
		/// </summary>
		public static string HoursBeforeSchedule => I18NResource.GetString(ResourceDirectory, "HoursBeforeSchedule");

		/// <summary>
		///Hundredth Name
		/// </summary>
		public static string HundredthName => I18NResource.GetString(ResourceDirectory, "HundredthName");

		/// <summary>
		///Import Data
		/// </summary>
		public static string ImportData => I18NResource.GetString(ResourceDirectory, "ImportData");

		/// <summary>
		///Import Failed!
		/// </summary>
		public static string ImportFailed => I18NResource.GetString(ResourceDirectory, "ImportFailed");

		/// <summary>
		///You can bulk import journal transaction from a CSV file into MixERP. Click "Export Template" button to download a CSV template file. Create a file that matches with the export template. Import the CSV file.
		/// </summary>
		public static string ImportTransactionsDescription => I18NResource.GetString(ResourceDirectory, "ImportTransactionsDescription");

		/// <summary>
		///Including Other Participants
		/// </summary>
		public static string IncludingOtherParticipants => I18NResource.GetString(ResourceDirectory, "IncludingOtherParticipants");

		/// <summary>
		///<p>When you initialize day-end operation, the already logged-in application users including you are logged off after 120 seconds.</p><p>During the day-end period, only users having elevated privilege are allowed to log-in. Please do not close this window or navigate away from this page during initialization.</p>
		/// </summary>
		public static string InitializeDayEndOperationWarningMessage => I18NResource.GetString(ResourceDirectory, "InitializeDayEndOperationWarningMessage");

		/// <summary>
		///Initialize EOD
		/// </summary>
		public static string InitializeEOD => I18NResource.GetString(ResourceDirectory, "InitializeEOD");

		/// <summary>
		///Initialize EOD Processing
		/// </summary>
		public static string InitializeEODProcessing => I18NResource.GetString(ResourceDirectory, "InitializeEODProcessing");

		/// <summary>
		///Insufficient balance in cash repository.
		/// </summary>
		public static string InsufficientBalanceInCashRepository => I18NResource.GetString(ResourceDirectory, "InsufficientBalanceInCashRepository");

		/// <summary>
		///Invalid cash repository specified.
		/// </summary>
		public static string InvalidCashRepositorySpecified => I18NResource.GetString(ResourceDirectory, "InvalidCashRepositorySpecified");

		/// <summary>
		///Invalid cost center.
		/// </summary>
		public static string InvalidCostCenter => I18NResource.GetString(ResourceDirectory, "InvalidCostCenter");

		/// <summary>
		///Invalid Currency
		/// </summary>
		public static string InvalidCurrency => I18NResource.GetString(ResourceDirectory, "InvalidCurrency");

		/// <summary>
		///Invalid currency on line {0}.
		/// </summary>
		public static string InvalidCurrencyOnLineN => I18NResource.GetString(ResourceDirectory, "InvalidCurrencyOnLineN");

		/// <summary>
		///Invalid data
		/// </summary>
		public static string InvalidData => I18NResource.GetString(ResourceDirectory, "InvalidData");

		/// <summary>
		///Invalid data found on line {0}. Either "AccountNumber" or "AccountName" should contain a value.
		/// </summary>
		public static string InvalidDataOnLineN => I18NResource.GetString(ResourceDirectory, "InvalidDataOnLineN");

		/// <summary>
		///Invalid Date
		/// </summary>
		public static string InvalidDate => I18NResource.GetString(ResourceDirectory, "InvalidDate");

		/// <summary>
		///Journal Entries
		/// </summary>
		public static string JournalEntries => I18NResource.GetString(ResourceDirectory, "JournalEntries");

		/// <summary>
		///Journal Entry Verification
		/// </summary>
		public static string JournalEntryVerification => I18NResource.GetString(ResourceDirectory, "JournalEntryVerification");

		/// <summary>
		///Journal View
		/// </summary>
		public static string JournalView => I18NResource.GetString(ResourceDirectory, "JournalView");

		/// <summary>
		///LC Credit
		/// </summary>
		public static string LCCredit => I18NResource.GetString(ResourceDirectory, "LCCredit");

		/// <summary>
		///LC Debit
		/// </summary>
		public static string LCDebit => I18NResource.GetString(ResourceDirectory, "LCDebit");

		/// <summary>
		///Lets do this again
		/// </summary>
		public static string LetsDoAgain => I18NResource.GetString(ResourceDirectory, "LetsDoAgain");

		/// <summary>
		///Net Sales
		/// </summary>
		public static string NetSales => I18NResource.GetString(ResourceDirectory, "NetSales");

		/// <summary>
		///Next
		/// </summary>
		public static string Next => I18NResource.GetString(ResourceDirectory, "Next");

		/// <summary>
		///No
		/// </summary>
		public static string No => I18NResource.GetString(ResourceDirectory, "No");

		/// <summary>
		///No document(s) found.
		/// </summary>
		public static string NoDocumentFound => I18NResource.GetString(ResourceDirectory, "NoDocumentFound");

		/// <summary>
		///No reminder was set
		/// </summary>
		public static string NoReminderSet => I18NResource.GetString(ResourceDirectory, "NoReminderSet");

		/// <summary>
		///Not enough balance in the cash repository
		/// </summary>
		public static string NotEnoughBalanceCashRepository => I18NResource.GetString(ResourceDirectory, "NotEnoughBalanceCashRepository");

		/// <summary>
		///Notes
		/// </summary>
		public static string Notes => I18NResource.GetString(ResourceDirectory, "Notes");

		/// <summary>
		///Not implemented
		/// </summary>
		public static string NotImplemented => I18NResource.GetString(ResourceDirectory, "NotImplemented");

		/// <summary>
		///OK
		/// </summary>
		public static string OK => I18NResource.GetString(ResourceDirectory, "OK");

		/// <summary>
		///Only Me
		/// </summary>
		public static string OnlyMe => I18NResource.GetString(ResourceDirectory, "OnlyMe");

		/// <summary>
		///Payment Journal Summary Report
		/// </summary>
		public static string PaymentJournalSummary => I18NResource.GetString(ResourceDirectory, "PaymentJournalSummary");

		/// <summary>
		///Perform EOD
		/// </summary>
		public static string PerformEOD => I18NResource.GetString(ResourceDirectory, "PerformEOD");

		/// <summary>
		///Perform EOD Operation
		/// </summary>
		public static string PerformEODOperation => I18NResource.GetString(ResourceDirectory, "PerformEODOperation");

		/// <summary>
		///<p>When you perform EOD operation for a particular date, no transaction on that date or before can be altered, changed, or deleted.</p><p>During EOD operation, routine tasks such as interest calculation, settlements, and report generation are performed. This process is irreversible.</p>
		/// </summary>
		public static string PerformEODOperationWarningMessage => I18NResource.GetString(ResourceDirectory, "PerformEODOperationWarningMessage");

		/// <summary>
		///Post
		/// </summary>
		public static string Post => I18NResource.GetString(ResourceDirectory, "Post");

		/// <summary>
		///Posted By
		/// </summary>
		public static string PostedBy => I18NResource.GetString(ResourceDirectory, "PostedBy");

		/// <summary>
		///Posted On
		/// </summary>
		public static string PostedOn => I18NResource.GetString(ResourceDirectory, "PostedOn");

		/// <summary>
		///Post Transaction
		/// </summary>
		public static string PostTransaction => I18NResource.GetString(ResourceDirectory, "PostTransaction");

		/// <summary>
		///Print
		/// </summary>
		public static string Print => I18NResource.GetString(ResourceDirectory, "Print");

		/// <summary>
		///Profit & Loss Statement
		/// </summary>
		public static string ProfitAndLossStatement => I18NResource.GetString(ResourceDirectory, "ProfitAndLossStatement");

		/// <summary>
		///Reason
		/// </summary>
		public static string Reason => I18NResource.GetString(ResourceDirectory, "Reason");

		/// <summary>
		///Receipt Journal Summary Report
		/// </summary>
		public static string ReceiptJournalSummary => I18NResource.GetString(ResourceDirectory, "ReceiptJournalSummary");

		/// <summary>
		///Reconcile
		/// </summary>
		public static string Reconcile => I18NResource.GetString(ResourceDirectory, "Reconcile");

		/// <summary>
		///Reconciled by {0}.
		/// </summary>
		public static string ReconciledByName => I18NResource.GetString(ResourceDirectory, "ReconciledByName");

		/// <summary>
		///Reconcile Now
		/// </summary>
		public static string ReconcileNow => I18NResource.GetString(ResourceDirectory, "ReconcileNow");

		/// <summary>
		///Reconcile Transaction
		/// </summary>
		public static string ReconcileTransaction => I18NResource.GetString(ResourceDirectory, "ReconcileTransaction");

		/// <summary>
		///Referencing sides are not equal.
		/// </summary>
		public static string ReferencingSidesNotEqual => I18NResource.GetString(ResourceDirectory, "ReferencingSidesNotEqual");

		/// <summary>
		///Ref #
		/// </summary>
		public static string RefererenceNumberAbbreviated => I18NResource.GetString(ResourceDirectory, "RefererenceNumberAbbreviated");

		/// <summary>
		///Refresh
		/// </summary>
		public static string Refresh => I18NResource.GetString(ResourceDirectory, "Refresh");

		/// <summary>
		///Refresh Concurrently
		/// </summary>
		public static string RefreshConcurrently => I18NResource.GetString(ResourceDirectory, "RefreshConcurrently");

		/// <summary>
		///Materialized views periodically cache the result of expensive database queries, thus dramatically improving the application performance. This feature enables you to manually refresh all materialized views.
		/// </summary>
		public static string RefreshMaterializedViewsMessage => I18NResource.GetString(ResourceDirectory, "RefreshMaterializedViewsMessage");

		/// <summary>
		///Reminder
		/// </summary>
		public static string Reminder => I18NResource.GetString(ResourceDirectory, "Reminder");

		/// <summary>
		///Remind Me About
		/// </summary>
		public static string RemindMeAbout => I18NResource.GetString(ResourceDirectory, "RemindMeAbout");

		/// <summary>
		///Remind Me at Least
		/// </summary>
		public static string RemindMeLeast => I18NResource.GetString(ResourceDirectory, "RemindMeLeast");

		/// <summary>
		///Repeat?
		/// </summary>
		public static string Repeat => I18NResource.GetString(ResourceDirectory, "Repeat");

		/// <summary>
		///Repeat Every
		/// </summary>
		public static string RepeatEvery => I18NResource.GetString(ResourceDirectory, "RepeatEvery");

		/// <summary>
		///Request
		/// </summary>
		public static string Request => I18NResource.GetString(ResourceDirectory, "Request");

		/// <summary>
		///Return
		/// </summary>
		public static string Return => I18NResource.GetString(ResourceDirectory, "Return");

		/// <summary>
		///Return Back
		/// </summary>
		public static string ReturnBack => I18NResource.GetString(ResourceDirectory, "ReturnBack");

		/// <summary>
		///Save
		/// </summary>
		public static string Save => I18NResource.GetString(ResourceDirectory, "Save");

		/// <summary>
		///Select
		/// </summary>
		public static string Select => I18NResource.GetString(ResourceDirectory, "Select");

		/// <summary>
		///Select Account
		/// </summary>
		public static string SelectAccount => I18NResource.GetString(ResourceDirectory, "SelectAccount");

		/// <summary>
		///Select API
		/// </summary>
		public static string SelectApi => I18NResource.GetString(ResourceDirectory, "SelectApi");

		/// <summary>
		///Selected Role(s)
		/// </summary>
		public static string SelectedRole => I18NResource.GetString(ResourceDirectory, "SelectedRole");

		/// <summary>
		///Selected User(s)
		/// </summary>
		public static string SelectedUsers => I18NResource.GetString(ResourceDirectory, "SelectedUsers");

		/// <summary>
		///Select Roles
		/// </summary>
		public static string SelectRoles => I18NResource.GetString(ResourceDirectory, "SelectRoles");

		/// <summary>
		///Select Users
		/// </summary>
		public static string SelectUsers => I18NResource.GetString(ResourceDirectory, "SelectUsers");

		/// <summary>
		///Send Me an Email
		/// </summary>
		public static string SendMeEmail => I18NResource.GetString(ResourceDirectory, "SendMeEmail");

		/// <summary>
		///Show
		/// </summary>
		public static string Show => I18NResource.GetString(ResourceDirectory, "Show");

		/// <summary>
		///Show Compact
		/// </summary>
		public static string ShowCompact => I18NResource.GetString(ResourceDirectory, "ShowCompact");

		/// <summary>
		///Symbol
		/// </summary>
		public static string Symbol => I18NResource.GetString(ResourceDirectory, "Symbol");

		/// <summary>
		///Title
		/// </summary>
		public static string Title => I18NResource.GetString(ResourceDirectory, "Title");

		/// <summary>
		///To
		/// </summary>
		public static string To => I18NResource.GetString(ResourceDirectory, "To");

		/// <summary>
		///Total Assets
		/// </summary>
		public static string TotalAssets => I18NResource.GetString(ResourceDirectory, "TotalAssets");

		/// <summary>
		///Total Discount
		/// </summary>
		public static string TotalDiscount => I18NResource.GetString(ResourceDirectory, "TotalDiscount");

		/// <summary>
		///Total Liabilities
		/// </summary>
		public static string TotalLiabilities => I18NResource.GetString(ResourceDirectory, "TotalLiabilities");

		/// <summary>
		///Total Sales
		/// </summary>
		public static string TotalSales => I18NResource.GetString(ResourceDirectory, "TotalSales");

		/// <summary>
		///Total Sales Tax
		/// </summary>
		public static string TotalSalesTax => I18NResource.GetString(ResourceDirectory, "TotalSalesTax");

		/// <summary>
		///Tran Code
		/// </summary>
		public static string TranCode => I18NResource.GetString(ResourceDirectory, "TranCode");

		/// <summary>
		///Tran Id
		/// </summary>
		public static string TranId => I18NResource.GetString(ResourceDirectory, "TranId");

		/// <summary>
		///Transaction Id
		/// </summary>
		public static string TransactionId => I18NResource.GetString(ResourceDirectory, "TransactionId");

		/// <summary>
		///The transaction was posted successfully.
		/// </summary>
		public static string TransactionPostedSuccessfully => I18NResource.GetString(ResourceDirectory, "TransactionPostedSuccessfully");

		/// <summary>
		///<p>When you withdraw a transaction, it won't be forwarded to the workflow module. This means that your withdrawn transactions are rejected and require no further verification. However, you won't be able to unwithdraw this transaction later.</p>
		/// </summary>
		public static string TransactionWithdrawalInformation => I18NResource.GetString(ResourceDirectory, "TransactionWithdrawalInformation");

		/// <summary>
		///Upload a New Document
		/// </summary>
		public static string UploadNewDocument => I18NResource.GetString(ResourceDirectory, "UploadNewDocument");

		/// <summary>
		///Validate
		/// </summary>
		public static string Validate => I18NResource.GetString(ResourceDirectory, "Validate");

		/// <summary>
		///Verification
		/// </summary>
		public static string Verification => I18NResource.GetString(ResourceDirectory, "Verification");

		/// <summary>
		///Verified By
		/// </summary>
		public static string VerifiedBy => I18NResource.GetString(ResourceDirectory, "VerifiedBy");

		/// <summary>
		///Verified On
		/// </summary>
		public static string VerifiedOn => I18NResource.GetString(ResourceDirectory, "VerifiedOn");

		/// <summary>
		///Verify
		/// </summary>
		public static string Verify => I18NResource.GetString(ResourceDirectory, "Verify");

		/// <summary>
		///View Errors
		/// </summary>
		public static string ViewErrors => I18NResource.GetString(ResourceDirectory, "ViewErrors");

		/// <summary>
		///View Journal Advice
		/// </summary>
		public static string ViewJournalAdvice => I18NResource.GetString(ResourceDirectory, "ViewJournalAdvice");

		/// <summary>
		///View Journal Entries
		/// </summary>
		public static string ViewJournalEntries => I18NResource.GetString(ResourceDirectory, "ViewJournalEntries");

		/// <summary>
		///We failed to import the file you uploaded.
		/// </summary>
		public static string WeFailedToImport => I18NResource.GetString(ResourceDirectory, "WeFailedToImport");

		/// <summary>
		///Whom to Remind?
		/// </summary>
		public static string WhomToRemind => I18NResource.GetString(ResourceDirectory, "WhomToRemind");

		/// <summary>
		///Why do you want to withdraw this transaction?
		/// </summary>
		public static string WithdrawalReason => I18NResource.GetString(ResourceDirectory, "WithdrawalReason");

		/// <summary>
		///You haven't left a note yet.
		/// </summary>
		public static string YouHaventLeftNoteYet => I18NResource.GetString(ResourceDirectory, "YouHaventLeftNoteYet");

		/// <summary>
		///Amount
		/// </summary>
		public static string Amount => I18NResource.GetString(ResourceDirectory, "Amount");

	}
}
