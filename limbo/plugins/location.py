"""!location returns city and country of the hosting server."""
import re
import requests

def location():
  response = requests.get("http://freegeoip.net/json").json()
  print(response)
  return response['ip'] + ' (' + response['city'] + ', ' + response['country_name'] + ')'

def on_message(msg, server):
    text = msg.get("text", "")
    match = re.findall(r"!location( .*)?", text)
    if not match:
        return

    return location()

on_bot_message = on_message
