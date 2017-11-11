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
import io.thp.pyotherside 1.3
import "../js/ApiCore.js" as JS
import "../js/fontawesome.js" as FONT
Page {
    id: page
    property alias contentItem:listView

//    property int current_page:1;
//    property int pageCount:1;
//    property string next_page;
//    property bool next_active:false;
//    property string prev_page;
//    property bool prev_active:false;

    ListModel{
        id:listModel
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        header: PageHeader {
            title: appwindow.current_router == "recent"?qsTr("Recent Page"):
                   appwindow.current_router == "popular"?qsTr("Popular"):appwindow.current_router
        }
        PullDownMenu{
            id:pullDownMenu
            MenuItem{
                text:userinfo.logined?qsTr("New Topic"):qsTr("Login to create new topic")
                onClicked: {
                    //create new topic or 
                    if(userinfo.logined){
                        pageStack.push(Qt.resolvedUrl("PostPage.qml"))
                    }else{
                        toLoginPage();
                    }
                }
            }

            MenuItem{
                text:qsTr("Refresh")
                onClicked: {
                    load();
                }
            }
        }
        delegate: BackgroundItem {
            id:showlist
            height:titleid.height+latestPost.height+timeid.height+Theme.paddingMedium*4
            width: parent.width
            Label{
                id:titleid
                text:title
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
                text: latestpost?(qsTr("last post by") + " " + latestuser +":"+ latestpost):""
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
                text:FONT.Icon[category_icon.replace(/-/g,"_")]  + category + qsTr(" post time:")+ JS.humanedate(timestamp)
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
                text:"评论 : "+postcount+" / 浏览 : "+viewcount
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
                                   "tid":tid,
                                   "topic_title":title,
                                   "slug":slug,
                                   "user":user,
                                   "category":category,
                                   "category_icon":category_icon

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

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: listView.count === 0
        }
    }


    function load(){
        console.log("current router:"+current_router);

        switch(current_router){
        case "recent":
            py.getRecent();
            break;
        case "popular":
            py.getPopular();
            break;
        default:
            py.getRecent();
        }
    }

    Connections{
        target: signalCenter
        onGetRecent:{
            listModel.clear();
            for(var i = 0;i<result.length;i++){
                if(result[i].deleted)continue;
                listModel.append({
                                     "title":result[i].title,
                                     "user":result[i].user.username,
                                     "viewcount":result[i].viewcount,
                                     "postcount":result[i].postcount,
                                     "latestpost":result[i].teaser?result[i].teaser.content:"",
                                     "latestuser":result[i].teaser?result[i].teaser.user.username:"",
                                     "tid":result[i].tid,
                                     "timestamp":result[i].timestampISO,
                                     "slug":result[i].slug,
                                     "mainPid":result[i].mainPid,
                                     "category":result[i].category.name,
                                     "category_icon":result[i].category.icon

                                 });
            }
            listView.model = listModel;
        }
    }

    Component.onCompleted: {
        load();
    }
}

