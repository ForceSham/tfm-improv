admins={"Force_shaman#0000"}
players={}
hiddenCommands={"maplist","addmap","removemap","map","score","mod","gametype"}
maplist={}
gameTypeList={"Type restriction","Amount restriction","Nailzones","Anvil rain","Blackout","really bad"}
addMapQueue={}
removeMapQueue={}
allowedObjects = {}
functionNames = {"AutoNewGame","AllShamanSkills","AutoTimeLeft","MortCommand"}
tfmObjects={}

for i=1,#hiddenCommands do
	system.disableChatCommandDisplay(hiddenCommands[i])
end

for i=1,#functionNames do
	_G["tfm.exec.disable"..functionNames[i]]()
end

tfm.exec.chatMessage("<VI>Welcome to Improvision! Type !help for info.")
system.loadFile(1)

tfmObjects[32] = "Rune"
tfmObjects[1] = "Small Box"
tfmObjects[2] = "Large Box"
tfmObjects[10] = "Anvil"
tfmObjects[3] = "Small Plank"
tfmObjects[4] = "Large Plank"
tfmObjects[6] = "Ball"

adminTimer = 0
inHole = 0
gameStart=false
garbage=0
objectLimit=0

tfm.exec.newGame(2852771)

function table.exists(t,element)
	if element==nil then
		return false
	end
	for key,value in pairs(t) do
		if value==element then
			return true
		end
	end
return false
end

function table.find(t,element)
	for i,val in pairs(t) do
		if val == element then
			return i
		end
	end
end

function showhelp(name)
ui.addTextArea(3, "<a href='event:intro'><p align='center'><font size='15'><font color='#98E2EB'>Intro", name, 100, 70, 100, 50, 0x324650, 0x000000, 1, true)
ui.addTextArea(4, "<a href='event:commands'><p align='center'><font size='15'><font color='#98E2EB'>Commands", name, 205, 70, 100, 50, 0x324650, 0x000000, 1, true)
ui.addTextArea(5, "<a href='event:modes1'><p align='center'><font size='15'><font color='#98E2EB'>Modes 1", name, 310, 70, 100, 50, 0x324650, 0x000000, 1, true)
ui.addTextArea(6, "<a href='event:modes2'><p align='center'><font size='15'><font color='#98E2EB'>Modes 2", name, 415, 70, 100, 50, 0x324650, 0x000000, 1, true)
ui.addTextArea(7, "<a href='event:modes3'><p align='center'><font size='15'><font color='#98E2EB'>Modes 3", name, 520, 70, 100, 50, 0x324650, 0x000000, 1, true)
ui.addTextArea(8, "<a href='event:closeall'><p align='center'><font size='15'><font color='#98E2EB'>Close", name, 625, 70, 75, 100, 0x324650, 0x000000, 1, true)
ui.addTextArea(2, "<p align='center'><font color='#FEB1FC'><font face='comic sans ms'><font size='35'>Welcome to Improvision!</font>\n<font face='comic sans ms'><font size='15'><font color='#98E2EB'>This is a shaman based minigame where random events make shamming harder.\nAll three shaman modes are allowed, but harder modes are rewarded more!\nHard mode is recommended, as sometimes things get too difficult for divine.\nArrows are not allowed in divine, and spawning one will kill you.\n\nEasy mode players, look out for a red nail in the upper left corner of the map.\nIf you see one, it means B nails are not allowed for that map!</p></a></font>", name, 100, 100, 600, 250, 0x324650, 0x000000, 1, true)
end

function randomShamObject()
	local temp = {}
	while tfmObjects[temp[1]] == nil do
		temp[1] = math.random(1,18)
	end
	temp[2] = tfmObjects[temp[1]]
	return temp[1], temp[2]
end

function calcShamExp(name,shamanExp,shamanLevel)
	local currentTitle = getTitle(name)
	if inHole > 0 and #players > 1 then
		shamanExp = shamanExp + (inHole*diffMod*modeMod*50)
		tfm.exec.chatMessage("You got "..tostring(inHole*diffMod*modeMod*50).." exp!",name)
		updatePlayerData(name,5,tostring(tonumber(getInfo(name,5)+inHole)))
	end
	while shamanExp >= ((shamanLevel*50)+50) do
		shamanExp = shamanExp - ((shamanLevel*50)+50)
		shamanLevel = shamanLevel + 1
		tfm.exec.chatMessage("<VI>"..tostring(shaman).." is now level "..tostring(shamanLevel).."!")
	end
	updatePlayerData(name,2,shamanExp)
	updatePlayerData(name,3,shamanLevel)
	if currentTitle ~= getTitle(name) then
		tfm.exec.chatMessage("<font color='#FEB1FC'>"..tostring(name).." just unlocked the «"..getTitle(name).."» title!")
	end
	saveInfoFile(name)
