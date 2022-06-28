.pragma library
Qt.include("ApiCore.js")
//Qt.include("ApiCategory.js")
//Qt.include("Storge.js")
var signalcenter;
var siteUrl;


var userAgent = "Mozilla/5.0 (Mobile Linux; U; like Android 4.4.3; Sailfish OS/2.0) AppleWebkit/535.19 (KHTML, like Gecko) Version/4.0 Mobile Safari/535.19";

function setsignalcenter(mycenter){
    signalcenter=mycenter;
}
function sendWebRequest(url, callback, method, postdata, headers, otherparams) {
    var xmlhttp = new XMLHttpRequest();

    xmlhttp.onreadystatechange = function() {
        switch(xmlhttp.readyState) {
        case xmlhttp.OPENED:signalcenter.loadStarted();break;
        case xmlhttp.HEADERS_RECEIVED:if (xmlhttp.status !== 200 && xmlhttp.status !== 400 ){
            signalcenter.loadFailed(qsTr("connect error,code:")+ xmlhttp.status+"  "+xmlhttp.statusText);
            break;
        }
        case xmlhttp.DONE:if (xmlhttp.status === 200 || xmlhttp.status === 400) {
                try {
                    if(otherparams){
                        callback(xmlhttp.responseText, otherparams);
                    }else{
                        callback(xmlhttp.responseText);
                    }
                    signalcenter.loadFinished();
                } catch(e) {
                    console.log("callback error:", e)
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
        xmlhttp.timeout = 15000;
        if(headers){
            // xmlhttp.withCredentials = true;
            for(var i in headers){
                xmlhttp.setRequestHeader(i, headers[i]);
            }
        }
        xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xmlhttp.setRequestHeader("User-Agent", userAgent);
        xmlhttp.send();
    }
    if(method==="POST") {
        xmlhttp.open("POST",url);
        xmlhttp.timeout = 15000;
        if(headers){
            for(var i in headers){
                xmlhttp.setRequestHeader(i, headers[i]);
            }
        }
        xmlhttp.setRequestHeader("User-Agent", userAgent);
        xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xmlhttp.setRequestHeader("Content-Length", postdata.length);
        xmlhttp.send(postdata);
    }
    if(method==="DELETE"){
        xmlhttp.open("DELETE",url);
        xmlhttp.timeout = 5000;
        if(headers){
            for(var i in headers){
                xmlhttp.setRequestHeader(i, headers[i]);
            }
        }
        xmlhttp.setRequestHeader("User-Agent", userAgent);
        xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xmlhttp.setRequestHeader("Content-Length", postdata.length);
        xmlhttp.send(postdata);
    }
}


function parseParams(postdata){
    var paramArray = [];
    for (var i in postdata){
        paramArray.push(i+"="+encodeURIComponent(postdata[i]));
    }
    paramArray = paramArray.sort();
    var result = paramArray.join("&");
    return result;
}

function setAuthorization(token){
    if(token){
        return {
            "Authorization": "Bearer "+ token
        }
    }else{
        return {}
    }
}

function setTwofactor(code){
    if(code){
        return {
            "x-two-factor-authentication": code
        }
    }else{
        return {}
    }
}


// https://github.com/NodeBB/nodebb-plugin-write-api/blob/master/routes/v2/readme.md

function getRecent(slug, token, uid){
    var url = siteUrl + '/api/recent?' + slug //( slug?(slug + (uid?("&_uid="+uid):"")): (tid + (uid?("?_uid="+uid):"") ) );
    console.log(url)
    sendWebRequest(url,loadRecnetList, "GET","", "");
}

function loadRecnetList(oritxt){
    if(oritxt)signalcenter.getRecent(JSON.parse(oritxt));
}

function getTopic(tid, slug, token, uid){
    var url = siteUrl + '/api/topic/' + (slug?slug:tid);
    console.log(url)
    sendWebRequest(url,loadTopicDetail,"GET","","");
}

function loadTopicDetail(oritxt){
    if(oritxt)signalcenter.getTopic(JSON.parse(oritxt));
}

function getPopular(slug){
    var url = siteUrl + '/api/popular?' +slug
    sendWebRequest(url,loadPopularList,"GET","");
}
function loadPopularList(oritxt){
    // Yes, reuse getRecent signal
    if(oritxt)signalcenter.getRecent(JSON.parse(oritxt));
}

function listcategory(){
    var url = siteUrl + '/api/categories';
    sendWebRequest(url,loadCategories,"GET","");
}
function loadCategories(oritxt){
    if(oritxt)signalcenter.getCategories(JSON.parse(oritxt));
}

function search(term, slug, token){
    var url = siteUrl + '/api/search?term=' + term + '&in=titlesposts&'+slug;
    sendWebRequest(url,loadSearch,"GET","", setAuthorization(token));
}
function loadSearch(oritxt){
    if(oritxt)signalcenter.getSearch(JSON.parse(oritxt));
}

function getNotifications(token){
    var url = siteUrl + '/api/notifications';
    sendWebRequest(url,loadNotifications,"GET","", setAuthorization(token));
}
function loadNotifications(oritxt){
    if(oritxt)signalcenter.getUnread(JSON.parse(oritxt));
}
function getUnread(token){
    var url = siteUrl + '/api/unread'
    sendWebRequest(url,loadNotifications,"GET","", setAuthorization(token));
}

// topic
function createTopic(uid, cid, title, content, token){
    var url = siteUrl + '/api/v3/topics/';
    var postdata = {
        '_uid': uid, 
        'cid': cid, 
        'title': title, 
        'content': content
    }
    sendWebRequest(url,sendCreateTopic,"POST", parseParams(postdata), setAuthorization(token));
}
function sendCreateTopic(oritxt){
    console.log(oritxt)
    if(oritxt)signalcenter.newTopic(JSON.parse(oritxt));
}


function replayTopic(tid, uid, content, token){
    console.log("cookie", token)
    var url = siteUrl + '/api/v3/topics/'+tid;
    console.log(url)
    var postdata = {
        "tid": tid,
        "content": content,
        "_uid": uid
    }

    sendWebRequest(url,sendReplayTopic,"POST", parseParams(postdata), setAuthorization(token));
}
function sendReplayTopic(oritxt){
//    console.log(oritxt)
    if(oritxt)signalcenter.replayTopic(JSON.parse(oritxt));
}

function replayTo(tid, uid, toPid, content, token){
    var url = siteUrl + '/api/v3/topics/' + tid;
    var postdata = {
        "content": content,
        "_uid": uid,
        "toPid": toPid
    }
    sendWebRequest(url,sendReplayFloor,"POST", parseParams(postdata), setAuthorization(token));
}
function sendReplayFloor(oritxt){
    // console.log(oritxt)
    if(oritxt)signalcenter.replayFloor(JSON.parse(oritxt));
}


function getuserinfo(username, is_username, token, uid){
    // var url = siteUrl + ('/api/user/email/%s' if "@" in str(id_) else '/api/user/%s' if is_username else '/api/user/uid/%s');
    var uri = "";
    if(is_username){
        if(username.indexOf("@")>0){
            uri = '/api/user/email/' + username
        }else{
            uri = '/api/user/' + username
        }
    }else{
        uri = '/api/user/uid/' + username;
    }
    var url = siteUrl + uri; // + "?_uid=" + uid;
    sendWebRequest(url,loadUserInfo,"GET", "", "");
}
function loadUserInfo(oritxt){
    if(oritxt)signalcenter.getUserInfo(JSON.parse(oritxt));
}

function login(username, password, twofacode){
    // get user uid
    // create token
    var url = siteUrl + "/api/user/"+username;
    if(username.indexOf("@") > -1){
        url = siteUrl + "/api/user/email/"+username;
    }
    var otherparams ={
        "password": password,
        "twofacode": twofacode
    }
    sendWebRequest(url, loadLogin,"GET", "","", otherparams);
}
function loadLogin(oritxt, otherparams){
    if(oritxt){
        var password = otherparams.password;
        var twofacode = otherparams.twofacode;
        var uid = JSON.parse(oritxt).uid;
        getUserToken(uid, password, twofacode, oritxt);
    }else{
        console.log(password)
        //signalcenter.loginFailed();
    }
}


function getUserToken(uid, password, twofacode, oritxt){
    var url = siteUrl + "/api/v3/users/"+uid+"/tokens";
    var postdata = {
        "password": password
    }
    console.log("start get user token")
    sendWebRequest(url, loadUserToken, "POST", parseParams(postdata), setTwofactor(twofacode), oritxt);
}
function loadUserToken(oritxt, userinfostr){
    if(oritxt){
        var result = JSON.parse(oritxt);
        if(result.code !== "ok"){
            if(result.code === "2fa-enabled"){
                // x-two-factor-authentication header
                signalcenter.loginTwofactor();
                return;
            }else{
                signalcenter.loginFailed(JSON.parse(oritxt).message);
                return;
            }
        }
        var token = result.payload.token;
        var userinfo = JSON.parse(userinfostr);
        var ret = {
            "token": token, 
            "uid": userinfo.uid, 
            "username": userinfo.username, 
            "avatar": userinfo.avatar||""
        }
        signalcenter.loadUserToken(ret);
    }else{
        //signalcenter.loginFailed();
    }
}

function delUserToken(uid, token){
    var url = siteUrl + "/api/v3/users/"+ uid + "/tokens/"+ token;
    sendWebRequest(url, loadDelToken, "DELETE", "", setAuthorization(token));
}
function loadDelToken(oritxt){
    console.log(oritxt);
}

/**
    GET /:uid/tokens
    Retrieves a list of active tokens for that user
    Accepts: No parameters
 */
function validate(uid, token){
    var url = siteUrl + "/api/v3/users/" + uid + "/tokens";
    sendWebRequest(url, loadValidate, "GET", "", setAuthorization(token), token);
}
function loadValidate(oritxt, token){
    if(oritxt){
        var result = JSON.parse(oritxt);
        if(result.code == "ok"){
            var tokenArray = result.payload.tokens;
            for(var i in tokenArray){
                if(tokenArray[i] == token){
                    signalcenter.validateSuccess();
                    return;
                }
            }
            signalcenter.validateFailed();
        }else{
            signalcenter.validateFailed();
        }
    }
}