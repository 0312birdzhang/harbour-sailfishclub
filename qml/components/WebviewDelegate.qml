import QtQuick 2.0
import Sailfish.Silica 1.0

import QtWebKit 3.0
import QtWebKit.experimental 1.0

SilicaWebView  {
    id: webView
    width: parent.width
    height: parent.width * 0.56
    experimental.preferences.localStorageEnabled: true
    experimental.preferences.offlineWebApplicationCacheEnabled: true
    experimental.preferences.universalAccessFromFileURLsAllowed: true
    experimental.preferences.webGLEnabled: true
    experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
    anchors {
        left: parent.left
        right: parent.right
    }
    Component.onCompleted: {
        if (content.substring(0,4) !== "http"){
            content = "http"+content;
        }
        webView.url = content;
    }


}
