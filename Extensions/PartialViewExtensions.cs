using System.Web.Mvc;
using Frapid.Dashboard.Extensions;

namespace MixERP.Finance.Extensions
{
    public static class PartialViewExtensions
    {
        public static MvcHtmlString PartialView(this HtmlHelper helper, string path, string tenant)
        {
            return helper.PartialView<AreaRegistration>(path, tenant);
        }

        public static MvcHtmlString DashboardPartialView(this HtmlHelper helper, string path, string tenant)
        {
            return helper.PartialView<Frapid.Dashboard.AreaRegistration>(path, tenant);
        }

        public static MvcHtmlString PartialView(this HtmlHelper helper, string path, string tenant, object model)
        {
            return helper.PartialView<AreaRegistration>(path, tenant, model);
        }

        public static MvcHtmlString SocialPartialView(this HtmlHelper helper, string path, string tenant)
        {
            return helper.PartialView<Social.AreaRegistration>(path, tenant);
        }

        public static MvcHtmlString SocialPartialView(this HtmlHelper helper, string path, string tenant, object model)
        {
            return helper.PartialView<Social.AreaRegistration>(path, tenant, model);
        }
    }
}