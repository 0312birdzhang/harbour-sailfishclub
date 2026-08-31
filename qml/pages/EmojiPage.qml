import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: emojiPage
    allowedOrientations: Orientation.Portrait

    function cpToChar(cp) {
        var parts = cp.split("-")
        var s = ""
        for (var i = 0; i < parts.length; i++) {
            var code = parseInt(parts[i], 16)
            if (code > 0xFFFF) {
                // surrogate pair for codepoints > 0xFFFF
                code -= 0x10000
                s += String.fromCharCode(0xD800 + (code >> 10)) + String.fromCharCode(0xDC00 + (code & 0x3FF))
            } else {
                s += String.fromCharCode(code)
            }
        }
        return s
    }

    ListModel { id: customModel }
    ListModel { id: standardModel }

    Component {
        id: emojiDelegate
        Item {
            width: Screen.width / 7
            height: Screen.width / 7

            Image {
                anchors.centerIn: parent
                width: parent.width * 0.6
                height: parent.height * 0.6
                fillMode: Image.PreserveAspectFit
                source: model.source
                visible: model.source !== ""
            }

            Label {
                anchors.centerIn: parent
                text: model.code
                font.pixelSize: Theme.fontSizeExtraLarge
                visible: model.source === ""
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    signalCenter.emojiSelected(model.code)
                    pageStack.pop()
                }
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Emoji") }

            SectionHeader { text: qsTr("Custom emoji") }

            Grid {
                columns: 7
                width: parent.width
                Repeater {
                    model: customModel
                    delegate: emojiDelegate
                }
            }

            SectionHeader { text: qsTr("Standard emoji") }

            Grid {
                columns: 7
                width: parent.width
                Repeater {
                    model: standardModel
                    delegate: emojiDelegate
                }
            }
        }
    }

    Component.onCompleted: {
        // custom emoji from gfx/custom_emojis, filename is the emoji code
        var custom = ["doge", "erha", "huaji", "mobai", "penle", "tanshou", "weiqu", "yinxian", "yunbei"]
        for (var i = 0; i < custom.length; i++) {
            var ext = custom[i] === "mobai" ? ".gif" : ".png"
            customModel.append({
                "code": ":" + custom[i] + ":",
                "source": "../gfx/custom_emojis/" + custom[i] + ext
            })
        }
        // standard emoji: twemoji assets (qml/js/emoji/<codepoint>.svg)
        var std = [
            // smileys
            "1f600","1f601","1f602","1f603","1f604","1f605","1f606","1f607","1f608","1f609",
            "1f60a","1f60b","1f60c","1f60d","1f60e","1f60f","1f610","1f611","1f612","1f613",
            "1f614","1f615","1f616","1f617","1f618","1f619","1f61a","1f61b","1f61c","1f61d",
            "1f61e","1f61f","1f620","1f621","1f622","1f623","1f624","1f625","1f626","1f627",
            "1f628","1f629","1f62a","1f62b","1f62c","1f62d","1f62e","1f62f","1f630","1f631",
            "1f632","1f633","1f634","1f635","1f636","1f637","1f638","1f639","1f63a","1f63b",
            "1f63c","1f63d","1f63e","1f63f","1f640","1f641","1f642","1f643","1f644","1f910",
            "1f911","1f912","1f913","1f914","1f915","1f916","1f917","1f918","1f919","1f91a",
            "1f91b","1f91c","1f91d","1f91e","1f91f",
            // hands
            "1f44b","1f44c","1f44d","1f44e","1f44f","1f450","1f4aa","1f64b","1f64c","1f64d",
            "1f64e","1f64f",
            // hearts & symbols
            "2764","1f493","1f494","1f495","1f496","1f497","1f498","1f499","1f49a","1f49b",
            "1f49c","1f49d","1f49e","1f49f","2728","2b50","1f31f","1f4af","1f4a4","1f4a9",
            // nature
            "26a1","2600","2744","1f308","1f319","1f31e","1f331","1f338","1f339","1f33a",
            "1f33b","1f340","1f343",
            // food
            "1f34e","1f34f","1f349","1f347","1f34a","1f34c","1f34d","1f351","1f352","1f353",
            "2615","1f37a","1f37b","1f378","1f374","1f382",
            // activity
            "1f525","1f389","1f38a","1f381","1f680","1f697","1f6b2","1f3b5","1f3b6","1f3a7",
            "1f3ac","1f4f7","1f4f1","1f4bb","1f3a8","1f3c0","1f3c8","26bd","1f3be"
        ]
        for (var j = 0; j < std.length; j++) {
            var cp = std[j]
            standardModel.append({
                "code": cpToChar(cp),
                "source": "../js/emoji/" + cp + ".svg"
            })
        }
    }
}