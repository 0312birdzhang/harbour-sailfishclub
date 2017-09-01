import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3


Python {
    id:signalcenter;
    signal loadStarted()
    signal loadFinished()
    signal loadFailed(string errorstring)

    function showMessage(msg){
        if (msg||false){
            showMsg(msg);
        }
    }

    Component.onCompleted: {
        setHandler('loadStarted', loadStarted);
        setHandler('loadFinished', loadFinished);
        setHandler('loadFailed', loadFailed);
    }
}


