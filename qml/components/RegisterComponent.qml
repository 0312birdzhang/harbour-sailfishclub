import QtQuick 2.0
import Sailfish.Silica 1.0
//import "../js/main.js" as Script

Item {
    id:registerComponent
    signal registerSucceed()
    signal registerFailed(string fail)
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge * 5

        VerticalScrollDecorator {}

        BusyIndicator {
            id:busyIndicator
            parent: registerComponent
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }
            PageHeader {
                id:header
                title: qsTr("Create Account")
            }
            spacing: Theme.paddingMedium
            TextField {
                id: email
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Email address");
                focus: true;
                inputMethodHints:Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly | Qt.ImhNoPredictiveText
                validator: RegExpValidator { regExp:/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
                placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: nickname.focus = true
            }
            // TextField {
            //     id: firstname
            //     anchors { left: parent.left; right: parent.right }
            //     focus: true;
            //     label: qsTr("User Name");
            //     placeholderText: label
            //     RegExpValidator { regExp: /.{2,14}/ }
            //     inputMethodHints:Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
            //     EnterKey.enabled: text || inputMethodComposing
            //     EnterKey.iconSource: "image://theme/icon-m-enter-next"
            //     EnterKey.onClicked: nickname.focus = true
            // }
            TextField {
                id: nickname
                anchors { left: parent.left; right: parent.right }
                focus: true;
                label: qsTr("User Name");
                placeholderText: label
                validator: RegExpValidator { regExp: /.{2,16}/ }
                //echoMode: TextInput.text
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
            }


            TextField {
                id: password
                anchors { left: parent.left; right: parent.right }
                echoMode: TextInput.Password
                label: qsTr("Password");
                placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: confirmPassword.focus = true
            }

            TextField {
                id: confirmPassword
                anchors { left: parent.left; right: parent.right }
                echoMode: TextInput.Password; enabled: password.text || text
                errorHighlight: password.text != text
                label: qsTr("Confirm Password")
                placeholderText: label; opacity: enabled ? 1 : 0.5
                Behavior on opacity { FadeAnimation { } }
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.highlighted: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                   confirmPassword.focus = false;
                }

            }

        }


        Button{
            id:registerButton
            anchors{
                top:column.bottom
                horizontalCenter: parent.horizontalCenter
            }
            text:qsTr("Register")
            enabled: email.text && password.text && confirmPassword.text &&
                     password.text == confirmPassword.text
            onClicked: {
                errorLabel.visible = false;
                registerButton.enabled = false;
                busyIndicator.running = true;
                py.register(nickname.text,password.text,email.text);

            }
        }
        Label {
            id:errorLabel
            anchors{
                top:column.bottom
                topMargin: Theme.paddingLarge * 4
                horizontalCenter: parent.horizontalCenter
            }
            width: column.width
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        Connections {
            target: signalCenter
            onRegisterSucceed: {
                errorLabel.visible = false;
                busyIndicator.running = false;
                registerComponent.registerSucceed();
            }
            onRegisterFailed: {
                busyIndicator.running = false;
                errorLabel.visible = true;
                registerButton.enabled = true;
                errorLabel.text = qsTr("Register fail")+" [ "+fail+" ]. " + qsTr("Please try again.");
            }
        }
    }


}
