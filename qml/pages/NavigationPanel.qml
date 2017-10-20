import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

import "../components"
import "../js/fontawesome.js" as FontAwesome

Panel {
    id: panel

    property bool _userAvatarLock: false

    signal clicked
    signal userAvatarClicked

    function initUserAvatar() {

    }

    function reloadIndex(classname){
        toIndexPage();
    }

    onUserAvatarClicked: {
        //to loginpage or userinfo page
        if(userinfo.logined){
//            toUserInfoPage();
        }else{
            toLoginPage();
        }
    }

    Column {
        id: column
        spacing: Theme.paddingMedium
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Item {
            id: userAvatar
            width: column.width
            height: cover.height
            BusyIndicator {
                id: avatarLoading
                anchors.centerIn: parent
                parent: userAvatar
                size: BusyIndicatorSize.Small
                opacity: avatarLoading.running ? 1 : 0
                running: cover.status != Image.Ready && profile.status != Image.Ready
            }
            Image {
                id: cover
                width: parent.width
                height: cover.width *2/3
                fillMode: Image.PreserveAspectCrop
                opacity: 0.6
                asynchronous: true
                source: "../gfx/background.png"
            }
            Image {
                id: profile
                width: userAvatar.width/4
                height: width
                anchors.centerIn: cover
                // asynchronous: true
                smooth: true
                source: userinfo.logined?(siteUrl+userinfo.avatar):"image://theme/harbour-sailfishclub"
                sourceSize: Qt.size(userAvatar.width/4, userAvatar.width/4)
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        userAvatarClicked();
                    }
                }

            }
            Rectangle{
                id: rectsrc
                color: "#fffffffff"
                width: userAvatar.width/4
                height: userAvatar.width/4
                radius: userAvatar.width/8
                visible: false
                smooth: true
            }

            OpacityMask{
                source: profile
                maskSource: rectsrc
                width: userAvatar.width/4
                height: userAvatar.width/4
                anchors.centerIn: parent
            }
            Label{
                id:userName
                text:userinfo.logined?userinfo.username:qsTr("Guest")
                font.family: Theme.fontSizeSmall
                color: Theme.primaryColor
                anchors{
                    top: profile.bottom
                    topMargin: Theme.paddingSmall
                    horizontalCenter: parent.horizontalCenter
                }
            }

        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("categories")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: FontAwesome.fa_list
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    // reloadIndex("categories");
                }
            }
        }


        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("tags")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: FontAwesome.fa_tags
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    // reloadIndex("categories");
                }
            }
        }

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("popular")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: FontAwesome.fa_fire
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    // reloadIndex("categories");
                }
            }
        }

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Settings")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "image://theme/icon-m-developer-mode"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                   pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
                }
            }
        }
    }
}
