import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT

Column {
    property alias isActive: body.activeFocus
    property string _editId
    property string replayUser: ""
    property string _replyToId
    readonly property bool _hasText: body.text.trim()

    signal sendButtonClicked();

    function reply(cid, name, text) {
        _editId = ""
        _replyToId = cid
        body.text = ""
        body.forceActiveFocus()
        _setTypeLabel(qsTrId("orn-reply-to").arg(name), text)
    }

    function edit(cid, text) {
        _editId = cid
        _replyToId = ""
        body.text = text
        body.forceActiveFocus()
        //% "Edit your comment"
        _setTypeLabel(qsTrId("orn-comment-edit-label"), text)
        body.cursorPosition = body.text.length
    }

    function _setTypeLabel(title, preview) {
        // OpenRepos returns comments in paragraph tags so it goes to the next line
        typeLabel.text = "<font color='%0'>%1</font><font color='%2'>%3</font>"
            .arg(Theme.secondaryColor).arg(title).arg(Theme.highlightColor).arg(preview)
    }

    function _reset() {
        _editId = ""
        _replyToId = ""
        body.text = ""
        typeLabel.text = ""
        body.focus = false
    }

    width: parent.width
    spacing: Theme.paddingSmall

    Item {
        id: typeItem
        visible: false
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        height: _editId || _replyToId ?
                    Math.max(typeIcon.height, typeLabel.height, cancelButton.height) : 0

        Behavior on height { NumberAnimation { } }

        Image {
            id: typeIcon
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            source: {
                if (_editId) {
                    return "image://theme/icon-m-edit?" + Theme.highlightColor
                }
                if (_replyToId) {
                    return "image://theme/icon-m-rotate-left?" + Theme.highlightColor
                }
                return ""
            }
        }

        Label {
            id: typeLabel
            anchors {
                left: typeIcon.right
                right: cancelButton.left
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        IconButton {
            id: cancelButton
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            visible: parent.height
            icon.source: "image://theme/icon-m-dismiss?" +
                  (pressed ? Theme.highlightColor : Theme.primaryColor)
            onClicked: _reset()
        }
    }

    Item {
        id: spacer
        height: Theme.paddingMedium
        width: parent.width
    }

    Flickable {
        id: tagsPanel
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        height: tagsRow.height + Theme.paddingMedium
        contentWidth: tagsRow.width
        clip: true
        opacity: body.activeFocus ? 1.0 : 0.0
        visible: opacity > 0.0

        Behavior on opacity { NumberAnimation { } }

        Row {
            id: tagsRow
            spacing: Theme.paddingSmall

            HtmlTagButton {

                text: "<b>B</b>"
                tag: "**"
                attrs: tag
            }

            HtmlTagButton {

                text: "<i>I</i>"
                tag: "*"
                attrs: tag
            }

           HtmlTagButton {

               text: "<b>H</b>"
               tag: "### "
               attrs: '    '
           }

            HtmlTagButton {
                text: "<s>S</s>"
                tag: "~~"
                attrs: tag
            }

            HtmlTagButton {
                text: '<font face="monospace">‹›</font>'
                tag: "```\n"
                attrs: tag
            }

           HtmlTagButton {
               text: '🙶'
               tag: ">"
               attrs: '  '
           }

           HtmlTagButton {
               text: FONT.Icon.fa_picture_o
               tag: ""
               MouseArea{
                   anchors.fill: parent
                   onClicked: {
                       console.log("open image select dialog")
                       pageStack.push(selectImageComponent);
                   }
                   onPressedChanged: if (pressed) pressTimer.start()
                   onCanceled: pressTimer.stop()
                   Timer {
                       id: pressTimer
                       interval: Theme.minimumPressHighlightTime
                   }
               }
           }

           HtmlTagButton {
               text: FONT.Icon.fa_list_ol
               tag: "- "
               attrs: '\n '
           }


        }
    }


        TextArea {
            id: body
            width: parent.width - Theme.horizontalPageMargin
            label: qsTr("Your comment")
            placeholderText: label
            font.pixelSize: Theme.fontSizeSmall
            focusOutBehavior: FocusBehavior.KeepFocus
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: parent.focus = true
            text: replayUser + (appwindow.topicdraft?appwindow.topicdraft:"")
            Component.onCompleted: {
                _editor.textFormat = TextEdit.PlainText
                body.focus = true
              }
        }
    Row{
        spacing: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        Button{
            id: sendButton
            text: qsTr("send")
//            text: {
//                if (opacity < 1.0) {
//                    return ""
//                }
//                if (_editId) {
//                    return qsTr("update")
//                }
//                if (_replyToId) {
//                    return qsTr("reply")
//                }
//                return qsTr("send")
//            }
//            anchors.horizontalCenter: parent.horizontalCenter
            opacity: (body.text && body.text.length > 2)?1:0.3
            Behavior on opacity { FadeAnimation { } }
            enabled: opacity == 1
            onClicked: {
                sendButtonClicked();
                if (_editId) {
                    // OrnClient.editComment(_editId, body.text)
                } else if (_replyToId) {
                    // OrnClient.comment(appId, body.text, _replyToId)
                } else {
                    // OrnClient.comment(appId, body.text)
                }
            }

        }
        Button{
            id: previewButton
            text: qsTr("preview")
            opacity: (body.text && body.text.length > 2)?1:0.3
            enabled: opacity == 1
            Behavior on opacity { FadeAnimation { } }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/PreviewPage.qml"), {"mdtext":body.text});
            }
        }
    }

    Component{
        id:selectImageComponent
        ImagePreviewGrid{
            onSelectImage: {
                remorse.execute(qsTr("Start upload image..."),function(){
                    py.uploadImage(url,desc);
                    pageStack.pop();
                },3000);
            }
        }
    }

    Connections{
        target: signalCenter
        onUploadImage:{
            if(!result){
                notification.showPopup(
                        qsTr("Error"),
                        qsTr("Image upload failed"),
                        "image://theme/icon-lock-warning"
                        );
            }else{
                var editor = body._editor;
                var mdurl = "\n![%0](%1)".arg(desc).arg(result)
                editor.insert(editor.cursorPosition,mdurl);
            }
        }
    }
}
