package com.tuarua.jtorrent.settings;

import java.util.Map;

/**
 * Created by Eoin Landy on 25/07/2016.
 */
public class Advanced {
    public int diskCacheSize = 0;//0 is off, -1 is auto, otherwise value in MiB
    public int diskCacheTTL = 60; //seconds
    public int outgoingPortsMin = 0;//0 is disabled
    public int outgoingPortsMax = 0;//0 is disabled
    public int numMaxHalfOpenConnections = 20;//0 is disabled
    public String announceIP = "";

    public Boolean enableOsCache = true;
    public Boolean recheckTorrentsOnCompletion = false;
    public Boolean resolveCountries = true;
    public Boolean resolvePeerHostNames = false;
    public Boolean isSuperSeedingEnabled = false;
    public Boolean announceToAllTrackers = false;
    public Boolean enableTrackerExchange = true;
    public Boolean listenOnIPv6 = false;
    //public Object networkInterface;
    public Map<String,String> networkInterface;
}
