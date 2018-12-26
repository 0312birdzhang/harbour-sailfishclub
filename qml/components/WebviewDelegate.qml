import QtQuick 2.0
import Sailfish.Silica 1.0

//import QtWebKit 3.0
//import QtWebKit.experimental 1.0

Column{
    width: parent.width
    height: parent.height * 0.56
    spacing: Theme.paddingMedium


    Label{
        textFormat: Text.RichText
        anchors{
            left: parent.left
            right: parent.right
            margins: Theme.paddingMedium
        }
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        font.letterSpacing: 2;
        linkColor: Theme.highlightColor
        text: "\n" + button.url;
        onLinkActivated: {
            Qt.openUrlExternally(link);
        }

    }

    // Image{
    //     source: "image://theme/icon-m-redirect"
    //     anchors.right: parent.right
    //     MouseArea{
    //         anchors.fill: parent
    //         onClicked:{
    //             Qt.openUrlExternally(webView.url);
    //         }
    //     }
    // }

    // SilicaWebView  {
    //     id: webView
    //     width: parent.width
    //     height: parent.height * 0.56
    //     opacity: 0
    //     experimental.preferences.localStorageEnabled: true
    //     experimental.preferences.offlineWebApplicationCacheEnabled: true
    //     experimental.preferences.universalAccessFromFileURLsAllowed: true
    //     experimental.preferences.webGLEnabled: true
    //     experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"

    //     BusyIndicator {
    //         id: busyIndicator
    //         anchors.centerIn: parent
    //         running: webView.opacity == 0
    //         size: BusyIndicatorSize.Medium
    //     }
    //     onLoadingChanged: {
    //         switch (loadRequest.status){
    //         case WebView.LoadSucceededStatus:
    //             opacity = 1
    //             break
    //         default:
    //             opacity = 0
    //             break
    //         }
    //     }

    //     anchors {
    //         left: parent.left
    //         right: parent.right
    //     }
    //     Component.onCompleted: {
    //         if (content.indexOf("http:") < 0 && content.indexOf("https:") < 0 ){
    //              if(content.index.Of("//") < 0 ){
    //                    content = "https://" + content;
    //              }else{
    //                    content = "https:" + content;
    //              }    
    //         }
    //         webView.url = content;
    //     }
    // }

     Component.onCompleted: {
         if (content.indexOf("http:") < 0 && content.indexOf("https:") < 0 ){
              if(content.indexOf("//") < 0 ){
                    content = "https://" + content;
              }else{
                    content = "https:" + content;
              }
         }
         button.url = content;
     }
}
