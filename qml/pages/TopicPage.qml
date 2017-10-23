import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../components"
import "../js/ApiCore.js" as JS

Page{
    id:topicPage

    property int tid;
    property string title;
    property string slug;
    property string user;

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
            title: title;
            _titleItem.font.pixelSize: Theme.fontSizeSmall
            description: user;
        }
        spacing: Theme.paddingSmall
        delegate: BackgroundItem {
            height: topicHeader.height +contentLabel.height + Theme.paddingMedium * 2
            width: parent.width

            TopicHeader{
                id: topicHeader
                avatar: avatar?(siteUrl+avatar):"image://theme/harbour-sailfishclub" //TODO
                username: username
                groupTitle:user_group_name
                floor: floor+"#"
                posttime:JS.humanedate(timestamp)
                width: parent.width
                height: Theme.itemSizeLarge
            }

            Label{
                id:contentLabel
                text:content
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                font.letterSpacing: 2;
                anchors{
                    top:topicHeader.bottom
                    left:parent.left
                    right:parent.right
                    topMargin: Theme.paddingLarge
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                    bottomMargin: Theme.paddingLarge
                }
            }

            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
                color: Theme.highlightColor
            }

        }

    }

    Component.onCompleted: {
        var topicData = py.getTopic(tid,slug);
        if (topicData && topicData != "Forbidden"){
            var posts = topicData.posts;
            var pagination = topicData.pagination;
            current_page = pagination.currentPage;
            pageCount = pagination.pageCount;
            if(pageCount > 1){
                next_page = pagination.next.qs;
                next_active = pagination.next.action;
                prev_page = pagination.prev.qs;
                prev_active = pagination.prev.action;
            }
            for(var i = 0;i<posts.length; i ++){

                //过滤掉删除的
                if(posts[i].deleted){
                    continue;
                }

                topicModel.append({
                                     "timestamp":posts[i].timestamp,
                                      "content":posts[i].content,
                                      "uid":posts[i].uid,
                                      "username":posts[i].user.username,
                                      "avatar":posts[i].user.picture,
                                      "floor":posts[i].index,
                                      "user_group_icon":posts[i].user.selectedGroup?posts[i].user.selectedGroup.icon:"",
                                      "user_group_name":posts[i].user.selectedGroup?posts[i].user.selectedGroup.name:"",

                                  });
                topicView.model = topicModel;
            }
        }
    }
}
