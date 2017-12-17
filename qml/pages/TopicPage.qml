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


    allowedOrientations:Orientation.All

    ListModel{
        id:topicModel
    }


    SilicaListView{
        id:topicView
        anchors.fill: parent
        enabled: PageStatus.Active
        header: PageHeader {
            title: JS.decodeHTMLEntities(topic_title);
            _titleItem.font.pixelSize: Theme.fontSizeSmall
            description: FONT.Icon[category_icon.replace(/-/g,"_")]  + category;
        }
        delegate: ListItem {
            contentHeight: topicHeader.height +contentLabel.height + signatureLabel.height + Theme.paddingMedium * 4
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
                height: isLandscape?parent.width/12:parent.width/8
            }

            Label{
//            TextCollapsible{
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
                }
                onLinkActivated: {
//                    console.log("height:"+height)
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

//            OpacityRampEffect {
//                id: effect
//                slope: 0.60
//                offset: 0.10
//                direction: OpacityRamp.TopToBottom
//                sourceItem: contentLabel
//            }

            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
                color: Theme.secondaryHighlightColor
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
                                               "pid":pid,
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
        onOpenBrowser:{
            Qt.openUrlExternally(siteUrl+"/topic/"+tid);
        }
        onOpenShare:{
            pageStack.push(Qt.resolvedUrl("../components/ShareToPage.qml"),{
                "link":siteUrl+"/topic/"+tid,
                "linkTitle":topic_title
            })
        }

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
                topic_title = topicData.title;
                slug = topicData.slug;
                category = topicData.category.name;
                category_icon = topicData.category.icon;

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
                    topicView.model = topicModel;
                }
                topicView.scrollToTop();
            }else{
                console.log("load failed!!!");
                notification.show(qsTr("Load failed,try again later"),
                                  "image://theme/icon-lock-warning"
                                  )
            }
        }
    }

    function load(){
        py.getTopic(tid,slug?slug+"?page="+current_page:undefined);
    }

    

    Component{
        id: postComponent
        Dialog  {
            id:dialog
            orientation: Orientation.All
            property string replayTo:"";
            property string tid;
            property string pid;

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
                    DialogHeader{
                         acceptText: ""
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
                            if(pid){
                                py.replayFloor(dialog.tid,userinfo.uid,pid,subcomments);
                            }else{
                                py.replayTopic(dialog.tid,userinfo.uid,subcomments);
                            }

                        }
                    }

                }

            }

            Connections{
                target: signalCenter
                onReplayFloor:{
                    replayCallback(result);
                }
                onReplayTopic:{
                    replayCallback(result);
                }
            }

            function replayCallback(ret){
                if(!ret || ret == "false"){
                    notification.showPopup(qsTr("ReplayError"),JSON.stringify(ret),"image://theme/icon-lock-warning");
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

    Component{
        id:loginDialog
        LoginDialog{
            anchors.fill: parent
            onAccepted: {
                pageStack.pop();
            }
        }
    }

    Component.onCompleted: {
        load();
    }
    Component.onDestruction: {

    }
}