end	

function objectTypeRestriction()
	if getInfo(shaman,4) == 1 or tfm.get.room.playerList[shaman].shamanMode == 2 then
		tfmObjects[4] = "Large Plank"
	else
		tfmObjects[4] = nil
	end
	tfm.exec.chatMessage("<J>Objects allowed:")
	while allowedObjects[5-getInfo(shaman,4)] == nil do
		objId, objName = randomShamObject()
		if not table.exists(allowedObjects,objId) then
			table.insert(allowedObjects,objId)
			tfm.exec.chatMessage("<J>"..tostring(objName))
		end
	end
end

function objectAmountRestriction()
	if tfm.get.room.playerList[shaman].shamanMode == 0 then
		objectLimit = math.random(23-(getInfo(shaman,4)*5),28-(getInfo(shaman,4)*5))
	elseif tfm.get.room.playerList[shaman].shamanMode == 1 then
		objectLimit = math.random(25-(getInfo(shaman,4)*5),30-(getInfo(shaman,4)*5))
	else
		objectLimit = math.random(30-(getInfo(shaman,4)*5),35-(getInfo(shaman,4)*5))
	end
	tfm.exec.chatMessage("<J>You're limited to spawning "..tostring(objectLimit).." objects!")
	tfm.exec.setUIMapName(objectLimit)
end

function nailZones()
	coord1=math.random(100,700)
	coord2=math.random(50,350)
	garbage=math.random()
	garbage=math.random()
	garbage=math.random()
	coord3=math.random(100,700)
	coord4=math.random(75,325)
	tfm.exec.chatMessage("<J>Some no nail zones have appeared!")
	tfm.exec.addPhysicObject(1,coord1,coord2,{
		type=8,
		mass=0,
		dynamic=true,
		fixedRotation=true,
		miceCollision=false,
		groundCollision=false
		})
	tfm.exec.addPhysicObject(3,coord3,coord4,{
		type=8,
		mass=0,
		dynamic=true,
		fixedRotation=true,
		miceCollision=false,
		groundCollision=false
		})	
	tfm.exec.addPhysicObject(2,coord1,coord2,{
		type=8,
		height=200,
		width=250,
		angle=math.random(0,90)*(getInfo(shaman,4)/2),
		dynamic=true,
		mass=-999999,
		fixedRotation=true,
		miceCollision=false,
		groundCollision=false
		})	
	tfm.exec.addPhysicObject(4,coord3,coord4,{
		type=8,
		height=200,
		width=250,
		angle=math.random(0,90)*(getInfo(shaman,4)/2),
		dynamic=true,
		mass=-999999,
		fixedRotation=true,
		miceCollision=false,
		groundCollision=false
		})	
	tfm.exec.addJoint(1,1,2,{
		type=0,
		forceMotor=1
	})
	tfm.exec.addJoint(2,3,4,{
		type=0,
		forceMotor=1
	})
end

function balanceMode()
--Currently unused in game
	tfm.exec.chatMessage("<J>Balance mode activated!")
	tfm.exec.addPhysicObject(1,400,210,{
		type=0,
		mass=0,
		dynamic=true,
		fixedRotation=true,
		miceCollision=false,
		groundCollision=false
		})	
	tfm.exec.addPhysicObject(2,400,210,{
		type=8,
		height=400,
		width=800,
		dynamic=true,
		mass=-999999,
		fixedRotation=true,
		miceCollision=false,
		groundCollision=false
		})	
	tfm.exec.addJoint(1,1,2,{
		type=0,
		forceMotor=1
		})
end

function checkMice()
	for x,y in pairs(tfm.get.room.playerList) do
		if not y.isDead then
			return true
		end
	end
	return false
end

function saveMaplist()
	local temp = ""
	for i,map in pairs(maplist) do
		temp = temp..tostring(map).." "
	end
	system.saveFile(temp,1)
end	

function getInfo(name,element)
	for x,y in pairs(players) do
		if y[1] == name then
			return players[x][element]
		end
	end
end

