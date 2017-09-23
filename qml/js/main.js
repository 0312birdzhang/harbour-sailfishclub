.import QtQuick.LocalStorage 2.0 as SQL//数据库连接模块

function getDatabase() {
    return SQL.LocalStorage.openDatabaseSync("db", "1.0", "sailfishos club", 10000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS LoginData(user text,pass text);');
                });

}

var val={};
function getUserData(){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('select * from LoginData;');
        //console.log(rs.rowsAffected)
        if (rs.rows.length > 0) {
            val.user = rs.rows.item(0).user;
            val.pass = rs.rows.item(0).pass;
        } else {

        }
    });

    return val;
}

function setUserData(user,pass){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO LoginData VALUES (?,?);', [user,pass]);
        console.log(rs.rowsAffected)
        if (rs.rowsAffected > 0) {
            console.log("Saved!");
        } else {
            console.log("Failed!");
        }
    }
    );
}

function clearValue(){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('delete from LoginData;');
        console.log(rs.rowsAffected)
        if (rs.rowsAffected > 0) {
            console.log("Deleted!");
        } else {
            console.log("Failed!");
        }
    }
    );
}
