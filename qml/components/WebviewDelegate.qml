import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import Sailfish.Silica 1.0

SilicaWebView {
    id: webView
    width: parent.width
    height: parent.width * 0.56
    anchors {
        left: parent.left
        right: parent.right
    }

    FadeAnimation on opacity {}

    Component.onCompleted: {
        if (content.substring(0,4) !== "http"){
            content = "http"+content;
        }

        webView.url = content;
    }
}