function eventNewGame()
if gameStart then
	--reset global vars
	tfm.exec.removePhysicObject(5)
	objectLimit = 1000
	allowedObjects = {}
	shaman = "Hello"
	mort = false
	anvilRain = false
	amountRestrict = false
	anvilTimer = 0
	blackout = false
	blackoutTimer = 0
	teleport = false
	inHole = 0
	nextmap = nil
	tfm.exec.setUIMapName(tfm.get.room.currentMap)
	--determine shaman
	for x,y in pairs(tfm.get.room.playerList) do
		if y.isShaman then
			shaman = tostring(x)
		end
	end
	--get player data
	if tonumber(getInfo(shaman,4)) == 1 then
		diffText="<CH>Easy"
		diffMod=.5
	elseif tonumber(getInfo(shaman,4)) == 2 then
		diffText="<J>Medium"
		diffMod=1
	else
		diffText="<R>Hard"
		diffMod=2
	end
	if tfm.get.room.playerList[shaman].shamanMode == 0 then
		modeMod=.2
	elseif tfm.get.room.playerList[shaman].shamanMode == 1 then
		modeMod=1
	else
		modeMod=2
	end
	--update info bar
	tfm.exec.setUIShamanName(shaman.." Lv."..tostring(getInfo(shaman,3)).."    Difficulty: "..diffText)
	--roll first gamemode
	if not forceGameType then
		gameType2 = 0
		gameType1=math.random(getInfo(shaman,4)*2)
		--roll second gamemode if diff 2 or 3
		if tonumber(getInfo(shaman,4)) > 1 then
			while gameType1 == gameType2 or gameType2 == 0 or gameType1+gameType2 == 3 do
				gameType2=math.random(getInfo(shaman,4)*2)
			end
		end
	else
		forceGameType = false
	end
	--launch rolled gamemodes
	if gameType1 == 1 or gameType2 == 1 then
		objectTypeRestriction()
	end
	if gameType1 == 2 or gameType2 == 2 then
		objectAmountRestriction()
		amountRestrict = true
	end
	if gameType1 == 3 or gameType2 == 3 then
		nailZones()
	end
	if gameType1 == 4 or gameType2 == 4 then
		anvilRain = not anvilRain
		tfm.exec.chatMessage("<J>Chance of scattered showers this round..")
	end
	if gameType1 == 5 or gameType2 == 5 then
		blackout = not blackout
		tfm.exec.chatMessage("<J>Darkness within darkness will consume you, "..tostring(shaman).."!")
	end
	if gameType1 == 6 or gameType2 == 6 then
		teleport = not teleport
		tfm.exec.chatMessage("<J>You're gonna have a bad time.")
	end
else
	tfm.exec.setGameTime(5)
	gameStart = not gameStart
	for x,y in pairs(tfm.get.room.playerList) do
		system.loadPlayerData(x)
		system.bindKeyboard(x,80,true,true)
	end
end
end

function eventPlayerDied(dead)
	if dead == shaman then
		tfm.exec.setGameTime(20)
	end
end

function eventNewPlayer(name)
	system.loadPlayerData(name)
	system.bindKeyboard(name,80,true,true)
	tfm.exec.chatMessage("<VI>Welcome to Improvision! Type !help for info.",name)
end

function eventPlayerLeft(name)
	for x,y in pairs(players) do
		if y[1] == name then
			table.remove(players,x)
			break
		end
	end
end

