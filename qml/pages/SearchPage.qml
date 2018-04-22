import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: searchPage
    property alias contentItem:column
    allowedOrientations:Orientation.All

    property string initialSearch
    function _reset() {
        searchModel.searchKey = ""
        viewPlaceholder.text = qsTr("Search results will be shown here")
        viewPlaceholder.hintText = qsTr("Type some keywords in the field above")
    }

    function _search(text) {
        if(!text) return;
        py.search(text, "page=" + current_page);
        viewPlaceholder.text = ""
        viewPlaceholder.hintText = ""
    }

    ListModel{
        id: searchModel
    }

    Component.onCompleted: if (!initialSearch) _reset()

    Column{
        id:column
        z: -2
        width: page.width
        height: page.height
        SilicaListView{
            id: searchView
            anchors.fill: parent
            header: Column {
                width: parent.width

                PageHeader {
                    title: qsTr("Search")
                }

                SearchField {
                    width: parent.width
                    placeholderText: qsTr("SearchPlaceholder")

                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: _search(text)

                    onTextChanged: if (!text) _reset()
                    Component.onCompleted: {
                        if (initialSearch) {
                            text = initialSearch
                            _search(initialSearch)
                        } else {
                            forceActiveFocus()
                        }
                    }
                }
            }

            delegate: BackgroundItem {
                id:showlist
                height:titleid.height+latestPost.height+timeid.height+Theme.paddingMedium*4
                width: listView.width
                Label{
                    id:titleid
                    text:JS.decodeHTMLEntities(title)
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    font.bold:true;
                    anchors {
                        top:parent.top;
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }


                Label{
                    id:latestPost
                    text: qsTr("author:") + user + " / " + (latestpost?(qsTr("latest reply") +
                                                                        " " + latestuser + ":"
                                                                        + appwindow.formatFirstPagehtml(latestpost)):"")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    linkColor:Theme.primaryColor
                    maximumLineCount: 3
                    anchors {
                        top: titleid.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }
                Label{
                    id:timeid
                    text:FONT.Icon[category_icon.replace(/-/g,"_")]  + category + " "+ JS.humanedate(timestamp)
                    //opacity: 0.7
                    font.pixelSize: Theme.fontSizeTiny
                    //font.italic: true
                    color: Theme.secondaryColor
                    //horizontalAlignment: Text.AlignRight
                    anchors {
                        top:latestPost.bottom
                        left: parent.left
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                    }
                }
                Label{
                    id:viewinfo
                    text:qsTr("comments: ") +postcount+" / " + qsTr("views: ") +viewcount
                    //opacity: 0.7
                    font.pixelSize: Theme.fontSizeTiny
                    //font.italic: true
                    color: Theme.secondaryColor
                    //horizontalAlignment: Text.AlignRight
                    anchors {
                        top:latestPost.bottom
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }
                Separator {
                    visible:(index > 0?true:false)
                    width:parent.width;
                    //alignment:Qt.AlignHCenter
                    color: Theme.highlightColor
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("TopicPage.qml"),{
                                       "tid":tid
                                   });
                }
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

            VerticalScrollDecorator { }

            ViewPlaceholder {
                id: viewPlaceholder
                enabled: text
                verticalOffset: {
                    var h = Qt.inputMethod.keyboardRectangle.height
                    return h ? (parent.height - h) * 0.5 : 0
                }

                Behavior on verticalOffset {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }

            BusyIndicator {
                id: busyIndicator
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
                running: parent.count === 0 && !viewPlaceholder.enabled
            }
        }

        Connections{
            target: signalCenter
            onGetSearch:{
                if (result && result != "Forbidden"){
                    var posts = result.posts;
                    var pagination = result.pagination;
                    if(pagination){
                        current_page = pagination.currentPage;
                        pageCount = pagination.pageCount;
                        if(pageCount > 1){
                            next_page = pagination.next.qs;
                            next_active = pagination.next.active;
                            prev_page = pagination.prev.qs;
                            prev_active = pagination.prev.active;
                        }
                    }else{
                        next_active = false;
                        prev_active = false;
                    }

                    searchModel.clear();
                    for(var i = 0;i<posts.length;i++){
                        if(topics[i].deleted)continue;
                        searchModel.append({
                                             "title":posts[i].title,
                                             "user":posts[i].user.username,
                                             "viewcount":posts[i].viewcount,
                                             "postcount":posts[i].postcount,
                                             "latestpost":posts[i].teaser?topics[i].teaser.content:"",
                                             "latestuser":posts[i].teaser?topics[i].teaser.user.username:"",
                                             "tid":posts[i].tid,
                                             "timestamp":posts[i].timestampISO,
                                             "slug":posts[i].slug,
                                             "mainPid":posts[i].mainPid,
                                             "category":posts[i].category.name,
                                             "category_icon":posts[i].category.icon

                                         });
                    }
                    searchView.model = searchModel;
                }else{
                    console.log("load failed!!!");
                    notification.show(qsTr("Load failed,try again later"),
                                      "image://theme/icon-lock-warning"
                                      )
                }
            }
        }
    }
}
