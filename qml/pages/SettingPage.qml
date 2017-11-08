import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfishclub.settings 1.0

Page{
    id:page

    SilicaFlickable {
        id: settings
        anchors.fill: parent
        contentHeight: aboutRectangle.height

        VerticalScrollDecorator { flickable: about }

        Column {
            id: aboutRectangle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("PageSize")
            }

            Slider {
                id:slider
                value:settings.get_pagesize()
                minimumValue:10
                maximumValue:50
                stepSize: 5
                width: parent.width
                valueText: value
                label: qsTr("Every page size")
            }
        }


        Component.onDestoryed: {
            settings.set_pagesize(slider.value);
        }

    }

    
}
