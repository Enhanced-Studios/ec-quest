fx_version "cerulean"
games {"gta5"}

description "Enhanced Illegal quests"
author "Enhanced Studios"
version '1.0.0'

lua54 'yes'

ui_page 'web/build/index.html'

shared_scripts {'@ox_lib/init.lua', "shared/**/*"}
client_script "client/**/*"
server_scripts {'@oxmysql/lib/MySQL.lua', "server/**/*"}

files {'locales/*.json', 'web/build/index.html', 'web/build/**/*'}
