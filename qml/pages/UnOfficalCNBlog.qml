import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import "../components"

Page {
    property int current_page:0;
    property int pageCount:1;
    property string next_page;
    property bool next_active:false;
    property string prev_page;
    property bool prev_active:false;

    allowedOrientations:Orientation.Portrait

    ListModel{
        id: listModel
    }

    SilicaListView{
        id: listView
        anchors.fill: parent
        enabled: PageStatus.Active
        header: PageHeader{
            title: qsTr("Blog posts")
        }
        delegate: UnOfficalBlogListComponent{
            width: listView.width
        }
        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: listView.count === 0 && !PageStatus.Active
            text: qsTr("Load Failed,Click to retry")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    load();
                }
            }
        }

        footer: Component{

                Item {
                    id: loadMoreID
                    anchors {
                        left: parent.left;
                        right: parent.right;
                        topMargin: Theme.paddingSmall
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
    }


    function load(){
        py.getUnOfficalList(current_page);
    }


    Connections{
        target: signalCenter
        onGetUnOfficalList:{
            if(result && result !== "False"){
                pageCount = result.total;
                if(current_page < 1){
                    prev_active = false;
                    next_active = true;
                }else{
                    prev_active = true;
                }

                if(current_page*20 > pageCount){
                    next_active = false;
                }else{
                    next_active = true;
                }

                listModel.clear();
                var posts = result.post_infos;
                for(var i = 0; i<posts.length; i++){
                    listModel.append({
                        "updated_at": posts[i].updated_at,
                        "title": posts[i].title,
                        "slug": posts[i].slug,
                        "description": posts[i].description,
                        "cover": posts[i].cover,
                        "author": posts[i].author,
                        "inserted_at": posts[i].inserted_at
                    });
                }
                listView.model = listModel;
                listView.scrollToTop();

            }else{
                console.log("load failed!!!");
                loading = false;
                notification.show(qsTr("Load failed,try again later"),
                                  "image://theme/icon-lock-warning"
                                  )
            }
        }
    }

    
    Component.onCompleted: {
        load();
    }
}
