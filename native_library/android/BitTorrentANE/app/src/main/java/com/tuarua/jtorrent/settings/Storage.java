package com.tuarua.jtorrent.settings;

/**
 * Created by Eoin Landy on 25/07/2016.
 */
public class Storage extends Object {
    public String outputPath;
    public String torrentPath;
    public String resumePath;
    public String sessionStatePath;
    public String geoipDataPath;
    public Boolean sparse = true;
    public Boolean enabled = true;
}
