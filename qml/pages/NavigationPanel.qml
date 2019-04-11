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

    function goRouter(router){
        if(current_router === router){
            clicked();
        }else{
            current_router = router;
            if(router === "recent" ){
                toIndexPage();
            }else if(router === "popular"){
                toPopularPage();
            }else if(router === "categories"){
                toCategoriesPage();
            }else{

            }
        }
    }

    onUserAvatarClicked: {
        //to loginpage or userinfo page
        if(userinfo.logined){
            toUserInfoPage(userinfo.uid);
        }else{
            toLoginPage();
        }
    }

    Connections{
        target: signalCenter;
        onLoginSuccessed:{
            console.log("logined!!!")
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
                running: cover.status != Image.Ready && profile.status !== Image.Ready
            }
            Image {
                id: cover
                width: parent.width
                height: parent.isLandscape?cover.width/2:cover.width *2/3
                fillMode: Image.PreserveAspectCrop
                opacity: 0.6
                asynchronous: true
                source: "../gfx/background.png"
            }



            Avatar{
                id: profile
                width: userAvatar.width/4
                height: width
                anchors.centerIn: cover
                avatar: userinfo.logined?("" != userinfo.avatar?(siteUrl+userinfo.avatar):""):"image://theme/harbour-sailfishclub"
                color:  userinfo.user_color
                text:   userinfo.user_text
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        userAvatarClicked();
                    }
                }
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
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon:FontAwesome.Icon.fa_list
                text:  qsTr("Categories")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                    goRouter("categories");
                }
            }
        }


//        Item {
//            width: column.width
//            height: Theme.itemSizeExtraSmall
//            HorizontalFontAwesomeTextButton {
//                anchors {
//                    left: parent.left
//                    leftMargin: Theme.paddingLarge
//                    right: parent.right
//                }
//                icon:FontAwesome.Icon.fa_tags
//                text: qsTr("tags")
//                color: Theme.secondaryColor
//                spacing: Theme.paddingMedium
//                onClicked: {
//                    goRouter("tags");
//                }
//            }
//        }

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon:FontAwesome.Icon.fa_fire
                text:  qsTr("Popular")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                     goRouter("popular");
                }
            }
        }

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon:FontAwesome.Icon.fa_clock_o
                text:  qsTr("Recent")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                     goRouter("recent");
                }
            }
        }

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            enabled: userinfo.logined
            visible: enabled
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon:FontAwesome.Icon.fa_search
                text:  qsTr("Search")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                     pageStack.push(Qt.resolvedUrl("SearchPage.qml"));
                }
            }
        }


        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon: FontAwesome.Icon.fa_inbox
                text:  qsTr("Notifications")
                enabled: userinfo.logined
                visible: enabled
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                   pageStack.push(Qt.resolvedUrl("NotificationsPage.qml"));
                }
            }
        }

        


        Item{
            width: column.width
            height: Theme.iconSizeSmall
        }

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon: FontAwesome.Icon.fa_newspaper_o
                text:  qsTr("UnOfficalCNBlog")
                enabled: true
                visible: enabled
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                   pageStack.push(Qt.resolvedUrl("UnOfficalCNBlog.qml"));
                }
            }
        }

        Item{
            width: column.width
            height: Theme.iconSizeSmall
        }

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon: FontAwesome.Icon.fa_info
                text:  qsTr("About")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                   pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
            }
        }
        

        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            enabled: userinfo.logined
            visible: enabled
            HorizontalFontAwesomeTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                }
                icon: FontAwesome.Icon.fa_sign_out
                text:  qsTr("Logout")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                onClicked: {
                    remorse.execute(qsTr("Start logout..."), function() {
                        userinfo.logined = false;
                        userinfo.uid = "";
                        userinfo.userslug = "";
                        userinfo.username = "";
                        userinfo.avatar = "";
                        userinfo.user_text = "";
                        py.logout();
                        appwindow.current_router = "recent"
                        toIndexPage();
                    },3000)
                }
            }
        }


    }


}
