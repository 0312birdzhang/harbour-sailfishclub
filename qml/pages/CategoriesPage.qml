import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/fontawesome.js" as FONT

Page{
    id: page
    property alias contentItem:column
    allowedOrientations:Orientation.All

    Column{
        id: column
        z: -2
        width: page.width
        height: page.height
        SilicaListView {
            id: listView
            header: PageHeader{
                title: qsTr("Categories")
            }
            width: parent.width
            height: parent.height

            delegate: Item {

            }

            ViewPlaceholder{
                enabled: true
                text: qsTr("Not completed yeat")
                hintText: qsTr("Comming soon...")
            }
        }
    }
}
