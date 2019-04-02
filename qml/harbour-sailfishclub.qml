/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "pages/objects"
import "components"
import "js/main.js" as JS
import "js/ApiCore.js" as Api
import "js/ApiMain.js" as Main
import "js/fontawesome.js" as FontAwesome
import io.thp.pyotherside 1.5
import Nemo.Notifications 1.0
import Nemo.DBus 2.0
import Nemo.Configuration 1.0
import harbour.sailfishclub 1.0


ApplicationWindow
{
    id: appwindow

    property Page currentPage: pageStack.currentPage

    property string appname: "旗鱼俱乐部"
    property bool loading: false
    // property bool pymodelLoaded: false
    property int page_size: 20
    property string current_router: "recent"
    property string siteUrl: "https://sailfishos.club"
    property alias  userinfo: userinfo
    property bool _showReplayNotification: true
    property bool networkStatus
    property int unreadSize: 0
    property string postdraft //发帖草稿
    property string topicdraft // 回贴草稿
    property int loginRetry: 3

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.Portrait


    onNetworkStatusChanged: {
        if(networkStatus == false) {
            //% "Network connection failure"
            notification.showPopup(qsTr("Network not connected"), qsTr("Try again later please"), "icon-s-high-importance");
            loading = false;
        }else{
            if(!userinfo.logined){
                py.initLogin();
            }
        }
    }

    onApplicationActiveChanged: {
        if (applicationActive){
            _showReplayNotification = false
        }else{
            _showReplayNotification = true
        }
    }

//    DBusAdaptor {
//        service: "harbour.sailfishclub.service"
//        iface: "harbour.sailfishclub.service"
//        path: "/harbour/sailfishclub/service"
//        xml: "  <interface name=\"harbour.sailfishclub.service\">\n" +
//             "    <method name=\"openPage\"/>\n" +
//             "  </interface>\n"

//        function openPage(page, arguments) {
//            if (page === "pages/NotificationsPage.qml") {
//                _showReplayNotification = false
//            }
//            __silica_applicationwindow_instance.activate()
//            pageStack.push(Qt.resolvedUrl(page), arguments)
//        }
//    }

    // from https://github.com/DylanVanAssche/harbour-sailfinder/blob/develop/qml/harbour-sailfinder.qml
    DBusInterface {
        bus: DBus.SystemBus
        service: "net.connman"
        path: "/"
        iface: "net.connman.Manager"
        signalsEnabled: true
        Component.onCompleted: getStatus() // Init

        // Methods
        function getStatus() {
            typedCall("GetProperties", [], function(properties) {
                if(properties["State"] == "online") {
                    networkStatus = true
                }
                else {
                    networkStatus = false
                }
            },
            function(trace) {
                console.error("Network state couldn't be retrieved: " + trace)
            })
        }

        // Signals
        function propertyChanged(name, value) {
            if(name == "State") {
                if(value == "online") {
                    networkStatus = true
                }
                else {
                    networkStatus = false
                }
            }
        }
    }
    
    Notification{
        id: notification
        function show(message, icn) {
            replacesId = 0
            previewSummary = ""
            previewBody = message
            icon = icn ? icn : ""
            publish()
        }

        function showPopup(title, message, icn) {
            replacesId = 0
            previewSummary = title
            previewBody = message
            icon = icn
            publish()
        }

        expireTimeout: 3000
    }

    Notification {
        id: replaiesNotification
        appIcon: "image://theme/icon-lock-chat"
        previewSummary: qsTr("new replay")
        previewBody: qsTr("preview replay")
        body: ""
        expireTimeout: 60000
        remoteActions: [ {
                name: "default",
                service: "harbour.sailfishclub.service",
                path: "/harbour/sailfishclub/service",
                iface: "harbour.sailfishclub.service",
                method: "openPage",
                arguments: [ "pages/NotificationsPage.qml", {} ]
            } ]

        Component.onCompleted: {
            _showReplayNotification = false
        }

        onClosed: {
            _showReplayNotification = true
        }
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: loading
        size: BusyIndicatorSize.Large
    }

    RemorsePopup {
        id: remorse
    }

    SettingsObject {
        id: settings
    }

    Timer{
        id:processingtimer;
        interval: 40000;
        onTriggered: signalCenter.loadFailed(qsTr("Request timeout"));
    }

    // 定时获取通知
    Timer{
        id: getNotifytimer;
        interval: 240000;
        running: false;
        repeat: true
        onTriggered: {
            if(userinfo.logined){
                console.log("start to get notification...")
                py.getUnread();
            }
        }
    }

    FontLoader {
        source: "js/fontawesome-webfont.ttf"
    }

    Connections{
        target: signalCenter;
        onLoadStarted:{
            appwindow.loading=true;
            processingtimer.restart();
        }
        onLoadFinished:{
            appwindow.loading=false;
            processingtimer.stop();
        }
        onLoadFailed:{
            appwindow.loading=false;
            processingtimer.stop();
            notification.show(errorstring);
        }
    }

    Signalcenter{
        id: signalCenter;
        onGetUnread:{
            if (result && result !== "Forbidden"){
                var nos = result.topics;
                if(nos.topicCount > 0 && _showReplayNotification){
                    console.log("push notification")
                    replaiesNotification.body = nos[0].teaser.content;
                    replaiesNotification.publish();
                }
            }
        }
        onLoginSuccessed: {
            getNotifytimer.start()
        }
        onLoginFailed: {
            if(loginRetry>0){
                py.initLogin();
                loginRetry--;
            }
        }
    }

    UserInfo{
        id:userinfo
    }

    TransferMethodsModel {
        id: appTransferMethodsModel
        filter: "text/x-url"
    }

    Python{
        id:py
        Component.onCompleted: {
            addImportPath('qrc:/py')
            py.importModule('main', function () {
                initLogin();
            });
//            py.importModule('app', function(){
//            });
        }

        function initLogin(){
            if(!networkStatus){
                return;
            }
            // 登录
            var username = settings.get_username();
            var password = settings.get_password();
            var uid = settings.get_uid();
            var token = settings.get_token();
            if(uid && token){
                console.log("logined via token")
                py.validate(uid, token)
            }else if(username && password){
                var derpass = Api.decrypt(password, py.getSecretKey());
                if(derpass)py.login(username,derpass);
                console.log("logined via password")
            }
        }

        function validate(uid, token){
            if(!uid||!token || uid === 0 || token === "undefined"){
                return;
            }
            call('main.validate',[uid, token],function(result){
                // console.log(JSON.stringify(result))
                if(result && result !== "Forbidden" && result !== "False"){
                    userinfo.uid = uid.toString();
                    userinfo.username = result.username;
//                    userinfo.fullname = result.fullname;
                    userinfo.email = result.email|| "";
                    userinfo.website = result.website;
                    userinfo.avatar = result.picture|| "";
                    userinfo.groupTitle = result.groupTitle|| "";
                    userinfo.groupIcon = result.groupIcon|| "";
                    userinfo.signature = result.signature|| "";
                    userinfo.topiccount = result.topiccount.toString();
                    userinfo.postcount = result.postcount.toString();
                    userinfo.aboutme = result.aboutme|| "";
                    userinfo.user_text = result["icon:text"];
                    userinfo.user_color = result["icon:bgColor"];
                    userinfo.user_cover = appwindow.siteUrl + result["cover:url"];
                    userinfo.reputation = result.reputation;
                    userinfo.followerCount = result.followerCount|| 0;
                    userinfo.followingCount = result.followingCount|| 0;

                    userinfo.logined = true;
                    signalCenter.loginSuccessed();
                    saveData(uid, token,userinfo.username,"");

                }
            })
        }
        function login(username, password){
            if(!username||!password || username === "undefined" || password === "undefined"){
                return;
            }
            call('main.login',[username,password],function(result){
                if(result && result != "Forbidden" && result != "False"){
                    userinfo.uid = result.uid.toString();
                    userinfo.username = result.username;
//                    userinfo.fullname = result.fullname;
                    userinfo.email = result.email|| "";
                    userinfo.website = result.website;
                    userinfo.avatar = result.picture|| "";
                    userinfo.groupTitle = result.groupTitle|| "";
                    userinfo.groupIcon = result.groupIcon|| "";
                    userinfo.signature = result.signature|| "";
                    userinfo.topiccount = result.topiccount.toString();
                    userinfo.postcount = result.postcount.toString();
                    userinfo.aboutme = result.aboutme|| "";
                    userinfo.user_text = result["icon:text"];
                    userinfo.user_color = result["icon:bgColor"];
                    userinfo.user_cover = appwindow.siteUrl + result["cover:url"];
                    // console.log(appwindow.siteUrl + result["cover:url"]);
                    userinfo.reputation = result.reputation;
                    userinfo.followerCount = result.followerCount?result.followerCount:0;
                    userinfo.followingCount = result.followingCount?result.followingCount:0;
                    userinfo.logined = true;
                    signalCenter.loginSuccessed();
                    saveData(result.uid, result.token, userinfo.username,password);
                }else if(result == "Forbidden"){
                    notification.show(qsTr("Login failed,try again later"),
                                      "image://theme/icon-s-high-importance"
                                      );
                    loading = false;
                }else{
                    signalCenter.loginFailed(result);
                    loading = false;
                }
            })
        }

        function logout(){
            var uid = settings.get_uid();
            var token = settings.get_token();
            call('main.logout',[uid, token],function(result){
                settings.set_username("");
                settings.set_password("");
                settings.set_uid(0);
                settings.set_token("");
            });
            getNotifytimer.stop();
        }

        function saveData(uid, token, username, password){
            if(!userinfo.logined){
                console.log("not logined")
                return;
            }
            settings.set_username(username);
            if(password && password !== ""){
                // var pass_encrypted = encryPass(password);
                var pass_encrypted = Api.encrypt(password, py.getSecretKey());
                if(pass_encrypted){
                    settings.set_password(pass_encrypted);
                }
            }
            settings.set_uid(parseInt(uid));
            settings.set_token(token);
        }

        // 获取最新帖子
        function getRecent(slug){
            loading = true;
            call('main.getrecent',[slug],function(result){
                loading = false;
                signalCenter.getRecent(result);
            });
        }

        // 搜索贴子
        function search(term, slug){
            console.log("slug:"+slug)
            loading = true;
            term = encodeURI(term);
            call('main.search',[term, slug, settings.get_token()],function(result){
                loading = false;
                signalCenter.getSearch(result);
            });
        }

        //获取热门贴子
        function getPopular(slug){
            loading = true;
            call('main.getpopular',[slug],function(result){
                loading = false;
                signalCenter.getRecent(result);
            });
        }

        // 获取分类
        function getCategories(){
            loading = true;
            call('main.listcategory',[],function(result){
                loading = false;
                signalCenter.getCategories(result);
            });
        }
        //加密
        // function encryPass(password){
        //     return call_sync('secret.encrypt',[password]);
        // }
        //解密
        // function decryPass(password){
        //     return call_sync('secret.decrypt',[password]);
        // }

        function getSecretKey(){
            return call_sync('main.getSecretKey',[]);
        }

        // 获取贴子内容
        function getTopic(tid,slug){
//            console.log("tid:"+tid+",slug:"+slug);
            loading = true;
            if(userinfo.logined){
                var token = settings.get_token();
//                console.log("token:"+token)
                call('main.getTopic',[tid,slug,token],function(result){
                    loading = false;
                    signalCenter.getTopic(result);
                });
            }else{
                call('main.getTopic',[tid,slug],function(result){
                    loading = false;
                    signalCenter.getTopic(result);
                });
            }
            
        }

        // 回复贴子
        function replayTopic(tid,uid,content){
            loading = true;
            call('main.replay',[tid,uid,content],function(result){
                loading = false;
                signalCenter.replayTopic(result);
            });
        }

        // 回复贴子中的楼层
        function replayFloor(tid, uid, toPid, content){
            loading = true;
            call('main.replayTo',[tid, uid, toPid, content],function(result){
                loading = false;
                signalCenter.replayFloor(result);
            });
        }

        // 发新贴
        function newTopic(title, content, uid, cid){
            loading = true;
            call('main.post',[title, content, uid, cid],function(result){
                loading = false;
                signalCenter.newTopic(result);
            });
        }

        //预览发贴内容
        function previewMd(text){
            loading = true;
            call('main.previewMd',[text],function(result){
                loading = false;
                signalCenter.previewMd(result);
            });
        }

        //上传图片到sm.ms
        function uploadImage(path,desc){
            loading = true;
            call('main.uploadImgSm',[path],function(ret){
                loading = false;
                //替换反斜线
                if(ret)ret = ret.replace(/\\/g,"");
                signalCenter.uploadImage(ret,desc);
            });
        }

        // 新用户注册
        function register(user,password,email){
             call('main.createUser',[user,password,email],function(result){
                 if(result && result != "Forbidden" && result != "False"){
                     signalCenter.registerSucceed();
                     py.login(user,password);
                 }else{
                     signalCenter.registerFailed(result);

                 }
             });
        }

        // 获取用户信息
        function getUserInfo(uid){
            loading = true;
            call('main.getuserinfo',[uid,false],function(result){
                loading = false;
                signalCenter.getUserInfo(result);
            });
        }

        // 获取贴子回复通知
        function getUnread(){
            if(!networkStatus)return;
            call('main.getUnread', [settings.get_token()], function(result){
                signalCenter.getUnread(result);
                if(result && result != "Forbidden"){
                    unreadSize = result.topicCount;
                }
            });
        }


        function getUnOfficalList(page){
            loading = true;
            call('main.getUnOfficalBlog',[page], function(result){
                loading = false;
                signalCenter.getUnOfficalList(result);
            })
        }


        function getUnOfficalContent(slug){
            loading = true;
            call('main.getUnOfficalBlogContent',[slug], function(result){
                loading = false;
                signalCenter.getUnOfficalContent(result);
            })
        }

        // 弃用
        function loadImage(username,image_id){
            call('myprovider.load',[username,image_id],function(result){
                var source;
                if(!result){
                    source = "image://theme/harbour-sailfishclub"
                }else{
                    source = result;
                }
                // pymodelLoaded = true;
                signalCenter.loadImage(source);
            });
        }
    }

    PanelView {
        id: panelView
        property int ori: pageStack.currentPage.orientation
        width: pageStack.currentPage.width
        panelWidth: Screen.width / 3 * 2
        panelHeight: pageStack.currentPage.height
        height: currentPage && currentPage.contentHeight || pageStack.currentPage.height
        visible:  (!!currentPage && !!currentPage.__withPanelView) || !panelView.closed

        rotation: pageStack.currentPage.rotation

        enabled: !loading
        anchors.centerIn: parent
        anchors.verticalCenterOffset: ori === Orientation.Portrait ? -(panelHeight - height) / 2 :
                                             ori === Orientation.PortraitInverted ? (panelHeight - height) / 2 : 0
        anchors.horizontalCenterOffset: ori === Orientation.Landscape ? (panelHeight - height) / 2 :
                                               ori === Orientation.LandscapeInverted ? -(panelHeight - height) / 2 : 0

        Connections {
            target: pageStack
            onCurrentPageChanged: panelView.hidePanel()
        }

        leftPanel: NavigationPanel {
            id: leftPanel
            busy: loading
            enabled: !busy
            onClicked: {
                panelView.hidePanel();
            }

            Component.onCompleted: {
                panelView.hidePanel();
            }
        }
    }

    //主页列表显示
    Component {
        id: indexPageComponent
        FirstPage {
            id: indexPage
            property bool __withPanelView: true
            Binding {
                target: indexPage.contentItem
                property: "parent"
                value: indexPage.status === PageStatus.Active
                       ? (panelView.closed ? panelView : indexPage)
                       : indexPage
            }
        }
    }

    Component{
        id: categoriesPageComponent
        CategoriesPage{
            id:categoriesPage
            property bool __withPanelView: true
            Binding {
                target: categoriesPage.contentItem
                property: "parent"
                value: categoriesPage.status === PageStatus.Active
                       ? (panelView.closed ? panelView : categoriesPage)
                       : categoriesPage
            }


        }
    }


    Component{
        id: searchPageComponent
        SearchPage{
            id: searchPage
            property bool __withPanelView: true
            Binding {
                target: searchPage.contentItem
                property: "parent"
                value: searchPage.status === PageStatus.Active
                       ? (panelView.closed ? panelView : searchPage)
                       : searchPage
            }
        }
    }


    initialPage: Component {
        Page{
            id:splashPage
            allowedOrientations:Orientation.All
            Component.onCompleted: {
                splash.visible = true;
                timerDisplay.running = true;


            }

            SilicaFlickable {
                id: splash
                visible: false
                anchors.fill:parent
                Item{
                    anchors.fill: parent
                    width: parent.width
                    height: parent.height
                    Label{
                        id:welcomFont
                        text:qsTr("Welcome to")
                        font.pixelSize: Theme.fontSizeExtraLarge
                        anchors{
                            left:parent.left
                            leftMargin:Theme.paddingLarge
                            bottom:storeName.top
                            //bottomMargin: Theme.paddingSmall
                        }
                    }
                    Label{
                        id:storeName
                        text:qsTr("SailfishClub")
                        font.pixelSize: Theme.fontSizeExtraLarge
                        color: Theme.highlightColor
                        anchors{
                            left:parent.left
                            leftMargin:Theme.paddingLarge
                            bottom:vendor.top
                            bottomMargin: Theme.paddingLarge * 2
                        }
                    }

                    Label{
                        id:vendor
                        text:"by BirdZhang"
                        font.pixelSize: Theme.fontSizeMedium
                        //color: Theme.highlightColor
                        opacity:0.5
                        anchors{
                            left:parent.left
                            leftMargin:Theme.paddingLarge
                            bottom:parent.bottom
                            bottomMargin: Theme.paddingLarge
                        }
                    }

                    BusyIndicator{
                        anchors{
                            right:parent.right
                            rightMargin: Theme.paddingLarge
                            bottom:parent.bottom
                            bottomMargin: Theme.paddingLarge
                        }
                        running: true
                        size: BusyIndicatorSize.Small
                    }

                }


                NumberAnimation on opacity {duration: 500}


            }
            Timer {
                id: timerDisplay
                running: false;
                repeat: false;
                triggeredOnStart: false
                interval: 1.5 * 1000
                onTriggered: {
                    splash.visible = false;
                    loading = false;
                    toIndexPage();

                }
            }
        }
    }



    function toIndexPage() {
        popAttachedPages();
        pageStack.replace(indexPageComponent)

    }

    function toPopularPage() {
        popAttachedPages();
        pageStack.replace(indexPageComponent)

    }

    function toLoginPage(){
        pageStack.push(Qt.resolvedUrl("pages/LoginDialog.qml"));
    }

    function toCategoriesPage(){
        popAttachedPages();
        pageStack.replace(categoriesPageComponent)
    }


    function toUserInfoPage(uid){
        pageStack.push(Qt.resolvedUrl("pages/ProfilePage.qml"),{
                "uid":uid
            });
    }

    function popAttachedPages() {
        // find the first page
        var firstPage = pageStack.previousPage();
        if (!firstPage) {
            return;
        }
        while (pageStack.previousPage(firstPage)) {
            firstPage = pageStack.previousPage(firstPage);
        }
        // pop to first page
        pageStack.pop(firstPage);
    }

    function formathtml(html) {
        //html = html.replace(/[\n]/gi,""); //替换掉html中的换行
        html = html.replace(/<a\shref=\"\/post\//g, "<a href=\""+siteUrl+"/post/");
        html = html.replace(/<a\shref=\"\/topic\//g, "<a href=\""+siteUrl+"/topic/");
        html = html.replace(/<a\shref=\"\/uid\//g, "<a href=\""+siteUrl+"/uid/");
        html = html.replace(/<a href=/g,"<a style='color:" + Theme.highlightColor + "' target='_blank' href=");
        html = html.replace(/<a class=/g,"<a style='color:" + Theme.highlightColor + "' target='_blank' class=");
//        html = html.replace(/<p>/g,"<p style=\"text-indent:24px\">");
        html = html.replace(/<img\ssrc=\"\/assets\//g, "<img src=\""+siteUrl+"/assets/");
        // html = html.replace(/<img\ssrc=\"https:\/\/sailfishos.club\/plugins\/nodebb-plugin-emoji/g,"<emoji src=\"https:\/\/sailfishos.club\/plugins\/nodebb-plugin-emoji"); // emoji
        html = html.replace(/<p><img/g,"<p><img");
        html = html.replace(/<p><a [^<>]*href=\"([^<>"]*)\".*?><img/g,"<p><a href='$1'><img");
        html = html.replace(/&#x2F;/g,"/");
        // html = html.replace(/<img src=\"([^<>"]*)\".*?>/g,"<a href='$1'><img src=\"$1\"/></a>");
        // html = html.replace(/<emoji src/g,"<img src"); // emoji
        // html = "<style>pre {display: flex;white-space: normal;word-break: break-word;} img{max-width:"+(Screen.width-Theme.paddingMedium*2)+"px;}</style>" + html;
        // html = "<style>img.img-responsive{max-width:"+(Screen.width-Theme.paddingSmall*2)+"px; display:block;}</style>" + html;
        return html;
    }


    function splitContent(topic_content, parent){
        return JS.splitContent(topic_content, parent);
    }

    //首页不显示图片
    function formatFirstPagehtml(html){
        if(html){
            html = html.replace(/<img src=\"([^<>"]*)\".*?>/g,"");
            return html;
        }else{
            return "";
        }
    }

    function openLink(link) {
        console.log("link:"+link);
        var linklist=link.split(".");
        var linktype=linklist[linklist.length -1];
        if(linktype =="png" ||linktype =="jpg"||linktype =="jpeg"||linktype =="gif"||linktype =="ico"||linktype =="svg"){
            pageStack.push(Qt.resolvedUrl("./components/ImagePage.qml"),{"localUrl":link});
        }else if (/https:\/\/sailfishos\.club\/uid\/[0-9]{1,}/.exec(link)) {
            var uidlink = /https:\/\/sailfishos\.club\/uid\/[0-9]{1,}/.exec(link)
            var uid = /[0-9]{1,}/.exec(uidlink[0].split("/"))[0];
            //to user profile page
            toUserInfoPage(uid);
        }else if (/https:\/\/sailfishos\.club\/topic\/[0-9]{1,}/.exec(link)) {
            var topiclink = /https:\/\/sailfishos\.club\/topic\/[0-9]{1,}/.exec(link)
            var tid = /[0-9]{1,}/.exec(topiclink[0].split("/"))[0];
            //to topic page
            console.log("to topic page, tid:"+ tid)
            pageStack.push(Qt.resolvedUrl("pages/TopicPage.qml"),{
                                       "tid": tid
                                   });
        }else if (/https:\/\/sailfishos\.club\/post\/[0-9]{1,}/.exec(link)) {
            var postlink = /https:\/\/sailfishos\.club\/post\/[0-9]{1,}/.exec(link)
            var pid = /[0-9]{1,}/.exec(postlink[0].split("/"))[0];
            console.log("pid:"+pid); //TODO
            //ddd
//            pageStack.currentPage.children[0];

        }else{
            remorse.execute(qsTr("Starting open link..."),function(){
                Qt.openUrlExternally(link);
            },3000);
        }
    }

    function onCacheUpdated(callbackObject, status, url) {
        //console.log("Cache update callback: type: " + typeof(callbackObject) + " status: " + status + " url: " + url );
        try {
            if (typeof(callbackObject) === "function") {
                //console.log("funtion!");
                callbackObject(status,url);
            } else if (typeof(callbackObject) === "object") {
                //console.log("object!");
                if (callbackObject.cacheCallback !== undefined) {
                    callbackObject.cacheCallback(status,url);
                } else {
                    console.log("object callback is undefined!");
                }
            } else if (typeof(callbackObject) === "string") {
                //console.log("string!");
                var obj = Api.objs.get(callbackObject);
                if (obj.cacheCallback !== undefined) {
                    obj.cacheCallback(status,url);
                } else {
                    console.log("object callback is undefined!");
                }
                Api.objs.remove(callbackObject);
            } else {
                console.log("type is: " + typeof(callbackObject));
            }
        } catch (err) {
            console.log("Cache callback error: " + err + " type: " + typeof(callbackObject) + " value: " + JSON.stringify(callbackObject) );
        }
    }
    Connections {
       target: imageCache
       onCacheUpdated: appwindow.onCacheUpdated(callback, status, url)
    }

    Component.onCompleted: {
        Main.signalcenter = signalCenter;
        JS.app = appwindow;
    }

}

