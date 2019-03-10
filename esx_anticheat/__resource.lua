--[[
	Bundled from:
		HG-Anticheat: https://github.com/HackerGeo-sp1ne/HG_AntiCheat
		FiveM-BanSql: https://github.com/RedAlex/FiveM-BanSql

]]

description 'AntiCheat'

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
    'anticheat-cl.lua'
}
server_scripts {
	'@es_extended/locale.lua',
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/en.lua',
	'config.lua',
    'anticheat-sv.lua'
}

dependencies {
	'essentialmode',
	'async'
}
