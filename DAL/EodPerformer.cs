using System;
using Frapid.Configuration.Db;
using Frapid.Mapper.Database;
using MixERP.Finance.AppModels;
using MixERP.Finance.DAL.Eod;

namespace MixERP.Finance.DAL
{
    public class EodPerformer
    {
        public event EventHandler<EodEventArgs> NotificationReceived;

        private IEodPerformer GetPerformer(string tenant)
        {
            string providerName = DbProvider.GetProviderName(tenant);
            var type = DbProvider.GetDbType(providerName);

            if (type == DatabaseType.PostgreSQL)
            {
                return new PostgreSQLEodPerformer();
            }

            if (type == DatabaseType.SqlServer)
            {
                return new SqlServerEodPerformer();
            }

            throw new NotImplementedException();
        }


        public void Perform(string tenant, long loginId)
        {
            var eod = this.GetPerformer(tenant);
            {
                eod.NotificationReceived += this.Performer_NotificationReceived;
                eod.Perform(tenant, loginId);
            }
        }

        private void Performer_NotificationReceived(object sender, EodEventArgs e)
        {
            this.NotificationReceived?.Invoke(sender, e);
        }
    }
}