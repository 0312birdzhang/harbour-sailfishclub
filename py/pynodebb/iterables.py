#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/iterables.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals
from __future__ import division

from copy import deepcopy
from math import ceil

from pynodebb import constants
from pynodebb.settings import settings
from pynodebb.exceptions import InvalidPage


class ResourceIterable(object):
    def __init__(self, client, resource_list):
        self.client = client
        self.resource_list = resource_list

    def __iter__(self):
        return self

    def __len__(self):
        """Returns the total number of resources in the iterable."""
        return int(self.resource_list.get(self.resource_count_id, 0))

    def __str__(self):
        if not len(self):
            return '<Page 0 of 0>'
        return '<Page %d of %d>' % (self.current_page, self.num_pages)

    @property
    def url_path(self):
        raise NotImplementedError

    @property
    def resource_id(self):
        raise NotImplementedError

    @property
    def resource_count_id(self):
        raise NotImplementedError

    @property
    def resource_type(self):
        raise NotImplementedError

    @property
    def current_page(self):
        return self.resource_list['currentPage']

    @property
    def num_pages(self):
        return int(ceil(len(self) / settings['page_size']))

    @property
    def has_next(self):
        return self.current_page < self.num_pages

    @property
    def has_previous(self):
        return self.current_page > 1

    @property
    def resources(self):
        return self.resource_list[self.resource_id]

    @property
    def raw(self):
        return self.resource_list

    def next(self):
        """Retrieves the `next` resource in the provided `resource_list`.

        `ResourceIterable` and all subclasses has support for pagination. That is,
        when `next` reaches the end of the resource list, a synchronous request
        is made to your NodeBB instance, asking for the next page.

        When there are no more remaining pages, the iterator stops and raises
        a `StopIteration` exception. Otherwise, the next page is fetched.

        """
        resource_id = self.resource_id
        resources = self.resource_list.get(resource_id)

        # No more items left in the current page, try fetching more.
        if not resources:
            pagination = self.resource_list.get('pagination')

            # No pagination or we're at the end of the list.
            if pagination is None:
                raise StopIteration
            if not pagination['next']['active']:
                raise StopIteration

            # Build the next page url to make a request against.
            next_qs = pagination['next']['qs']
            url_path = self.url_path + '?' + next_qs

            status_code, response = self.client.get(url_path)
            if status_code != 200:
                raise StopIteration

            self.resource_list = response
            resources = self.resource_list.get(resource_id, [])

        # Double check for emptiness (in case we get 0 items in the next page).
        if not resources:
            raise StopIteration
        return resources.pop(0)

    def page(self, page_number):
        """
        Given a `page_number`, retrieve and create a new iterable, setting the
        start position to be `page_number`.

        There are a few things you need to note when using `self.page`:

        1. If the `page_number` is equal to the current page is returned
        2. The returned copy will always be an deepcopy (not a reference)
        3. Invoking `page(0)` and `page(1)` will result in the same page

        Args:
            page_number (int): The page number we want to begin at

        Raises:
            InvalidPage: Raised when the specified `page_number` is invalid

        Returns:
            ResourceIterable: An instance (deepcopy) of ResourceIterable
                containing the associated `resource_list`.

        """
        # Sanity check to make sure the `page_number` makes sense.
        try:
            page_number = int(page_number)
            if page_number < 0:
                raise InvalidPage()
            if page_number > self.num_pages:
                raise InvalidPage()
        except ValueError:
            raise InvalidPage()

        # We're trying to get the current page, return `self`.
        if str(self.current_page) == str(page_number):
            return deepcopy(self)

        # Fetch the page at `page_number` then return cloned `self`.
        url_path = self.url_path + '?page=%s' % page_number
        status_code, response = self.client.get(url_path)
        if status_code != 200:
            raise InvalidPage()

        # Clone, update `resource_list` and return the deepcopy.
        cloned_iterable = deepcopy(self)
        cloned_iterable.resource_list = response
        return cloned_iterable


class TopicIterable(ResourceIterable):
    @property
    def url_path(self):
        return '/api/category/%s' % self.resource_list['slug']

    @property
    def resource_id(self):
        return 'topics'

    @property
    def resource_count_id(self):
        return 'topic_count'

    @property
    def resource_type(self):
        return constants.TOPIC


class PostIterable(ResourceIterable):
    @property
    def url_path(self):
        return '/api/post/%s' % self.resource_list['slug']

    @property
    def resource_id(self):
        return 'posts'

    @property
    def resource_count_id(self):
        return 'postcount'  # wtf nodebb?

    @property
    def resource_type(self):
        return constants.POST
