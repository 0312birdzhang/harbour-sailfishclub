.pragma library
Qt.include("ApiCore.js")
//Qt.include("ApiCategory.js")
//Qt.include("Storge.js")
var signalcenter;
function setsignalcenter(mycenter){
    signalcenter=mycenter;
}
function sendWebRequest(url, callback, method, postdata) {
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
        switch(xmlhttp.readyState) {
        case xmlhttp.OPENED:signalcenter.loadStarted();break;
        case xmlhttp.HEADERS_RECEIVED:if (xmlhttp.status != 200)signalcenter.loadFailed(qsTr("connect error,code:")+xmlhttp.status+"  "+xmlhttp.statusText);break;
        case xmlhttp.DONE:if (xmlhttp.status == 200) {
                try {
                    callback(xmlhttp.responseText);
                    signalcenter.loadFinished();
                } catch(e) {
                    console.log(e)
                    signalcenter.loadFailed(qsTr("loading erro..."));
                }
            } else {
                signalcenter.loadFailed("");
            }
            break;
        }
    }
    if(method==="GET") {
        xmlhttp.open("GET",url);
        xmlhttp.send();
    }
    if(method==="POST") {
        xmlhttp.open("POST",url);
        xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xmlhttp.setRequestHeader("Content-Length", postdata.length);
        xmlhttp.send(postdata);
    }
}

//浏览器auth认证
var webviewUrl = oauth2_authorize+"?response_type=code&client_id="+api_id+"&redirect_uri="+api_redirect+"&state=sfc"

console.log(api_url+"?client_id="+api_id+"&grant_type=authorization_code&client_secret="+api_securet+"&redirect_uri="+api_redirect+"&code=");
var application;
//登录二次认证
function reqToken(code){
    var params = "client_id="+api_id+"&grant_type=authorization_code&client_secret="+api_securet+"&redirect_uri="+api_redirect+"&code="+code;
    console.log("ReqToken:"+params);
    sendWebRequest(api_url,getToken,"POST",params);
}
function getToken(oritxt){
    console.log("json:"+oritxt)
    var obj=JSON.parse(oritxt);
    if(obj.error){
        signalcenter.loadFailed(obj.error_description);
    }else{
        var access_token = obj.access_token;
        var refresh_token = obj.refresh_token;
        var token_type = obj.token_type;
        var expires_in = obj.expires_in;
        var uid = obj.uid;

//        application.access_token = access_token;
//        application.refresh_token = refresh_token;
//        application.token_type = token_type;
//        application.expires_in = expires_in;
//        application.uid = uid;

        var userData = {
            "access_token":access_token,
            "refresh_token":refresh_token,
            "token_type":token_type,
            "expires_in":expires_in,
            "uid":uid,
            "savetime":parseInt(new Date().getTime()/1000)
        }
        signalcenter.loginSuccessed();
        getCurrentUser();
        application.saveAuthData(JSON.stringify(userData))
    }


}

function getCurrentUser(){
    var url = api_url + openapi_user + "?access_token="+application.access_token + "&dataType=json";
    sendWebRequest(url,loadCurrentUser,"GET","");
}
function loadCurrentUser(oritxt){
    var obj=JSON.parse(oritxt);
    if(obj.error){
        signalcenter.loadFailed(obj.error_description);
        signalcenter.toLoginpage();
    }else{
        application.user._id = obj.id;
        application.user.email = obj.email;
        application.user.name = obj.name;
        application.user.gender = obj.gender;
        application.user.avatar = obj.avatar;
        application.user.location = obj.location;
        application.user.url = obj.url;
        console.log("avatar:"+obj.avatar)
        signalcenter.toIndexpage();
    }
}

