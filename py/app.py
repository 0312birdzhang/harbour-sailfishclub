"""
Copyright (C) 2018-2019 Nguyen Long.
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

import os
import traceback
import urllib.parse
import json
import pprint
import sqlite3
import pyotherside
import requests
from datetime import datetime
from diskcache import Cache
import hashlib
from http.cookies import SimpleCookie
from config import DOMAIN_NAME

HARBOUR_APP_NAME = 'sailfishclub'
OrganizationName = 'harbour-sailfishclub'
HOME = os.path.expanduser('~')
XDG_DATA_HOME = os.environ.get('XDG_DATA_HOME', os.path.join(HOME, '.local', 'share'))
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME', os.path.join(HOME, '.config'))
XDG_CACHE_HOME = os.path.join('XDG_CACHE_HOME', os.path.join(HOME, '.cache'))
COOKIE_PATH = os.path.join(XDG_DATA_HOME, OrganizationName, HARBOUR_APP_NAME, '.QtWebKit', 'cookies.db')
CACHE_PATH = os.path.join(XDG_CACHE_HOME, OrganizationName, HARBOUR_APP_NAME)

class Api:
    def __init__(self):
        self.userId = 0
        self.csrf = ""
        self.base_url = f"https://{DOMAIN_NAME}"
        self.session = requests.Session()

        try:
            if not os.path.exists(CACHE_PATH):
                os.makedirs(CACHE_PATH)
            self.cache = Cache(CACHE_PATH)
        except:
            Utils.log(traceback.format_exc())
            self.cache = None

    def init_cookie(self, saved_cookie):
        if saved_cookie:
            self.session.cookies.update({
                "express.sid": saved_cookie
            })

    def get_csrf_token(self):
        headers = {
            "user-agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
        }
        res = self.session.get(f'{self.base_url}/api/config', headers = headers)
        res.raise_for_status()
        return res.json()['csrf_token']

    def login(self, username, password):
        csrf_token = self.get_csrf_token()
        print("csrf:",csrf_token)
        self.csrf = csrf_token
        payload = {
            'username': username,
            'password': password,
        }
        headers = {
            'X-CSRF-Token': csrf_token,
        }

        res = self.session.post(f'{self.base_url}/api/v3/utilities/login', data=payload, headers=headers)
        if res.json()["status"]["code"] !='ok':
            raise Exception('Login failed. Please check your credentials.')
        cookies = res.cookies
        cookies_dict = requests.utils.dict_from_cookiejar(cookies)
        jsondata = res.json()
        jsondata["cookies"] = cookies_dict.get("express.sid")
        return jsondata

    def get_recent_topics(self, limit=10):
        url = f'{self.base_url}/api/recent'
        res = self.session.get(url)
        res.raise_for_status()
        return res.json()['topics'][:limit]

    def get_topic(self, tid):
        url = f'{self.base_url}/api/topic/{tid}'
        res = self.session.get(url)
        res.raise_for_status()
        return res.json()

    def create_topic(self, cid, title, content):
        """
        需要启用插件 nodebb-plugin-write-api
        并启用 Cookie 或 Token 认证
        """
        url = f'{self.base_url}/api/v3/topics'
        payload = {
            'cid': cid,
            'title': title,
            'content': content,
        }
        headers = {
            'X-CSRF-Token': self.csrf,
        }
        res = self.session.post(url, json=payload, headers=headers)
        res.raise_for_status()
        return res.json()

    def reply_to_topic(self, tid, content, pid):
        url = f'{self.base_url}/api/v3/topics/{tid}'
        payload = {
            'content': content,
            'toPid': pid
        }
        headers = {
            'X-CSRF-Token': self.csrf,
        }
        res = self.session.post(url, json=payload, headers = headers)
        res.raise_for_status()
        return res.json()

    def get_unread():
        url = f'{self.base_url}/api/notifications'
        headers = {
            'X-CSRF-Token': self.csrf,
        }
        res = self.session.get(url, headers = headers)
        res.raise_for_status()
        return res.json()


    def get_other_param(self, username):
        """
        Get BDUSS and uid
        """
        sid, expires = self.get_session_id_from_cookie()
        Utils.log(expires)
        Utils.log(sid)
        if sid and expires:
            return {
                "sid": sid,
                "expires": expires
            }
        else:
            return None

    def get_session_id_from_cookie(self):
        """
        Try get session Id from WebKit cookies DB
        """
        conn = sqlite3.connect(COOKIE_PATH)
        cursor = conn.cursor()
        params = ('%sexpress.sid' % (DOMAIN_NAME,) ,)
        cursor.execute('SELECT * FROM cookies WHERE cookieId = ?', params)
        row = cursor.fetchone()
        expires = ""
        sid = ""
        Utils.log("start get get_session_id_from_cookie")
        if row is not None:
            cookie = SimpleCookie()
            cookievalue = row[1].decode('utf-8')
            cookie.load(cookievalue)
            for cookie_name, morsel in cookie.items():
                Utils.log(cookie_name)
                if cookie_name == 'express.sid':
                    sid = morsel.value
            for ex in cookievalue.split(";"):
                if "expires" in ex:
                    expires = ex.split("=")[-1].lstrip()
            return sid, expires
        else:
            Utils.error("not found cookies")
            return None, None

    def getMd5(self, name):
        h = hashlib.md5()
        h.update(name.encode(encoding='utf-8', errors='strict'))
        return h.hexdigest()[8:-8]

    def set_query_list_data(self, router='recent', result={}, expire=3600.00):
        """
        Set recent,popular,etc json string to cache
        """
        try:
            if type(self.cache) is Cache:
                Utils.log(self.getMd5(router))
                self.cache.set(self.getMd5(router), json.dumps(result), expire = expire)
            return True
        except:
            Utils.log(traceback.format_exc())
            return False
            # utils.error('Could not save to cache. Please try again.')

    def get_query_list_data(self, router='recent'):
        """
        Get recent,popular,etc json string in cache
        """
        if type(self.cache) is Cache:
            Utils.log(self.getMd5(router))
            try:
                cacheData = self.cache.get(self.getMd5(router))
                if cacheData:
                    return json.loads(cacheData)
            except:
                Utils.log(traceback.format_exc())
        return None

class Utils:
    def __init__(self):
        pass

    @staticmethod
    def log(str):
        """
        Print log to console
        """

        Utils.send('log', str)

    @staticmethod
    def error(str):
        """
        Send error string to QML to show on banner
        """

        Utils.send('error', str)

    @staticmethod
    def send(event, msg=None):
        """
        Send data to QML
        """

        pyotherside.send(event, msg)

api = Api()
utils = Utils()
