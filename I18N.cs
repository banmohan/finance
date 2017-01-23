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
		///Cash Flow Statement
		/// </summary>
		public static string CashFlowStatement => I18NResource.GetString(ResourceDirectory, "CashFlowStatement");

		/// <summary>
		///Profit and Loss Statement
		/// </summary>
		public static string ProfitandLossStatement => I18NResource.GetString(ResourceDirectory, "ProfitandLossStatement");

		/// <summary>
		///Bank Accounts
		/// </summary>
		public static string BankAccounts => I18NResource.GetString(ResourceDirectory, "BankAccounts");

		/// <summary>
		///Cash Flow Setups
		/// </summary>
		public static string CashFlowSetups => I18NResource.GetString(ResourceDirectory, "CashFlowSetups");

		/// <summary>
		///Frequency Setups
		/// </summary>
		public static string FrequencySetups => I18NResource.GetString(ResourceDirectory, "FrequencySetups");

		/// <summary>
		///Currencies
		/// </summary>
		public static string Currencies => I18NResource.GetString(ResourceDirectory, "Currencies");

		/// <summary>
		///Cost Centers
		/// </summary>
		public static string CostCenters => I18NResource.GetString(ResourceDirectory, "CostCenters");

		/// <summary>
		///Cash Repositories
		/// </summary>
		public static string CashRepositories => I18NResource.GetString(ResourceDirectory, "CashRepositories");

		/// <summary>
		///Chart Of Accounts
		/// </summary>
		public static string ChartOfAccounts => I18NResource.GetString(ResourceDirectory, "ChartOfAccounts");

		/// <summary>
		///Cash Flow Headings
		/// </summary>
		public static string CashFlowHeadings => I18NResource.GetString(ResourceDirectory, "CashFlowHeadings");

		/// <summary>
		///Fiscal Years
		/// </summary>
		public static string FiscalYears => I18NResource.GetString(ResourceDirectory, "FiscalYears");

		/// <summary>
		///Checklist
		/// </summary>
		public static string Checklist => I18NResource.GetString(ResourceDirectory, "Checklist");

		/// <summary>
		///The transaction was posted successfully
		/// </summary>
		public static string TransactionPostedSuccessfully => I18NResource.GetString(ResourceDirectory, "TransactionPostedSuccessfully");

		/// <summary>
		///Why do you want to withdraw this transaction
		/// </summary>
		public static string WhyDoYouWantWithdrawTransaction => I18NResource.GetString(ResourceDirectory, "WhyDoYouWantWithdrawTransaction");

		/// <summary>
		///Are you sure
		/// </summary>
		public static string AreYouSure => I18NResource.GetString(ResourceDirectory, "AreYouSure");

		/// <summary>
		///You haven't left a note yet
		/// </summary>
		public static string YouHaventLeftNoteYet => I18NResource.GetString(ResourceDirectory, "YouHaventLeftNoteYet");

		/// <summary>
		///No document(s) found
		/// </summary>
		public static string NoDocumentFound => I18NResource.GetString(ResourceDirectory, "NoDocumentFound");

		/// <summary>
		///No reminder was set
		/// </summary>
		public static string NoReminderSet => I18NResource.GetString(ResourceDirectory, "NoReminderSet");

		/// <summary>
		///Notes
		/// </summary>
		public static string Notes => I18NResource.GetString(ResourceDirectory, "Notes");

		/// <summary>
		///Add Note
		/// </summary>
		public static string AddNote => I18NResource.GetString(ResourceDirectory, "AddNote");

		/// <summary>
		///Documents
		/// </summary>
		public static string Documents => I18NResource.GetString(ResourceDirectory, "Documents");

		/// <summary>
		///Upload a New Document
		/// </summary>
		public static string UploadNewDocument => I18NResource.GetString(ResourceDirectory, "UploadNewDocument");

		/// <summary>
		///Reminder
		/// </summary>
		public static string Reminder => I18NResource.GetString(ResourceDirectory, "Reminder");

		/// <summary>
		///Create a New Reminder
		/// </summary>
		public static string CreateNewReminder => I18NResource.GetString(ResourceDirectory, "CreateNewReminder");

		/// <summary>
		///Advice
		/// </summary>
		public static string Advice => I18NResource.GetString(ResourceDirectory, "Advice");

		/// <summary>
		///Email Me This Document
		/// </summary>
		public static string EmailMeDocument => I18NResource.GetString(ResourceDirectory, "EmailMeDocument");

		/// <summary>
		///Title
		/// </summary>
		public static string Title => I18NResource.GetString(ResourceDirectory, "Title");

		/// <summary>
		///Remind Me About
		/// </summary>
		public static string RemindMeAbout => I18NResource.GetString(ResourceDirectory, "RemindMeAbout");

		/// <summary>
		///Whom to Remind
		/// </summary>
		public static string WhomToRemind => I18NResource.GetString(ResourceDirectory, "WhomToRemind");

		/// <summary>
		///OnlyMe
		/// </summary>
		public static string OnlyMe => I18NResource.GetString(ResourceDirectory, "OnlyMe");

		/// <summary>
		///Selected Role(s)
		/// </summary>
		public static string SelectedRole => I18NResource.GetString(ResourceDirectory, "SelectedRole");

		/// <summary>
		///Selected Users(s)
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
		///Starts From
		/// </summary>
		public static string StartsFrom => I18NResource.GetString(ResourceDirectory, "StartsFrom");

		/// <summary>
		///Ends On
		/// </summary>
		public static string EndsOn => I18NResource.GetString(ResourceDirectory, "EndsOn");

		/// <summary>
		///Enter Description for Reminder
		/// </summary>
		public static string EnterDescriptionReminder => I18NResource.GetString(ResourceDirectory, "EnterDescriptionReminder");

		/// <summary>
		///Repeat
		/// </summary>
		public static string Repeat => I18NResource.GetString(ResourceDirectory, "Repeat");

		/// <summary>
		///No
		/// </summary>
		public static string No => I18NResource.GetString(ResourceDirectory, "No");

		/// <summary>
		///Hour
		/// </summary>
		public static string Hour => I18NResource.GetString(ResourceDirectory, "Hour");

		/// <summary>
		///Day
		/// </summary>
		public static string Day => I18NResource.GetString(ResourceDirectory, "Day");

		/// <summary>
		///Repeat Every
		/// </summary>
		public static string RepeatEvery => I18NResource.GetString(ResourceDirectory, "RepeatEvery");

		/// <summary>
		///hours
		/// </summary>
		public static string Hours => I18NResource.GetString(ResourceDirectory, "Hours");

		/// <summary>
		///days
		/// </summary>
		public static string Days => I18NResource.GetString(ResourceDirectory, "Days");

		/// <summary>
		///Remind Me at Least
		/// </summary>
		public static string RemindMeLeast => I18NResource.GetString(ResourceDirectory, "RemindMeLeast");

		/// <summary>
		///hours before the schedule
		/// </summary>
		public static string HoursBeforeSchedule => I18NResource.GetString(ResourceDirectory, "HoursBeforeSchedule");

		/// <summary>
		///Display This Reminder to Other Users
		/// </summary>
		public static string DisplayReminderOtherUsers => I18NResource.GetString(ResourceDirectory, "DisplayReminderOtherUsers");

		/// <summary>
		///Send Me an Email
		/// </summary>
		public static string SendMeEmail => I18NResource.GetString(ResourceDirectory, "SendMeEmail");

		/// <summary>
		///Including Other Participants
		/// </summary>
		public static string IncludingOtherParticipants => I18NResource.GetString(ResourceDirectory, "IncludingOtherParticipants");

		/// <summary>
		///Attach All Documents
		/// </summary>
		public static string AttachAllDocuments => I18NResource.GetString(ResourceDirectory, "AttachAllDocuments");

		/// <summary>
		///Cancel
		/// </summary>
		public static string Cancel => I18NResource.GetString(ResourceDirectory, "Cancel");

		/// <summary>
		///OK
		/// </summary>
		public static string OK => I18NResource.GetString(ResourceDirectory, "OK");

		/// <summary>
		///Journal View
		/// </summary>
		public static string JournalView => I18NResource.GetString(ResourceDirectory, "JournalView");

		/// <summary>
		///Export This Document
		/// </summary>
		public static string ExportDocument => I18NResource.GetString(ResourceDirectory, "ExportDocument");

		/// <summary>
		///Show
		/// </summary>
		public static string Show => I18NResource.GetString(ResourceDirectory, "Show");

		/// <summary>
		///Actions
		/// </summary>
		public static string Actions => I18NResource.GetString(ResourceDirectory, "Actions");

		/// <summary>
		///Select
		/// </summary>
		public static string Select => I18NResource.GetString(ResourceDirectory, "Select");

		/// <summary>
		///TranId
		/// </summary>
		public static string TranId => I18NResource.GetString(ResourceDirectory, "TranId");

		/// <summary>
		///TranCode
		/// </summary>
		public static string TranCode => I18NResource.GetString(ResourceDirectory, "TranCode");

		/// <summary>
		///ValueDate
		/// </summary>
		public static string ValueDate => I18NResource.GetString(ResourceDirectory, "ValueDate");

		/// <summary>
		///BookDate
		/// </summary>
		public static string BookDate => I18NResource.GetString(ResourceDirectory, "BookDate");

		/// <summary>
		///Ref#
		/// </summary>
		public static string Ref => I18NResource.GetString(ResourceDirectory, "Ref");

		/// <summary>
		///StatementReference
		/// </summary>
		public static string StatementReference => I18NResource.GetString(ResourceDirectory, "StatementReference");

		/// <summary>
		///PostedBy
		/// </summary>
		public static string PostedBy => I18NResource.GetString(ResourceDirectory, "PostedBy");

		/// <summary>
		///Office
		/// </summary>
		public static string Office => I18NResource.GetString(ResourceDirectory, "Office");

		/// <summary>
		///Status
		/// </summary>
		public static string Status => I18NResource.GetString(ResourceDirectory, "Status");

		/// <summary>
		///Verified By
		/// </summary>
		public static string VerifiedBy => I18NResource.GetString(ResourceDirectory, "VerifiedBy");

		/// <summary>
		///Verified On
		/// </summary>
		public static string VerifiedOn => I18NResource.GetString(ResourceDirectory, "VerifiedOn");

		/// <summary>
		///Reason
		/// </summary>
		public static string Reason => I18NResource.GetString(ResourceDirectory, "Reason");

		/// <summary>
		///Verification
		/// </summary>
		public static string Verification => I18NResource.GetString(ResourceDirectory, "Verification");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Exchange Rates
		/// </summary>
		public static string ExchangeRates => I18NResource.GetString(ResourceDirectory, "ExchangeRates");

		/// <summary>
		///Select Account
		/// </summary>
		public static string SelectAccount => I18NResource.GetString(ResourceDirectory, "SelectAccount");

		/// <summary>
		///From
		/// </summary>
		public static string From => I18NResource.GetString(ResourceDirectory, "From");

		/// <summary>
		///To
		/// </summary>
		public static string To => I18NResource.GetString(ResourceDirectory, "To");

		/// <summary>
		///Reconcile
		/// </summary>
		public static string Reconcile => I18NResource.GetString(ResourceDirectory, "Reconcile");

		/// <summary>
		///Book
		/// </summary>
		public static string Book => I18NResource.GetString(ResourceDirectory, "Book");

		/// <summary>
		///ReconciliationMemo
		/// </summary>
		public static string ReconciliationMemo => I18NResource.GetString(ResourceDirectory, "ReconciliationMemo");

		/// <summary>
		///ReferenceNumber
		/// </summary>
		public static string ReferenceNumber => I18NResource.GetString(ResourceDirectory, "ReferenceNumber");

		/// <summary>
		///Debit
		/// </summary>
		public static string Debit => I18NResource.GetString(ResourceDirectory, "Debit");

		/// <summary>
		///Credit
		/// </summary>
		public static string Credit => I18NResource.GetString(ResourceDirectory, "Credit");

		/// <summary>
		///Balance
		/// </summary>
		public static string Balance => I18NResource.GetString(ResourceDirectory, "Balance");

		/// <summary>
		///TransactionId
		/// </summary>
		public static string TransactionId => I18NResource.GetString(ResourceDirectory, "TransactionId");

		/// <summary>
		///TransactionDetailId
		/// </summary>
		public static string TransactionDetailId => I18NResource.GetString(ResourceDirectory, "TransactionDetailId");

		/// <summary>
		///AccountId
		/// </summary>
		public static string AccountId => I18NResource.GetString(ResourceDirectory, "AccountId");

		/// <summary>
		///AccountNumber
		/// </summary>
		public static string AccountNumber => I18NResource.GetString(ResourceDirectory, "AccountNumber");

		/// <summary>
		///Account
		/// </summary>
		public static string Account => I18NResource.GetString(ResourceDirectory, "Account");

		/// <summary>
		///TransactionCode
		/// </summary>
		public static string TransactionCode => I18NResource.GetString(ResourceDirectory, "TransactionCode");

		/// <summary>
		///ReconcileTransaction
		/// </summary>
		public static string ReconcileTransaction => I18NResource.GetString(ResourceDirectory, "ReconcileTransaction");

		/// <summary>
		///EnterNewBookDate
		/// </summary>
		public static string EnterNewBookDate => I18NResource.GetString(ResourceDirectory, "EnterNewBookDate");

		/// <summary>
		///PostedOn
		/// </summary>
		public static string PostedOn => I18NResource.GetString(ResourceDirectory, "PostedOn");

		/// <summary>
		///ApprovedBy
		/// </summary>
		public static string ApprovedBy => I18NResource.GetString(ResourceDirectory, "ApprovedBy");

		/// <summary>
		///AccountReconciliation
		/// </summary>
		public static string AccountReconciliation => I18NResource.GetString(ResourceDirectory, "AccountReconciliation");

		/// <summary>
		///Initialize EOD Processing for
		/// </summary>
		public static string InitializeEODProcessing => I18NResource.GetString(ResourceDirectory, "InitializeEODProcessing");

		/// <summary>
		///Initialize EOD
		/// </summary>
		public static string InitializeEOD => I18NResource.GetString(ResourceDirectory, "InitializeEOD");

		/// <summary>
		///Perform EOD Operation
		/// </summary>
		public static string PerformEODOperation => I18NResource.GetString(ResourceDirectory, "PerformEODOperation");

		/// <summary>
		///EOD Console
		/// </summary>
		public static string EODConsole => I18NResource.GetString(ResourceDirectory, "EODConsole");

		/// <summary>
		///Base Currency
		/// </summary>
		public static string BaseCurrency => I18NResource.GetString(ResourceDirectory, "BaseCurrency");

		/// <summary>
		///Select API
		/// </summary>
		public static string SelectAPI => I18NResource.GetString(ResourceDirectory, "SelectAPI");

		/// <summary>
		///Currency Code
		/// </summary>
		public static string CurrencyCode => I18NResource.GetString(ResourceDirectory, "CurrencyCode");

		/// <summary>
		///Symbol
		/// </summary>
		public static string Symbol => I18NResource.GetString(ResourceDirectory, "Symbol");

		/// <summary>
		///Currency Name
		/// </summary>
		public static string CurrencyName => I18NResource.GetString(ResourceDirectory, "CurrencyName");

		/// <summary>
		///Hundredth Name
		/// </summary>
		public static string HundredthName => I18NResource.GetString(ResourceDirectory, "HundredthName");

		/// <summary>
		///Exchange Rate
		/// </summary>
		public static string ExchangeRate => I18NResource.GetString(ResourceDirectory, "ExchangeRate");

		/// <summary>
		///JournalEntries
		/// </summary>
		public static string JournalEntries => I18NResource.GetString(ResourceDirectory, "JournalEntries");

		/// <summary>
		///Add a New Journal Entry
		/// </summary>
		public static string AddNewJournalEntry => I18NResource.GetString(ResourceDirectory, "AddNewJournalEntry");

		/// <summary>
		///Cash Repository
		/// </summary>
		public static string CashRepository => I18NResource.GetString(ResourceDirectory, "CashRepository");

		/// <summary>
		///Currency
		/// </summary>
		public static string Currency => I18NResource.GetString(ResourceDirectory, "Currency");

		/// <summary>
		///ER
		/// </summary>
		public static string ER => I18NResource.GetString(ResourceDirectory, "ER");

		/// <summary>
		///LCDebit
		/// </summary>
		public static string LCDebit => I18NResource.GetString(ResourceDirectory, "LCDebit");

		/// <summary>
		///LC Credit
		/// </summary>
		public static string LCCredit => I18NResource.GetString(ResourceDirectory, "LCCredit");

		/// <summary>
		///Action
		/// </summary>
		public static string Action => I18NResource.GetString(ResourceDirectory, "Action");

		/// <summary>
		///Cost Center
		/// </summary>
		public static string CostCenter => I18NResource.GetString(ResourceDirectory, "CostCenter");

		/// <summary>
		///Debit Total
		/// </summary>
		public static string DebitTotal => I18NResource.GetString(ResourceDirectory, "DebitTotal");

		/// <summary>
		///Credit Total
		/// </summary>
		public static string CreditTotal => I18NResource.GetString(ResourceDirectory, "CreditTotal");

		/// <summary>
		///Post Transaction
		/// </summary>
		public static string PostTransaction => I18NResource.GetString(ResourceDirectory, "PostTransaction");

		/// <summary>
		///Journal Verification
		/// </summary>
		public static string JournalVerification => I18NResource.GetString(ResourceDirectory, "JournalVerification");

		/// <summary>
		///Auto Verification Policy
		/// </summary>
		public static string AutoVerificationPolicy => I18NResource.GetString(ResourceDirectory, "AutoVerificationPolicy");

		/// <summary>
		///Verification Policy
		/// </summary>
		public static string VerificationPolicy => I18NResource.GetString(ResourceDirectory, "VerificationPolicy");

		/// <summary>
		///Finance
		/// </summary>
		public static string Finance => I18NResource.GetString(ResourceDirectory, "Finance");

		/// <summary>
		///EOD Processing Has Begun
		/// </summary>
		public static string EODProcessingBegun => I18NResource.GetString(ResourceDirectory, "EODProcessingBegun");

		/// <summary>
		///Factor
		/// </summary>
		public static string Factor => I18NResource.GetString(ResourceDirectory, "Factor");

		/// <summary>
		///Print
		/// </summary>
		public static string Print => I18NResource.GetString(ResourceDirectory, "Print");

		/// <summary>
		///Profit and Loss Statement
		/// </summary>
		public static string ProfitLossStatement => I18NResource.GetString(ResourceDirectory, "ProfitLossStatement");

		/// <summary>
		///Show Compact
		/// </summary>
		public static string ShowCompact => I18NResource.GetString(ResourceDirectory, "ShowCompact");

		/// <summary>
		///Description
		/// </summary>
		public static string Description => I18NResource.GetString(ResourceDirectory, "Description");

		/// <summary>
		///Export to Doc
		/// </summary>
		public static string ExportDoc => I18NResource.GetString(ResourceDirectory, "ExportDoc");

		/// <summary>
		///Export to Excel
		/// </summary>
		public static string ExportExcel => I18NResource.GetString(ResourceDirectory, "ExportExcel");

		/// <summary>
		///Export to PDF
		/// </summary>
		public static string ExportPDF => I18NResource.GetString(ResourceDirectory, "ExportPDF");

		/// <summary>
		///Export
		/// </summary>
		public static string Export => I18NResource.GetString(ResourceDirectory, "Export");

		/// <summary>
		///UserId
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///OfficeId
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///Checklist Window
		/// </summary>
		public static string ChecklistWindow => I18NResource.GetString(ResourceDirectory, "ChecklistWindow");

		/// <summary>
		///View Journal Advice
		/// </summary>
		public static string ViewJournalAdvice => I18NResource.GetString(ResourceDirectory, "ViewJournalAdvice");

		/// <summary>
		///Invalid cash repository specified.
		/// </summary>
		public static string InvalidCashRepositorySpecified => I18NResource.GetString(ResourceDirectory, "InvalidCashRepositorySpecified");

		/// <summary>
		///Not enough balance in the cash repository
		/// </summary>
		public static string NotEnoughBalanceCashRepository => I18NResource.GetString(ResourceDirectory, "NotEnoughBalanceCashRepository");

		/// <summary>
		///Duplicate entry.
		/// </summary>
		public static string DuplicateEntry => I18NResource.GetString(ResourceDirectory, "DuplicateEntry");

		/// <summary>
		///Referencing sides are not equal.
		/// </summary>
		public static string ReferencingSidesNotEqual => I18NResource.GetString(ResourceDirectory, "ReferencingSidesNotEqual");

	}
}
