package us.infuse.starmicronics;

import android.content.Context;
import android.os.AsyncTask;
import android.os.SystemClock;
import android.util.Log;

import com.starmicronics.stario.StarIOPort;
import com.starmicronics.stario.StarIOPortException;
import com.starmicronics.stario.StarPrinterStatus;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.HashMap;
import java.util.Map;

public class CDVStarMicronicsAirCash extends CordovaPlugin {

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
            throws JSONException {
        boolean success = true;
        if (action.equals("isOnline")) {
            isOnline(args.getString(0), args.getString(1), callbackContext);
        } else if (action.equals("isOpen")) {
            isOnline(args.getString(0), args.getString(1), callbackContext);
        } else if (action.equals("openCashDrawer")) {
            this.openCashDrawer(args.getString(0), args.getString(1), callbackContext);
        } else {
            success = false;
        }

        return success;
    }

    public void isOnline(String drawerPortName, String drawerPortSetting, CallbackContext callbackContext) {
        Map<String, Object> result = this.checkDrawerStatus(drawerPortName, drawerPortSetting);
        if (result.get("error") != null) {
            callbackContext.error((String) result.get("error"));
        } else {
            callbackContext.success(((Boolean) result.get("isOnline")) ? 1 : 0);
        }
    }

    public void isOpen(String drawerPortName, String drawerPortSetting, CallbackContext callbackContext) {
        Map<String, Object> result = this.checkDrawerStatus(drawerPortName, drawerPortSetting);
        if (result.get("error") != null) {
            callbackContext.error((String) result.get("error"));
        } else {
            callbackContext.success(((Boolean) result.get("isOpen")) ? 1 : 0);
        }
    }

    /**
     * This function checks the status of the drawer
     *
     * @param portName     Port name to use for communication.
     *                     This should be (TCP:<IPAddress>)
     * @param portSettings Should be blank
     */
    public Map<String, Object> checkDrawerStatus(
            String portName, String portSettings) {
        StarIOPort port = null;
        Map<String, Object> result = new HashMap<String, Object>();
        try {
            Context context = this.cordova.getActivity().getApplicationContext();
            port = StarIOPort.getPort(portName, portSettings, 10000, context);

            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                result.put("error", e.getMessage());
            }

            StarPrinterStatus status = port.retreiveStatus();

            if (status.offline) {
                result.put("isOnline", false);
            } else {
                result.put("isOnline", true);
            }
            if (status.compulsionSwitch) {
                result.put("isOpen", true);
            } else {
                result.put("isOpen", false);
            }
        } catch (StarIOPortException e) {
            result.put("error", e.getMessage());
        } finally {
            if (port != null) {
                try {
                    StarIOPort.releasePort(port);
                } catch (StarIOPortException e) {
                    result.put("error", e.getMessage());
                }
            }
        }
        return result;
    }

    protected void openCashDrawer(final String drawerPortName, final String drawerportSetting,
                                  final CallbackContext callbackContext) {
        AsyncTask<Void, Void, StarPrinterStatus> DrawerOpenCheckTask =
                new AsyncTask<Void, Void, StarPrinterStatus>() {
                    StarIOPort port = null;

                    @Override
                    protected StarPrinterStatus doInBackground(Void... params) {
                        StarPrinterStatus status = new StarPrinterStatus();
                        try {
                            port = StarIOPort.getPort(drawerPortName, drawerportSetting, 10000);
                            status = port.beginCheckedBlock();
                        } catch (StarIOPortException e) {
                            if (port != null) {
                                try {
                                    StarIOPort.releasePort(port);
                                } catch (StarIOPortException e1) {
                                    Log.e(this.getClass().toString(), e1.getMessage());
                                }
                            }
                            port = null;

                        }
                        return status;
                    }

                    @Override
                    protected void onPostExecute(StarPrinterStatus status) {

                        if (port == null) {
                            callbackContext.error("DK-AirCash is turned off or other host is using the DK-AirCash");
                            return;
                        }

                        if (status.compulsionSwitch) {
                            callbackContext.error("Drawer was already opened");

                            if (port != null) {
                                try {
                                    StarIOPort.releasePort(port);
                                } catch (StarIOPortException e) {
                                    Log.e(this.getClass().toString(), e.getMessage());
                                }
                            }

                            return;
                        }

                        AsyncTask<Void, Void, StarPrinterStatus> task = new AsyncTask<Void, Void, StarPrinterStatus>() {

                            @Override
                            protected StarPrinterStatus doInBackground(Void... params) {
                                StarPrinterStatus status = new StarPrinterStatus();
                                long startTimeMillis = System.currentTimeMillis();

                                try {
                                    final byte[] drawerCommand = new byte[]{0x07};
                                    port.writePort(drawerCommand, 0, drawerCommand.length);

                                    status = port.endCheckedBlock();

                                    while (true) { // check drawer open status for 3 sec
                                        SystemClock.sleep(200);

                                        status = port.retreiveStatus();
                                        if (status.compulsionSwitch) {
                                            break;
                                        }

                                        if (System.currentTimeMillis() - startTimeMillis > 3000) {
                                            break;
                                        }
                                    }

                                } catch (StarIOPortException e) {
                                    Log.e(this.getClass().toString(), e.getMessage());
                                }

                                return status;
                            }

                            @Override
                            protected void onPostExecute(StarPrinterStatus status) {

                                if (!status.offline && !status.compulsionSwitch) {
                                    callbackContext.error("Drawer didn't open");
                                    if (port != null) {
                                        try {
                                            StarIOPort.releasePort(port);
                                            SystemClock.sleep(1000); // 1sec
                                        } catch (StarIOPortException e) {
                                            callbackContext.error(e.getMessage());
                                        }
                                    }

                                    return;
                                }

                                AsyncTask<Void, Void, Boolean> task2 = new AsyncTask<Void, Void, Boolean>() {

                                    StarPrinterStatus status = new StarPrinterStatus();

                                    @Override
                                    protected Boolean doInBackground(Void... params) {
                                        int timeoutMillis = 30000; // 30sec
                                        long startTimeMillis = System.currentTimeMillis();
                                        while (true) { // check drawer close status
                                            try {
                                                status = port.retreiveStatus();

                                                if (!status.compulsionSwitch) {
                                                    return true;
                                                }

                                                if (System.currentTimeMillis() - startTimeMillis > timeoutMillis) {
                                                    return false;
                                                }

                                                SystemClock.sleep(150);
                                            } catch (StarIOPortException e) {
                                                return false;
                                            }
                                        }
                                    }

                                    @Override
                                    protected void onPostExecute(Boolean result) {
                                        if (port != null) {
                                            try {
                                                StarIOPort.releasePort(port);
                                            } catch (StarIOPortException e) {
                                                callbackContext.error(e.getMessage());
                                            }
                                        }

                                        if (result) {
                                            callbackContext.success("Completed successfully");

                                            AsyncTask<Void, Void, Boolean> task3 = new AsyncTask<Void, Void, Boolean>() {

                                                @Override
                                                protected Boolean doInBackground(Void... params) {
                                                    SystemClock.sleep(2000);
                                                    return true;
                                                }

                                            };
                                            task3.execute();

                                        } else {
                                            callbackContext.error("Drawer didn't close within 30 seconds");
                                        }
                                    }

                                };
                                task2.execute();

                            } // task onPostExecute
                        };

                        task.execute();
                    } // DrawerOpenCheckTask onPostExecute
                };

        DrawerOpenCheckTask.execute();
    }

}
