using System;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using MixERP.Finance.AppModels;
using Npgsql;

namespace MixERP.Finance.DAL.Eod
{
    public class SqlServerEodPerformer : IEodPerformer
    {
        public event EventHandler<EodEventArgs> NotificationReceived;

        public void Perform(string tenant, long loginId)
        {
            Task eodTask;

            string sql = "EXECUTE finance.perform_eod_operation @LoginId;";

            using (var command = new SqlCommand(sql))
            {
                command.Parameters.AddWithNullableValue("@LoginId", loginId);
                command.CommandTimeout = 3600;
                eodTask = this.ListenNonQueryAsync(tenant, command);
            }
            try
            {
                eodTask.Start();
            }
            catch (Exception ex)
            {
                var e = new EodEventArgs(ex.Message, "error");
                var notificationReceived = this.NotificationReceived;
                notificationReceived?.Invoke(this, e);
            }
        }

        public Task ListenNonQueryAsync(string tenant, SqlCommand command)
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
                        var connection = new SqlConnection(connectionString))
                    {
                        command.Connection = connection;

                        connection.InfoMessage += this.Connection_Notice;
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

        private void Connection_Notice(object sender, SqlInfoMessageEventArgs e)
        {
            var notificationReceived = this.NotificationReceived;

            if (notificationReceived == null)
            {
                return;
            }

            if (!string.IsNullOrWhiteSpace(e.Message))
            {
                var args = new EodEventArgs(e.Message, e.Source);
                notificationReceived(this, args);
            }

            foreach (SqlError error in e.Errors)
            {
                var args = new EodEventArgs(error.Message, error.Source);
                notificationReceived(this, args);
            }
        }
    }
}