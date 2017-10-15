import QtQuick 2.0
import QtWebKit 3.0
//import QtWebKit.experimental 1.0
import Sailfish.Silica 1.0
import "../js/ApiMain.js" as JS

Page{
    id:user_center_main
    property string webviewurl
    WebView{
        id: webLogin
        opacity: 1
        visible: true
        url:webviewurl
//        url:"https://sailfishos.club"
        anchors.fill: parent
//        experimental.userAgent:"Qt; Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36  (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36"

        Behavior on opacity {
            NumberAnimation{duration: 300}
        }

        onLoadingChanged:{
            Qt.inputMethod.hide()
            var weburl=url.toString();
            if(weburl.indexOf(JS.api_redirect) != -1 && weburl.indexOf("code=") != -1 ){
                var parames = JS.parse_url(weburl);
                var code=parames["code"]
                JS.reqToken(code);
            }
         }
    }
    BusyIndicator {
        anchors.centerIn: parent
        running: webLogin.loading
        size: BusyIndicatorSize.Large
    }

    Connections{
        target: signalCenter
        onLoginSuccessed:{
            signalCenter.showMessage(qsTr("Login success!"));
            toIndexPage()
        }
        onLoginFailed:{
            signalCenter.showMessage(errorstring)
            //toLoginPage()
        }

    }
}
