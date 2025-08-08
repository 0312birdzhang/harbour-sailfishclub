import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

Item {
    id: webloginComponent
    width: parent.width
    height: parent.height
    signal loginSucceed()
    signal loginFailed(string fail)

    WebView {
          id: webview
          property string userAgent: "Mozilla/5.0 (Mobile Linux; U; like Android 4.4.3; Sailfish OS/2.0) AppleWebkit/535.19 (KHTML, like Gecko) Version/4.0 Mobile Safari/535.19"
          property bool _isScrolledToEnd: (webview.contentY + webview.height + 2) >= webview.contentHeight
          property bool _isScrolledToBeginning: webview.contentY <= 2
          property bool _isFinishedPanning: webview.atXBeginning && webview.atXEnd && !webview.moving
          anchors.fill: parent
          httpUserAgent: userAgent
          privateMode: false
          url: appwindow.siteUrl + "/login"
          onLoadingChanged: {
              if (loaded){
                  console.log("loaded")
                  WebEngineSettings.setPreference("security.csp.enable",
                                                  false,
                                                  WebEngineSettings.BoolPref)
              }
              if (webview.loaded &&
                   (webview.url.toString().indexOf("/recent") > 0 ||
                    webview.url.toString().indexOf("/user/") > 0 ||
                    webview.url.toString().indexOf("loggedin") > 0 ||
                    webview.url.toString().indexOf(appwindow.siteUrl) > -1
                    )){
                  runJavaScript(webloginComponent.getUserInfoScript, function(rs){
                      if (rs && rs.username){
                          py.call('app.api.get_other_param', [rs.username], function(ret){
                              if (ret){
                                  console.log("get ret")
                                  var expires = ret.expires;
                                  var cookie = rs.csrf+"; express.sid="+ret.sid;
                                  userinfo.logined = true;
                                  userinfo.uid = rs.uid;
                                  userinfo.username = rs.username;
                                  userinfo.avatar = rs.avatar||"";
                                  console.log("csrf:", rs.csrf);
                                  py.saveData(userinfo.uid, cookie, userinfo.username, "",
                                  userinfo.logined, userinfo.avatar, expires);
                                  signalCenter.loginSuccessed();
                                  webloginComponent.loginSucceed();
                              }
                          })
                      }else{
                          console.log("rs empty")
                      }
                  })
              }
          }

          Component.onCompleted: {
          }
      }

    property string getUserInfoScript: "(function(){
var userName = document.getElementById('user-header-name').innerText
var uid = document.getElementsByClassName('avatar user-icon avatar-rounded')[0].getAttribute('data-uid')
var avatar = document.getElementsByClassName('avatar user-icon avatar-rounded')[0].getAttribute('src')
var csrf = document.cookie
return {username: userName, uid: uid, avatar: avatar, csrf: csrf}
})()"
}

