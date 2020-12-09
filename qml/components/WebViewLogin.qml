import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0

Item {
    id: webloginComponent
    width: parent.width
    height: parent.height

    signal loginSucceed()
    signal loginFailed(string fail)

    SilicaWebView {
          id: webview
          anchors.fill: parent
          url: appwindow.siteUrl + "/login"
          overridePageStackNavigation: true
          property string userAgent: "Mozilla/5.0 (Mobile Linux; U; like Android 4.4.3; Sailfish OS/2.0) AppleWebkit/535.19 (KHTML, like Gecko) Version/4.0 Mobile Safari/535.19"
          property bool _isScrolledToEnd: (webview.contentY + webview.height + 2) >= webview.contentHeight
          property bool _isScrolledToBeginning: webview.contentY <= 2
          property bool _isFinishedPanning: webview.atXBeginning && webview.atXEnd && !webview.moving
          experimental.temporaryCookies: false
          experimental.deviceWidth: webview.width
          experimental.deviceHeight: webview.height
          experimental.userAgent: userAgent
          experimental.preferences.navigatorQtObjectEnabled: true
          experimental.customLayoutWidth: {
              // VK's Terms Of Service page doesn't render the same
              // way as Facebook/Google/Twitter/OneDrive etc, because
              // it doesn't respect the deviceWidth setting.
              var urlStr = "" + url
              if (urlStr.indexOf("vk.com/terms") > 0) {
                  return root.width * Theme._webviewCustomLayoutWidthScalingFactor
              }
  
              // For other services, zoom in a bit to make things more readable
              return root.width * 0.6
          }          
          onLoadingChanged: {
              console.log(loadRequest.url.toString())
              console.log("loadRequest.status", loadRequest.status)
              console.log("WebView.LoadSucceededStatus", WebView.LoadSucceededStatus)
              if (loadRequest.status === WebView.LoadSucceededStatus &&
                   (loadRequest.url.toString().indexOf("/recent") > 0 ||
                    loadRequest.url.toString().indexOf("/user/") > 0 ||
                    loadRequest.url.toString().indexOf("loggedin") > 0
                    )){
                  console.log("===========");
                  experimental.evaluateJavaScript(webloginComponent.getUserInfoScript, function(rs){
                      console.log(rs.username);
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
      }

    property string getUserInfoScript: "(function(){
var userName = document.getElementById('user-header-name').innerText
var uid = document.getElementsByClassName('avatar user-icon avatar-lg avatar-rounded')[0].getAttribute('data-uid')
var avatar = document.getElementsByClassName('avatar user-icon avatar-lg avatar-rounded')[0].getAttribute('src')
var csrf = document.cookie
return {username: userName, uid: uid, avatar: avatar, csrf: csrf}
})()"
}

