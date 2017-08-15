<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;

public class Handler : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        using (var reader = new System.IO.StreamReader(context.Request.InputStream))
	{
		string data = reader.ReadToEnd();
		if (data.Length < 36) {
			//read in
		} else {
			context.Response.WriteFile("inputmaps/test.7z");
		}
	}
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}