"""
!classify listens for linked images and returns the predicted labels
"""
from keras.applications.resnet50 import ResNet50
from keras.preprocessing import image
from keras.applications.resnet50 import preprocess_input, decode_predictions
import numpy as np

import re
from urlextract import URLExtract
import tempfile
import requests

def on_init(server):
  server.model = ResNet50(weights='imagenet')

def classify_image(img_path, server):
  img = image.load_img(img_path, target_size=(224, 224))
  x = image.img_to_array(img)
  x = np.expand_dims(x, axis=0)
  x = preprocess_input(x)
  
  preds = server.model.predict(x)
  return decode_predictions(preds, top=1)[0]

def classify_url(url, server):
  try:
    r = requests.get(url, allow_redirects=True)
    if not r.ok:
      return None
    else:
      tmp = tempfile.NamedTemporaryFile(mode='wb')
      tmp.write(r.content)
      preds = classify_image(tmp.name, server)
      return preds
  except requests.exceptions.RequestException as e:
    # Log error
    return None 

def get_url(msg):
  # Should ideally check if link is image using mimetype
  if 'attachments' in msg:
    url = msg['attachments'][0].get("title_link", "")
    return url

  extractor = URLExtract()
  text = msg.get("text", "")
  urls = extractor.find_urls(text)
  if not urls:
    return
  url = urls[0]
  return url

def on_message(msg, server):
    url = get_url(msg)
    if url:
      pred = classify_url(url, server)
      if pred:
        return "Detected image of: {}".format(pred[0][1])
      else:
        return "Unable to classify image"

on_bot_message = on_message
