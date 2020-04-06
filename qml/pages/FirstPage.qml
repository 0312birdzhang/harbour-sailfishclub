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
import io.thp.pyotherside 1.5
import "../js/ApiCore.js" as JS
import "../js/fontawesome.js" as FONT
Page {
    id: page
    property alias contentItem:column
    allowedOrientations: Orientation.All
    objectName: "firstPage"
    property string cid;
    property string cname;
    property int current_page:1;
    property int pageCount:1;
    property string next_page;
    property bool next_active:false;
    property string prev_page;
    property bool prev_active:false;
    property bool need_refresh: false

    Column{
        id:column
        z: -2
        width: page.width
        height: page.height


        ListModel{
            id:listModel
        }

        SilicaListView {
            id: listView
            width: parent.width
            height: parent.height
            header: PageHeader {
                title: appwindow.current_router == router_recent?qsTr("Recent Page"):
                       appwindow.current_router == router_popular?qsTr("Popular"):
                       appwindow.current_router == router_categories?cname:appwindow.current_router
            }
            PullDownMenu{
                id:pullDownMenu
//                busy: !PageStatus.Active
//                enabled: PageStatus.Active
                enabled: !appwindow.loading
                MenuItem{
                    text:userinfo.logined?qsTr("New Topic"):qsTr("Login to create new topic")
                    onClicked: {
                        //create new topic or
                        if(userinfo.logined){
                            pageStack.push(Qt.resolvedUrl("PostPage.qml"),
                                           {"listModel":listModel,
                                             "parentpage":page
                                           })
                        }else{
                            toLoginPage();
                        }
                    }
                }

                MenuItem{
                    text:qsTr("Refresh")
                    enabled: !appwindow.loading
                    onClicked: {
                        load(true);
                    }
                }
            }
            delegate: BackgroundItem {
                id:showlist
                height:titleid.height+latestPost.height+timeid.height+Theme.paddingMedium*4
                width: listView.width
                Label{
                    id:titleid
                    text: (isQuestion? FONT.Icon.fa_question_circle:"" ) +
                          (isSolved? FONT.Icon.fa_check_circle:"" )  +
                           JS.decodeHTMLEntities(titleRaw)
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    font.bold:true;
                    anchors {
                        top:parent.top;
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }


                Label{
                    id:latestPost
                    text: qsTr("author:") + user + " / " + (latestpost?(qsTr("latest reply") +
                                                                " " + latestuser + ":"
                                                                + appwindow.formatFirstPagehtml(latestpost)):"")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    linkColor:Theme.primaryColor
                    maximumLineCount: 3
                    anchors {
                        top: titleid.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }
                Label{
                    id:timeid
                    text: FONT.Icon[category_icon.replace(/-/g,"_")]  + category + " "+ JS.humanedate(timestamp)
                    //opacity: 0.7
                    font.pixelSize: Theme.fontSizeTiny
                    //font.italic: true
                    color: Theme.secondaryColor
                    //horizontalAlignment: Text.AlignRight
                    anchors {
                        top:latestPost.bottom
                        left: parent.left
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                    }
                }
                Label{
                    id:viewinfo
                    text:qsTr("comments: ") +postcount+" / " + qsTr("views: ") +viewcount
                    //opacity: 0.7
                    font.pixelSize: Theme.fontSizeTiny
                    //font.italic: true
                    color: Theme.secondaryColor
                    //horizontalAlignment: Text.AlignRight
                    anchors {
                        top:latestPost.bottom
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }
                Separator {
                    visible:(index > 0?true:false)
                    width:parent.width;
                    //alignment:Qt.AlignHCenter
                    color: Theme.highlightColor
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("TopicPage.qml"),{
                                        "tid":tid
//                                    "tid": 105
                                   });
                }
            }
            VerticalScrollDecorator {}

            ViewPlaceholder {
                enabled: listView.count === 0 && !PageStatus.Active
                text: qsTr("Load Failed,Click to retry")
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        load();
                    }
                }
            }

            footer: Component{

                Item {
                    id: loadMoreID
                    anchors {
                        left: parent.left;
                        right: parent.right;
                    }
                    height: Theme.itemSizeMedium
                    Row {
                        id:footItem
                        spacing: Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        Button {
                            text: qsTr("Prev Page")
                            visible: prev_active
                            onClicked: {
                                current_page--;
                                load();
                            }
                        }
                        Button{
                            text:qsTr("Next Page")
                            visible: next_active
                            onClicked: {
                                current_page++;
                                load();
                            }
                        }
                    }
                }

            }
        }
    }

    function load(via_pulley){
        console.log("current router:"+current_router);
        if(current_page == 1 && !via_pulley ){
            py.get_query_from_cache(appwindow.slug_first_page, current_router);
            return;
        }
        switch(current_router){
        case router_recent:
            py.getRecent("page=" + current_page );
            break;
        case router_popular:
            py.getPopular("page=" + current_page);
            break;
        case router_categories:
            py.getRecent("page=" + current_page + (cid?("&cid=" + cid ):""));
            break;
        default:
            py.getRecent("page=" + current_page );
        }
    }

    Connections{
        target: signalCenter
        onGetRecent:{
            if (result && result != "Forbidden"){
                var topics = result.topics;
                var pagination = result.pagination;
                if(pagination){
                    current_page = pagination.currentPage;
                    pageCount = pagination.pageCount;
                    if(pageCount > 1){
                        next_page = pagination.next.qs;
                        next_active = pagination.next.active;
                        prev_page = pagination.prev.qs;
                        prev_active = pagination.prev.active;
                    }
                }else{
                    next_active = false;
                    prev_active = false;
                }

                listModel.clear();
                for(var i = 0;i<topics.length;i++){
                    if(topics[i].deleted)continue;
                    listModel.append({
                                         "title":topics[i].title,
                                         "titleRaw":topics[i].titleRaw,
                                         "user":topics[i].user.username,
                                         "viewcount":topics[i].viewcount,
                                         "postcount":topics[i].postcount,
                                         "latestpost":topics[i].teaser?topics[i].teaser.content:"",
                                         "latestuser":topics[i].teaser?topics[i].teaser.user.username:"",
                                         "tid":topics[i].tid,
                                         "timestamp":topics[i].timestampISO,
                                         "slug":topics[i].slug,
                                         "mainPid":topics[i].mainPid,
                                         "category":topics[i].category.name,
                                         "category_icon":topics[i].category.icon,
                                         "isQuestion": topics[i].isQuestion == "1",
                                         "isSolved": topics[i].isSolved == "1"
                                     });
                }
                listView.model = listModel;
                listView.scrollToTop();
            }else{
                console.log("load failed!!!");
                loading = false;
                notification.show(qsTr("Load failed,try again later"),
                                  "image://theme/icon-lock-warning"
                                  )
            }
        }

        onReplayFloor:{
            load(true);
        }
        onReplayTopic:{
            load(true);
        }

        onNewTopic:{
            load(true);
        }

    }

    Component.onCompleted: {
        load(need_refresh);
    }
}

