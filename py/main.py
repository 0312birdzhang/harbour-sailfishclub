from __future__ import print_function
from pynodebb import Client
import pyotherside
from sfctoken import access_token
import logging
import sys
import requests

logger = logging.getLogger("sfcpython")
formatter = logging.Formatter('%(asctime)s %(levelname)-8s: %(message)s')
console_handler = logging.StreamHandler(sys.stdout)
console_handler.formatter = formatter
logger.addHandler(console_handler)
logger.setLevel(logging.DEBUG)

client = Client('https://sailfishos.club', access_token)
client.configure(**{
    'page_size': 20
})


# def login(user, password):
#     status_code, userInfo = client.users.login(user, password)
#     if not status_code or status_code != 200:
#         return False
#     return userInfo

def login(user, password):
    userinfo = getuserinfo(user, False if "@" in user else True) #Thanks fishegg find this bug
    if not userinfo:
        return False
    uid = userinfo.get("uid")
    if not uid:
        return False
    token = createToken(uid, password)
    if not token:
        return False
    logger.debug(token)
    userinfo["token"] = token
    return userinfo
    
def logout(uid, token):
    status_code, response = client.users.remove_token(uid, token)
    if not status_code or status_code != 200:
        return False
    return True


def validate(uid, token):
    """validate user token
    """
    status_code, tokens = client.users.get_tokens(uid)
    if not status_code or status_code != 200:
        return False
    if token not in tokens.get("tokens"):
        return False
    else:
        return getuserinfo(uid,False)

def createToken(uid, password):
    status_code, playload = client.users.grant_token(uid, password)
    if not status_code or status_code != 200:
        return False
    return playload.get("token")

def getuserinfo(user,is_username = True):
    status_code, userinfo = client.users.get(user, is_username)
    if not status_code or status_code != 200:
        return False
    return userinfo

def createUser(user,password,email):
    logger.debug("start register");
    status_code, userInfo = client.users.create(user,**{
        "password":password,
        "email":email
    })
    if not status_code or status_code != 200:
        return False
    else:
        return userInfo

def post(title, content, uid, cid):
    status_code, response = client.topics.create(uid, cid, title, content)
    if not status_code or status_code != 200:
        return False
    return response

def replay(tid,uid,content):
    status_code, response = client.posts.create(uid,tid,content)
    if not status_code or status_code != 200:
        return False
    return response

def replayTo(tid, uid, toPid, content):
    status_code, response = client.topics.post(tid, uid, toPid, content)
    if not status_code or status_code != 200:
        return False
    return response

def getrecent(slug):
    status_code, topics = client.topics.get_recent(slug=slug)
    if not status_code or status_code != 200:
        return False
    return topics

def getpopular(slug):
    status_code, topics = client.topics.get_popular(slug=slug)
    if not status_code or status_code != 200:
        return False
    return topics

def listcategory():
    status_code, categories = client.categories.list()
    if not status_code or status_code != 200:
        return False
    return categories

def getTopic(tid, slug, token = access_token ):
    status_code, topic = client.topics.get(tid, slug=slug, **{"_token" : token})
    if not status_code or status_code != 200:
        return False
    return topic



def uploadImgSm(path):
    if path.startswith("file:"):
        path = path.replace("file://","")
    url = 'https://sm.ms/api/upload'
    try:
        files = {'smfile' : open(path.encode("utf-8"), 'rb')}
        r = requests.post(url, files = files, timeout=5000)
        data1 = eval(r.text.encode('utf-8'))
        smurl = data1['data']['url']
        logger.info(smurl)
        return smurl
    except Exception as e:
        uploadVimCN(path)
        return None

def uploadVimCN(file):
    url = 'http://img.vim-cn.com/'
    try:
        files = {'file' : open(file.encode("utf-8"), 'rb')}
        r = requests.post(url, files = files, timeout=5000)
        return r.text
    except Exception as e:
        
        logger.error(str(e))
        return None

def previewMd(text):
    import mistune
    return mistune.markdown(text)



def image_provider(image_id, requested_size):
    
    return None


# pyotherside.set_image_provider(image_provider)
