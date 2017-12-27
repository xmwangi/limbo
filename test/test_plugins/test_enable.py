# -*- coding: UTF-8 -*-
import os
import sys

DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(DIR, '../../limbo/plugins'))

from enable import on_message
import limbo

def test_basic():
    ret = on_message({"text": u"!enable help,enable"}, None)
    assert ret == ['reinit_plugins',
                   ['help', 'enable'],
                   "enabling plugins: help,enable"]

