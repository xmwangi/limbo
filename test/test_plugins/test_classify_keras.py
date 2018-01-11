# -*- coding: UTF-8 -*-
import json
import os
import sys

import limbo
import vcr

DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(DIR, '../../limbo/plugins'))

from classify_keras import on_message
from classify_keras import on_init

FOX_IMAGE_URL='http://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Vulpes_vulpes_laying_in_snow.jpg/280px-Vulpes_vulpes_laying_in_snow.jpg'
CAT_IMAGE_URL='http://r.ddmcdn.com/s_f/o_1/cx_462/cy_245/cw_1349/ch_1349/w_720/APL/uploads/2015/06/caturday-shutterstock_149320799.jpg'

def msgobj(msg, attachments=[]):
    if attachments:
      return {
          "text": msg,
          "channel": "abc123",
          "attachments" : attachments
      }
    else:
      return {
          "text": msg,
          "channel": "abc123"
      }
    
def test_inline_link():
  server = limbo.FakeServer()
  on_init(server)
  with vcr.use_cassette('test/fixtures/classify_keras.yaml'):
    msg = msgobj(u"Hello {} world".format(FOX_IMAGE_URL))
    ret = on_message(msg, server)
    assert 'fox' in ret

def test_attachment():
  server = limbo.FakeServer()
  on_init(server)
  with vcr.use_cassette('test/fixtures/classify_keras.yaml'):
    msg = msgobj(u"Hello world", attachments=[{"title_link" : FOX_IMAGE_URL}])
    ret = on_message(msg, server)
    assert 'fox' in ret

def text_attachment_priority():
  server = limbo.FakeServer()
  on_init(server)
  with vcr.use_cassette('test/fixtures/classify_keras.yaml'):
    msg = msgobj(u"Hello {} world".format(CAT_IMAGE_URL), attachments=[{"title_link" : FOX_IMAGE_URL}])
    ret = on_message(msg, server)
    assert 'fox' in ret
