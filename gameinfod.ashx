<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Net;
public class Handler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        var uri = "ftp://allegiancezone.cloudapp.net:21122/gameinfod.json";
        //var wr = FtpWebRequest.Create();
        WebClient request = new WebClient();
        // This example assumes the FTP site uses anonymous logon.
        request.Credentials = new NetworkCredential("anonymous", "site@allegiancezone.com");
        try
        {
            byte[] newFileData = request.DownloadData(uri);
            //string fileString = System.Text.Encoding.UTF8.GetString(newFileData);
            //Console.WriteLine(fileString);
            context.Response.ContentType = "application/json";
            context.Response.BinaryWrite(newFileData);
        }
        catch (WebException e)
        {
            context.Response.StatusCode = 500;
            context.Response.Write(e.Message);
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}