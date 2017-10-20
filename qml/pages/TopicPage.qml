import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

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
        delegate: BackgroundItem {

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
        }
    }
}
