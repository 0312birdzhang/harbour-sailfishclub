.pragma library
Qt.include("ApiCore.js")
//Qt.include("ApiCategory.js")
//Qt.include("Storge.js")
var signalcenter;
var siteUrl;




function setsignalcenter(mycenter){
    signalcenter=mycenter;
}
function sendWebRequest(url, callback, method, postdata, token) {
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
        if(token){
            xmlhttp.setRequestHeader("Authorization", "Bearer "+ token);
        }
        xmlhttp.send();
    }
    if(method==="POST") {
        xmlhttp.open("POST",url);
        if(token){
            xmlhttp.setRequestHeader("Authorization", "Bearer "+ token);
        }
        xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xmlhttp.setRequestHeader("Content-Length", postdata.length);
        xmlhttp.send(postdata);
    }
}

function getRecent(slug){
    var url = siteUrl + '/api/recent?' +slug
    sendWebRequest(url,loadRecnetList,"GET","");
}

function loadRecnetList(oritxt){
    signalcenter.getRecent(JSON.parse(oritxt));
}

function getTopic(tid, slug, token){
    var url = siteUrl + '/api/topic/' + (slug?slug:tid);
    sendWebRequest(url,loadTopicDetail,"GET","",token);
}

function loadTopicDetail(oritxt){
    signalcenter.getTopic(JSON.parse(oritxt));
}

function getPopular(slug){
    var url = siteUrl + '/api/popular?' +slug
    sendWebRequest(url,loadPopularList,"GET","");
}
function loadPopularList(oritxt){
    // Yes, reuse getRecent signal
    signalcenter.getRecent(JSON.parse(oritxt));
}

function listcategory(){
    var url = siteUrl + '/api/categories';
    sendWebRequest(url,loadCategories,"GET","");
}
function loadCategories(oritxt){
    signalcenter.getCategories(JSON.parse(oritxt));
}

function search(term, slug, token){
    var url = siteUrl + '/api/search?term=' + term + '&in=titlesposts&'+slug;
    sendWebRequest(url,loadSearch,"GET","", token);
}
function loadSearch(oritxt){
    signalcenter.getSearch(JSON.parse(oritxt));
}

function getNotifications(token){
    var url = siteUrl + '/api/notifications';
    sendWebRequest(url,loadNotifications,"GET","", token);
}
function loadNotifications(oritxt){
    signalcenter.getUnread(JSON.parse(oritxt));
}
function getUnread(token){
    var url = siteUrl + '/api/unread'
    sendWebRequest(url,loadNotifications,"GET","", token);
}

// topic
function createTopic(uid, cid, title, content, token){
    var url = siteUrl + '/api/v1/topics/';
    var postdata = {
        '_uid': uid, 
        'cid': cid, 
        'title': title, 
        'content': content,
    }
    sendWebRequest(url,sendCreateTopic,"POST", postdata, token);
}
function sendCreateTopic(oritxt){
    signalcenter.newTopic(JSON.parse(oritxt));
}


function replayTopic(tid, uid, content, token){
    var url = siteUrl + '/api/v1/topics/'+tid;
    var postdata = {
        "content": content,
        "_uid": uid
    }
    sendWebRequest(url,sendReplayTopic,"POST", postdata, token);
}
function sendReplayTopic(oritxt){
    signalcenter.replayTopic(JSON.parse(oritxt));
}

function replayTo(tid, uid, toPid, content, token){
    var url = siteUrl + '/api/v1/topics/' + tid;
    var postdata = {
        "content": content,
        "_uid": uid,
        "toPid": toPid
    }
    sendWebRequest(url,sendReplayFloor,"POST", postdata, token);
}
function sendReplayFloor(oritxt){
    signalcenter.replayFloor(JSON.parse(oritxt));
}


function getuserinfo(username, is_username){
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
    var url = siteUrl + uri;
    sendWebRequest(url,loadUserInfo,"GET", "","");
}
function loadUserInfo(oritxt){
    signalcenter.getUserInfo(JSON.parse(oritxt));
}

function validatePwd(user, password){
    var url = siteUrl + '/login'
    var postdata = {
        "username": user,
        "password": password,
        "remember": "on",
        "noscript": false
    }
    sendWebRequest(url,getValidate,"POST", postdata,"");
}
function getValidate(oritxt){

}



function login(user, password){

}