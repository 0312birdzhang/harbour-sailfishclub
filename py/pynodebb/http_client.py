#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""pynodebb/http_client.py
Copyright (c) 2015 David Vuong <david.vuong256@gmail.com>
Licensed MIT
"""
from __future__ import unicode_literals

import requests
from urllib.parse import urlparse
from urllib.parse import urljoin

from pynodebb.settings import settings


class HttpClient(object):
    def __init__(self):
        self.endpoint = settings['api_endpoint']
        self.admin_uid = settings['admin_uid']
        self.headers = {'Authorization': 'Bearer %s' % settings['master_token'],
            "User-Agent": "SailfishOS Python APi Client v1.1"
        }
        self.cookies = dict()

    def _request(self, method, path, **kwargs):
        """Simple wrapper over `requests.request`.
        Formats the request headers, payload and endpoint and returns the
        response status_code and response.json in a tuple.
        Args:
            method (str): The HTTP method we want to make a request with.
            path (str): The "path" section of the URI e.g. `/api/users/5/`.
            **kwargs: The request payload (request body).
        Returns:
            tuple: A tuple in the form (response_code, response_json)
        """
        if '_uid' not in kwargs:
            kwargs.update({'_uid': self.admin_uid})

        # `_uid` is None, there's nothing we can do at this point.
        if kwargs['_uid'] is None:
            return 404, 'Not Found'

        if '_token' in kwargs:
            self.headers['Authorization'] = 'Bearer %s' % kwargs['_token']
            kwargs.pop("_token", None)

        if '_cookies' in kwargs:
            self.cookies = {
                'express.sid': kwargs['_cookies']
            }
            kwargs.pop("_cookies", None)

        # Query the NodeBB instance, extracting the status code and fail reason.
        response = requests.request(
            method, urljoin(self.endpoint, path),
            headers=self.headers, data=kwargs, 
            cookies=self.cookies,
            timeout = 20
        )
        code, reason = response.status_code, response.reason

        if response.reason != 'OK':  # Not a success response.
            return code, reason

        # ValueError occurs when `.json()` reads invalid JSON.
        try:
            json_response = response.json()
            if 'payload' in json_response:
                json_response = json_response['payload']
            return code, json_response
        except ValueError:
            return code, {}

    def get(self, path, **kwargs):
        return self._request('GET', path, **kwargs)

    def post(self, path, **kwargs):
        return self._request('POST', path, **kwargs)

    def put(self, path, **kwargs):
        return self._request('PUT', path, **kwargs)

    def delete(self, path, **kwargs):
        return self._request('DELETE', path, **kwargs)
