"""!enable <plugins> enables the specified plugins and disables the rest
!enable `*` enables all available plugins
"""
# Note: This plugin implements a couple of antipatterns to be discussed
# in MIT 6.S188.

import re

def on_message(msg, server):
    text = msg.get("text", "")
    match = re.findall(r"!enable( .*)?", text)
    if not match:
        return

    plugins = match[0].strip()
    if plugins == '*':
        plugins_to_load = None # load all plugins
    else:
        plugins_to_load = plugins.replace(' ', ',').replace(';',',').split(',')
    return ['reinit_plugins',
            plugins_to_load,
            "enabling plugins: {0}".format(plugins)]

on_bot_message = on_message
