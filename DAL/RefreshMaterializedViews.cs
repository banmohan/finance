using System.Threading.Tasks;
using Frapid.DataAccess;

namespace MixERP.Finance.DAL
{
    public static class RefreshMaterializedViews
    {
        private const string Template = @"DO
                                        $$
                                          DECLARE _sql text;
                                        BEGIN
                                            SELECT string_agg(sql, E'\n') INTO _sql
                                            FROM
                                            (
                                            SELECT
                                                  'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || quote_ident(nspname) || '.' ||  quote_ident(relname) || ';' AS sql
                                            FROM pg_class t
                                            INNER JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace
                                            WHERE t.relkind = 'm'
                                            AND nspname NOT LIKE 'pg-%'
                                            ) AS views;

                                            --RAISE INFO '%', _sql;
                                            EXECUTE _sql;
                                        END;
                                        $$
                                        LANGUAGE plpgsql;";

        public static async Task RefreshAsync(string tenant, bool concurrently)
        {
            string sql = Template;

            if (!concurrently)
            {
                sql = sql.Replace("VIEW CONCURRENTLY", "VIEW");
            }

            await Factory.NonQueryAsync(tenant, sql).ConfigureAwait(false);
        }
    }
}