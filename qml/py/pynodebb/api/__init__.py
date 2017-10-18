#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/api/__init__.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals


class Resource(object):
    def __init__(self, client):
        self.client = client

    def _get_resource_slug(self, resource_path, id_):
        """Internal method to retrieve the `resource_type` slug.

        This is necessary due to NodeBB's inconsistent API. As of writing this,
        NodeBB has 2 ways to retrieve data for resources.

        >>> import requests
        >>> # Method 1 (returns complete object however a "slug" is required.
        >>> requests.get('/api/resource/:id/:slug')
        >>> # Method 2 (returns partial resource, no slug required).
        >>> requests.get('/api/resource/id/:id')

        Sometimes the 2nd method is enough so the slug isn't required however,
        most of the time it is. Times where it is absolutely necessary are times
        when you want to get nested resources e.g. all topics for a particular
        category. The 2nd method won't return the topics.

        So this leaves us with the 1st method. The only problem is that we may
        not know what the resource slug is (most of the time, we don't).

        This method is a way to retrieve the slug, given the `resource_path`
        and resource `id_`. Here's a usage example:

        >>> resource = Resource(None)
        >>> # Example 1 (retrieving the category slug for a category).
        >>> slug_1 = resource._get_resource_slug('categories/cid', 1)
        >>> # Example 2 (retrieving the slug for a topic).
        >>> slug_2 = resource._get_resource_slug('topics/tid', 1)

        Note: To make matters worse, the `slug` field returned by their API
        is a combination of a resource id and the slug. For example:

        >>> cid, slug_in_db = 1, 'the-title-of-my-category'
        >>> returned_slug = '1/title-of-my-category'

        Args:
            resource_path (str): The partial URL path
            id_ (int): The id of the resource we want to get the slug for

        Returns:
            str: The resource slug if one was successfully found

        """
        endpoint = '/api/%s/%s' % (resource_path, id_)
        status_code, resource = self.client.get(endpoint)
        return resource.get('slug') if status_code == 200 else None

    def _get_and_validate_slug(self, slug, resource_path, id_):
        if slug is None:
            slug = self._get_resource_slug(resource_path, id_)
        if slug is None:
            return False, None
        return True, slug
