<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Net;
public class Handler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {

        var latest = context.Cache.Get("gameinfod") as byte[];
        if(latest==null)
        {    
            try
            {
                var uri = "ftp://allegiancezone.cloudapp.net:21122/gameinfod.json";
                //var wr = FtpWebRequest.Create();
                WebClient request = new WebClient();// This example assumes the FTP site uses anonymous logon.
                request.Credentials = new NetworkCredential("anonymous", "site@allegiancezone.com");
                latest = request.DownloadData(uri);
            
                // cache it:
                context.Cache.Add("gameinfod", latest, null
                    , DateTime.UtcNow.AddMinutes(3), System.Web.Caching.Cache.NoSlidingExpiration
                    , System.Web.Caching.CacheItemPriority.Normal
                    , null);
            }
            catch (WebException e)
            {
                context.Response.StatusCode = 500;
                context.Response.Write(e.Message);
            }
        }
        context.Response.ContentType = "application/json";
        context.Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(3));
        context.Response.BinaryWrite(latest);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}