package com.tuarua;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class BitTorrentANE  implements FREExtension {
    @Override
    public void initialize() {

    }

    @Override
    public FREContext createContext(String s) {
        BitTorrentANEContext context = new BitTorrentANEContext();
        return context;
    }

    @Override
    public void dispose() {

    }
}
