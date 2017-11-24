#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/api/mixins.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals


class ResourceListMixin(object):
    def list(self, id_, slug=None, start_page=None):
        """Retrieves a list of resources given the parent resource `id_`.

        Note that due to NodeBB's API, in order to retrieve resources for a
        given parent, we *need* the parent's `slug` along with its `id_`.

        For example, in order to retrieve all topics for a particular category,
        we need the category slug and category id. If the resource `slug` isn't
        supplied, a separate request is made to to retrieve the slug.

        The success tuple contains an iterable:

        >>> from pynodebb import Client
        >>> client = Client('http://localhost:4567', 'master_token')
        >>> status_code, topics = client.topics.list(5)
        >>> for topic in topics:
        ...     print(topic['title'])

        NodeBB provides a way to paginate resources. By default resources are
        paginated by 20 items per page. This can be changed in your NodeBB
        instance's ACP (Admin control panel).

        When `list` has reached the end of the page, it will fetch for the next
        page if one is present.

        Args:
            id_ (int): The id of the parent resource we want to list
                sub-resources for.
            slug (Optional[str]): The resource slug. Defaults to None meaning
                a separate requests is made to fetch the slug.
            start_page (Optional[int]): The page we want the iterable to start at.
                Defaults to the first page if nothing is provided.

        Returns:
            tuple: A tuple in the form (response_code, ResourceIterable)

        """
        is_200, slug = self._get_and_validate_slug(slug,
                                                   self.parent_resource_path,
                                                   id_)
        if not is_200:
            return 404, 'Not Found'

        # The slug returned by NodeBB contains the `id_` (:id_/:slug).
        url_path = '/api/%s/%s' % (self.parent_resource, slug)

        # Start at `page` if one was provided.
        if start_page is not None:
            url_path += '?page=%s' % start_page

        status_code, resources = self.client.get(url_path)
        if status_code == 200:
            resources = self.resource_iterable(self.client, resources)
        return status_code, resources


class ResourceRetrieveMixin(object):
    def get(self, id_, slug=None, **kwargs):
        """Retrieves the resource given the `id_` and (optional) `slug`.

        Args:
            id_ (int): The id of the resource we are trying to retrieve.
            slug (Optional[str]): The resource slug. If a slug isn't provided,
                `.get` will attempt to retrieve the slug for you

        Returns:
            tuple: A tuple in the form (response_code, ResourceIterable)

        """
        is_200, slug = self._get_and_validate_slug(slug, self.resource_path, id_)
        if not is_200:
            return 404, 'Not Found'

        # The slug returned by NodeBB contains the `id_` (:id_/:slug).
        url_path = '/api/%s/%s' % (self.resource_type, slug)
        return self.client.get(url_path, **kwargs)
