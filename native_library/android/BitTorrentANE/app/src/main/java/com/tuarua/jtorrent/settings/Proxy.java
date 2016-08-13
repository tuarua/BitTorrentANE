package com.tuarua.jtorrent.settings;

import com.tuarua.jtorrent.constants.ProxyType;

/**
 * Created by Eoin Landy on 25/07/2016.
 */
public class Proxy {
    public int type = ProxyType.DISABLED;
    public int port = 8080;
    public String host = "0.0.0.0";
    public Boolean useForPeerConnections = false;
    public Boolean force = false;
    public Boolean useAuth = false;
    public String username = "";
    public String password = "";
}
