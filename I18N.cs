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
		///Account
		/// </summary>
		public static string Account => I18NResource.GetString(ResourceDirectory, "Account");

		/// <summary>
		///Access is denied.
		/// </summary>
		public static string AccessIsDenied => I18NResource.GetString(ResourceDirectory, "AccessIsDenied");

		/// <summary>
		///EOD operation has begun now.
		/// </summary>
		public static string EODOperationBegunNow => I18NResource.GetString(ResourceDirectory, "EODOperationBegunNow");

		/// <summary>
		///Reconciled by {0}.
		/// </summary>
		public static string ReconciledByName => I18NResource.GetString(ResourceDirectory, "ReconciledByName");

		/// <summary>
		///Account Id
		/// </summary>
		public static string AccountId => I18NResource.GetString(ResourceDirectory, "AccountId");

		/// <summary>
		///Account Number
		/// </summary>
		public static string AccountNumber => I18NResource.GetString(ResourceDirectory, "AccountNumber");

		/// <summary>
		///Account Reconciliation
		/// </summary>
		public static string AccountReconciliation => I18NResource.GetString(ResourceDirectory, "AccountReconciliation");

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
		///Auto Verification Policy
		/// </summary>
		public static string AutoVerificationPolicy => I18NResource.GetString(ResourceDirectory, "AutoVerificationPolicy");

		/// <summary>
		///Balance
		/// </summary>
		public static string Balance => I18NResource.GetString(ResourceDirectory, "Balance");

		/// <summary>
		///Bank Accounts
		/// </summary>
		public static string BankAccounts => I18NResource.GetString(ResourceDirectory, "BankAccounts");

		/// <summary>
		///Base Currency
		/// </summary>
		public static string BaseCurrency => I18NResource.GetString(ResourceDirectory, "BaseCurrency");

		/// <summary>
		///Book
		/// </summary>
		public static string Book => I18NResource.GetString(ResourceDirectory, "Book");

		/// <summary>
		///Book Date
		/// </summary>
		public static string BookDate => I18NResource.GetString(ResourceDirectory, "BookDate");

		/// <summary>
		///Cancel
		/// </summary>
		public static string Cancel => I18NResource.GetString(ResourceDirectory, "Cancel");

		/// <summary>
		///Cancel/Withdraw Transaction
		/// </summary>
		public static string CancelWithdrawTransaction => I18NResource.GetString(ResourceDirectory, "CancelWithdrawTransaction");

		/// <summary>
		///Cash Flow Headings
		/// </summary>
		public static string CashFlowHeadings => I18NResource.GetString(ResourceDirectory, "CashFlowHeadings");

		/// <summary>
		///Cash Flow Setups
		/// </summary>
		public static string CashFlowSetups => I18NResource.GetString(ResourceDirectory, "CashFlowSetups");

		/// <summary>
		///Cash Flow Statement
		/// </summary>
		public static string CashFlowStatement => I18NResource.GetString(ResourceDirectory, "CashFlowStatement");

		/// <summary>
		///Cash Repositories
		/// </summary>
		public static string CashRepositories => I18NResource.GetString(ResourceDirectory, "CashRepositories");

		/// <summary>
		///Cash Repository
		/// </summary>
		public static string CashRepository => I18NResource.GetString(ResourceDirectory, "CashRepository");

		/// <summary>
		///Chart Of Accounts
		/// </summary>
		public static string ChartOfAccounts => I18NResource.GetString(ResourceDirectory, "ChartOfAccounts");

		/// <summary>
		///Checklist
		/// </summary>
		public static string Checklist => I18NResource.GetString(ResourceDirectory, "Checklist");

		/// <summary>
		///Checklist Window
		/// </summary>
		public static string ChecklistWindow => I18NResource.GetString(ResourceDirectory, "ChecklistWindow");

		/// <summary>
		///Cost Center
		/// </summary>
		public static string CostCenter => I18NResource.GetString(ResourceDirectory, "CostCenter");

		/// <summary>
		///Cost Centers
		/// </summary>
		public static string CostCenters => I18NResource.GetString(ResourceDirectory, "CostCenters");

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
		///Currencies
		/// </summary>
		public static string Currencies => I18NResource.GetString(ResourceDirectory, "Currencies");

		/// <summary>
		///Currency
		/// </summary>
		public static string Currency => I18NResource.GetString(ResourceDirectory, "Currency");

		/// <summary>
		///Currency Code
		/// </summary>
		public static string CurrencyCode => I18NResource.GetString(ResourceDirectory, "CurrencyCode");

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
		///Description
		/// </summary>
		public static string Description => I18NResource.GetString(ResourceDirectory, "Description");

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
		///<p>Please close this window and save your existing work before you will be signed off automatically.</p>
		/// </summary>
		public static string EODBegunSaveYourWork => I18NResource.GetString(ResourceDirectory, "EODBegunSaveYourWork");

		/// <summary>
		///EOD Console
		/// </summary>
		public static string EODConsole => I18NResource.GetString(ResourceDirectory, "EODConsole");

		/// <summary>
		///EOD Processing Has Begun
		/// </summary>
		public static string EODProcessingBegun => I18NResource.GetString(ResourceDirectory, "EODProcessingBegun");

		/// <summary>
		///ER
		/// </summary>
		public static string Er => I18NResource.GetString(ResourceDirectory, "Er");

		/// <summary>
		///Email Me This Document
		/// </summary>
		public static string EmailMeDocument => I18NResource.GetString(ResourceDirectory, "EmailMeDocument");

		/// <summary>
		///Ends On
		/// </summary>
		public static string EndsOn => I18NResource.GetString(ResourceDirectory, "EndsOn");

		/// <summary>
		///Enter Description for Reminder
		/// </summary>
		public static string EnterDescriptionReminder => I18NResource.GetString(ResourceDirectory, "EnterDescriptionReminder");

		/// <summary>
		///Enter New Book Date
		/// </summary>
		public static string EnterNewBookDate => I18NResource.GetString(ResourceDirectory, "EnterNewBookDate");

		/// <summary>
		///Exchange Rate
		/// </summary>
		public static string ExchangeRate => I18NResource.GetString(ResourceDirectory, "ExchangeRate");

		/// <summary>
		///Exchange Rates
		/// </summary>
		public static string ExchangeRates => I18NResource.GetString(ResourceDirectory, "ExchangeRates");

		/// <summary>
		///Export
		/// </summary>
		public static string Export => I18NResource.GetString(ResourceDirectory, "Export");

		/// <summary>
		///Export to Doc
		/// </summary>
		public static string ExportToDoc => I18NResource.GetString(ResourceDirectory, "ExportToDoc");

		/// <summary>
		///Export This Document
		/// </summary>
		public static string ExportThisDocument => I18NResource.GetString(ResourceDirectory, "ExportThisDocument");

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
		///Finance
		/// </summary>
		public static string Finance => I18NResource.GetString(ResourceDirectory, "Finance");

		/// <summary>
		///Fiscal Years
		/// </summary>
		public static string FiscalYears => I18NResource.GetString(ResourceDirectory, "FiscalYears");

		/// <summary>
		///Frequency Setups
		/// </summary>
		public static string FrequencySetups => I18NResource.GetString(ResourceDirectory, "FrequencySetups");

		/// <summary>
		///From
		/// </summary>
		public static string From => I18NResource.GetString(ResourceDirectory, "From");

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
		///Including Other Participants
		/// </summary>
		public static string IncludingOtherParticipants => I18NResource.GetString(ResourceDirectory, "IncludingOtherParticipants");

		/// <summary>
		///Initialize EOD
		/// </summary>
		public static string InitializeEOD => I18NResource.GetString(ResourceDirectory, "InitializeEOD");

		/// <summary>
		///Initialize EOD Processing for
		/// </summary>
		public static string InitializeEODProcessing => I18NResource.GetString(ResourceDirectory, "InitializeEODProcessing");

		/// <summary>
		///Invalid cash repository specified.
		/// </summary>
		public static string InvalidCashRepositorySpecified => I18NResource.GetString(ResourceDirectory, "InvalidCashRepositorySpecified");

		/// <summary>
		///Invalid cost center.
		/// </summary>
		public static string InvalidCostCenter => I18NResource.GetString(ResourceDirectory, "InvalidCostCenter");

		/// <summary>
		///Invalid data
		/// </summary>
		public static string InvalidData => I18NResource.GetString(ResourceDirectory, "InvalidData");

		/// <summary>
		///Invalid Date
		/// </summary>
		public static string InvalidDate => I18NResource.GetString(ResourceDirectory, "InvalidDate");

		/// <summary>
		///Insufficient balance in cash repository.
		/// </summary>
		public static string InsufficientBalanceInCashRepository => I18NResource.GetString(ResourceDirectory, "InsufficientBalanceInCashRepository");

		/// <summary>
		///<p>When you initialize day-end operation, the already logged-in application users including you are logged off after 120 seconds.</p><p>During the day-end period, only users having elevated privilege are allowed to log-in. Please do not close this window or navigate away from this page during initialization.</p>
		/// </summary>
		public static string InitializeDayEndOperationWarningMessage => I18NResource.GetString(ResourceDirectory, "InitializeDayEndOperationWarningMessage");

		/// <summary>
		///Journal Entry
		/// </summary>
		public static string JournalEntry => I18NResource.GetString(ResourceDirectory, "JournalEntry");

		/// <summary>
		///Journal Entries
		/// </summary>
		public static string JournalEntries => I18NResource.GetString(ResourceDirectory, "JournalEntries");

		/// <summary>
		///Journal Entry Verification
		/// </summary>
		public static string JournalEntryVerification => I18NResource.GetString(ResourceDirectory, "JournalEntryVerification");

		/// <summary>
		///Journal Verification
		/// </summary>
		public static string JournalVerification => I18NResource.GetString(ResourceDirectory, "JournalVerification");

		/// <summary>
		///Journal View
		/// </summary>
		public static string JournalView => I18NResource.GetString(ResourceDirectory, "JournalView");

		/// <summary>
		///LC Credit
		/// </summary>
		public static string LCCredit => I18NResource.GetString(ResourceDirectory, "LCCredit");

		/// <summary>
		///LCDebit
		/// </summary>
		public static string LCDebit => I18NResource.GetString(ResourceDirectory, "LCDebit");

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
		///Not implemented
		/// </summary>
		public static string NotImplemented => I18NResource.GetString(ResourceDirectory, "NotImplemented");

		/// <summary>
		///Notes
		/// </summary>
		public static string Notes => I18NResource.GetString(ResourceDirectory, "Notes");

		/// <summary>
		///OK
		/// </summary>
		public static string OK => I18NResource.GetString(ResourceDirectory, "OK");

		/// <summary>
		///Office
		/// </summary>
		public static string Office => I18NResource.GetString(ResourceDirectory, "Office");

		/// <summary>
		///OfficeId
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///OnlyMe
		/// </summary>
		public static string OnlyMe => I18NResource.GetString(ResourceDirectory, "OnlyMe");

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
		///Post Transaction
		/// </summary>
		public static string PostTransaction => I18NResource.GetString(ResourceDirectory, "PostTransaction");

		/// <summary>
		///Posted By
		/// </summary>
		public static string PostedBy => I18NResource.GetString(ResourceDirectory, "PostedBy");

		/// <summary>
		///PostedOn
		/// </summary>
		public static string PostedOn => I18NResource.GetString(ResourceDirectory, "PostedOn");

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
		///Reconcile
		/// </summary>
		public static string Reconcile => I18NResource.GetString(ResourceDirectory, "Reconcile");

		/// <summary>
		///Reconcile Now
		/// </summary>
		public static string ReconcileNow => I18NResource.GetString(ResourceDirectory, "ReconcileNow");

		/// <summary>
		///Reconcile Transaction
		/// </summary>
		public static string ReconcileTransaction => I18NResource.GetString(ResourceDirectory, "ReconcileTransaction");

		/// <summary>
		///Reconciliation Memo
		/// </summary>
		public static string ReconciliationMemo => I18NResource.GetString(ResourceDirectory, "ReconciliationMemo");

		/// <summary>
		///Reference Number
		/// </summary>
		public static string ReferenceNumber => I18NResource.GetString(ResourceDirectory, "ReferenceNumber");

		/// <summary>
		///Referencing sides are not equal.
		/// </summary>
		public static string ReferencingSidesNotEqual => I18NResource.GetString(ResourceDirectory, "ReferencingSidesNotEqual");

		/// <summary>
		///Ref #
		/// </summary>
		public static string RefererenceNumberAbbreviated => I18NResource.GetString(ResourceDirectory, "RefererenceNumberAbbreviated");

		/// <summary>
		///Remind Me About
		/// </summary>
		public static string RemindMeAbout => I18NResource.GetString(ResourceDirectory, "RemindMeAbout");

		/// <summary>
		///Remind Me at Least
		/// </summary>
		public static string RemindMeLeast => I18NResource.GetString(ResourceDirectory, "RemindMeLeast");

		/// <summary>
		///Reminder
		/// </summary>
		public static string Reminder => I18NResource.GetString(ResourceDirectory, "Reminder");

		/// <summary>
		///Repeat?
		/// </summary>
		public static string Repeat => I18NResource.GetString(ResourceDirectory, "Repeat");

		/// <summary>
		///Repeat Every
		/// </summary>
		public static string RepeatEvery => I18NResource.GetString(ResourceDirectory, "RepeatEvery");

		/// <summary>
		///Return
		/// </summary>
		public static string Return => I18NResource.GetString(ResourceDirectory, "Return");

		/// <summary>
		///Return Back
		/// </summary>
		public static string ReturnBack => I18NResource.GetString(ResourceDirectory, "ReturnBack");

		/// <summary>
		///Request
		/// </summary>
		public static string Request => I18NResource.GetString(ResourceDirectory, "Request");

		/// <summary>
		///Save
		/// </summary>
		public static string Save => I18NResource.GetString(ResourceDirectory, "Save");

		/// <summary>
		///Select
		/// </summary>
		public static string Select => I18NResource.GetString(ResourceDirectory, "Select");

		/// <summary>
		///Select API
		/// </summary>
		public static string SelectApi => I18NResource.GetString(ResourceDirectory, "SelectApi");

		/// <summary>
		///Select Account
		/// </summary>
		public static string SelectAccount => I18NResource.GetString(ResourceDirectory, "SelectAccount");

		/// <summary>
		///Select Roles
		/// </summary>
		public static string SelectRoles => I18NResource.GetString(ResourceDirectory, "SelectRoles");

		/// <summary>
		///Select Users
		/// </summary>
		public static string SelectUsers => I18NResource.GetString(ResourceDirectory, "SelectUsers");

		/// <summary>
		///Selected Role(s)
		/// </summary>
		public static string SelectedRole => I18NResource.GetString(ResourceDirectory, "SelectedRole");

		/// <summary>
		///Selected Users(s)
		/// </summary>
		public static string SelectedUsers => I18NResource.GetString(ResourceDirectory, "SelectedUsers");

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
		///Starts From
		/// </summary>
		public static string StartsFrom => I18NResource.GetString(ResourceDirectory, "StartsFrom");

		/// <summary>
		///Statement Reference
		/// </summary>
		public static string StatementReference => I18NResource.GetString(ResourceDirectory, "StatementReference");

		/// <summary>
		///Status
		/// </summary>
		public static string Status => I18NResource.GetString(ResourceDirectory, "Status");

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
		///Tran Code
		/// </summary>
		public static string TranCode => I18NResource.GetString(ResourceDirectory, "TranCode");

		/// <summary>
		///Tran Id
		/// </summary>
		public static string TranId => I18NResource.GetString(ResourceDirectory, "TranId");

		/// <summary>
		///Transaction Code
		/// </summary>
		public static string TransactionCode => I18NResource.GetString(ResourceDirectory, "TransactionCode");

		/// <summary>
		///Transaction Detail Id
		/// </summary>
		public static string TransactionDetailId => I18NResource.GetString(ResourceDirectory, "TransactionDetailId");

		/// <summary>
		///Transaction Id
		/// </summary>
		public static string TransactionId => I18NResource.GetString(ResourceDirectory, "TransactionId");

		/// <summary>
		///The transaction was posted successfully.
		/// </summary>
		public static string TransactionPostedSuccessfully => I18NResource.GetString(ResourceDirectory, "TransactionPostedSuccessfully");

		/// <summary>
		///Upload a New Document
		/// </summary>
		public static string UploadNewDocument => I18NResource.GetString(ResourceDirectory, "UploadNewDocument");

		/// <summary>
		///UserId
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///Value Date
		/// </summary>
		public static string ValueDate => I18NResource.GetString(ResourceDirectory, "ValueDate");

		/// <summary>
		///Verify
		/// </summary>
		public static string Verify => I18NResource.GetString(ResourceDirectory, "Verify");

		/// <summary>
		///Verification
		/// </summary>
		public static string Verification => I18NResource.GetString(ResourceDirectory, "Verification");

		/// <summary>
		///Verification Policy
		/// </summary>
		public static string VerificationPolicy => I18NResource.GetString(ResourceDirectory, "VerificationPolicy");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Verified By
		/// </summary>
		public static string VerifiedBy => I18NResource.GetString(ResourceDirectory, "VerifiedBy");

		/// <summary>
		///Verified On
		/// </summary>
		public static string VerifiedOn => I18NResource.GetString(ResourceDirectory, "VerifiedOn");

		/// <summary>
		///View Journal Advice
		/// </summary>
		public static string ViewJournalAdvice => I18NResource.GetString(ResourceDirectory, "ViewJournalAdvice");

		/// <summary>
		///View Journal Entries
		/// </summary>
		public static string ViewJournalEntries => I18NResource.GetString(ResourceDirectory, "ViewJournalEntries");

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
		///<p>When you withdraw a transaction, it won't be forwarded to the workflow module. This means that your withdrawn transactions are rejected and require no further verification. However, you won't be able to unwithdraw this transaction later.</p>
		/// </summary>
		public static string TransactionWithdrawalInformation => I18NResource.GetString(ResourceDirectory, "TransactionWithdrawalInformation");

		/// <summary>
		///Cannot withdraw transaction during restricted transaction mode.
		/// </summary>
		public static string CannotWithdrawTransactionDuringRestrictedTransactionMode => I18NResource.GetString(ResourceDirectory, "CannotWithdrawTransactionDuringRestrictedTransactionMode");

		/// <summary>
		///Access is denied. You cannot withdraw someone else's transaction.
		/// </summary>
		public static string AccessDeniedCannotWithdrawSomeoneElseTransaction => I18NResource.GetString(ResourceDirectory, "AccessDeniedCannotWithdrawSomeoneElseTransaction");

	}
}
