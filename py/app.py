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
import re
import sqlite3
import pprint
import pyotherside
import requests
import markdown
import timeago
from http.cookies import SimpleCookie
from datetime import datetime, timezone, timedelta
from bs4 import BeautifulSoup
from diskcache import Cache

#DOMAIN_NAME = 'forums.ubports.com'
DOMAIN_NAME = 'sailfishos.club'
BASE_URL = 'https://%s' % (DOMAIN_NAME, )
TIMEZONE = timezone(timedelta(hours=2), 'Europe/Helsinki')
HARBOUR_APP_NAME = 'harbour-weblogin-demo'
HOME = os.path.expanduser('~')
XDG_DATA_HOME = os.environ.get('XDG_DATA_HOME', os.path.join(HOME, '.local', 'share'))
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME', os.path.join(HOME, '.config'))
XDG_CACHE_HOME = os.path.join('XDG_CACHE_HOME', os.path.join(HOME, '.cache'))
COOKIE_PATH = os.path.join(XDG_DATA_HOME, HARBOUR_APP_NAME, HARBOUR_APP_NAME, '.QtWebKit', 'cookies.db')
CACHE_PATH = os.path.join(XDG_CACHE_HOME, HARBOUR_APP_NAME, HARBOUR_APP_NAME)

class Api:
    def __init__(self):
        self.userId = 0
        try:
            if not os.path.exists(CACHE_PATH):
                os.makedirs(CACHE_PATH)
            self.cache = Cache(CACHE_PATH)
        except:
            Utils.log(traceback.format_exc())
            self.cache = None

    def get_other_param(self, username):
        """
        Get BDUSS and uid
        """
        bduss = self.get_session_id_from_cookie()
        uid, avatarUrl = self.get_user_id_from_username(username)
        user = {}
        if bduss and uid:
            user['uid'] = uid
            user['bduss'] = bduss
            user['username'] = username
            user['avatarUrl'] = avatarUrl
            self.set_logged_in_user(user)
            return {
                "bduss": bduss,
                "uid": uid,
                "avatar": avatarUrl
            }
        else:
            return None


    def get_session_id_from_cookie(self):
        """
        Try get session Id from WebKit cookies DB
        """

        conn = sqlite3.connect(COOKIE_PATH)
        cursor = conn.cursor()
        params = ('%sexpress.sid' % (DOMAIN_NAME, ),)
        cursor.execute('SELECT * FROM cookies WHERE cookieId = ?', params)
        row = cursor.fetchone()
        if row is not None:
            cookie = SimpleCookie()
            cookie.load(row[1].decode('utf-8'))
            for cookie_name, morsel in cookie.items():
                if cookie_name == 'express.sid':
                    return morsel.value
    
    def get_user_id_from_username(self, username):
        Utils.log(username)
        """
        Get user_id from username
        """
        user_home_url = "%s/api/user/%s" % (BASE_URL, username )
        try:
            r = requests.get(user_home_url, timeout = 10)
            user_info = r.json()
            uid = user_info.get("uid")
            avatarUrl = user_info.get("cover:url")
            if not avatarUrl.startswith("http"):
                avatarUrl = "%s%s" % (BASE_URL, avatarUrl)
            return uid, avatarUrl
        except:
            Utils.log(traceback.format_exc())
            utils.error('Could not login. Please try again.')

    def set_logged_in_user(self, user={}):
        """
        Set logged in user to cache
        """
        try:
            if type(self.cache) is Cache:
                if 'uid' in user:
                    self.cache.set('user.uid', user['uid'])
                if 'username' in user:
                    self.cache.set('user.username', user['username'])
                if 'avatarUrl' in user:
                    self.cache.set('user.avatarUrl', user['avatarUrl'])
                if 'bduss' in user:
                    self.cache.set('user.bduss', user['bduss'])
                return True
            else:
                raise Exception('Could not save data.')
        except:
            Utils.log(traceback.format_exc())
            utils.error('Could not login. Please try again.')

    def get_logged_in_user(self):
        """
        Get logged in user from cache
        """

        if type(self.cache) is Cache:
            userId = self.cache.get('user.uid')
            if userId:
                self.userId = userId
                user = {}
                user['uid'] = userId
                user['username'] = self.cache.get('user.username')
                user['bduss'] = self.cache.get('user.bduss')
                user['avatarUrl'] = self.cache.get('user.avatarUrl')
                return user

    def do_logout(self):
        """
        Logout by clear cookie
        """

        self.sessionId = ''
        self.userId = 0

        # Clear WebKit cookies DB
        if os.path.exists(COOKIE_PATH):
            os.remove(COOKIE_PATH)

        # Clear cache
        if type(self.cache) is Cache:
            self.cache.clear()

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
