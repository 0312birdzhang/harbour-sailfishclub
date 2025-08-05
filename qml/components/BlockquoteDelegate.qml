import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    id: blockquote
    spacing: 8
    width: parent.width

    property alias text: quoteText.text

    Rectangle {
        width: 4
        height: quoteText.implicitHeight
        color: Theme.darkSecondaryColor
        radius: 2
    }

    Text {
        id: quoteText
        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        font.pixelSize: 15
        font.italic: true
        color: "#666"
        width: parent.width - 16
    }
}
