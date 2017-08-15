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
    private readonly SortedList<string, bool> bots = new SortedList<string, bool> {
        {"sir_Ackley",true},
            {"sir_Adger",true},
            {"sir_Aislinn",true},
            {"sir_Alfer",true},
            {"sir_Arantxa",true},
            {"sir_Arundel",true},
            {"sir_Athelstan",true},
            {"sir_Awarnach",true},
            {"sir_Beacher",true},
            {"sir_Blythe",true},
            {"sir_Brewster",true},
            {"sir_Bromley",true},
            {"sir_Cade",true},
            {"sir_Calder",true},
            {"sir_Cedric",true},
            {"sir_Clemens",true},
            {"sir_Demelza",true},
            {"sir_Dorset",true},
            {"sir_Dudley",true},
            {"sir_Erskine",true},
            {"sir_Farley",true},
            {"sir_Farrah",true},
            {"sir_Godefealouf",true},
            {"sir_Goldman",true},
            {"sir_Gray",true},
            {"sir_Gundulfuleps",true},
            {"sir_Hollace",true},
            {"sir_Humphre",true},
            {"sir_Isolda",true},
            {"sir_Landon",true},
            {"sir_Lidberaus",true},
            {"sir_Llewellyn",true},
            {"sir_Luella",true},
            {"sir_Maida",true},
            {"sir_Maranul",true},
            {"sir_Marden",true},
            {"sir_Nara",true},
            {"sir_Radella",true},
            {"sir_Ravinger",true},
            {"sir_Reginald",true},
            {"sir_Ripley",true},
            {"sir_Rodbous",true},
            {"sir_Rogerul",true},
            {"sir_Siddel",true},
            {"sir_Siluefter",true},
            {"sir_Tostig",true},
            {"sir_Tranter",true},
            {"sir_Tyne",true},
            {"sir_WiHimrexangtor",true},
            {"sir_Winifred",true},
            {"sir_Wyndam",true}
        };

    static List<AllegNetLib.FMD_LS_LobbyMissionInfo> _latest = new List<AllegNetLib.FMD_LS_LobbyMissionInfo>();
    public void ProcessRequest(HttpContext context)
    {
        var returns = "";
        try
        {
            var user = context.Request.Headers["HTTP_USER"];

            var discourseUser = GetDiscourseUser(user);
            if (discourseUser != null)
            {
                returns = string.Format("OK\t{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n",
                    discourseUser.id,
                    discourseUser.username,
                    discourseUser.password_hash,
                    discourseUser.salt,
                    discourseUser.active,
                    discourseUser.suspended_till == null ? "": discourseUser.suspended_till.ToString());
            }   
        }
        catch (Exception e)
        {
        }

        context.Response.ContentType = "text/plain";
        var bytes = System.Text.Encoding.ASCII.GetBytes(returns);
        context.Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(15));
        context.Response.BinaryWrite(bytes);
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
        var connString = ConfigurationManager.ConnectionStrings["discourse"].ConnectionString;

        using (var conn = new NpgsqlConnection(connString))
        {

            // Retrieve all rows
            using (var cmd = new NpgsqlCommand("{select id, username, password_hash, salt, active, suspended_till from users where username = @username", conn))
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
                        ud.suspended_till = reader.GetDateTime(5);
                        return ud;
                    }
                }
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
    public DateTime suspended_till;
}