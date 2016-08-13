package com.tuarua.jtorrent.settings;

/**
 * Created by Eoin Landy on 25/07/2016.
 */
public class Speed extends Object {
    public int uploadRateLimit = 0;
    public int downloadRateLimit = 0;
    public Boolean isuTPEnabled = true;
    public Boolean isuTPRateLimited = true;
    public Boolean rateLimitIpOverhead = false;
    public Boolean ignoreLimitsOnLAN = false;
}
