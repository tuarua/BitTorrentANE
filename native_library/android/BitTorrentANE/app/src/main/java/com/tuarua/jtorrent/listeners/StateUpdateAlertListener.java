package com.tuarua.jtorrent.listeners;

import com.frostwire.jlibtorrent.AlertListener;
import com.frostwire.jlibtorrent.alerts.Alert;
import com.frostwire.jlibtorrent.alerts.AlertType;
import com.frostwire.jlibtorrent.alerts.StateUpdateAlert;

/**
 * Created by Eoin Landy on 29/07/2016.
 */
public abstract class StateUpdateAlertListener implements AlertListener {
    @Override
    public int[] types() {
        return new int[]{AlertType.STATE_UPDATE.swig()};
    }

    @Override
    public void alert(Alert<?> alert) {
        switch (alert.type()) {
            case STATE_UPDATE:
                stateUpdate((StateUpdateAlert) alert);
                break;
            default:
                break;
        }
    }
    public abstract void stateUpdate(StateUpdateAlert alert);
}
