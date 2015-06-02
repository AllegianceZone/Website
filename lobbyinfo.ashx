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
    static List<AllegNetLib.FMD_LS_LobbyMissionInfo> _latest = new List<AllegNetLib.FMD_LS_LobbyMissionInfo>();
    public void ProcessRequest(HttpContext context)
    {
        if (context.Request.HttpMethod.Equals("post", StringComparison.CurrentCultureIgnoreCase)
            && context.Request.UserHostAddress == "191.236.106.84") // only let the lobby post
        {
            try
            {
                _lastExcpetion = null;
                _latest.Clear();
                using (var binaryReader = new System.IO.BinaryReader(context.Request.InputStream))
                {
                    var bytes = binaryReader.ReadBytes(Convert.ToInt32(context.Request.InputStream.Length));
                    var avail = bytes.Length;
                    var offset = 0;
                    do
                    {
                        var len = BitConverter.ToUInt16(bytes, offset);
                        var oneSet = new byte[len];
                        Buffer.BlockCopy(bytes, offset, oneSet, 0, len);
                        offset += len;
                        _latest.Add(AzUnpack.FromLobbyInfo.Convert(oneSet));
                        avail -= len;
                    } while (avail > 0);
                }
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
                json = Newtonsoft.Json.JsonConvert.SerializeObject(_latest.ToArray(), Newtonsoft.Json.Formatting.Indented);
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
