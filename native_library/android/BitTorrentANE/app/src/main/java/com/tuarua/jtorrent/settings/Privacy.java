package com.tuarua.jtorrent.settings;

import com.tuarua.jtorrent.constants.Encryption;

/**
 * Created by Eoin Landy on 25/07/2016.
 */
public class Privacy {
    public int encryption = Encryption.ENABLED;
    public Boolean useDHT = true;
    public Boolean useLSD = true;//Local Peer Discovery
    public Boolean usePEX = true;//Peer Exchange
    public Boolean useAnonymousMode = false;
}
