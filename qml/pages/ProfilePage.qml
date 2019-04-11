import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/fontawesome.js" as FontAwesome

Page{
    id: profilePage
    objectName: "profilePage"
    allowedOrientations: Orientation.Portrait
    property string uid;
    property variant userData: null;
    property bool isMe: uid === userinfo.uid;

    function getUid(){
        return userData ? userData.uid : uid;
    }

    function getProfile(){
    //    if ( isMe ){
    //        console.log("is me")
    //        userData = userinfo;
    //    }else{
    //        console.log("not me")
    //        py.getUserInfo(uid);
    //    }
    // TODO
        py.getUserInfo(uid);

    }

    onUidChanged: getProfile();

    Connections{
        target: signalCenter
        onGetUserInfo:{
            if(result && result != "" && result != "Forbidden"){
//                console.log(JSON.stringify(result));
                var tmpData = {};
                tmpData.uid = result.uid;
                tmpData.username = result.username;
                tmpData.fullname = result.fullname;
                tmpData.userslug = result.userslug;
                tmpData.email = result.email;
                tmpData.avatar = result.picture;
                tmpData.aboutme = result.aboutme;
                tmpData.postcount = result.postcount;
                tmpData.topiccount = result.topiccount;
                tmpData.website= result.website;
                tmpData.signature= result.signature;
                tmpData.groupTitle= result.groupTitle;
                tmpData.groupIcon= result.groupIcon;
                tmpData.status= result.status;
                tmpData.user_text = result["icon:text"];
                tmpData.user_color = result["icon:bgColor"];
                tmpData.user_cover = appwindow.siteUrl + result["cover:url"];
                // console.log(appwindow.siteUrl + result["cover:url"])
                tmpData.followerCount = result.followerCount;
                tmpData.followingCount = result.followingCount;
                tmpData.reputation = result.reputation;
//                tmpData.groupTitle = result.selectedGroup ? result.selectedGroup.userTitle: "";
//                tmpData.gtoupIcon = result.selectedGroup ? result.selectedGroup.icon: "";
                userData = tmpData;

            }
        }
    }

//    Image {
//        id: imageBg;
//        anchors { left: parent.left; right: parent.right; top: parent.top; }
//        height: Theme.itemSizeExtraLarge * 4 - view.contentY;
//        clip: true;
//        source: "../gfx/background.png"
//        fillMode: Image.PreserveAspectCrop;
//    }



    SilicaFlickable {
        id: view;
        anchors.fill: parent
        contentWidth: parent.width;
        contentHeight: contentCol.height + Theme.paddingLarge * 4;
        VerticalScrollDecorator { flickable: view }
        Column {
            id: contentCol;
            width: parent.width;
            spacing: Theme.paddingSmall
            CacheImage{
                id: userCover
                asynchronous: true
                smooth: true
                sourceUncached: /*userData?userData.user_cover:*/"../gfx/background.png"
                width: parent.width
                height: isLandscape?parent.width/3:parent.width/2;
                sourceSize.width: width
                clip: true
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                Avatar {
                    id: avatar;
                    anchors {
                        horizontalCenter: parent.horizontalCenter;
                        verticalCenter: parent.verticalCenter;
                    }
                    height: isLandscape?parent.width/9:parent.width/6;
                    width: height;
                    avatar: userData?("" !== userData.avatar?(siteUrl+userData.avatar):""):"image://theme/harbour-sailfishclub"
                    color:  userData?userData.user_color:""
                    text:   userData?userData.user_text:""
                    username: userData? userData.username:""
                }

                Column{
                    width: parent.width;
                    spacing: Theme.paddingSmall
                    anchors.top: avatar.bottom
//                    Text {
//                        anchors{
//                            horizontalCenter: parent.horizontalCenter;
//                        }
//                        font.pixelSize: Theme.fontSizeLarge;
//                        color: "white";
//                        text: userData ? userData.fullname : "";
//                    }
                    Text {
                        anchors{
                            horizontalCenter: parent.horizontalCenter;
                        }
                        font.pixelSize: Theme.fontSizeMedium;
                        color: "white";
                        text: userData ? userData.username : "";
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        wrapMode: Text.Wrap;
                        maximumLineCount: 1;
                        textFormat: Text.PlainText;
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: "white";
                        text: userData ? userData.aboutme?userData.aboutme:"":"";
                    }
                }

            }
            




//            Text {
//                anchors{
//                    horizontalCenter: parent.horizontalCenter;
//                }
//                font.pixelSize: Theme.fontSizeSmall;
//                color: Theme.secondaryColor;
//                text: userData ? userData.email : "";
//                MouseArea{
//                    anchors.fill: parent
//                    onClicked: {
//                        remorse.execute(qsTr("Starting open Email..."),function(){
//                            Qt.openUrlExternally(userData.email);
//                        },3000);
//                    }
//                }
//            }

//            Text{
//                anchors{
//                    horizontalCenter: parent.horizontalCenter;
//                }
//                color: "white";
//                font.pixelSize: Theme.fontSizeSmall;
//                text: userData ? ( userData.groupTitle ?
//                                      (FontAwesome.Icon[userData.groupIcon.replace(/-/g,"_")] + userData.groupTitle ): "") : ""
//            }



            Column{
                width: parent.width
                Grid {
                    id: grid;
                    width: parent.width;
                    columns: 3;
                    spacing: Theme.paddingSmall
                    ProfileCell {
                        iconName: "sc";
                        title: qsTr("Reputation");
                        subTitle: userData ? userData.reputation : "";

                    }
                    ProfileCell {
                        iconName: "gz";
                        title: qsTr("FollowingCount");
                        subTitle: userData ? userData.followingCount ? userData.followingCount:0 :0;

                    }
                    ProfileCell {
                        iconName: "fs";
                        title: qsTr("Fans")
                        subTitle: userData ? userData.followerCount ? userData.followerCount:0 : 0;
                    }
                    ProfileCell {
                        iconName: "tiezi";
                        title: qsTr("Posts");
                        subTitle: userData ? userData.postcount : "";
                    }
                }
            }
        }
    }
}
