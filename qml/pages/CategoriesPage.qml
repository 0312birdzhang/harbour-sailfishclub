import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/fontawesome.js" as FONT

Page{
    id: page
    property alias contentItem:column
    property bool _bannerRequested: false
    property bool landscape: width > height
    allowedOrientations:Orientation.All
    objectName: "cateogriesPage"
    ListModel{
        id: bannerModel
    }

    ListModel{
        id: categoriesModel
    }

    Column{
        id:column
        z: 10
        width: page.width
        height: page.height

        PageHeader{
            id: header
            title: qsTr("Categories")
        }

        Item{
            id: body
            width: parent.width
            height: parent.height - header.height
            clip: true

            // portrait: banner on top, full width; landscape: banner on the left, vertical carousel
            ActivityTopicBanner{
                id:bannerItem
                landscape: page.landscape
                anchors.top: parent.top
                anchors.left: parent.left
            }

            SilicaFlickable{
                id: flickable
                x: page.landscape ? bannerItem.width : 0
                y: page.landscape ? 0 : bannerItem.height
                width: page.landscape ? body.width - bannerItem.width : body.width
                height: page.landscape ? body.height : body.height - bannerItem.height
                clip: true
                contentWidth: width;
                contentHeight: content.height + Theme.itemSizeExtraLarge
                Column{
                    id: content
                    width: parent.width
                    anchors{
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.paddingSmall
                    }
                    spacing: Theme.paddingMedium

                    Repeater{
                        id: listView
                        delegate: ListItem{
                            height: nameLabel.height + descLabel.height + Theme.paddingSmall * 2
                            width: parent.width
                            Label{
                                id: nameLabel
                                text:  cname + FONT.Icon[icon.replace(/-/g,"_")]
                                color: Theme.primaryColor
                                font.bold:true;
                                font.pixelSize: Theme.fontSizeMedium
                                anchors{
                                    left: parent.left
                                    leftMargin: Theme.paddingLarge
                                    right: parent.right
                                    top: parent.top
                                    topMargin: Theme.paddingSmall
                                }
                            }
                            Label{
                                id: descLabel
                                text: description
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeTiny
                                anchors{
                                    left: parent.left
                                    leftMargin: Theme.paddingLarge
                                    right: parent.right
                                    top: nameLabel.bottom
                                }
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("./FirstPage.qml"),{
                                                       "cid":cid,
                                                       "cname":cname + FONT.Icon[icon.replace(/-/g,"_")],
                                                       "need_refresh": true
                                                   });
                                }
                            }

                        }
                    }

                }

                ViewPlaceholder {
                    enabled: bannerModel.count === 0 && categoriesModel.count === 0 && !PageStatus.Active
                    text: qsTr("Load Failed,Click to retry")
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            api.getCategories();
                        }
                    }
                }

                VerticalScrollDecorator{
                    flickable: flickable
                }

            }
        }
    }

    Connections{
        target: signalCenter
        onGetCategories:{
            if(result && result != "Forbidden"){
                var categories = result.categories;
                categoriesModel.clear();
                fillCategoryModel(categories);
                listView.model = categoriesModel;
                // v4.15: banner data is no longer in the categories response,
                // fetch structured recent topics for the banner instead
                _bannerRequested = true;
                api.getRecent("page=1")
            }else{

            }

        }
        onGetRecent:{
            // only handle the recent request that this page itself initiated,
            // ignore others (e.g. FirstPage loading a category's topics)
            if(!_bannerRequested) return;
            _bannerRequested = false;
            if(result && result != "Forbidden"){
                var banners = result.topics;
                var seen = {};
                bannerModel.clear();
                for(var i = 0; banners && i< banners.length;i++){
                    if(banners[i].deleted)continue;
                    // only keep the latest topic per category (板块)
                    var catCid = String(banners[i].cid);
                    if(seen[catCid])continue;
                    seen[catCid] = true;
                    bannerModel.append({
                                       "title":banners[i].title,
                                       "user":banners[i].user.username,
                                       "viewcount":banners[i].viewcount,
                                       "postcount":banners[i].postcount,
                                       "latestpost":banners[i].teaser?banners[i].teaser.content:"",
                                       "latestuser":(banners[i].teaser && banners[i].teaser.user)?banners[i].teaser.user.username:"",
                                       "tid":banners[i].tid,
                                       "timestamp":banners[i].timestampISO,
                                       "slug":banners[i].slug,
                                       "mainPid":banners[i].mainPid,
                                       "category":banners[i].category.name,
                                       "category_icon":banners[i].category.icon,
                                       "category_bgColor":banners[i].category.bgColor
                                   });
                }
                console.log("[categories] after append, bannerModel.count:", bannerModel.count)
                bannerItem.model = bannerModel;
            }
        }
    }


    function fillCategoryModel(categories){
        // v4.15 returns a flat list; group children under their parent by parentCid
        var byParent = {};
        var roots = [];
        for(var i=0;i<categories.length;i++){
            var c = categories[i];
            // skip the "uncategorised" pseudo category (cid -1)
            if(String(c.cid) === "-1" ||
               String(c.name).indexOf("uncategorized") >= 0){
                continue;
            }
            var pid = String(c.parentCid);
            if(pid === "0"){
                roots.push(c);
            }else{
                if(!byParent[pid]) byParent[pid] = [];
                byParent[pid].push(c);
            }
        }
        for(var r=0; r<roots.length; r++){
            appendCategoryTree(roots[r], byParent, "");
        }
    }

    function appendCategoryTree(c, byParent, indent){
        categoriesModel.append({
            "cid":  c.cid,
            "cname": indent + c.name,
            "description":indent + c.description,
            "icon":c.icon,
            "slug":c.slug,
            "parentCid":c.parentCid
            });
        var kids = byParent[String(c.cid)];
        for(var k=0; kids && k<kids.length; k++){
            appendCategoryTree(kids[k], byParent, indent + "    ");
        }
    }

    Component.onCompleted: {
        appwindow.get_query_from_cache(appwindow.router_categories,"")
    }
    onStatusChanged: {
        if(status === PageStatus.Active){
            console.log("[cat] ACTIVE, landscape:", landscape, ", body:", body.width, "x", body.height,
                        ", banner:", bannerItem.width, "x", bannerItem.height, ", flickable y:", flickable.y)
        }
    }
    Component.onDestruction: {
        appwindow.loading = false;
    }
}
