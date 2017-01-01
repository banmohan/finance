using System;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using MixERP.Finance.AppModels;
using Npgsql;

namespace MixERP.Finance.DAL.Eod
{
    public class PostgreSQLEodPerformer : IEodPerformer
    {
        public event EventHandler<EodEventArgs> NotificationReceived;

        public void Perform(string tenant, long loginId)
        {
            try
            {
                string sql = "VACUUM ANALYZE VERBOSE; SELECT * FROM finance.perform_eod_operation(@LoginId::bigint);";

                using (var command = new NpgsqlCommand(sql))
                {
                    command.Parameters.AddWithNullableValue("@LoginId", loginId);
                    command.CommandTimeout = 3600;

                    string connectionString = FrapidDbServer.GetConnectionString(tenant);

                    try
                    {
                        using (var connection = new NpgsqlConnection(connectionString))
                        {
                            command.Connection = connection;
                            connection.Notice += this.Connection_Notice;
                            connection.Open();
                            command.ExecuteNonQuery();
                        }
                    }
                    catch (NpgsqlException ex)
                    {
                        var e = new EodEventArgs(ex.Message, "error");
                        var notificationReceived = this.NotificationReceived;
                        notificationReceived?.Invoke(this, e);
                    }
                }
            }
            catch (Exception ex)
            {
                var e = new EodEventArgs(ex.Message, "error");
                var notificationReceived = this.NotificationReceived;
                notificationReceived?.Invoke(this, e);
            }
        }


        private void Connection_Notice(object sender, NpgsqlNoticeEventArgs e)
        {
            var notificationReceived = this.NotificationReceived;

            if (notificationReceived != null)
            {
                if (e.Notice != null)
                {
                    var args = new EodEventArgs(e.Notice.MessageText, e.Notice.Detail);

                    notificationReceived(this, args);
                }
            }
        }
    }
}