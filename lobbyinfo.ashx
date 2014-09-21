<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Net;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using Newtonsoft.Json;

public class Handler : IHttpHandler
{

    static Dictionary<UInt32, FMD_LS_LOBBYMISSIONINFO> _badcache = new Dictionary<UInt32, FMD_LS_LOBBYMISSIONINFO>();
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
                    var size = bytes.Length;
                    // get handle to the bytes
                    GCHandle handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                    var lobbymissioninfo = (FMD_LS_LOBBYMISSIONINFO)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(FMD_LS_LOBBYMISSIONINFO));
                    handle.Free();
                    _badcache[lobbymissioninfo.dwCookie] = lobbymissioninfo;
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

[StructLayout(LayoutKind.Sequential, Pack = 1)]
struct FMD_LS_LOBBYMISSIONINFO
{
    public UInt16 cbmsg;
    public UInt16 fmid;
    // IB = index of bytes
    // CB = count of bytes
    UInt16 ibszGameName;
    UInt16 cbszGameName;
    public string GameName { get { return readInternalString(ibszGameName, cbszGameName); } }
    UInt16 ibrgSquadIDs;
    UInt16 cbrgSquadIDs;
    public string SquadIDs { get { return readInternalString(ibrgSquadIDs, cbrgSquadIDs); } }
    UInt16 ibszGameDetailsFiles;
    UInt16 cbszGameDetailsFiles;
    public string GameDetailsFiles { get { return readInternalString(ibszGameDetailsFiles, cbszGameDetailsFiles); } }
    UInt16 ibszIGCStaticFile;
    UInt16 cbszIGCStaticFile;
    public string IGCStaticFile { get { return readInternalString(ibszIGCStaticFile, cbszIGCStaticFile); } }
    UInt16 ibszServerName;
    UInt16 cbszServerName;
    public string ServerName { get { return readInternalString(ibszServerName, cbszServerName); } }
    UInt16 ibszServerAddr;
    UInt16 cbszServerAddr;
    public string ServerAddr { get { return readInternalString(ibszServerAddr, cbszServerAddr); } }
    UInt16 ibszPrivilegedUsers;
    UInt16 cbszPrivilegedUsers;
    public string PrivilegedUsers { get { return readInternalString(ibszPrivilegedUsers, cbszPrivilegedUsers); } }
    UInt16 ibszServerVersion;
    UInt16 cbszServerVersion;
    public string ServerVersion { get { return readInternalString(ibszServerVersion, cbszServerVersion); } }
    public UInt32 dwPort;
    public UInt32 dwCookie;
    public UInt32 dwStartTime;
    public Int16 nMinRank;
    public Int16 nMaxRank;

    public numbers Numbers;
    public internalflag Flags;

    private string readInternalString(UInt16 offset, UInt16 count)
    {
        GCHandle handle = GCHandle.Alloc(this, GCHandleType.Pinned);
        var ptr = handle.AddrOfPinnedObject();
        var loc = ptr + offset;
        var str = Marshal.PtrToStringAnsi(loc, cbszGameName);
        handle.Free();
        return str;
    }
}
[StructLayout(LayoutKind.Sequential, Pack = 1, Size = 52)]
public struct numbers
{
    public int fCountDownStarted { get { return readInternalInt(0, 11); } } // uint nNumPlayers        : 11;
    public int nNumNoatPlayers { get { return readInternalInt(11, 11); } }// uint nNumNoatPlayers    : 11; 
    public int nMaxPlayersPerGame { get { return readInternalInt(22, 11); } }// uint nMaxPlayersPerGame : 11;
    public int nMinPlayersPerTeam { get { return readInternalInt(33, 8); } }// uint nMinPlayersPerTeam : 8;
    public int nMaxPlayersPerTeam { get { return readInternalInt(41, 8); } }// uint nMaxPlayersPerTeam : 8;
    public int nTeams { get { return readInternalInt(49, 3); } }// uint nTeams             : 3
    private int readInternalInt(byte offset, byte width)
    {
        GCHandle handle = GCHandle.Alloc(this, GCHandleType.Pinned);
        var ptr = handle.AddrOfPinnedObject();
        Int32 result = 0;
        byte setback = 0;
        if (offset + width > 32)
        {
            setback = 52 - 32;
            offset -= setback;
        }
        var loc = ptr + offset;
        var b = (Int32)Marshal.PtrToStructure(loc + setback, typeof(Int32));
        var mask = ((2 << (width + 1)) - 1);
        result = (b & mask);
        handle.Free();
        return Convert.ToInt32(result);
    }
}
[StructLayout(LayoutKind.Sequential, Pack = 1, Size = 18)]
public struct internalflag
{
    public bool fCountDownStarted { get { return readInternalFlat(0); } }// bool fCountdownStarted: 1;
    public bool fInProgress { get { return readInternalFlat(1); } }// bool fInProgress: 1;
    public bool fMSArena { get { return readInternalFlat(2); } }// bool fMSArena: 1;
    public bool fScoresCount { get { return readInternalFlat(3); } }   // bool fScoresCount: 1;
    public bool fInvulnerableStations { get { return readInternalFlat(4); } }    // bool fInvulnerableStations: 1;
    public bool fAllowDevelopments { get { return readInternalFlat(5); } }// bool fAllowDevelopments: 1;
    public bool fLimitedLives { get { return readInternalFlat(6); } }// bool fLimitedLives: 1;
    public bool fConquest { get { return readInternalFlat(7); } }// bool fConquest: 1;
    public bool fDeathMatch { get { return readInternalFlat(8); } }  // bool fDeathMatch: 1;
    public bool fCountdown { get { return readInternalFlat(9); } }  // bool fCountdown: 1;
    public bool fProsperity { get { return readInternalFlat(10); } }// bool fProsperity: 1;
    public bool fArtifacts { get { return readInternalFlat(11); } } // bool fArtifacts: 1;
    public bool fFlags { get { return readInternalFlat(12); } } // bool fFlags: 1;
    public bool fTerritorial { get { return readInternalFlat(13); } }// bool fTerritorial: 1;
    public bool fGuaranteedSlotsAvailable { get { return readInternalFlat(14); } }// bool fGuaranteedSlotsAvailable: 1;
    public bool fAnySlotsAvailable { get { return readInternalFlat(15); } }// bool fAnySlotsAvailable: 1;
    public bool fSquadGame { get { return readInternalFlat(16); } } // bool fSquadGame: 1;   
    public bool fEjectPods { get { return readInternalFlat(17); } }// bool fEjectPods: 1;
    private bool readInternalFlat(byte offset)
    {
        GCHandle handle = GCHandle.Alloc(this, GCHandleType.Pinned);
        var ptr = handle.AddrOfPinnedObject();
        var loc = ptr + (offset / 4);
        var bit = offset % 4;
        var b = (byte)Marshal.PtrToStructure(loc, typeof(byte));
        var result = (b & (2 << bit)) == 1;
        handle.Free();
        return result;
    }
}