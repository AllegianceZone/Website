<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;

public class Handler : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        using (var reader = new System.IO.StreamReader(context.Request.InputStream))
	    {
            if (context.Request.UserAgent == "Allegiance")
            {
                try
                {
                    string data = reader.ReadToEnd();
                    var user = context.Request.Headers["HTTP_USER"];
                    if (data.Length > 36)
                    {
                        var file = context.Request.Files[0];
                        file.SaveAs("inputmaps/" + user + ".7z");
                        context.Response.Write("OK");
                    }
                    else
                    {
                        context.Response.WriteFile("inputmaps/" + user + ".7z");
                    }
                }
                catch (Exception e)
                {
                    context.Response.ContentType = "text/plain";
                    context.Response.Write(string.Format("NOPE\t\n{0}\n{1}", e.Message, e.StackTrace));
                }
            }
	    }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}
