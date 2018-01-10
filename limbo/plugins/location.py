"""!location returns the location of the server."""
import re
import requests

def location():
  return requests.get("http://freegeoip.net/json").json()['city']

def on_message(msg, server):
    text = msg.get("text", "")
    match = re.findall(r"!location( .*)?", text)
    if not match:
        return

    return location()

on_bot_message = on_message
