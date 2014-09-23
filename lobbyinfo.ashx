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
public class Handler : IHttpHandler
{
    static Exception _lastExcpetion = null;
    static string latest = "[]";
    static DateTime lastUpdate = DateTime.MinValue;
    public void ProcessRequest(HttpContext context)
    {
        //var latest = context.Cache.Get("lobbyinfo") as Dictionary<UInt32, FMD_LS_LobbyMissionInfo>;
        //if (latest == null)
        //    latest = new Dictionary<uint, FMD_LS_LobbyMissionInfo>();
        
        if (context.Request.HttpMethod.Equals("post", StringComparison.CurrentCultureIgnoreCase))
        {
            try
            {
                _lastExcpetion = null;
                using (var tr = new StreamReader(context.Request.InputStream))
                {
                    latest = tr.ReadToEnd();
                    lastUpdate = DateTime.UtcNow;
                }
                // cache it: NOT WORKING -> TODO: Redis
                //context.Cache.Add("lobbyinfo", latest, null
                //    , DateTime.UtcNow.AddMinutes(20), System.Web.Caching.Cache.NoSlidingExpiration
                //    , System.Web.Caching.CacheItemPriority.Normal
                //    , null);
            }
            catch (Exception e)
            {
                _lastExcpetion = e;
                throw;
            }
        }
        else
        {
            context.Response.ContentType = "application/json";
            string json = "";
            if (_lastExcpetion == null)
            {
                if (DateTime.UtcNow - lastUpdate > TimeSpan.FromSeconds(10))
                {
                    var wc = (new System.Net.WebClient()).DownloadString("http://azforum.cloudapp.net/lobbyinfo.json");
                    latest = wc;
                    lastUpdate = DateTime.UtcNow;
                }                
                json = latest;
            }
            else
            {
                json = JsonConvert.SerializeObject(_lastExcpetion, Formatting.Indented);
                _lastExcpetion = null;
            }
            var bytes = System.Text.Encoding.ASCII.GetBytes(json);
            context.Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(15));
            context.Response.BinaryWrite(bytes);
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
