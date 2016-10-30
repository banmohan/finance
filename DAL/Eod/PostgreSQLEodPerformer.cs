using System;
using System.Threading.Tasks;
using Frapid.Configuration;
using MixERP.Finance.AppModels;
using Npgsql;

namespace MixERP.Finance.DAL.Eod
{
    public class PostgreSQLEodPerformer : IEodPerformer
    {
        public event EventHandler<EodEventArgs> NotificationReceived;

        public void Perform(string tenant, long loginId)
        {
            string sql = "VACUUM ANALYZE VERBOSE;";
            Task vacuumAnalyzeTask;
            Task eodTask;

            using (var command = new NpgsqlCommand(sql))
            {
                command.CommandTimeout = 3600;
                vacuumAnalyzeTask = this.ListenNonQueryAsync(tenant, command);
            }


            sql = "SELECT * FROM finance.perform_eod_operation(@LoginId::bigint);";

            using (var command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@LoginId", loginId);
                command.CommandTimeout = 3600;
                eodTask = this.ListenNonQueryAsync(tenant, command);
            }
            try
            {
                vacuumAnalyzeTask.Start();

                vacuumAnalyzeTask.ContinueWith(delegate { eodTask.Start(); });
            }
            catch (Exception ex)
            {
                var e = new EodEventArgs(ex.Message, "error");
                var notificationReceived = this.NotificationReceived;
                notificationReceived?.Invoke(this, e);
            }
        }

        public Task ListenNonQueryAsync(string tenant, NpgsqlCommand command)
        {
            if (command == null)
            {
                return null;
            }
            string connectionString = FrapidDbServer.GetConnectionString(tenant);

            var task = new Task(delegate
            {
                try
                {
                    using (
                        var connection = new NpgsqlConnection(connectionString))
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
            });

            return task;
        }

        private void Connection_Notice(object sender, NpgsqlNoticeEventArgs e)
        {
            var notificationReceived = this.NotificationReceived;

            if (notificationReceived != null)
            {
                if (e.Notice != null)
                {
                    var args = new EodEventArgs(e.Notice.Message, e.Notice.Detail);

                    notificationReceived(this, args);
                }
            }
        }
    }
}