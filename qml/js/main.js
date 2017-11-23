.pragma library

var py;
// login function
function login(uid, token, username, password){
    if(uid && token){
        py.validate(uid, token)
    }else{
        py.login(username, password)
    }
}

