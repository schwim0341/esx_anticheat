ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Text               = {}
local lastduree          = ""
local lasttarget         = ""
local BanList            = {}
local BanListLoad        = false
local BanListHistory     = {}
local BanListHistoryLoad = false

--[[ AC COMMAND TO TOGGLE ANTICHEAT ]]--
RegisterCommand("ac", function(thePlayer, args, rawCommand)
	TriggerClientEvent('AntiCheat:Toggle', -1, 1)
end)

--[[ CHECK USER FOR ADMIN OR WHITELIST ]]--
RegisterServerEvent('Anticheat:Whitelist')
AddEventHandler('Anticheat:Whitelist', function(playerId)
	local _source = source
	local deets = getIdentity(playerId)
	if deets.group == 'admin' or deets.group == 'superadmin' or inArray(deets.identifier, Config.whitelist) then
		TriggerClientEvent('Anticheat:WLReturn', _source, true)
	end
end)

--[[ BLACKLISTED CARS - KICK AND BAN ]]--
RegisterServerEvent('AntiCheat:Cars')
AddEventHandler('AntiCheat:Cars', function(blacklistedCar)
	local blcar = blacklistedCar
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)    
	print("[AntiCheat] | " ..xPlayer.name.. "["..xPlayer.identifier.. "] ".._U('was_dropped_blcars'))
	TriggerClientEvent('chatMessage', -1, '^3[AntiCheat]', {255, 0, 0}, "^3" ..xPlayer.name.. "^1 ".._U('was_dropped_blcars'))
	--DropPlayer(source, _U('drop_player_blcars_notification')..Config.Discord)
	bandata = {}
	bandata.reason = _U('drop_player_blcars_notification', blcar)..Config.Discord -- drop/ban reason
	bandata.period = '0' -- days, 0 for permanent
	TriggerEvent('Anticheat:AutoBan', _source, bandata)
end)

--[[ SUPERJUMP - KICK AND BAN ]]--
RegisterServerEvent('AntiCheat:Jump')
AddEventHandler('AntiCheat:Jump', function()
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)  
	print("[AntiCheat] | " ..xPlayer.name.. "[" ..xPlayer.identifier.. "] ".._U('was_dropped_superjump'))
	TriggerClientEvent('chatMessage', -1, '^3[AntiCheat]', {255, 0, 0}, "^3" ..xPlayer.name.. "^1 ".._U('was_dropped_superjump'))
	--DropPlayer(source, _U('drop_player_superjump_notification')..Config.Discord)
	bandata = {}
	bandata.reason = _U('drop_player_superjump_notification')..Config.Discord -- drop/ban reason
	bandata.period = '0' -- days, 0 for permanent
	TriggerEvent('Anticheat:AutoBan', _source, bandata)
end)

