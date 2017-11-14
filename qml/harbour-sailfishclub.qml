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
import "js/ApiMain.js" as Main
import "js/fontawesome.js" as FontAwesome
import io.thp.pyotherside 1.4
import org.nemomobile.notifications 1.0
import harbour.sailfishclub.settings 1.0

ApplicationWindow
{
    id:appwindow
    property string appname: "旗鱼俱乐部"
    property bool loading: false
    property int page_size: 20
    property string current_router: "recent"
    property string siteUrl: "https://sailfishos.club"
    property alias  userinfo: userinfo

    Notification{
        id:notification
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
        interval: 60000;
        onTriggered: signalCenter.loadFailed(qsTr("请求超时"));
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
            signalCenter.showMessage(errorstring);
        }
    }

    Signalcenter{
        id: signalCenter;
    }

    UserInfo{
        id:userinfo
    }





    Python{
        id:py
        Component.onCompleted: {
            addImportPath('qrc:/py/')
            py.importModule('main', function () {
                initPagesize();
            });
            py.importModule('secret', function () {
            });

        }
        function initPagesize(){
            py.call('main.initClient',[page_size]);
        }

        function login(username,password){
            if(!username||!password || username == "undefined" || password == "undefined"){
                return;
            }
            call('main.login',[username,password],function(result){
//                console.log("result:"+result)
                if(result && result != "Forbidden" && result != "False"){
                    userinfo.uid = result.uid;
                    userinfo.username = result.username;
                    userinfo.email = result.email;
                    userinfo.website = result.website;
                    userinfo.avatar = result.picture?result.picture:"";
                    userinfo.groupTitle = result.groupTitle?result.groupTitle:"";
                    userinfo.groupIcon = result.groupIcon?result.groupIcon:"";
                    userinfo.signature = result.signature?result.signature:"";
                    userinfo.topiccount = result.topiccount.toString();
                    userinfo.postcount = result.postcount.toString();
                    userinfo.aboutme = result.aboutme?result.aboutme:"";
                    userinfo.user_text = result["icon:text"];
                    userinfo.user_color = result["icon:bgColor"];
                    userinfo.logined = true;
                    signalCenter.loginSucceed();
                    saveData(username,password);
                }else if(result == "Forbidden"){
                    notification.show(qsTr("Login failed,try again later"),
                                      "image://theme/icon-s-high-importance"
                                      );
                }else{
                    signalCenter.loginFailed(result);
                }
            })
        }

        function saveData(username,password){
            if(!userinfo.logined){
                console.log("not logined")
                return;
            }

            //保持加密后的密码
            var pass_encrypted = encryPass(password);
            if(pass_encrypted){
                //                JS.setUserData(username,pass_encrypted);
                settings.set_username(username);
                settings.set_password(pass_encrypted);
            }
        }

        // 获取最新帖子
        function getRecent(model){
//            return call_sync('main.getrecent',[]);
            call('main.getrecent',[],function(result){
                signalCenter.getRecent(result);
            });
        }
        //获取热门贴子
        function getPopular(){
//            return call_sync('main.getpopular',[]);
            call('main.getpopular',[],function(result){
                signalCenter.getRecent(result);
            });
        }

        // 获取分类
        function getCategories(){
//            return call_sync('main.listcategory',[]);
            call('main.listcategory',[],function(result){
                signalCenter.getCategories(result);
            });
        }
        //加密密码
        function encryPass(password){
            return call_sync('secret.encrypt',[password]);
        }
        //解密密码
        function decryPass(password){
            return call_sync('secret.decrypt',[password]);
        }

        // 获取贴子内容
        function getTopic(tid,slug){
//            return call_sync('main.getTopic',[tid,slug]);
            call('main.getTopic',[tid,slug],function(result){
                signalCenter.getTopic(result);
            });
        }

        // 回复贴子
        function replayTopic(tid,uid,content){
            return call_sync('main.replay',[tid,uid,content]);
        }

        // 发新贴
        function newTopic(title, content, uid, cid){
            return call_sync('main.post',[title, content, uid, cid]);
        }

        //预览发贴内容
        function previewMd(text){
            return call_sync('main.previewMd',[text]);
        }

        //上传图片到sm.ms
        function uploadImage(path){
            return call_sync('main.uploadImgSm',[path]);
        }

        // 新用户注册
        function register(user,password,email){
//            console.log("register:"+user+",pass:"+password+",email:"+email)
             call('main.createUser',[user,password,email],function(result){
//                 console.log("result:"+result)
                 if(result && result != "Forbidden" && result != "False"){
                     signalCenter.registerSucceed();
                     py.login(user,password);
                 }else{
                     signalCenter.registerFailed(result);

                 }
             });
        }
    }

    PanelView {
        id: panelView

        property Page currentPage: pageStack.currentPage

        width: currentPage.width
        panelWidth: Screen.width *0.6
        panelHeight: pageStack.currentPage.height
        height: currentPage && currentPage.contentHeight || pageStack.currentPage.height
        visible:  (!!currentPage && !!currentPage.withPanelView) || !panelView.closed
        anchors.centerIn: parent
        //anchors.verticalCenterOffset:  -(panelHeight - height) / 2

        anchors.horizontalCenterOffset:  0

        Connections {
            target: pageStack
            onCurrentPageChanged: panelView.hidePanel()
        }

        leftPanel: NavigationPanel {
            id: leftPanel
            busy: false
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
            property bool _dataInitialized: false
            property bool withPanelView: true
            Binding {
                target: indexPage.contentItem
                property: "parent"
                value: indexPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : indexPage) //修正listview焦点
                       : indexPage
            }

            onStatusChanged: {
                if (indexPage.status === PageStatus.Active) {
                    if (!_dataInitialized) {
                        _dataInitialized = true;
                    }
                }
            }
        }
    }

    Component{
        id: categoriesPageComponent
        CategoriesPage{
            id:categoriesPage
            property bool _dataInitialized: false
            property bool withPanelView: true
            Binding {
                target: categoriesPage.contentItem
                property: "parent"
                value: categoriesPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : categoriesPage) //修正listview焦点
                       : categoriesPage
            }

            onStatusChanged: {
                if (categoriesPage.status === PageStatus.Active) {
                    if (!_dataInitialized) {
                        _dataInitialized = true;
                    }
                }
            }
        }
    }


    initialPage: Component {
        Page{
            id:splashPage
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
                interval: 2 * 1000
                onTriggered: {
                    splash.visible = false;
                    loading = false;
                    var username = settings.get_username();
                    var password = settings.get_password();
                    if(username && password){
                        //login validate
                        var derpass = py.decryPass(password);
//                        console.log("user:"+username+",pass:"+derpass);
                        if(derpass)py.login(username,derpass);
                    }
                    toIndexPage();

                }
            }
        }
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations


    function toIndexPage() {
        popAttachedPages();
        pageStack.replace(indexPageComponent)

    }

    function toPopularPage() {
        popAttachedPages();
        pageStack.replace(indexPageComponent)

    }

    function toLoginPage(){
        popAttachedPages();
        pageStack.replace(Qt.resolvedUrl("pages/LoginDialog.qml"));
    }

    function toCategoriesPage(){
        popAttachedPages();
        pageStack.replace(categoriesPageComponent)
    }

    function toUserInfoPage(uid){
        //
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

    function formathtml(html){
        html=html.replace(/<a href=/g,"<a style='color:"+Theme.highlightColor+"' target='_blank' href=");
        html=html.replace(/<a class=/g,"<a style='color:"+Theme.highlightColor+"' target='_blank' class=");
        html=html.replace(/<p>/g,"<p style='text-indent:24px'>");
        html=html.replace(/<img\ssrc=\"\/assets\//g, "<img src=\"https://sailfishos.club/assets/");
        html=html.replace(/<p style='text-indent:24px'><img/g,"<p><img");
        html=html.replace(/<p style='text-indent:24px'><a [^<>]*href=\"([^<>"]*)\".*?><img/g,"<p><a href='$1'><img");
        html=html.replace(/&#x2F;/g,"/");
        html=html.replace(/<img src=\"([^<>"]*)\".*?>/g,"<img src=\"$1\" width="+(Screen.width-Theme.paddingMedium*2)+"/>");
        html = "<style>pre {display: flex;white-space: normal;word-break: break-word;}</style>" + html;

        return html;
    }



    function openLink(link) {
        if (link === _processingLink) {
            return
        }
        // Check if link looks like an OpenRepos application link
        if (/http[s]:\/\/sailfishos\.club\/topic\/[1-9]*/.exec(link)) {
            _processingLink = link
            var req = new XMLHttpRequest()
            // Prepare a http request to get headers
            req.open("GET", link, true)
            req.onreadystatechange = function() {
                if (req.readyState == 4) {
                    if (req.status == 200) {
                        // Check if headers contain an id link
                        var match = /<\/node\/(\d*)>.*/.exec(req.getResponseHeader("link"))
                        if (match) {
                            // Load the application page
                            pageStack.push(Qt.resolvedUrl("pages/TopicPage.qml"), {
                                               tid: match[1],
                                               returnToUser: false
                                           })
                            _processingLink = ""
                            return
                        }
                    }
                    _processingLink = ""
                    Qt.openUrlExternally(link)
                }
            }
            req.send(null)
        // Open other links externally
        } 
        // @someone
        else if(true){

        }else {
            Qt.openUrlExternally(link)
        }
    }
    Component.onCompleted: {
        Main.signalcenter = signalCenter;
        page_size = settings.get_pagesize();
    }
}

