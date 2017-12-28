# -*- coding: UTF-8 -*-
import os
import sys
import mock
import unittest

DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(DIR, '../../limbo/plugins'))

from enable import on_message
from enable import reinit_plugins

class EnableTest(unittest.TestCase):

    @mock.patch('enable.reinit_plugins')
    def test_basic(self, reinit_plugins_mock):
        server = 'fake_server'
        ret = on_message({"text": u"!enable help,enable"}, server)
        assert ret == "enabling plugins: help,enable"
        reinit_plugins_mock.assert_called_with(['help','enable'], server)

    @mock.patch('enable.reinit_plugins')
    def test_star(self, reinit_plugins_mock):
        server = 'fake_server'
        ret = on_message({"text": u"!enable *"}, server)
        assert ret == "enabling all plugins"
        reinit_plugins_mock.assert_called_with(None, server)
