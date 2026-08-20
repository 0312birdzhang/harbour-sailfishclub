import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/ApiCore.js" as JS
import "../js/fontawesome.js" as FONT

Page {
    id: searchPage
    objectName: "searchPage"
    property int current_page:1;
    property int pageCount:1;
    property string next_page;
    property bool next_active:false;
    property string prev_page;
    property bool prev_active:false;

    allowedOrientations: Orientation.Portrait

    property string initialSearch
    property string _currentSearch: ""
    function _reset() {
        viewPlaceholder.text = qsTr("Search results will be shown here")
        viewPlaceholder.hintText = qsTr("Type some keywords in the field above")
    }

    function _search(text) {
        if(!text) return;
        _currentSearch = text;
        searchModel.clear();
        // py.search(text, "page=" + current_page);
        appwindow.get_query_from_cache( appwindow.router_search,"page=" + current_page, text)
        viewPlaceholder.text = ""
        viewPlaceholder.hintText = ""
    }

    ListModel{
        id: searchModel
    }

    Component.onCompleted: if (!initialSearch) _reset()


    SilicaListView{
        id: searchView
        width: parent.width
        height: parent.height
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
            property string _postContent: model.content
            height: titleid.height + previewArea.height + timeid.height + Theme.paddingMedium * 4
            width: searchView.width
            Column{
                id: resultColumn
                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.paddingMedium
                }
                spacing: Theme.paddingSmall

                Label{
                    id:titleid
                    width: parent.width
                    height: Theme.fontSizeSmall * 3
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    font.bold:true;
                    color: initialSearch.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                                                       : (highlighted ? Theme.highlightColor : Theme.primaryColor)
                    textFormat: Text.StyledText
                    text: Theme.highlightText(JS.decodeHTMLEntities(model.title), initialSearch, Theme.highlightColor)
                }

                // rich text preview, fixed height, clipped so every item stays the same height
                Item{
                    id: previewArea
                    width: parent.width
                    height: Theme.itemSizeMedium * 2
                    clip: true
                    Column{
                        width: parent.width
                        Repeater{
                            id: contentRepeater
                            model: appwindow.splitContent(_postContent, previewArea, 3)
                            Loader{
                                width: parent.width
                                source: Qt.resolvedUrl("../components/" + type + "Delegate.qml")
                            }
                        }
                    }
                }

                Label{
                    id:timeid
                    text:FONT.Icon[category_icon.replace(/-/g,"_")]  + category + " "+ JS.humanedate(timestamp)
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                }
            }
            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
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
                            _search(_currentSearch);
                        }
                    }
                    Button{
                        text:qsTr("Next Page")
                        visible: next_active
                        onClicked: {
                            current_page++;
                            _search(_currentSearch);
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
                return h ? (parent.height - h) * 0.2 : 0
            }

            Behavior on verticalOffset {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
    }

    Connections{
        target: signalCenter
        onGetSearch:{
            // console.log("result:"+ result);
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

                for(var i = 0; posts && i<posts.length;i++){
                    searchModel.append({
                                       "title":posts[i].topic.title,
                                       "titleRaw":posts[i].topic.title,
                                       "user":posts[i].user.username,
                                       "tid":posts[i].tid,
                                       "content": posts[i].content,
                                       "timestamp":posts[i].timestampISO,
                                       "slug":posts[i].slug,
                                       "mainPid":posts[i].mainPid,
                                       "category":posts[i].category.name,
                                       "category_icon":posts[i].category.icon
                                       });
                }
                searchView.model = searchModel;
                // console.log("searchModel count:"+searchModel.count)
            }else{
                console.log("load failed!!!");
                // notification.show(qsTr("Load failed,try again later"),
                //                   "image://theme/icon-lock-warning"
                //                   );
                viewPlaceholder.hintText = qsTr("Load failed,try again later");                                 
            }
        }
    }
}
