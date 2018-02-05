import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT
import "../js/ApiCore.js" as JS
import "../components"

Page{
    id: notificationPage

    ListModel{
        id: unreadModel
    }

    Connections{
        target: signalCenter
        onGetUnread:{
            if (result && result != "Forbidden"){
                var posts = result.topics;
                for(var i = 0; i < posts.length; i++){
                    unreadModel.append({
                       "timestamp":posts[i].timestampISO,
                       "content":posts[i].teaser.content,
                       "signature":posts[i].user.signature?posts[i].user.signature:"",
                       "uid":posts[i].uid.toString(),
                       "pid":posts[i].pid,
                       "username":posts[i].user.username,
                       "userslug":posts[i].user.userslug,
                       "picture":posts[i].user.picture,
                       "floor":posts[i].index,
                       "user_group_icon":posts[i].user.selectedGroup?posts[i].user.selectedGroup.icon:"",
                       "user_group_name":posts[i].user.selectedGroup?posts[i].user.selectedGroup.userTitle:"",
                       "user_text":posts[i].user["icon:text"],
                       "user_color":posts[i].user["icon:bgColor"]
                      });

                }
                view.model = unreadModel;
                if(posts && _showReplayNotification && !posts[0].read ){
                    replaiesNotification.body = posts[0].bodyLong;
                    replaiesNotification.publish();
                }

            }
        }
    }

    SilicaListView{
        id: view
        width: parent.width
        height: parent.height
        header: PageHeader{
            title: qsTr("Notifications")
        }
        delegate: BackgroundItem{
            width: view.width
            TopicHeader{
                id: topicHeader
                avatar: picture?(siteUrl+picture):""
                user: username
                user_id: uid
                groupTitle:"" == user_group_name?"":("["+user_group_name+"]")
                index: ""
                text: user_text
                color: user_color
                time: JS.humanedate(timestamp)
                width: parent.width
                height: isLandscape?parent.width/12:parent.width/8
            }

            Label{
                id: contentLabel
                text:formathtml(content)
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                font.letterSpacing: 2;
                anchors{
                    top:topicHeader.bottom
                    left:parent.left
                    right:parent.right
                    topMargin: Theme.paddingMedium
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                }
                onLinkActivated: {
                    appwindow.openLink(link);
                }
            }

            Label{
                id: signatureLabel
                anchors{
                    top: contentLabel.bottom
                    right: parent.right
                    rightMargin: Theme.paddingMedium
                }
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeExtraSmall * 0.8
                font.italic: true
                text: signature
                visible: signature
            }

            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
                color: Theme.secondaryHighlightColor
            }

        }

        ViewPlaceholder {
            enabled: unreadModel.count == 0
            text: qsTr("No unread news")
        }
    }

    Component.onCompleted:{
        py.getUnread();
    }

}
