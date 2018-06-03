import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../js/ApiCore.js" as JS
import "../js/fontawesome.js" as FONT

Page {
    id: searchPage
    property int current_page:1;
    property int pageCount:1;
    property string next_page;
    property bool next_active:false;
    property string prev_page;
    property bool prev_active:false;

    allowedOrientations:Orientation.All

    property string initialSearch
    function _reset() {
        viewPlaceholder.text = qsTr("Search results will be shown here")
        viewPlaceholder.hintText = qsTr("Type some keywords in the field above")
    }

    function _search(text) {
        if(!text) return;
        searchModel.clear();
        py.search(text, "page=" + current_page);
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
            height:titleid.height + latestPost.height+timeid.height+Theme.paddingMedium*4
            width: searchView.width
            Label{
                id:titleid
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                wrapMode: Text.WordWrap
                font.bold:true;
                color: initialSearch.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                                                   : (highlighted ? Theme.highlightColor : Theme.primaryColor)
                textFormat: Text.StyledText
                text: Theme.highlightText(JS.decodeHTMLEntities(model.title), initialSearch, Theme.highlightColor)
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
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                color: initialSearch.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                                                   : (highlighted ? Theme.highlightColor : Theme.primaryColor)
                text: Theme.highlightText(content, initialSearch, Theme.highlightColor)
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
                            _search(initialSearch);
                        }
                    }
                    Button{
                        text:qsTr("Next Page")
                        visible: next_active
                        onClicked: {
                            current_page++;
                            _search(initialSearch);
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

                for(var i = 0;i<posts.length;i++){
                    searchModel.append({
                                       "title":posts[i].topic.title,
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
                appwindow.loading = false;
                console.log("load failed!!!");
                // notification.show(qsTr("Load failed,try again later"),
                //                   "image://theme/icon-lock-warning"
                //                   );
                viewPlaceholder.hintText = qsTr("Load failed,try again later");                                 
            }
        }
    }
}
