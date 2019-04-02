import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0


Item {
    id: webloginComponent
    width: parent.width
    height: parent.height

    signal loginSucceed()
    signal loginFailed(string fail)

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaWebView {
          id: webview
          anchors.fill: parent

          experimental.overview: true
        //   experimental.userStyleSheets: [ (Theme.colorScheme == Theme.LightOnDark) ? Qt.resolvedUrl("./htmlViewer_Dark.css") : Qt.resolvedUrl("./htmlViewer_Light.css") ]
          // express.sid
          experimental.transparentBackground: true
          onLoadingChanged: {
              console.log(loadRequest.url.toString())
              if (loadRequest.status === WebView.LoadSucceededStatus){
                  webview.experimental.evaluateJavaScript(root.getUserInfoScript, function(rs){
                      if (rs && rs.username){
                          py.call('app.api.get_other_param', [rs.username], function(ret){
                              if (ret){
                                  userinfo.logined = true;
                                  userinfo.uid = ret.uid;
                                  userinfo.username = rs.username;
                                  userinfo.avatar = ret.avatar
                                  signalCenter.loginSuccessed();
                                  py.saveData(ret.uid, 
                                    ret.bduss, 
                                    rs.username,""
                                    );
                                //   pageStack.pop();
                                  webloginComponent.loginSucceed();
                              }
                          })
                      }
                  })
              }
          }
      }

    property string getUserInfoScript: "(function(){
var userName = document.getElementById('user-header-name').innerText;
var res = {username: userName};
return res;
})()"

    Component.onCompleted: {
        Qt.createQmlObject("import QtWebKit.experimental 1.0");
        var url = appwindow.siteUrl + "/login"
        webview.url = url;
    }
}