RegisterServerEvent('Anticheat:AutoBan')
AddEventHandler('Anticheat:AutoBan', function(source, args)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)  
	--print('Source: ',ESX.DumpTable(_source))
	--print('Arguments: ',ESX.DumpTable(args))
	--print ('period: '..args.period)
	--print ('reason: '..args.reason)
	local identifier
	local license
	local liveid    = ""
	local xblid     = ""
	local discord   = ""
	local playerip
	local duree = tonumber(args.period)
	local reason = args.reason
	local targetplayername = xPlayer.name
	local sourceplayername = 'autobanned'
		
	if reason == "" then
		reason = _U('no_reason')
	end
	
	for k,v in ipairs(GetPlayerIdentifiers(_source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			identifier = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			liveid = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			xblid  = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			discord = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			playerip = v
		end
	end
	if duree > 0 then
		local permanent = 0
		ban(_source,identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
		DropPlayer(_source, reason)
	else
		local permanent = 1
		ban(_source,identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
		DropPlayer(_source, reason)
	end
end)



TriggerEvent('es:addGroupCommand', 'banreload', Config.permission, function (source)
  BanListLoad        = false
  BanListHistoryLoad = false
  Wait(5000)
  if BanListLoad == true then
	TriggerEvent('bansql:sendMessage', source, _U('banlist_loaded'))
	if BanListHistoryLoad == true then
		TriggerEvent('bansql:sendMessage', source, _U('banhistory_loaded'))
	end
  else
	TriggerEvent('bansql:sendMessage', source, _U('banlist_starterror'))
  end
end)

TriggerEvent('es:addGroupCommand', 'banhistory', Config.permission, function (source, args, user)
 if args[1] ~= nil and BanListHistory ~= {} then
	local nombre = (tonumber(args[1]))
	local name   = table.concat(args, " ",1)
	if name ~= "" then

			if nombre ~= nil and nombre > 0 and BanListHistory[nombre] ~= nil then
					local expiration = BanListHistory[nombre].expiration
					local timeat     = BanListHistory[nombre].timeat
					local calcul1    = expiration - timeat
					local calcul2    = calcul1 / 86400
					local calcul2 	 =  math.ceil(calcul2)
					local resultat   = (tostring(BanListHistory[nombre].targetplayername)) .. " , " .. (tostring(BanListHistory[nombre].sourceplayername)) .. " , " .. (tostring(BanListHistory[nombre].reason)) .. " , " .. calcul2 .. _U('days')
					
					TriggerEvent('bansql:sendMessage', source, (nombre .." : ".. resultat))
			else
					for i = 1, #BanListHistory, 1 do
						if (tostring(BanListHistory[i].targetplayername)) == tostring(name) then
							local expiration = BanListHistory[i].expiration
							local timeat     = BanListHistory[i].timeat
							local calcul1    = expiration - timeat
							local calcul2    = calcul1 / 86400
							local calcul2 	 =  math.ceil(calcul2)					
							local resultat   = (tostring(BanListHistory[i].targetplayername)) .. " , " .. (tostring(BanListHistory[i].sourceplayername)) .. " , " .. (tostring(BanListHistory[i].reason)) .. " , " .. calcul2 .. _U('days')

							TriggerEvent('bansql:sendMessage', source, (i .." : ".. resultat))
						end
					end
			end
	else
		TriggerEvent('bansql:sendMessage', source, _U('invalid_name'))
	end
  else
	TriggerEvent('bansql:sendMessage', source, _U('add_history'))
  end
end)

TriggerEvent('es:addGroupCommand', 'unban', Config.permission, function (source, args, user)
  if args[1] ~= nil then
    local name = table.concat(args, " ")
     MySQL.Async.fetchScalar('SELECT identifier FROM banlist WHERE targetplayername=@name',
    {
        ['@name'] = name
    }, function(identifier)
        if identifier ~= nil then
            MySQL.Async.execute(
            'DELETE FROM banlist WHERE targetplayername=@name',
            {
              ['@name']  = name
            },
                function ()
                loadBanList()
            end)
			if Config.EnableDiscordLink then
				local sourceplayername = GetPlayerName(source)
				local message = (name .. _U('was_unbanned') .." ".. _U('by') .." ".. sourceplayername)
				sendToDiscord(Config.webhookunban, "BanSql", message, Config.green)
			end
			TriggerEvent('bansql:sendMessage', source, name .. _U('was_unbanned'))
        else
			TriggerEvent('bansql:sendMessage', source, _U('invalid_name'))
        end
    end)
  else
	TriggerEvent('bansql:sendMessage', source, _U('invalid_name'))
  end
end)

TriggerEvent('es:addGroupCommand', 'ban', Config.permission, function (source, args, user)
	local identifier
	local license
	local liveid    = "no info"
	local xblid     = "no info"
	local discord   = "no info"
	local playerip
	local target    = tonumber(args[1])
	local duree     = tonumber(args[2])
	local reason    = table.concat(args, " ",3)
	local permanent = 0
		
		if reason == "" then
			reason = _U('no_reason')
		end
		if target ~= nil and target > 0 then
			local ping = GetPlayerPing(target)
        
			if ping ~= nil and ping > 0 then
				if duree ~= nil and duree < 365 then
					local sourceplayername = GetPlayerName(source)
					local targetplayername = GetPlayerName(target)
						for k,v in ipairs(GetPlayerIdentifiers(target))do
							if string.sub(v, 1, string.len("steam:")) == "steam:" then
								identifier = v
							elseif string.sub(v, 1, string.len("license:")) == "license:" then
								license = v
							elseif string.sub(v, 1, string.len("live:")) == "live:" then
								liveid = v
							elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
								xblid  = v
							elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
								discord = v
							elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
								playerip = v
							end
						end
				
					if duree > 0 then
						ban(source,identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
						DropPlayer(target, _U('you_have_been_banned') .. reason)
					else
						local permanent = 1
						ban(source,identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
						DropPlayer(target, _U('you_have_been_permabanned') .. reason)
					end
				
				else
					TriggerEvent('bansql:sendMessage', source, _U('invalid_time'))
				end	
			else
				TriggerEvent('bansql:sendMessage', source, _U('invalid_id'))
			end
		else
			TriggerEvent('bansql:sendMessage', source, _U('invalid_id'))
			TriggerEvent('bansql:sendMessage', source, _U('add'))
		end
end)

TriggerEvent('es:addGroupCommand', 'banoffline', Config.permission, function (source, args, user)
	if args ~= "" then
		lastduree  = tonumber(args[1])
		lasttarget = table.concat(args, " ",2)
		if lastduree ~= "" and lastduree ~= nil then
			if lasttarget ~= "" and lasttarget ~= nil then
				TriggerEvent('bansql:sendMessage', source, (lasttarget .. _U('banned_for') .. lastduree .. _U('banned_for_continued')))
			else
				TriggerEvent('bansql:sendMessage', source, _U('invalid_id'))
			end
		else
			TriggerEvent('bansql:sendMessage', source, _U('invalid_time'))
			TriggerEvent('bansql:sendMessage', source, _U('invalid_id'))
		end
	else
		TriggerEvent('bansql:sendMessage', source, _U('add_offline'))
	end
end)

TriggerEvent('es:addGroupCommand', 'reason', Config.permission, function (source, args, user)
	local duree            = lastduree
	local name             = lasttarget
	local reason           = table.concat(args, " ",1)
	local permanent        = 0
	local playerip         = "0.0.0.0"
	local liveid           = "no info"
	local xblid            = "no info"
	local discord          = "no info"
	local sourceplayername = GetPlayerName(source)

	if name ~= "" then
		if duree ~= nil and duree < 365 then
			if reason == "" then
				reason = _U('no_reason')
			end

			MySQL.Async.fetchAll('SELECT * FROM baninfo WHERE playername = @playername', 
			{
				['@playername'] = name
			}, function(data)

				if data[1] ~= nil then
					if duree > 0 then
						ban(source,data[1].identifier,data[1].license,data[1].liveid,data[1].xblid,data[1].discord,data[1].playerip,name,sourceplayername,duree,reason,permanent)
						lastduree  = ""
						lasttarget = ""
					else
						local permanent = 1
						ban(source,data[1].identifier,data[1].license,data[1].liveid,data[1].xblid,data[1].discord,data[1].playerip,name,sourceplayername,duree,reason,permanent)
						lastduree  = ""
						lasttarget = ""
					end
				else
					TriggerEvent('bansql:sendMessage', source, _U('invalid_id'))
				end
			end)
		else
			TriggerEvent('bansql:sendMessage', source, _U('invalid_time'))
		end	
	else
		TriggerEvent('bansql:sendMessage', source, _U('invalid_id'))
	end
end)

-- console / rcon can also utilize es:command events, but breaks since the source isn't a connected player, ending up in error messages
AddEventHandler('bansql:sendMessage', function(source, message)
	if source ~= 0 then
		TriggerClientEvent('chat:addMessage', source, { args = { '^1Banlist', message } } )
	else
		print('SqlBan: ' .. message)
	end
end)

function sendToDiscord (canal, name, message, color)
  -- Modify here your discordWebHook username = name, content = message,embeds = embeds
local DiscordWebHook = canal
local embeds = {
    {
        ["title"]= message,
        ["type"]= "rich",
        ["color"] = color,
        ["footer"]=  {
        ["text"]= "BanSql_logs",
       },
    }
}

  if message == nil or message == '' then return FALSE end
  PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

function ban(source,identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)

	local expiration = duree * 86400
	local timeat     = os.time()
	local message
	
	if expiration < os.time() then
		expiration = os.time()+expiration
	end
	
		table.insert(BanList, {
			identifier = identifier,
			license    = license,
			liveid     = liveid,
			xblid      = xblid,
			discord    = discord,
			playerip   = playerip,
			reason     = reason,
			expiration = expiration,
			permanent  = permanent
          })




		MySQL.Async.execute(
                'INSERT INTO banlist (identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,expiration,timeat,permanent) VALUES (@identifier,@license,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@expiration,@timeat,@permanent)',
                { 
				['@identifier']       = identifier,
				['@license']          = license,
				['@liveid']           = liveid,
				['@xblid']            = xblid,
				['@discord']          = discord,
				['@playerip']         = playerip,
				['@targetplayername'] = targetplayername,
				['@sourceplayername'] = sourceplayername,
				['@reason']           = reason,
				['@expiration']       = expiration,
				['@timeat']           = os.time(),
				['@permanent']        = permanent,
				},
				function ()
		end)

		if permanent == 0 then
			TriggerEvent('bansql:sendMessage', source, (targetplayername .. _U('banned_for') .. duree .. _U('days_for') .. reason))
			message = (targetplayername .. identifier .." | ".. license .." | ".. liveid .." | ".. xblid .." | ".. discord .." | ".. playerip .." " .. _U('banned_for') .. duree .. _U('days_for') .. reason.." ".. _U('by') .." ".. sourceplayername)
		else
			TriggerEvent('bansql:sendMessage', source, (targetplayername .. _U('permabanned_for') .. reason))
			message = (targetplayername .. identifier .. " | " .. license .. " | " .. liveid .. " | " .. xblid .. " | " .. discord .. " | " .. playerip .." " .. _U('permabanned_for') .. reason .. " " .. _U('by') .. " " .. sourceplayername)
		end
		if Config.EnableDiscordLink then
			sendToDiscord(Config.webhookban, "BanSql", message, Config.red)
		end

		MySQL.Async.execute(
                'INSERT INTO banlisthistory (identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,expiration,timeat,permanent) VALUES (@identifier,@license,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@expiration,@timeat,@permanent)',
                { 
				['@identifier']       = identifier,
				['@license']          = license,
				['@liveid']           = liveid,
				['@xblid']            = xblid,
				['@discord']          = discord,
				['@playerip']         = playerip,
				['@targetplayername'] = targetplayername,
				['@sourceplayername'] = sourceplayername,
				['@reason']           = reason,
				['@expiration']       = expiration,
				['@timeat']           = os.time(),
				['@permanent']        = permanent,
				},
				function ()
		end)
		
		BanListHistoryLoad = false
end

function loadBanList()
  MySQL.Async.fetchAll(
    'SELECT * FROM banlist',
    {},
    function (data)
      BanList = {}

      for i=1, #data, 1 do
        table.insert(BanList, {
			identifier = data[i].identifier,
			license    = data[i].license,
			liveid     = data[i].liveid,
			xblid      = data[i].xblid,
			discord    = data[i].discord,
			playerip   = data[i].playerip,
			reason     = data[i].reason,
			expiration = data[i].expiration,
			permanent  = data[i].permanent
          })
      end
    end
  )
end

function loadBanListHistory()
  MySQL.Async.fetchAll(
    'SELECT * FROM banlisthistory',
    {},
    function (data)
      BanListHistory = {}

      for i=1, #data, 1 do
        table.insert(BanListHistory, {
			identifier       = data[i].identifier,
			license          = data[i].license,
			liveid           = data[i].liveid,
			xblid            = data[i].xblid,
			discord          = data[i].discord,
			playerip         = data[i].playerip,
			targetplayername = data[i].targetplayername,
			sourceplayername = data[i].sourceplayername,
			reason           = data[i].reason,
			expiration       = data[i].expiration,
			permanent        = data[i].permanent,
			timeat           = data[i].timeat
          })
      end
    end
  )
end


function deletebanned(identifier) 

MySQL.Async.execute(
            'DELETE FROM banlist WHERE identifier=@identifier',
            {
              ['@identifier']  = identifier
            },
                function ()
                loadBanList()
            end)
end



AddEventHandler('playerConnecting', function (playerName,setKickReason)
	local steamID  = "empty"
	local license  = "empty"
	local liveid   = "empty"
	local xblid    = "empty"
	local discord  = "empty"
	local playerip = "empty"

	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamID = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			liveid = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			xblid  = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			discord = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			playerip = v
		end
	end

	--Si Banlist pas chargée
	if (Banlist == {}) then
		Citizen.Wait(1000)
	end

    if steamID == false then
		setKickReason(_U('invalid_steam'))
		CancelEvent()
    end

	for i = 1, #BanList, 1 do
		if 
			((tostring(BanList[i].identifier)) == tostring(steamID) 
			or (tostring(BanList[i].license)) == tostring(license) 
			or (tostring(BanList[i].liveid)) == tostring(liveid) 
			or (tostring(BanList[i].xblid)) == tostring(xblid) 
			or (tostring(BanList[i].discord)) == tostring(discord) 
			or (tostring(BanList[i].playerip)) == tostring(playerip)) 
		then

			if (tonumber(BanList[i].permanent)) == 1 then

				setKickReason(_U('you_have_been_permabanned') .. BanList[i].reason)
				CancelEvent()
				break

			elseif (tonumber(BanList[i].expiration)) > os.time() then

				local tempsrestant     = (((tonumber(BanList[i].expiration)) - os.time())/60)
				if tempsrestant >= 1440 then
					local day        = (tempsrestant / 60) / 24
					local hrs        = (day - math.floor(day)) * 24
					local minutes    = (hrs - math.floor(hrs)) * 60
					local txtday     = math.floor(day)
					local txthrs     = math.floor(hrs)
					local txtminutes = math.ceil(minutes)
						setKickReason(_U('you_have_been_banned') .. BanList[i].reason .. _U('time_left') .. txtday .. _U('days') ..txthrs .. _U('hours') ..txtminutes .. _U('minutes'))
						CancelEvent()
						break
				elseif tempsrestant >= 60 and tempsrestant < 1440 then
					local day        = (tempsrestant / 60) / 24
					local hrs        = tempsrestant / 60
					local minutes    = (hrs - math.floor(hrs)) * 60
					local txtday     = math.floor(day)
					local txthrs     = math.floor(hrs)
					local txtminutes = math.ceil(minutes)
						setKickReason(_U('you_have_been_banned') .. BanList[i].reason .. _U('time_left') .. txtday .. _U('days') .. txthrs .. _U('hours') .. txtminutes .. _U('minutes'))
						CancelEvent()
						break
				elseif tempsrestant < 60 then
					local txtday     = 0
					local txthrs     = 0
					local txtminutes = math.ceil(tempsrestant)
						setKickReason(_U('you_have_been_banned') .. BanList[i].reason .. _U('time_left') .. txtday .. _U('days') .. txthrs .. _U('hours') .. txtminutes .. _U('minutes'))
						CancelEvent()
						break
				end

			elseif (tonumber(BanList[i].expiration)) < os.time() and (tonumber(BanList[i].permanent)) == 0 then

				deletebanned(steamID)
				break

			end
		end

	end

end)

AddEventHandler('es:playerLoaded',function(source)
  CreateThread(function()
  Wait(5000)
	local steamID  = "no info"
	local license  = "no info"
	local liveid   = "no info"
	local xblid    = "no info"
	local discord  = "no info"
	local playerip = "no info"
	local playername = GetPlayerName(source)

	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamID = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			liveid = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			xblid  = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			discord = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			playerip = v
		end
	end

		MySQL.Async.fetchAll('SELECT * FROM `baninfo` WHERE `identifier` = @identifier', {
			['@identifier'] = steamID
		}, function(data)
		local found = false
			for i=1, #data, 1 do
				if data[i].identifier == steamID then
					found = true
				end
			end
			if not found then
				MySQL.Async.execute('INSERT INTO baninfo (identifier,license,liveid,xblid,discord,playerip,playername) VALUES (@identifier,@license,@liveid,@xblid,@discord,@playerip,@playername)', 
					{ 
					['@identifier'] = steamID,
					['@license']    = license,
					['@liveid']     = liveid,
					['@xblid']      = xblid,
					['@discord']    = discord,
					['@playerip']   = playerip,
					['@playername'] = playername
					},
					function ()
				end)
			else
				MySQL.Async.execute('UPDATE `baninfo` SET `license` = @license, `liveid` = @liveid, `xblid` = @xblid, `discord` = @discord, `playerip` = @playerip, `playername` = @playername WHERE `identifier` = @identifier', 
					{ 
					['@identifier'] = steamID,
					['@license']    = license,
					['@liveid']     = liveid,
					['@xblid']      = xblid,
					['@discord']    = discord,
					['@playerip']   = playerip,
					['@playername'] = playername
					},
					function ()
				end)
			end
		end)
  end)
end)

function getIdentity(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			name = identity['name'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			dateofbirth = identity['dateofbirth'],
			sex = identity['sex'],
			height = identity['height'],
			job = identity['job'],
			group = identity['group']
		}
	else
		return nil
	end
end

function inArray(value, array)
	for _,v in pairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

CreateThread(function()
	while true do
		Wait(1000)
		if BanListLoad == false then
			loadBanList()
			if BanList ~= {} then
				print(_U('banlist_loaded'))
				BanListLoad = true
			else
				print(_U('banlist_starterror'))
			end
		end
		if BanListHistoryLoad == false then
			loadBanListHistory()
			if BanListHistory ~= {} then
				print(_U('banhistory_loaded'))
				BanListHistoryLoad = true
			else
				print(_U('banlist_starterror'))
			end
		end
	end
end)
