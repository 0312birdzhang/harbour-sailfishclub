import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/fontawesome.js" as FONT
import "../components"

Page{
    id: notificationPage

    ListModel{
        id: notificationsModel
    }

    Connections{
        target: signalCenter
        onGetNotifications:{
            if (result && result != "Forbidden"){
                var nos = result.notifications;
                for(var i = 0; i < nos.length; i++){
                    var path = nos[i].path;
                    var from = nos[i].from;
                    var pid = nos[i].pid;
                    var datetime = nos[i].datetime;
                    var tid = nos[i].tid;
                    var bodyLong = nos[i].bodyLong;
                    var user = nos[i].user.username;
                    var avatar = nos[i].user.picture;
                    ListModel.append({
                                "path": path,
                                "from": from,
                                "pid": pid,
                                "datetime": datetime,
                                "tid": tid,
                                "bodyLong": bodyLong,
                                "user": user,
                                "avatar": avatar
                            });

                }
                if(nos && _showReplayNotification /*&& !nos[0].read*/){
                    replaiesNotification.body = nos[0].bodyLong;
                    replaiesNotification.publish();
                }

            }
        }
    }


    components.onCompleted:{
        py.getNotifications();
    }
}
