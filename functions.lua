--[[
    PrTn's-Racing [FUNCTIONS]
]]

function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function split(inputstr, sep) 
	sep=sep or '%s' 
	local t={} 
	for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do 
		table.insert(t,field) 
		if s=="" then 
			return t 
		end 
	end 
end

function notify(string)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(string)
    DrawNotification(true, false)
end

function alert(msg) 
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function LocalPed()
	return GetPlayerPed(-1)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do 
    count = count + 1 end
    return count
end

function formatTimer(startTime, currTime)
    local newTime
	if currTime == nil then
		newTime = startTime
	else
		newTime = currTime - startTime
	end
	
	local floor = math.floor

	local ms = floor(newTime % 1000)
	local hundredths = floor(ms / 10)
	local seconds = floor(newTime / 1000)
	local minutes = floor(seconds / 60);   seconds = floor(seconds % 60)
	formattedTime = string.format("%02d:%02d.%02d", minutes, seconds, hundredths)

	return formattedTime

end

function DrawHudText(text,colour,coordsx,coordsy,scalex,scaley) --courtesy of driftcounter
    SetTextFont(4) -- 7 is the heavy GTA font
    SetTextProportional(7)
    SetTextScale(scalex, scaley)
    local colourr,colourg,colourb,coloura = table.unpack(colour)
    SetTextColour(colourr,colourg,colourb, coloura)
    SetTextDropshadow(0, 0, 0, 0, coloura)
    SetTextEdge(1, 0, 0, 0, coloura)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(coordsx,coordsy)
end

function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY, rot, r, g, b)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
	
    
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	if r and g and b then
		SetTextColour(r, g, b, 250)
	else
		SetTextColour(255, 255, 255, 250)
	end
	SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(textInput)
	SetDrawOrigin(x,y,z+2, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end