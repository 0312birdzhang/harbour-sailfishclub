import QtQuick 2.0
import Sailfish.Silica 1.0
import QtDocGallery 5.0
import org.nemomobile.thumbnailer 1.0

Page {
    signal selectImage(string url,string title)

    DocumentGalleryModel {
        id: galleryModel
        rootType: DocumentGallery.Image
        properties: [ "url", "title", "dateTaken" ]
        autoUpdate: true
        sortProperties: ["-dateTaken"]
    }


    // Gridview with Sailfish Silica specific
    SilicaGridView {
        id: grid
        header: PageHeader { title: qsTr("Select an image") }
        cellWidth: width / 3
        cellHeight: width / 3
        anchors.fill: parent
        model: galleryModel

        // Sailfish Silica PulleyMenu on top of the grid
        PullDownMenu {
            MenuItem {
                text: qsTr("Latest first")
                onClicked: galleryModel.sortProperties = [ "-dateTaken" ]
            }
            MenuItem {
                text: qsTr("Oldest first")
                onClicked: galleryModel.sortProperties = [ "dateTaken" ]
            }
        }

        delegate: Image {
            asynchronous: true

            // From org.nemomobile.thumbnailer
            source:  "image://nemoThumbnail/" + url

            sourceSize.width: grid.cellWidth
            sourceSize.height: grid.cellHeight

            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    console.log("path:"+url+",title:"+galleryModel.get(index).title)
                    selectImage(url,galleryModel.get(index).title);
                }
            }
        }
        ScrollDecorator {}
    }
}
