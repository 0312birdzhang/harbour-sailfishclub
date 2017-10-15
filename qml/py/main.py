from __future__ import print_function
from pynodebb import Client
from sfctoken import access_token
import token
import pyotherside


client = Client('https://sailfishos.club', access_token)
client.configure(**{
  'page_size': 20
})


def login(user, password):
    status_code, userInfo = client.users.login(user, password)
    if not status_code:
        return False
    return userInfo


def post(title, content, uid, cid):
    status_code, response = client.topics.create(uid, cid, title, content)
    if not status_code or status_code != 200:
        return False
    return True

def getrecent():
    status_code, topics = client.topics.get_recent()
    if not status_code or status_code != 200:
        return False
    return topics


def listcategory():
    status_code, categories = client.categories.list()
    for category in categories:
        print(category["cid"], category["name"])

#pyotherside.send('loadStarted')
#pyotherside.send('loadFinished')
#pyotherside.send('loadFailed',str(e))
