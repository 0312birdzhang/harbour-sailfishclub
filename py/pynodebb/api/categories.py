#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/api/categories.py

Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

from pynodebb.api import Resource


class Category(Resource):
    def create(self, cid, name, **kwargs):
        raise NotImplementedError

    def update(self, cid, **kwargs):
        raise NotImplementedError

    def get(self, cid):
        raise NotImplementedError

    def get_partial(self, cid):
        """Retrieves the partial category given the category `cid`.

        Note that this is partial due to the fact that NodeBB doesn't return
        topics unless the requesting URL contains the category slug which we may
        not always have.

        Args:
            cid (int, str): The NodeBB category id

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        return self.client.get('/api/category/cid/' + cid)

    def list(self):
        """Retrieves a list of categories.

        Note that categories are *not* paginated (as of now) simply because in
        most cases, even in NodeBB, there aren't many categories.

        Returns:
            tuple: Tuple in the form (response_code, json_response)

        """
        status_code, response_body = self.client.get('/api/categories')
        if status_code != 200:
            return status_code, response_body
        # return status_code, response_body.get('categories', [])
        return status_code, response_body
