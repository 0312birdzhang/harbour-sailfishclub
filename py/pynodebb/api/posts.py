#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/api/posts.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

from pynodebb.api import Resource
from pynodebb.api.mixins import ResourceListMixin
from pynodebb.iterables import PostIterable


class Post(Resource,
           ResourceListMixin):

    resource_type = 'post'
    resource_path = 'post/pid'
    parent_resource = 'topic'
    parent_resource_path = 'topic/tid'
    resource_iterable = PostIterable

    def create(self, uid, tid, content):
        """Given the `tid` (topic id) and the `content` of a new post, create a post.

        Args:
            uid (str, int): The user id of the post author.
            tid (str, int): The id of the topic we want to create a post for.
            content (str): The post description/content. Please refer to your
                ACL to determine the minimum content length.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self.client.post('/api/v1/topics/%s' % tid, _uid=uid, content=content)
