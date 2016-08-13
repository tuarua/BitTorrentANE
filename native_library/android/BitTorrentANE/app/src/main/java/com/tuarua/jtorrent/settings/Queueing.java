package com.tuarua.jtorrent.settings;

/**
 * Created by Eoin Landy on 25/07/2016.
 */
public class Queueing {
    public Boolean enabled = false;
    public int maxActiveDownloads = 3;
    public int maxActiveTorrents = 5;
    public int maxActiveUploads = 3;
    public Boolean ignoreSlow = false;
}
