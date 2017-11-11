import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/fontawesome.js" as FONT

Page{
    id: page
    property alias contentItem:listView
    SilicaListView {
        id: listView
        header: PageHeader{
            title: qsTr("Categories")
        }

        anchors.fill: parent
        delegate: Item {

        }

        ViewPlaceholder{
            enabled: true
            text: qsTr("Not completed yeat")
            hintText: qsTr("Comming soon...")
        }
    }
}
