package com.tuarua.jtorrent.listeners;

import com.frostwire.jlibtorrent.AlertListener;
import com.frostwire.jlibtorrent.alerts.Alert;
import com.frostwire.jlibtorrent.alerts.AlertType;
import com.frostwire.jlibtorrent.alerts.MetadataReceivedAlert;

/**
 * Created by Eoin Landy on 26/07/2016.
 */
public abstract class MetadataReceivedAlertListener implements AlertListener {
    @Override
    public int[] types() {
        return new int[]{AlertType.METADATA_RECEIVED.swig()};
    }

    @Override
    public void alert(Alert<?> alert) {
        switch (alert.type()) {
            case METADATA_RECEIVED:
                metaDataReceived((MetadataReceivedAlert) alert);
                break;
            default:
                break;
        }
    }
    public abstract void metaDataReceived(MetadataReceivedAlert alert);
}
