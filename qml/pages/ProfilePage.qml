import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page{
    property string uid;
    property variant userData: null;
    property bool isMe: getUid() === userinfo.uid;

    function getUid(){
        return userData ? userData.id : uid;
    }

    function getProfile(){
        if ( isMe ){
            userData = userinfo;
        }else{
            py.getUserInfo(uid);
        }


    }

    onUidChanged: getProfile();

    Image {
        id: imageBg;
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        height: Theme.graphicSizeLarge*2.7 - view.contentY;
        clip: true;
        source: "../gfx/background.png"
        fillMode: Image.PreserveAspectCrop;
    }

    SilicaFlickable {
        id: view;
        anchors { fill: parent; topMargin: 0; }
        contentWidth: parent.width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            width: parent.width;
            Item { width: 1; height: Theme.thumbnailSize; }
            Item {
                width: parent.width;
                height: Theme.graphicSizeLarge*2;

                Rectangle {
                    id: bottomBanner;
                    anchors { fill: parent; topMargin: parent.height*3/5; }
                    color: "#00ffffff";
                }

                Image {
                    id: avatar;
                    anchors {
                        left: parent.left; leftMargin: Theme.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    width: 100; height: 100;
                    source: "../gfx/person_photo_bg.png"
                    Avatar{
                        id: profile
                        anchors { fill: parent; margins: Theme.paddingMedium; }
                        avatar: userData?("" !== userData.avatar?(siteUrl+userData.avatar):""):"image://theme/harbour-sailfishclub"
                        color:  userData.user_color
                        text:   userData.user_text
                    }
                }

                Column {
                    anchors {
                        left: avatar.right; leftMargin: Theme.paddingMedium;
                        right: parent.right; rightMargin: Theme.paddingMedium;
                        bottom: bottomBanner.top;
                    }
                    Row {
                        spacing: Theme.paddingSmall;
                        Text {
                            anchors.verticalCenter: parent.verticalCenter;
                            font.pixelSize: Theme.fontXSmall;
                            color: "white";
                            text: userData ? userData.username : "";
                        }
//                        Image {
//                            source: {
//                                if (userData){
//                                    if (userData.sex === "1"){
//                                        return "gfx/icon_man"+Theme.invertedString;
//                                    } else {
//                                        return "gfx/icon_woman"+Theme.invertedString;
//                                    }
//                                } else {
//                                    return "";
//                                }
//                            }
//                        }
                    }
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        wrapMode: Text.Wrap;
                        maximumLineCount: 1;
                        textFormat: Text.PlainText;
                        font.pixelSize: Theme.fontXSmall-4;
                        color: "white";
                        text: userData ? userData.aboutme : "";
                    }
                }

            }
            Grid {
                id: grid;
                width: parent.width;
                columns: 3;
                ProfileCell {
                    visible: isMe;
                    iconName: "sc";
                    title: qsTr("Collections");
                    markVisible: getUid() === userinfo.uid;
                    onClicked: {
//                        var prop = { title: title }
//                        pageStack.push(Qt.resolvedUrl("Profile/BookmarkPage.qml"), prop);
                    }
                }
                ProfileCell {
                    iconName: "myba";
                    title: qsTr("Reputation");
                    subTitle: userData ? userData.reputation : "";
                    onClicked: {
//                        var prop = { title: title, uid: getUid() }
//                        pageStack.push(Qt.resolvedUrl("Profile/ProfileForumList.qml"), prop);
                    }
                }
                ProfileCell {
                    iconName: "gz";
                    title: qsTr("FollowingCount");
                    subTitle: userData ? userData.followingCount : "";
                    onClicked: {
//                        var prop = { title: title, type: "follow", uid: getUid() }
//                        pageStack.push(Qt.resolvedUrl("Profile/FriendsPage.qml"), prop);
                    }
                }
                ProfileCell {
                    iconName: "fs";
                    title: qsTr("Fans")
                    subTitle: userData ? userData.followerCount : "";
                    onClicked: {
                        if (getUid() === userinfo.uid){
//                            infoCenter.clear("fans");
                        }
//                        var prop = { title: title, type: "fans", uid: getUid() }
//                        pageStack.push(Qt.resolvedUrl("Profile/FriendsPage.qml"), prop);
                    }
                    markVisible: getUid() === userinfo.uid;
                }
                ProfileCell {
                    iconName: "tiezi";
                    title: qsTr("Posts");
                    subTitle: userData ? userData.postcount : "";
                    onClicked: {
//                        var prop = { title: title, uid: getUid() };
//                        pageStack.push(Qt.resolvedUrl("Profile/ProfilePost.qml"), prop);
                    }
                }
            }
        }
    }
}
