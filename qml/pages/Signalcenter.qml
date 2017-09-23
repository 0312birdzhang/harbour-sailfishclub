import QtQuick 2.0
import Sailfish.Silica 1.0
//import io.thp.pyotherside 1.3

QtObject{
    id:signalcenter;
    signal loadStarted;
    signal loadFinished;
    signal loadFailed(string errorstring);
    signal loginSucceed;
    signal loginFailed(string fail);
    signal registerSucceed;
    signal registerFailed(string fail);

    function showMessage(msg){
        if (msg||false){
            showMsg(msg);
        }
    }


//    Python {
//        Component.onCompleted: {
//            setHandler('loadStarted', loadStarted);
//            setHandler('loadFinished', loadFinished);
//            setHandler('loadFailed', loadFailed);
//        }

//    }
}




