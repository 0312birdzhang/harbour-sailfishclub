#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/api/topics.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

from pynodebb.api import Resource
from pynodebb.api.mixins import ResourceListMixin
from pynodebb.api.mixins import ResourceRetrieveMixin
from pynodebb.iterables import TopicIterable


class Topic(Resource,
            ResourceListMixin,
            ResourceRetrieveMixin):

    resource_type = 'topic'
    resource_path = 'topic/tid'
    parent_resource = 'category'
    parent_resource_path = 'category/cid'
    resource_iterable = TopicIterable

    DAILY = 'daily'
    WEEKLY = 'weekly'
    MONTHLY = 'monthly'
    ALL_TIME = 'alltime'

    POPULAR_TIME_INTERVALS = (
        DAILY, WEEKLY, MONTHLY, ALL_TIME,
    )
    DEFAULT_POPULAR_INTERVAL = ALL_TIME

    def create(self, uid, cid, title, content):
        """Creates a new topic under a category given the category `cid`.

        Args:
            uid (str, int): The user id of the topic author.
            cid (str, int): The category id we want to create the new topic under.
            title (str): The title of the new topic. Please refer to your ACL settings
                for the minimum title length.
            content (str): The topic description/content. Please refer to your
                ACL to determine the minimum content length.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self.client.post('/api/v1/topics/', **{
            '_uid': uid, 'cid': cid, 'title': title, 'content': content,
        })

    def delete(self, tid):
        raise NotImplementedError

    def post(self, tid, content):
        raise NotImplementedError

    def tag(self, tid, tags):
        raise NotImplementedError

    def untag(self, tid):
        raise NotImplementedError

    def _extract_topics(self, response):
        status_code, response_body = response
        if status_code != 200:
            return status_code, response_body
        return status_code, response_body.get('topics', [])

    def get_recent(self):
        """Fetches the first set of recent topics.

        Note that recent topics are sorted in descending order. The most recent
        topics will be at the beginning of the list.

        When there aren't any recent topics, an empty array list is returned
        in place of the `json_response`.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self._extract_topics(self.client.get('/api/recent'))

    def get_popular(self, interval=DEFAULT_POPULAR_INTERVAL):
        """Fetches popular topics given the popularity time `interval`.

        Args:
            interval (Optional[str]): The popularity time interval. When no interval
                is provided, defaults to `self.DEFAULT_POPULAR_INTERVAL`. To find
                what other time intervals are available, see `self.POPULAR_TIME_INTERVALS`.

        Raises:
            ValueError: When the `interval` isn't a valid popular topic time interval.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        if interval not in self.POPULAR_TIME_INTERVALS:
            raise ValueError('Invalid topic type: %s' % interval)
        return self._extract_topics(self.client.get('/api/popular/' + interval))
