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

public class Handler : IHttpHandler
{

    static Dictionary<UInt32, FMD_LS_LobbyMissionInfo> _badcache = new Dictionary<UInt32, FMD_LS_LobbyMissionInfo>();
    static Exception _lastExcpetion = null;
    public void ProcessRequest(HttpContext context)
    {
        if (context.Request.HttpMethod.Equals("post", StringComparison.CurrentCultureIgnoreCase))
        {
            try
            {
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
                        var n = new FMD_LS_LobbyMissionInfo(bytes);
                        //_badcache[n.dwCookie] = n;
                        var pretty = Newtonsoft.Json.JsonConvert.SerializeObject(n, Newtonsoft.Json.Formatting.Indented);
                        Console.WriteLine(pretty);
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
                json = JsonConvert.SerializeObject(_badcache, Formatting.Indented);
            }
            else
            {
                json = JsonConvert.SerializeObject(_lastExcpetion, Formatting.Indented);
            }
            var bytes = System.Text.Encoding.ASCII.GetBytes(json);
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

public class FMD_LS_LobbyMissionInfo
{
    public byte[] Bytes { get; private set; }
    public FMD_LS_LobbyMissionInfo(byte[] data)
    {
        Bytes = data;
    }

    public UInt16 cbmsg { get { return BitConverter.ToUInt16(Bytes, 0); } }
    public UInt16 fmid { get { return BitConverter.ToUInt16(Bytes, 2); } }
    UInt16 ibszGameName { get { return BitConverter.ToUInt16(Bytes, 4); } }
    UInt16 cbszGameName { get { return BitConverter.ToUInt16(Bytes, 6); } }
    public string GameName { get { return readInternalString(ibszGameName, cbszGameName); } }
    UInt16 ibrgSquadIDs { get { return BitConverter.ToUInt16(Bytes, 8); } }
    UInt16 cbrgSquadIDs { get { return BitConverter.ToUInt16(Bytes, 10); } }
    public string SquadIDs { get { return readInternalString(ibrgSquadIDs, cbrgSquadIDs); } }
    UInt16 ibszGameDetailsFiles { get { return BitConverter.ToUInt16(Bytes, 12); } }
    UInt16 cbszGameDetailsFiles { get { return BitConverter.ToUInt16(Bytes, 14); } }
    public string GameDetailsFiles { get { return readInternalString(ibszGameDetailsFiles, cbszGameDetailsFiles); } }
    UInt16 ibszIGCStaticFile { get { return BitConverter.ToUInt16(Bytes, 16); } }
    UInt16 cbszIGCStaticFile { get { return BitConverter.ToUInt16(Bytes, 18); } }
    public string IGCStaticFile { get { return readInternalString(ibszIGCStaticFile, cbszIGCStaticFile); } }
    UInt16 ibszServerName { get { return BitConverter.ToUInt16(Bytes, 20); } }
    UInt16 cbszServerName { get { return BitConverter.ToUInt16(Bytes, 22); } }
    public string ServerName { get { return readInternalString(ibszServerName, cbszServerName); } }
    UInt16 ibszServerAddr { get { return BitConverter.ToUInt16(Bytes, 24); } }
    UInt16 cbszServerAddr { get { return BitConverter.ToUInt16(Bytes, 26); } }
    public string ServerAddr { get { return readInternalString(ibszServerAddr, cbszServerAddr); } }
    UInt16 ibszPrivilegedUsers { get { return BitConverter.ToUInt16(Bytes, 28); } }
    UInt16 cbszPrivilegedUsers { get { return BitConverter.ToUInt16(Bytes, 30); } }
    public string PrivilegedUsers { get { return readInternalString(ibszPrivilegedUsers, cbszPrivilegedUsers); } }
    UInt16 ibszServerVersion { get { return BitConverter.ToUInt16(Bytes, 32); } }
    UInt16 cbszServerVersion { get { return BitConverter.ToUInt16(Bytes, 34); } }
    public string ServerVersion { get { return readInternalString(ibszServerVersion, cbszServerVersion); } }
    public UInt32 dwPort { get { return BitConverter.ToUInt32(Bytes, 36); } }
    public UInt32 dwCookie { get { return BitConverter.ToUInt32(Bytes, 40); } }
    public UInt32 dwStartTime { get { return BitConverter.ToUInt32(Bytes, 44); } }
    public Int16 nMinRank { get { return BitConverter.ToInt16(Bytes, 46); } }
    public Int16 nMaxRank { get { return BitConverter.ToInt16(Bytes, 48); } }






    public bool fCountDownStarted { get { return readInternalBool(0); } } // bool fCountdownStarted: 1;
    public bool fInProgress { get { return readInternalBool(1); } } // bool fInProgress: 1;
    public bool fMSArena { get { return readInternalBool(2); } } // bool fMSArena: 1;
    public bool fScoresCount { get { return readInternalBool(3); } } // bool fScoresCount: 1;
    public bool fInvulnerableStations { get { return readInternalBool(4); } } // bool fInvulnerableStations: 1;
    public bool fAllowDevelopments { get { return readInternalBool(5); } } // bool fAllowDevelopments: 1;
    public bool fLimitedLives { get { return readInternalBool(6); } } // bool fLimitedLives: 1;
    public bool fConquest { get { return readInternalBool(7); } } // bool fConquest: 1;
    public bool fDeathMatch { get { return readInternalBool(8); } } // bool fDeathMatch: 1;
    public bool fCountdown { get { return readInternalBool(9); } } // bool fCountdown: 1;
    public bool fProsperity { get { return readInternalBool(10); } }// bool fProsperity: 1;
    public bool fArtifacts { get { return readInternalBool(11); } }// bool fArtifacts: 1;
    public bool fFlags { get { return readInternalBool(12); } }// bool fFlags: 1;
    public bool fTerritorial { get { return readInternalBool(13); } }// bool fTerritorial: 1;
    public bool fGuaranteedSlotsAvailable { get { return readInternalBool(14); } }// bool fGuaranteedSlotsAvailable: 1;
    public bool fAnySlotsAvailable { get { return readInternalBool(15); } }// bool fAnySlotsAvailable: 1;
    public bool fSquadGame { get { return readInternalBool(16); } }// bool fSquadGame: 1;   
    public bool fEjectPods { get { return readInternalBool(17); } }// bool fEjectPods: 1;



    private string readInternalString(UInt16 offset, UInt16 count)
    {
        var _b = Bytes;
        return Encoding.ASCII.GetString(_b, offset, count).Replace("\0", "");
    }
    private bool readInternalBool(int bit)
    {
        // start at byte 56, and add 4 bits to input
        // bitmask starts at bytes56,+4 bits
        bit += (56 * 8) + 4;
        var _b = Bytes;
        var _myByte = _b[bit / 8];
        var rem = bit % 8;
        var flag = (_myByte & (1 << rem)) != 0;
        return flag;
    }
}