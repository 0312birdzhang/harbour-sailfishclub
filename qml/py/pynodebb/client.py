#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/client.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

from pynodebb.http_client import HttpClient
from pynodebb.settings import settings

from pynodebb.api.users import User
from pynodebb.api.topics import Topic
from pynodebb.api.groups import Group
from pynodebb.api.posts import Post
from pynodebb.api.categories import Category


class Client(object):
    def __init__(self, endpoint, token, admin_uid=None):
        """Instantiates the NodeBB API Client.

        Args:
            endpoint (str): An absolute url to your NodeBB instance. For example:
                `http://localhost:4567`. Note that the trailing slash is optional.
            token (str): A master token generated within your ACP.
            admin_uid (Optional[str]): When using a master token, requests require
                some form of context (which user made a request) and that context is
                based on a `_uid` field. Defaults to `HttpClient.DEFAULT_ADMIN_UID`.

        """
        self.configure(api_endpoint=endpoint, master_token=token, admin_uid=admin_uid)
        self.http_client = HttpClient()

        self.users = User(self.http_client)
        self.topics = Topic(self.http_client)
        self.posts = Post(self.http_client)
        self.groups = Group(self.http_client)
        self.categories = Category(self.http_client)

    @classmethod
    def configure(cls, force=False, **kwargs):
        """Simple wrapper which configures the `settings` dictionary.

        Note that if when configuring settings, if any values in `kwargs` are
        empty, they will not be considered. To consider overriding values with
        None, set `force=True`.

        Args:
            force (bool): Set to True to override settings even if values are None.
            **kwargs: A `dict` of overrides. See `settings.py` for all possible
                key, value pairs.

        Returns:
            dict: The newly configured settings dictionary

        """
        if not force:
            kwargs = {k: v for k, v in kwargs.items() if v}
        settings.update(kwargs)
        return settings
