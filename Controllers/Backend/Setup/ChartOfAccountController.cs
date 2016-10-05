using Frapid.Dashboard;
using System.Web.Mvc;

namespace MixERP.Finance.Controllers.Backend.Setup
{
    public class ChartOfAccountController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/chart-of-accounts")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/ChartOfAccounts.cshtml", this.Tenant));
        }
    }
    public class CashRepositoryController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cash-repositories")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CashRepositories.cshtml", this.Tenant));
        }
    }
    public class CurrencyController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/currencies")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Currencies.cshtml", this.Tenant));
        }
    }
    public class BankAccountController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/bank-accounts")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/BankAccounts.cshtml", this.Tenant));
        }
    }
    public class CashFlowHeadingController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cash-flow/headings")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CashFlowHeadings.cshtml", this.Tenant));
        }
    }

    public class CashFlowSetupController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cash-flow/setup")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CashFlowSetups.cshtml", this.Tenant));
        }
    }
    public class CostCenterController : FinanceDashboardController
    {
        [Route("dashboard/finance/setup/cost-centers")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CostCenters.cshtml", this.Tenant));
        }
    }
}