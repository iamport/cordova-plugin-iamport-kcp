package kr.iamport.cordova.kcp;

import org.apache.cordova.CordovaPlugin;

public class IamportKcpPlugin extends CordovaPlugin {

    private KcpUrlSchemeHandler urlSchemeHandler;

    protected void pluginInitialize() {
        this.urlSchemeHandler = new KcpUrlSchemeHandler(cordova);
    }

    public boolean onOverrideUrlLoading(String url) {
        return this.urlSchemeHandler.handleUrl(url);
    }

}