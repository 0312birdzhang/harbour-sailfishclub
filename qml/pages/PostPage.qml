import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog  {
    id:dialog
    property int cid;
    property int tid;
    property ListModel replaysTmpModel
    property Page parentpage;
    canAccept: subcomments.text.length > 2
    acceptDestination: parentpage
    acceptDestinationAction: PageStackAction.Pop
    acceptDestinationProperties:replaysTmpModel
    onAccepted: {
        //评论楼中楼
        if(cid){

        }else{
            //replay
            console.log("replay:"+tid+",uid:"+userinfo.uid+",comments:"+subcomments.text)
            var ret = py.replayTopic(tid,userinfo.uid,subcomments.text);
            console.log(JSON.stringify(ret));
            if(!ret || ret == "false"){
                notification.showPopup(qsTr("ReplayError"),JSON.stringify(ret));
                return;
            }else{
                replaysTmpModel.append({
                                     "timestamp":ret.timestampISO,
                                     "content":subcomments.text,
                                     "uid":userinfo.uid,
                                     "username":userinfo.username,
                                     "picture":userinfo.avatar,
                                     "floor":ret.index,
                                     "user_group_icon":userinfo.groupIcon,
                                     "user_group_name":userinfo.groupTitle,
                                     "user_text":userinfo.user_text,
                                     "user_color":userinfo.user_color
                                   })
            }
        }
    }

    Flickable {
        // ComboBox requires a flickable ancestor
        width: parent.width
        height: parent.height
        interactive: false
        anchors.fill: parent
        Column{
            id: column
            width: parent.width
            height: rectangle.height
            DialogHeader {
                title:qsTr("Replay")
            }
            anchors{
                //top:dialogHead.bottom
                left:parent.left
                right:parent.right
            }

            spacing: Theme.paddingLarge
            Rectangle{
                id:rectangle
                width: parent.width-Theme.paddingLarge
                height: subcomments.height + Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                border.color:Theme.highlightColor
                color:"#00000000"
                radius: 30

                TextArea {
                    id:subcomments
                    anchors{
                        top:parent.top
                        topMargin: Theme.paddingMedium
                    }
                    //validator: RegExpValidator { regExp: /.{1,128}/ }
                    width:window.width - Theme.paddingLarge*4
                    height: Math.max(dialog.width/3, implicitHeight)
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    placeholderText: qsTr("markdown is supported")
//                    EnterKey.onClicked : dialog.accept()
                    label: qsTr("Comments")
                }
            }

        }


    }
}