function eventLoop(currentTime,timeRemaining)
--admin stuff
	if adminTimer > 0 then
		adminTimer = adminTimer - 1
	end
	if #addMapQueue~=0 and adminTimer == 0 then
		while #addMapQueue > 0 do
			table.insert(maplist,addMapQueue[#addMapQueue])
			tfm.exec.chatMessage(tostring(addMapQueue[#addMapQueue]).." was added to maplist!","Force_shaman#0000")
			addMapQueue[#addMapQueue] = nil
		end
		saveMaplist()
		adminTimer = 125
	elseif #removeMapQueue~=0 and adminTimer == 0 then
		while #removeMapQueue > 0 do
			tfm.exec.chatMessage(tostring(removeMapQueue[#removeMapQueue]).." was removed from maplist!","Force_shaman#0000")
			for x,y in pairs(maplist) do
				if y == removeMapQueue[#removeMapQueue] then
					table.remove(maplist,x)
				end
			end
			removeMapQueue[#removeMapQueue] = nil
		end
		saveMaplist()
		adminTimer = 125
	end
--mort
	if timeRemaining < 150000 then 
		mort = true
	end
--play new map
	if timeRemaining <= 0 or not checkMice() then
		if inHole > 0 then
			calcShamExp(shaman,getInfo(shaman,2),getInfo(shaman,3))
		end
		if nextmap == nil then 
			garbage=math.random()
			garbage=math.random()
			garbage=math.random()
			tfm.exec.newGame(maplist[math.random(#maplist)])
		else
			tfm.exec.newGame(nextmap)
		end
		tfm.exec.setGameTime(153)
	end
--anvil rain
	if anvilRain then
		anvilTimer = anvilTimer + 1
		if anvilTimer%30 == 0 then
			tfm.exec.addShamanObject(10,math.random(50,750),-50)
			if tonumber(getInfo(shaman,4)) == 3 then
				garbage=math.random()
				garbage=math.random()
				garbage=math.random()
				tfm.exec.addShamanObject(10,math.random(50,750),-50)
			end
		end
	end
--blackout
	if blackout then
		blackoutTimer = blackoutTimer + 1
		if blackoutTimer%20 == 2 then
			tfm.exec.addPhysicObject(5,400,210,{
			type=12,
			height=400,
			width=800,
			dynamic=false,
			miceCollision=false,
			groundCollision=false,
			color=0x000000
			})	
		elseif blackoutTimer%20 == 0 then
		tfm.exec.removePhysicObject(5)
		end
	end
end

function updatePlayerData(name,element,value)
	for x,y in pairs(players) do
		if y[1] == name then
			players[x][element] = value
		end
	end
end
	
function saveInfoFile(name)
	system.savePlayerData(name,tostring(getInfo(name,2)).." "..tostring(getInfo(name,3)).." "..tostring(getInfo(name,4)).." "..tostring(getInfo(name,5)))
end
	
function eventSummoningEnd(playerName,objectType,xPosition,yPosition,angle,objectDescription)
	if objectLimit>0 and tostring(objectType)~="0" and (gameType1 == 2 or gameType2 == 2) and mort then 
		objectLimit = objectLimit - 1
		tfm.exec.setUIMapName(objectLimit)
	elseif objectLimit == 0 and tostring(objectType)~="0" then
		tfm.exec.killPlayer(playerName)
		tfm.exec.removeObject(objectDescription.id)
	end
	if allowedObjects[1] ~= nil and mort then
		if table.exists(allowedObjects,objectDescription.baseType) ~= true and objectDescription.baseType ~=0 then
			tfm.exec.killPlayer(playerName)
			tfm.exec.removeObject(objectDescription.id)
		end
	end
	if objectType == 0 and tfm.get.room.playerList[shaman].shamanMode == 2 then
		tfm.exec.killPlayer(playerName)
	end
end

function getTitle(name)
	if tonumber(getInfo(name,5)) >= 10000 then return "Clairvoyant"
	elseif tonumber(getInfo(name,5)) >= 9000 then return "Miracle Worker"
	elseif tonumber(getInfo(name,5)) >= 8000 then return "Force Adept"
	elseif tonumber(getInfo(name,5)) >= 7000 then return "TI-84 Plus"
	elseif tonumber(getInfo(name,5)) >= 6000 then return "99 Construction"
	elseif tonumber(getInfo(name,5)) >= 5000 then return "Please Stop"
	elseif tonumber(getInfo(name,5)) >= 4500 then return "No Life"
	elseif tonumber(getInfo(name,5)) >= 4000 then return "Masochist"
	elseif tonumber(getInfo(name,5)) >= 3500 then return "Tryhard"
	elseif tonumber(getInfo(name,5)) >= 3000 then return "Warlock"
	elseif tonumber(getInfo(name,5)) >= 2500 then return "Conjuror"
	elseif tonumber(getInfo(name,5)) >= 2000 then return "Wizard"
	elseif tonumber(getInfo(name,5)) >= 1500 then return "High Roller"
	elseif tonumber(getInfo(name,5)) >= 1000 then return "Gambler"
	elseif tonumber(getInfo(name,5)) >= 750 then return "Risky"
	elseif tonumber(getInfo(name,5)) >= 500 then return "Adamant"
	elseif tonumber(getInfo(name,5)) >= 250 then return "Determined"
	elseif tonumber(getInfo(name,5)) >= 100 then return "Stubborn"
	elseif tonumber(getInfo(name,5)) >= 75 then return "Shaman"
	elseif tonumber(getInfo(name,5)) >= 50 then return "Shaman Intern"
	elseif tonumber(getInfo(name,5)) >= 25 then return "Still Noob"
	elseif tonumber(getInfo(name,5)) >= 10 then return "Noob"
	else return "Little Mouse"
	end
end
	
function openProfile(name,caller)
	ui.addPopup(1,0,"<p align='center'>"..name.."<br>Level: "..tostring(getInfo(name,3)).."<br>"..tostring(getInfo(name,2)).."/"..tostring(50+tonumber(getInfo(name,3))*50).."<br>Diff: "..tostring(getInfo(name,4)).."<br>Mice Saved: "..tostring(getInfo(name,5)).."<br>«"..getTitle(name).."»",caller,50,50,150,false)
end

function eventKeyboard(name,key,down,xpos,ypos)
	if key == 80 then
	openProfile(name,name)
	end
end

function eventChatCommand(name,msg)
	local arg = {}
	for argument in msg:gmatch("[^%s]+") do
		table.insert(arg,argument)
	end
	if (string.lower(arg[1]) == "mort" or string.lower(arg[1]) == "m") then
		if mort then
			tfm.exec.killPlayer(name)
		else
			tfm.exec.chatMessage("You can't mort at the start of the round!",name)
		end
	elseif string.lower(arg[1]) == "mod" and table.exists(admins,name)	then
		tfm.exec.chatMessage("<R>[Improvision]"..string.gsub(msg, "mod",""))
	elseif string.lower(arg[1]) == "map" and tonumber(arg[2]) ~= nil and table.exists(admins,name) then
		nextmap = arg[2]
		for i=1,#admins do
			tfm.exec.chatMessage("Next map will be "..nextmap,admins[i])
		end
	elseif string.lower(arg[1]) == "addmap" and table.exists(admins,name) and tonumber(arg[2])~=nil then
		if table.exists(maplist,arg[2]) then
			tfm.exec.chatMessage(tostring(arg[2]).." is already in rotation!",name)
		else
			table.insert(addMapQueue,arg[2])
			for i=1,#admins do
				tfm.exec.chatMessage("Added to queue",admins[i])
			end
		end
	elseif string.lower(arg[1]) == "removemap" and table.exists(admins,name) and tonumber(arg[2])~=nil then
		if table.exists(maplist,arg[2]) then
			table.insert(removeMapQueue,arg[2])
			tfm.exec.chatMessage("Added to queue","Force_shaman#0000")
		else
			tfm.exec.chatMessage("That isn't in the maplist!","Force_shaman#0000")
		end
	elseif string.lower(arg[1]) == "score" and tonumber(arg[3])~= nil and table.exists(admins,name) then
		tfm.exec.setPlayerScore(arg[2],arg[3])
	elseif arg[1] == "help" then
		showhelp(name)
	elseif arg[1] == "maplist" then
		local temp = ""
		for i,map in pairs(maplist) do
			temp = temp..tostring(map).." "
		end
		tfm.exec.chatMessage(temp,name)
	elseif string.lower(arg[1]) == "setdiff" then
		if tonumber(arg[2]) == 1 or tonumber(arg[2]) == 2 or tonumber(arg[2]) == 3 then
			updatePlayerData(name,4,arg[2])
			tfm.exec.chatMessage("Difficulty set.",name)
		end
	elseif string.lower(arg[1]) == "profile" then
		for i=1,#players do
			if players[i][1] == arg[2] then
				openProfile(arg[2],name)
			end
		end
	elseif string.lower(arg[1]) == "gametype" then
		if tonumber(arg[2]) > 0 and tonumber(arg[2]) < 7 then
			gameType1 = tonumber(arg[2])
			forceGameType = true
			for i=1,#admins do
				tfm.exec.chatMessage("Next gametype will be "..(gameTypeList[tonumber(arg[2])]),admins[i])
			end
		end
		if arg[3]~= nil then
			if (tonumber(arg[3]) > 0 and tonumber(arg[3]) < 7) and tonumber(arg[3]) ~= gameType1 then
				gameType2 = tonumber(arg[3])
				for i=1,#admins do
					tfm.exec.chatMessage("Next gametype will be "..(gameTypeList[tonumber(arg[3])]),admins[i])
				end
			end
		end
	end
end

function eventPlayerWon(name,elapsed,elapsedrespawn)
	if name ~= shaman then
		inHole = inHole + 1
	end
end

function eventFileLoaded(fileNumber,fileData)
	for map in fileData:gmatch("[^%s]+") do
		table.insert(maplist,map)
	end
end

function eventFileSaved()
	tfm.exec.chatMessage("<VP>Maplist updated!")
end

function eventSummoningStart(name,objectType,x,y,angle)
	if teleport and objectType ~= 0 then
		tfm.exec.movePlayer(name,x,y)
	end
end

function eventPlayerDataLoaded(name,data)
	if data == "" or data == nil or data == "#" then
		table.insert(players,{name,0,1,1,0})
	else
		local arg = {}
		for argument in data:gmatch("[^%s]+") do
			table.insert(arg,argument)
		end
		players[#players+1] = {name}
		players[#players][2] = tonumber(arg[1])
		players[#players][3] = tonumber(arg[2])
		players[#players][4] = tonumber(arg[3])
		if arg[4] == nil then
			players[#players][5] = 0
		else
			players[#players][5] = tonumber(arg[4])
		end
	end
 end
 
 function eventTextAreaCallback(id,player,event)
	if event == "intro" then
		 ui.updateTextArea(2,"<p align='center'><font color='#FEB1FC'><font face='comic sans ms'><font size='35'>Welcome to Improvision!</font>\n<font face='comic sans ms'><font size='15'><font color='#98E2EB'>This is a shaman based minigame where random events make shamming harder.\nAll three shaman modes are allowed, but harder modes are rewarded more!\nHard mode is recommended, as sometimes things get too difficult for divine.\nArrows are not allowed in divine, and spawning one will kill you.\n\nEasy mode players, look out for a red nail in the upper left corner of the map.\nIf you see one, it means B nails are not allowed for that map!</p></a></font>",player)
	elseif event == "commands" then
		 ui.updateTextArea(2,"<p align='center'><font color='#FEB1FC'><font face='comic sans ms'><font size='15'>Commands\n\n<font color='#98E2EB'>!setdiff 1 | Sets your difficulty to easy.\n!setdiff 2 | Sets your difficulty to medium.\n!setdiff 3 | Sets your difficulty to hard.\n!m or !mort | Either command will kill you. TFM's /mort is disabled here.\n!maplist | Will send the module's entire maplist to your chat.\nPressing P will open your profile!</p></a></font>",player)
	elseif event == "modes1" then
		 ui.updateTextArea(2,"<p align='center'><font color='#FEB1FC'><font face='comic sans ms'><font size='15'>Easy Gamemodes\n\n<font color='#98E2EB'>Object amount restriction: You may only spawn a certain amount of objects, depending on difficulty and shaman mode. Going over the limit will kill you. Your object counter can be seen in the upper left corner where the map code is usually seen.\n\nObject type restriction: You're given 2-4 types of objects to use depending on difficulty. Spawning an object not listed will kill you. And yes, the object gets deleted too.\n\nYou can always get these gamemodes in any difficulty.</p></a></font>",player)
	elseif event == "modes2" then
		 ui.updateTextArea(2,"<p align='center'><font color='#FEB1FC'><font face='comic sans ms'><font size='15'>Medium Gamemodes\nNote: You'll get two gamemodes at once when playing on medium or  hard!\n\n<font color='#98E2EB'>Nailzones: Two  nailzones (clouds) will spawn randomly. You cannot make any anchors/nails inside these clouds. If you do, bad things will happen. On hard, they're bigger.\n\nScattered Showers: An anvil (two on hard) will randomly fall from the sky every 15 seconds. Not much needs to be said about why this is bad.\n\nThese gamemodes only appear on medium or hard.</p></a></font>",player)
	elseif event == "modes3" then
		 ui.updateTextArea(2,"<p align='center'><font color='#FEB1FC'><font face='comic sans ms'><font size='15'>Hard Gamemodes\n\n<font color='#98E2EB'>Blackout: The map will be completely black, and only periodically be revealed. Yes, the nailclouds get hidden too.\n\nHaving a bad time: Every attempt to begin spawning an object will teleport you to that spawn location. This can be used to teleport, but trying to build without killing yourself will more than make up for that.\n\nThese gamemodes only appear on hard.</p></a></font>",player)
	elseif event == "closeall" then
		for i=2,8 do
			ui.removeTextArea(i,player)
		end
	end
 end