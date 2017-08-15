<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using Newtonsoft.Json;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json.Linq;
using Npgsql;
using System.Configuration;
using Npgsql.PostgresTypes;
public class Handler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        var returns = "";
        try
        {
            var user = context.Request.Headers["USER"];

            var discourseUser = GetDiscourseUser(user);
            if (discourseUser != null)
            {
                returns = string.Format(
                    "OK\t{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n",
                    discourseUser.id,
                    discourseUser.username,
                    discourseUser.password_hash,
                    discourseUser.salt,
                    discourseUser.active,
                    discourseUser.suspended_till.HasValue ? discourseUser.suspended_till.ToString() : ""
                    );
            }
        }
        catch (Exception e)
        {
            returns = string.Format("NOPE\t\n{0}\n{1}", e.Message, e.StackTrace);
        }
        context.Response.Write(returns);
    }

    public bool IsReusable
    {
        get
        {
            return true;
        }
    }

    public UserData GetDiscourseUser(string username)
    {
        var connString = Environment.GetEnvironmentVariable("CONNECTION_STRING");

        using (var conn = new NpgsqlConnection(connString))
        {
            // Retrieve all rows
            using (var cmd = new NpgsqlCommand("select id, username, password_hash, salt, active, suspended_till from users where username = @username", conn))
            {
                cmd.Parameters.AddWithValue("@username", NpgsqlTypes.NpgsqlDbType.Text, username);
                conn.Open();
                cmd.Prepare();

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var ud = new UserData();
                        ud.id = reader.GetInt32(0);
                        ud.username = reader.GetString(1);
                        ud.password_hash = reader.GetString(2);
                        ud.salt = reader.GetString(3);
                        ud.active = reader.GetBoolean(4);
                        ud.suspended_till = reader.IsDBNull(5) ? ((DateTime?) null) : reader.GetDateTime(5);
                        return ud;
                    }
                }
                conn.Close();
            }

        }
        return null;
    }
}
public class UserData
{
    public int id;
    public string username;
    public string password_hash;
    public string salt;
    public bool active;
    public DateTime? suspended_till;
}