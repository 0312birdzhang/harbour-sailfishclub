from __future__ import print_function
from pynodebb import Client
import pyotherside
from sfctoken import access_token
import logging

client = Client('https://sailfishos.club', access_token)

def initClient(page_size):
    client.configure(**{
        'page_size': page_size
    })


def login(user, password):
    """{'lastonlineISO': '2017-10-19T01:16:54.375Z', 'birthday': '', 'email': '0312birdzhang@gmail.com', 'postcount': '99', 'icon:bgColor': '#1b5e20', 'uid': '2', 'signature': '———扬帆起航🚢', 'lastonline': '1508375814375', 'followerCount': '2', 'groupTitle': 'administrators', 'fullname': '', 'lastposttime': '1508242534975', 'username': 'BirdZhang', 'topiccount': '35', 'cover:position': '50.13333511352539% 63.46666717529297%', 'icon:text': 'B', 'picture': '/assets/uploads/profile/2-profileavatar.jpeg', 'joindate': '1492905871911', 'passwordExpiry': '0', 'email:confirmed': 1, 'userslug': 'birdzhang', 'aboutme': '没错，我就是站长😂', 'location': '', 'profileviews': '299', 'reputation': '1', 'website': 'http://birdzhang.xyz', 'githubid': '1762041', 'joindateISO': '2017-04-23T00:04:31.911Z', 'uploadedpicture': '/assets/uploads/profile/2-profileavatar.jpeg', 'status': 'offline', 'banned': '0'}
    """
    status_code, userInfo = client.users.login(user, password)
    logging.debug(status_code)
    logging.debug(userInfo)
    if not status_code or status_code != 200:
        return False
    return userInfo

def create(user,password,email):
    status_code, userInfo = client.users.create(user,**{
        "password":password,
        "email":email
    })
    if not status_code or status_code != 200:
        return False
    else:
        uid = userInfo.get("uid")
        return uid
    return True

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

def getrecent():
    status_code, topics = client.topics.get_recent()
    if not status_code or status_code != 200:
        return False
    return topics

def getpopular():
    status_code, topics = client.topics.get_popular()
    logging.debug(str(status_code))
    if not status_code or status_code != 200:
        return False
    logging.debug(str(topics))
    return topics

def listcategory():
    status_code, categories = client.categories.list()
    if not status_code or status_code != 200:
        return False
    return categories

def getTopic(tid,slug):
    status_code, topic = client.topics.get(tid,slug=slug)
    if not status_code or status_code != 200:
        return False
    return topic



def uploadImgSm(file):
    import requests
    import sys
    url = 'https://sm.ms/api/upload'
    try:
        files = {'smfile' : open(file, 'rb')}
        r = requests.post(url, files = files)
        data1 = eval(r.text.encode('utf-8'))
        smurl = data1['data']['url']
        print(smurl)
        return smurl
    except Exception as e:
        print(str(e))
        return None


def previewMd(text):
    import mistune
    return mistune.markdown(text)