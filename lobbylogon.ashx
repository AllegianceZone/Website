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

using System.Collections.Concurrent;
public class Handler : IHttpHandler
{

    static ConcurrentDictionary<string,UserData> db = new ConcurrentDictionary<string,UserData>();

    public void ProcessRequest(HttpContext context)
    {
        if (context.Request.HttpMethod == "GET")
        {
            HandleLogonRequest(context);
        }
        else if (context.Request.HttpMethod == "POST")
        {
            HandleNewDataPosted(context);
        }
    }

    public void HandleNewDataPosted(HttpContext context)
    {
        var returns = "";
        try
        {
            if (context.Request.Headers["X-PSK"] == Environment.GetEnvironmentVariable("X-PSK")
                && context.Request.Headers["X-TYPE"] == "psql")
            {
                var content = "";
                using (var reader = new System.IO.StreamReader(context.Request.InputStream))
                {
                    content = reader.ReadToEnd();
                }

                // parse the table.
                var users = content.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries).Skip(2)
                        .Where(x => !string.IsNullOrEmpty(x) && !x.StartsWith("("))
                        .Select(x =>
                        {
                            var cells = x.Split('|').Select(y => y.Trim()).ToArray();
                            var user = new UserData();
                            user.id = Convert.ToInt32(cells[0]);
                            user.username = cells[1];
                            user.active = cells[2].Contains('t');
                            user.game_password = cells[3];
                            user.suspended_till = cells[4].Length > 0 ? Convert.ToDateTime(cells[4]) : (DateTime?)null;
                            return user;
                        });

                foreach (var user in users)
                {
                    db.AddOrUpdate(user.username, user, (username, old) => user);
                }

                returns = "Nice\n" + db.Count + "\n";
            }
        }
        catch (Exception e)
        {
            returns = string.Format("NOPE\t\n{0}\n{1}", e.Message, e.StackTrace);
        }
        context.Response.Write(returns);
    }

    public void HandleLogonRequest(HttpContext context)
    {
        var returns = string.Format("NOPE\t{0}\n", db.Count);;
        try
        {   
            var user =     context.Request.Headers["USER"];
            var password = context.Request.Headers["PASSWORD"];
            if (!string.IsNullOrEmpty(user) && !string.IsNullOrEmpty(password))
            {
                UserData userdata;
                db.TryGetValue(user, out userdata);
                if (userdata != null && userdata.game_password.Length > 0 && userdata.game_password == password)
                {
                    returns = string.Format("OK\t{0}\t{1}\t{2}\t{3}\n"
                        , userdata.id
                        , userdata.username
                        , userdata.active
                        , userdata.suspended_till.HasValue ? userdata.suspended_till.Value.ToString() : "");
                }
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
}
public class UserData
{
    public int id;
    public string username = "";
    public bool active;
    public string game_password = "";
    public DateTime? suspended_till;
}