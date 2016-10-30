using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Dashboard;
using MixERP.Finance.Cache;

namespace MixERP.Finance
{
    public sealed class CustomJavascriptVariable : ICustomJavascriptVariable
    {
        public async Task<Dictionary<string, string>> GetAsync(string tenant, int officeId)
        {
            var dictionary = new Dictionary<string, string>();
            var model = await Dates.GetFrequencyDatesAsync(tenant, officeId).ConfigureAwait(false);

            dictionary.Add("OfficeId", model.OfficeId.ToString());
            dictionary.Add("Today", model.Today.ToString("O"));
            dictionary.Add("MonthStartDate", model.MonthStartDate.ToString("O"));
            dictionary.Add("MonthEndDate", model.MonthEndDate.ToString("O"));
            dictionary.Add("QuarterStartDate", model.QuarterStartDate.ToString("O"));
            dictionary.Add("QuarterEndDate", model.QuarterEndDate.ToString("O"));
            dictionary.Add("FiscalHalfStartDate", model.FiscalHalfStartDate.ToString("O"));
            dictionary.Add("FiscalHalfEndDate", model.FiscalHalfEndDate.ToString("O"));
            dictionary.Add("FiscalYearStartDate", model.FiscalYearStartDate.ToString("O"));
            dictionary.Add("FiscalYearEndDate", model.FiscalYearEndDate.ToString("O"));

            return dictionary;
        }
    }
}