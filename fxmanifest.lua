fx_version 'cerulean'
game 'gta5'

this_is_a_map 'yes'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua',
}

shared_scripts {
	'config.lua',
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/job.lua',
	'client/client.lua'
}

files {
    'html/index.html',
	'html/carousel.css',
	'html/design.css',
	'html/script.js',		
	'html/pickr.es5.min.js',	
	'html/picker.js',	
	'html/jquery-ui.js',
	'html/jqueri-ui.css',
	'html/nano.min.css',	
    'html/images/*.png',
    'imgs/*.png',
}

ui_page 'html/index.html'