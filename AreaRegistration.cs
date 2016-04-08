using System.Web.Mvc;
using Frapid.Areas;

namespace MixERP.Finance
{
    public class AreaRegistration : FrapidAreaRegistration
    {
        public override string AreaName => "MixERP.Finance";

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.Routes.LowercaseUrls = true;
            context.Routes.MapMvcAttributeRoutes();
        }
    }
}