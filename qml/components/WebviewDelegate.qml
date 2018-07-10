import QtQuick 2.0
import Sailfish.Silica 1.0

import QtWebKit 3.0
import QtWebKit.experimental 1.0

Column{
    width: parent.width
    height: parent.height * 0.56
    spacing: Theme.paddingSmall

    Image{
        source: "image://theme/icon-s-repost"
        anchors.right: parent.right
        MouseArea{
            anchors.fill: parent
            onClicked:{
                Qt.openUrlExternally(webView.url);
            }
        }
    }
    SilicaWebView  {
        id: webView
        width: parent.width
        height: parent.height * 0.56
        opacity: 0
        experimental.preferences.localStorageEnabled: true
        experimental.preferences.offlineWebApplicationCacheEnabled: true
        experimental.preferences.universalAccessFromFileURLsAllowed: true
        experimental.preferences.webGLEnabled: true
        experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"

        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: parent
            running: webView.opacity == 0
            size: BusyIndicatorSize.Medium
        }
        onLoadingChanged: {
            switch (loadRequest.status){
            case WebView.LoadSucceededStatus:
                opacity = 1
                break
            default:
                opacity = 0
                break
            }
        }

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
}
