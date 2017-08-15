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
    private readonly string[] bots = {
            "sir_Ackley",
            "sir_Adger",
            "sir_Aislinn",
            "sir_Alfer",
            "sir_Arantxa",
            "sir_Arundel",
            "sir_Athelstan",
            "sir_Awarnach",
            "sir_Beacher",
            "sir_Blythe",
            "sir_Brewster",
            "sir_Bromley",
            "sir_Cade",
            "sir_Calder",
            "sir_Cedric",
            "sir_Clemens",
            "sir_Demelza",
            "sir_Dorset",
            "sir_Dudley",
            "sir_Erskine",
            "sir_Farley",
            "sir_Farrah",
            "sir_Godefealouf",
            "sir_Goldman",
            "sir_Gray",
            "sir_Gundulfuleps",
            "sir_Hollace",
            "sir_Humphre",
            "sir_Isolda",
            "sir_Landon",
            "sir_Lidberaus",
            "sir_Llewellyn",
            "sir_Luella",
            "sir_Maida",
            "sir_Maranul",
            "sir_Marden",
            "sir_Nara",
            "sir_Radella",
            "sir_Ravinger",
            "sir_Reginald",
            "sir_Ripley",
            "sir_Rodbous",
            "sir_Rogerul",
            "sir_Siddel",
            "sir_Siluefter",
            "sir_Tostig",
            "sir_Tranter",
            "sir_Tyne",
            "sir_WiHimrexangtor",
            "sir_Winifred",
            "sir_Wyndam"
        };

    static List<AllegNetLib.FMD_LS_LobbyMissionInfo> _latest = new List<AllegNetLib.FMD_LS_LobbyMissionInfo>();
    public void ProcessRequest(HttpContext context)
    {
        var returns = "";
        try
        {
            var user = context.Request.Headers["HTTP_USER"];
            var pos = -1;
            for (int i = 0; i < bots.Length; i++)
            {
                if(bots[i] == user)
                {
                    pos = i;
                }
            }
            var user_id = 7 * 11 * 23 * 29 * 31 + (pos * 37);
            var user_username = user;
            var user_password_hash = user_id / 23;
            var user_salt = user_id / 11;
            var user_active = "true";
            var user_suspended_till = "";

            if (
                    //context.Request.UserAgent == "Allegiance"  && 
                   pos > -1)
            {
                returns = string.Format("OK\t{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n",
                    user_id,
                    user_username,
                    user_password_hash,
                    user_salt,
                    user_active,
                    user_suspended_till);
            }
        } catch(Exception e)
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
}
