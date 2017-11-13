import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../components"
import "../js/ApiCore.js" as JS
import "../js/fontawesome.js" as FONT
Page{
    id:topicPage

    property int tid;
    property string topic_title;
    property string slug;
    property string user;
    property string category_icon;
    property string category;

    property int current_page:1;
    property int pageCount:1;
    property string next_page;
    property bool next_active:false;
    property string prev_page;
    property bool prev_active:false;


    ListModel{
        id:topicModel
    }


    SilicaListView{
        id:topicView
        anchors.fill: parent
        header: PageHeader {
            title: topic_title;
            _titleItem.font.pixelSize: Theme.fontSizeSmall
            description: FONT.Icon[category_icon.replace(/-/g,"_")]  + category;
        }
        delegate: ListItem {
            contentHeight: topicHeader.height +contentLabel.height + Theme.paddingMedium * 4
            width: topicView.width

            TopicHeader{
                id: topicHeader
                avatar: picture?(siteUrl+picture):""
                user: username
                user_id: uid
                groupTitle:"" == user_group_name?"":("["+user_group_name+"]")
                index: floor+"#"
                text: user_text
                color: user_color
                time:JS.humanedate(timestamp)
                width: parent.width
                height: parent.width/8
            }

            Label{
                id:contentLabel
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
//                    bottomMargin: Theme.paddingLarge
                }
            }

            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
                color: Theme.highlightColor
            }
            menu: contextMenu
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Replay")
                        onClicked:{
                            pageStack.push(postComponent, {
                                               "tid":tid,
                                               "replayTo":"@"+userslug+" ",
                                               "parentpage":topicPage,
                                               "replaysTmpModel":topicModel
                                           });
                            toolbar.hideExbar();
                        }
                    }
                }
            }

        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: topicView.count === 0
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

        property int flpy0: 0
        onMovementStarted:{
            flpy0=topicView.contentY;
            toolbar.hideExbar();
        }
        onContentYChanged:{
            if(contentY-flpy0<0){
                toolbar.visible=true
                toolbar.height=toolbar.iheight;
            }else{
                toolbar.height=0;
            }
        }



        ViewPlaceholder {
            enabled: topicView.count == 0 && !PageStatus.Active
            text: qsTr("Empty,Click to retry")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    load();
                }
            }
        }


    }

    TopicToolBar{
        id:toolbar
    }

    Connections{
        target: signalCenter
        onGetTopic:{
            var topicData = result;
            if (topicData && topicData != "Forbidden"){
                var posts = topicData.posts;
                var pagination = topicData.pagination;
                current_page = pagination.currentPage;
                pageCount = pagination.pageCount;
                if(pageCount > 1){
                    next_page = pagination.next.qs;
                    next_active = pagination.next.active;
                    prev_page = pagination.prev.qs;
                    prev_active = pagination.prev.active;
                }
                topicModel.clear();
                for(var i = 0;i<posts.length; i ++){
                    //过滤掉删除的
                    if(posts[i].deleted){
                        continue;
                    }
                    topicModel.append({
                                          "timestamp":posts[i].timestampISO,
                                          "content":posts[i].content,
                                          "uid":posts[i].uid,
                                          "username":posts[i].user.username,
                                          "userslug":posts[i].user.userslug,
                                          "picture":posts[i].user.picture,
                                          "floor":posts[i].index,
                                          "user_group_icon":posts[i].user.selectedGroup?posts[i].user.selectedGroup.icon:"",
                                          "user_group_name":posts[i].user.selectedGroup?posts[i].user.selectedGroup.userTitle:"",
                                          "user_text":posts[i].user["icon:text"],
                                          "user_color":posts[i].user["icon:bgColor"]

                                      });
                    topicView.model = topicModel;
                }
                topicView.scrollToTop();
            }else{
                console.log("load failed!!!");
            }
        }
    }

    function load(){
        py.getTopic(tid,slug+"?page="+current_page);

    }

    

    Component{
        id: postComponent
        Dialog  {
            id:dialog
            property string replayTo:"";
            property int tid;
            property ListModel replaysTmpModel
            property Page parentpage;
            canAccept: false
            acceptDestination: parentpage
            acceptDestinationAction: PageStackAction.Pop
            acceptDestinationProperties:replaysTmpModel
            SilicaFlickable {
                // ComboBox requires a flickable ancestor
                width: parent.width
                height: parent.height
                anchors.fill: parent
                contentHeight: column.height + Theme.paddingLarge * 2
                Column{
                    id: column
                    width: parent.width
                    height: commentField.height
                    DialogHeader {
                        title:""
                    }
                    anchors{
                        //top:dialogHead.bottom
                        left:parent.left
                        right:parent.right
                    }

                    spacing: Theme.paddingLarge

                    CommentField{
                        id: commentField
                        replayUser: replayTo
                        _replyToId: tid;
                        onSendButtonClicked: {
                            var subcomments = commentField.children[3].text;
                            //replay
                            console.log("sub:"+ subcomments+",tid:"+dialog.tid+",uid:"+userinfo.uid);
                            var ret = py.replayTopic(dialog.tid,userinfo.uid,subcomments);
                            console.log(JSON.stringify(ret));
                            if(!ret || ret == "false"){
                                notification.showPopup(qsTr("ReplayError"),JSON.stringify(ret),"image://theme/icon-lock-warning");
//                                return;
                            }else{
                                replaysTmpModel.append({
                                                     "timestamp":ret.timestampISO,
                                                     "content":ret.content,
                                                     "uid":userinfo.uid.toString(),
                                                     "username":userinfo.username,
                                                     "picture":userinfo.avatar,
                                                     "floor":ret.index,
                                                     "user_group_icon":userinfo.groupIcon,
                                                     "user_group_name":ret.user.selectedGroup?ret.user.selectedGroup.userTitle:"",
                                                     "user_text":userinfo.user_text,
                                                     "user_color":userinfo.user_color
                                                   });
                                pageStack.pop();
                            }
                        }
                    }

                }

            }
        }

    }

    Component{
        id:loginDialog
        LoginComponent{
            anchors.fill: parent
            onLoginSucceed: {
                pageStack.pop();
            }
        }
    }

    Component.onCompleted: {
        load();
    }
}
