import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Dialog {
    id: dialog

    readonly property bool registerSucced: _registerSucceed
    property bool _registerSucceed: false
    property bool _canAccept: false
    property bool _showRegisterView: true

    onAccepted: toWelcomePage();
    //只有当登陆成功的时候才能accept
    canAccept: _canAccept
    BusyIndicator {
        id: busyIndicator
        parent: dialog
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: !_showRegisterView
        opacity: busyIndicator.running ? 1 : 0
    }


    Timer {
        id: timer
        interval: 300
        onTriggered: {
            _canAccept = true;
            _loginSucceed = true;
            dialog.accept();
        }
    }

    RegisterComponent {
        id:loginView
        anchors.fill: parent
        opacity: _showRegisterView ? 1 : 0
        onRegisterSucceed: {
            _canAccept = true;
            _registerSucceed = true;
            dialog.accept();
        }
    }
}
