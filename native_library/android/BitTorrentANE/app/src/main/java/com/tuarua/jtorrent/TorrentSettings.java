package com.tuarua.jtorrent;
import com.tuarua.jtorrent.constants.LogLevel;
import com.tuarua.jtorrent.settings.Advanced;
import com.tuarua.jtorrent.settings.Connections;
import com.tuarua.jtorrent.settings.Filters;
import com.tuarua.jtorrent.settings.Listening;
import com.tuarua.jtorrent.settings.Privacy;
import com.tuarua.jtorrent.settings.Proxy;
import com.tuarua.jtorrent.settings.Queueing;
import com.tuarua.jtorrent.settings.Speed;
import com.tuarua.jtorrent.settings.Storage;

import java.util.ArrayList;

/**
 * Created by Eoin Landy on 25/07/2016.
 */
public class TorrentSettings {
    public static ArrayList<String> priorityFileTypes = new ArrayList<String>();
    public static Boolean queryFileProgress = true;
    public static Storage storage = new Storage();
    public static Privacy privacy = new Privacy();
    public static Queueing queueing = new Queueing();
    public static Filters filters = new Filters();
    public static Speed speed = new Speed();
    public static Connections connections = new Connections();
    public static Proxy proxy = new Proxy();
    public static Listening listening = new Listening();
    public static Advanced advanced = new Advanced();
}
