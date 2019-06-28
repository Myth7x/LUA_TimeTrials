--[[
    PrTn's-Racing [CLIENT] Trackname
]]

-- [ Configuration ]
local course_name = "kagarasanup" -- Name of the Course/Track
local world_pos = { x = -5710.20, y = -1770.25, z = 9.98 } -- XYZ Coordinates for Marker 3d
local start_heading = 355.56
local line_1 = "Kagarasan"
local line_2 = "Uphill"

local print_client_log = false -- Enable Log in Console

local cp_1 = {}
local cp_2 = {}

----------------------------------------------------------------------------------------------------------------------------

local is_racing = false
local is_noclip_enabled = false
local input_bool = false
local cP = 1
local cP2 = 2
local checkpoint
local blip
local load_record = false
local sync_trigger = 0
local should_collectgarbage = 0
local usr_vehicle = 0


local blips = {
    {title=line_1 .. " " .. line_2, colour=4, id=315, x = world_pos.x, y =  world_pos.y, z = world_pos.z} -- Map Marker 2d
}

--[ Record Variables ]
local load_table = {}
local time_table = {}
local drift_table = {}

--[ Dynamic Checkpoint Variables ]
local checkpoint_table = {}
local checkpoint_table2 = {}
local checkpoint_count = 0




Citizen.CreateThread(function() -- Main Loop
    -- [ Main Loop ]
	
	--RegisterNetEvent(course_name .. ":Receive_IsRacing_Bools")
	--AddEventHandler(course_name .. ":Receive_IsRacing_Bools", function(identifier, is_online)
	--	if identifier and is_online then
	--		print("Getting IsRacing Bool for: " .. identifier .. " Data is: " .. is_online)
	--	end
	--end)
	
	RegisterNetEvent(course_name .. ":Receive_Checkpoints")
	AddEventHandler(course_name .. ":Receive_Checkpoints", function(cp, cp2, count)
		checkpoint_table = split(cp, ",")
		checkpoint_table2 = split(cp2, ",")
		checkpoint_count = count
		cp_1 = checkpoint_table
		cp_2 = checkpoint_table2
		cp_count = checkpoint_count
		--print("[ ".. cp_count ..  " Checkpoints found ]")
		--print("Received Checkpoints for " .. course_name .. " | CP1: " .. cp_1[1] .. ", " .. cp_1[2] .. ", " .. cp_1[3] .. ", " .. cp_1[4]  .. " | CP2: " .. cp_2[1] .. ", " .. cp_2[2] .. ", " .. cp_2[3] .. ", " .. cp_2[4])
	end)
	
    while true do Citizen.Wait(5)
        if not is_racing then
			
            if load_record == false and sync_trigger > 1800 or sync_trigger == 0 then collectgarbage() -- Check if update for record is needed
                load_record = true
                sync_trigger = 1
            end

            -- Get Records if needed
            if load_record == true then 
                load_record = false
                TriggerServerEvent("pRace:LoadRecord", course_name)
            end

            if time_table[1] or time_table[2] then time_table = {} end
            if drift_table[1] or drift_table[2] then drift_table = {} end


            time_table[1] = load_table[1]
            time_table[2] = load_table[2]
            time_table[3] = load_table[3]
            --drift_table[1] = load_table[3]
            --drift_table[2] = load_table[4]
			
			

            if print_client_log then 
                if time_table[1] and time_table[2] then print("[PW] - loaded time record for Course: " .. course_name .. " - " .. time_table[1] .. ":" .. time_table[2]) end
                if drift_table[1] and drift_table[2] then print("[PW] - loaded drift record for Course: " .. course_name .. " - " .. drift_table[1] .. ":" .. drift_table[2]) end
				
				if not time_table[1] and not time_table[2] then print("[PW] - could not load record for Course: " .. course_name) end
            end

            DrawMarker(1, world_pos.x, world_pos.y, world_pos.z - 1.2, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 1.5001, 250, 250, 250, 180, 0, 0, 0,0)

            if GetDistanceBetweenCoords( world_pos.x, world_pos.y, world_pos.z, GetEntityCoords(LocalPed())) < 30.0 then
				Draw3DText( world_pos.x, world_pos.y, world_pos.z  -.290, line_1,4,0.3,0.2, 0, 198, 198, 295)
                if line_2 ~= nil or line_1 ~= nil then Draw3DText( world_pos.x, world_pos.y, world_pos.z  -.640, line_2,4,0.3,0.2, 0, 198, 198, 155) end
			end

            if GetDistanceBetweenCoords( world_pos.x, world_pos.y, world_pos.z, GetEntityCoords(LocalPed())) < 14.0 then
				if time_table[1] and time_table[2] and time_table[3] then
					--Draw3DText( world_pos.x, world_pos.y, world_pos.z  -1.080, "Time Record: " .. time_table[1] .. " - " .. formatTimer(tonumber(time_table[2])) .. " - " .. time_table[3],4,0.19,0.1)
					Draw3DText( world_pos.x, world_pos.y, world_pos.z  -1.100, "User: ~r~" .. time_table[1] .. "~w~ | Time: ~y~" .. formatTimer(tonumber(time_table[2])),4,0.19,0.1, 0, 255, 255, 255)
					Draw3DText( world_pos.x, world_pos.y, world_pos.z  -1.280,  "Car: " .. time_table[3],4,0.19,0.1, 0, 218, 218, 218)
				end
				--if drift_table[1] and drift_table[2] then
				--	Draw3DText( world_pos.x, world_pos.y, world_pos.z  -.800, "Drift Record: " .. drift_table[1] .. " - " .. drift_table[2],4,0.19,0.1)
				--end
            end
            local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1),  false)
			
            if GetDistanceBetweenCoords( world_pos.x, world_pos.y, world_pos.z, GetEntityCoords(LocalPed())) < 2.0 and vehicle and (GetPedInVehicleSeat(vehicle, -1) == LocalPed()) then
				if not is_noclip_enabled then
					Draw3DText( world_pos.x, world_pos.y, world_pos.z  -1.500, "~g~ Start Race [E]",4,0.15,0.1, 0, 88, 188, 88)
					if IsControlJustReleased(1, 46) or IsControlPressed(1, 46) then
						if not is_racing then
							TriggerServerEvent("Write_Data", 3, 1)
							is_racing = true
							TriggerEvent("pRace:TPALL" .. course_name)
							--TriggerServerEvent("pRace:SaveRecord", 0, course_name, "CourseTest:"..course_name, 133337)
						else
							return
						end
					end
				end
			end
			should_collectgarbage = should_collectgarbage + 1
            sync_trigger = sync_trigger + 1
			
			if should_collectgarbage > 4000 then
				collectgarbage()
				should_collectgarbage = 0
			end
        end
    end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if should_collectgarbage > 3000 then
			collectgarbage()
		end
		
		
		--for l_i=0, 32, 1 do
		--	if l_i ~= PlayerId() then
		--		local user_identifier = PlayerIdentifier('steam', l_i)
		--		TriggerServerEvent("Load_IsRacing", user_identifier)
		--		print("Triggeres Loading for : " .. user_identifier)
		--	end
		--end
		
		if (IsControlJustReleased(1, 289) or IsDisabledControlJustReleased( 0, 289 ) or IsControlJustReleased(1, 170) or IsDisabledControlJustReleased( 0, 170 )) or is_noclip_enabled and is_racing then -- Check for Input / NoClip Key
            if is_racing then TriggerServerEvent("Write_Data", 3, 0) end
			input_bool = true
           if is_racing then PlaySoundFrontend(-1, "ScreenFlash", "WastedSounds") end
            DeleteCheckpoint(checkpoint)
            RemoveBlip(blip)
            is_racing = false
            cP = 1
            cP2 = 2
        end
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1),  false)
		if GetDistanceBetweenCoords( world_pos.x, world_pos.y, world_pos.z, GetEntityCoords(LocalPed())) < 7.0 and vehicle and (GetPedInVehicleSeat(vehicle, -1) == LocalPed()) then
			local playerPed = GetPlayerPed(-1)
			if IsPedInAnyVehicle(playerPed,  true) then
				for i=0, 32, 1 do
					if i ~= PlayerId() then
						local otherPlayerPed = GetPlayerPed(i)
						if IsPedInAnyVehicle(otherPlayerPed,  true) then
							local otherPlayerVehicle = GetVehiclePedIsIn(otherPlayerPed,  true)
							SetEntityNoCollisionEntity(vehicle,  otherPlayerVehicle,  true)
							SetEntityNoCollisionEntity(otherPlayerVehicle,    vehicle,  true)
						end
					end
				end
			end
		end
	end

end)


Citizen.CreateThread(function() -- Map Blip
    for _, info in pairs(blips) do
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(info.blip, 1.0)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end
end)

RegisterNetEvent("pRace:" .. course_name .. "GetRecord") -- GetRecord Event
AddEventHandler("pRace:" .. course_name .. "GetRecord", function(record_table)
    if load_table[1] or load_table[2] then load_table = {} end -- If theres anything in the temp table clear it
    load_table = record_table -- Move records to temp table
    if print_client_log then print("[PW] - Got record: (time) " .. load_table[1] .. ":" .. formatTimer(tonumber(load_table[2])) .. ", (drift)" .. load_table[3]) end
end)


RegisterNetEvent("pRace:ReceiveNoclipBool")
AddEventHandler("pRace:ReceiveNoclipBool", function(is_noclipping)
    is_noclip_enabled = is_noclipping
    if print_client_log then print("[PW] - Received NoClip Bool") end
end)

 -- [ Checkpoint Events ]
 RegisterNetEvent("pRace:TPALL" .. course_name)
 AddEventHandler("pRace:TPALL" .. course_name, function()
    SetPedCoordsKeepVehicle(PlayerPedId(), world_pos.x, world_pos.y, world_pos.z)
	PlaySoundFrontend(-1, "5s", "MP_MISSION_COUNTDOWN_SOUNDSET" )
    SetEntityHeading(PlayerPedId(), start_heading)
    Citizen.CreateThread(function()
        if print_client_log then print("[PW] - Setting up race: " .. course_name) end
        local time = 0
		local toggled_noclip = false
        function setcountdown(x)
          time = GetGameTimer() + x*1000
        end
        function getcountdown()
          return math.floor((time-GetGameTimer())/1000)
        end
        setcountdown(5)  -- The Seconds that count down
		TriggerServerEvent("NoNameDrift:Load_Checkpoint", course_name, cP)
        while getcountdown() > -1 and not input_bool and not toggled_noclip do
			Citizen.Wait(5)
			toggled_noclip = is_noclip_enabled
			FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)), true)
            if getcountdown() < 1 then
				SetPedCoordsKeepVehicle(PlayerPedId(), world_pos.x - 0.1, world_pos.y - 0.1, world_pos.z)
				local speed = 0.1
				local r_red = math.floor(math.sin(GetGameTimer() / 12 * tonumber(speed)) * 127 + 128)
				local r_green = math.floor(math.sin(GetGameTimer() / 12 * tonumber(speed) + 2) * 127 + 128)
				local r_blue = math.floor(math.sin(GetGameTimer() / 12 * tonumber(speed) + 4) * 127 + 128)
				DrawHudText("GO", {r_red,r_green,r_blue,255},0.44,0.4,4.0,4.0)
			else
				if (getcountdown() < 2) or (getcountdown() < 3 and getcountdown() > 1) or (getcountdown() < 4 and getcountdown() > 2) then
					SetPedCoordsNoGang(PlayerPedId(), world_pos.x, world_pos.y, world_pos.z)
				end
				DrawHudText(getcountdown(), {255,191,0,255},0.48,0.4,4.0,4.0)
			end
			FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)), false) -- move this one down 1 line to not have "burnout", but 100% freeze
        end
        if not toggled_noclip and not input_bool then
            if print_client_log then print("[PW] - Starting race: " .. course_name) end
            TriggerEvent("pRace:BeginRace" .. course_name)
        else
			TriggerServerEvent("Write_Data", 3, 0)
            DeleteCheckpoint(checkpoint)
            RemoveBlip(blip)
            is_racing = false
            input_bool = false
            cP = 1
            cP2 = 2
			cp_1 = {}
            cp_2 = {}
        end
    end)
 end)
 



RegisterNetEvent("pRace:BeginRace" .. course_name) -- Main loop
AddEventHandler("pRace:BeginRace" .. course_name, function()
    local startTime = GetGameTimer()
	local IsCheckpointFirstLoaded = false
	local IsCheckpointDeleted = false
	local CPCount = 0
	local cur_time = 0
	local cp_create_time = 0
	local should_update_once = 0
	local user_collisions = 0
	local last_collission = 0
	local cur_cp = 2
	local cur_uc = 0
	local time_r = 240
	local time_g = 240
	local time_b = 240
	local color_trigger = 250
	usr_vehicle = GetVehiclePedIsUsing(GetPlayerPed(-1))
	
	 function CheckValues()
		if ((cur_cp / 2) <  cP) or (cP > cP2) then -- Checkpoint Num
			return false
		end
		if ((cur_uc / 2) < user_collisions) or ((cur_uc / 2) > user_collisions) then -- User Collission/Crashes
			return false
		end
		return true
	 end
	
    Citizen.CreateThread(function()
		local _,currentScore = StatGetInt("MP0_DRIFT_SCORE",-1)
		
		if cp_1 ~= {} and cp_2 ~= {} then
			checkpoint = CreateCheckpoint(tonumber(cp_1[4]), tonumber(cp_1[1]),  tonumber(cp_1[2]),  tonumber(cp_1[3]) + 2, tonumber(cp_2[1]), tonumber(cp_2[2]),  tonumber(cp_2[3]), 8.0, 204, 204, 1, 100, 0)
			blip = AddBlipForCoord(tonumber(cp_1[1]),  tonumber(cp_1[2]),  tonumber(cp_1[3]))
		end
		
        while is_racing do Citizen.Wait(5)
			cur_time = GetGameTimer()
			
			if not CheckValues() then
				print("DETECTED CHANGED VALUES")
				TriggerServerEvent("Write_Data", 3, 0)
				DeleteCheckpoint(checkpoint)
				RemoveBlip(blip)
				is_racing = false
				input_bool = false
				cP = 1
				cP2 = 2
				cp_1 = {}
				cp_2 = {}
				cur_cp = 2
				TriggerServerEvent("pRace:Need2DropPlayer", "[NoNameDrift AC] You've been caught trying to cheat.")
			end
			
			if should_collectgarbage > 3000 then
				collectgarbage()
			end
			
			should_update_once = should_update_once + 1
			if should_update_once > 25 then
				IsCheckpointFirstLoaded = false
			end
			
			if not IsCheckpointFirstLoaded then
				TriggerServerEvent("NoNameDrift:Load_Checkpoint", course_name, cP)
				IsCheckpointFirstLoaded = true
			end

			
            if print_client_log then print("[PW] - Im in race: " .. course_name) end
			local _3,raceScore = StatGetInt("MP0_DRIFT_SCORE",-1)
			DrawHudText("Score: " .. raceScore - currentScore, {255,255,255,255},0.019,0.689,0.7,0.7)
			DrawHudText("Crashes: " .. user_collisions , {255,255,255,255},0.019,0.719,0.7,0.7)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetPedDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

			
            
            DrawHudText(string.format("%i / %i", cP, checkpoint_count), {249, 249, 249, 255},0.118,0.765,0.7,0.7)
            DrawHudText(formatTimer(startTime - (user_collisions * 2000), GetGameTimer()), {time_r, time_g, time_b, 240}, 0.019,0.745,1.1,1.1)

			if IsCheckpointDeleted == true and CPCount < cP + 1 then
				checkpoint = CreateCheckpoint(tonumber(cp_1[4]), tonumber(cp_1[1]),  tonumber(cp_1[2]),  tonumber(cp_1[3]) + 2, tonumber(cp_2[1]), tonumber(cp_2[2]),  tonumber(cp_2[3]), 8.0, 204, 204, 1, 100, 0)
				blip = AddBlipForCoord(tonumber(cp_1[1]),  tonumber(cp_1[2]),  tonumber(cp_1[3]))
				CPCount = cP
				cp_create_time = GetGameTimer()
				IsCheckpointDeleted = false
				
			end
			
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1),  false)
			if vehicle and (last_collission + 500) < GetGameTimer() then -- Auto vorhanden?
				if HasEntityCollidedWithAnything(vehicle) then -- Angestoßen?
					time_g = 55
					time_b = 55
					user_collisions = user_collisions + 1
					last_collission = GetGameTimer()
					cur_uc = cur_uc + 2
					color_trigger = 250
				end
				
			end
			
			if color_trigger > 0 then color_trigger = color_trigger - 1 end
			
            if  GetDistanceBetweenCoords(tonumber(cp_1[1]),  tonumber(cp_1[2]),  tonumber(cp_1[3]), GetEntityCoords(GetPlayerPed(-1))) < 7.0 then
                if tonumber(cp_1[4]) == 5 and cP < cp_count + 1 then
					IsCheckpointDeleted = true
					IsCheckpointFirstLoaded = false
					DeleteCheckpoint(checkpoint)
					RemoveBlip(blip)
					if cur_time > (cp_create_time + 150) then
						PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS" )
						cP = cP + 1
						cP2 = cP2+1
						cur_cp = cP * 2
					end

                else
					TriggerServerEvent("Write_Data", 3, 0)
                    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET")
                    DeleteCheckpoint(checkpoint)
                    RemoveBlip(blip)
                    is_racing = false
                    cP = 1
                    cP2 = 2
					cp_1 = {}
					cp_2 = {}
                            
                    local _neu, driftScoreNeu = StatGetInt("MP0_DRIFT_SCORE",-1)
                    local achieved_score = driftScoreNeu - currentScore
                    local any_win = false
					-- New Checks cauz of drift scores
                            
                    --if tonumber(drift_table[2]) < achieved_score then -- Check for drift record
                    --    TriggerEvent("chatMessage", "^*^g[^lNN Bot^g]^r", {0,0,0}, string.format(GetPlayerName(PlayerId()) .. "^0^* finished ^l" .. line_1 .. " " .. line_2 .. " ^r^*^0with a score of ^l^_" .. achieved_score .. "^r^*^0 and a time of ^l^_" .. formatTimer(startTime, GetGameTimer()) .. "^r^*^0, a new drift record!"))
                    --    TriggerServerEvent("pRace:SaveRecord", 1, course_name, GetPlayerName(PlayerId()),  achieved_score)
                    --    any_win = true
                    --else
                    --    any_win = false
                    --end
					local penalty_seconds = 2000 * user_collisions
  
                    if tonumber(GetGameTimer() - (startTime - penalty_seconds)) < tonumber(time_table[2]) then -- Check for time record
                        TriggerEvent("chatMessage", "^*^g[^lNN Bot^g]^r", {0,0,0}, string.format("^0^* Finished ^l" .. line_1 .. " " .. line_2 .. " ^r^*^0with ^l" .. user_collisions .. " ^r^*^0crashes, a time of ^l^_" .. formatTimer(startTime - penalty_seconds, GetGameTimer()) .. "^r^*^0 and a score of ^l^_" .. achieved_score .. "^r^*^0, a new time record!"))
                        TriggerServerEvent("pRace:SaveRecord", 0, course_name, GetPlayerName(PlayerId()),  GetGameTimer() - (startTime - penalty_seconds), GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(usr_vehicle))))
						TriggerServerEvent("Write_Data", 1, 1)
                        any_win = true
                    else
						TriggerServerEvent("Write_Data", 2, 1)
                        any_win = false
                    end
    
                    if any_win == false then -- If no win output this message
                        TriggerEvent("chatMessage", "^*^g[^lNN Bot^g]^r", {0,0,0}, string.format("^0^* Finished ^l" .. line_1 .. " " .. line_2 .. " ^r^*^0with ^l" .. user_collisions .. " ^r^*^0crashes, a time of ^l^_" .. formatTimer(startTime - penalty_seconds, GetGameTimer()) .. "^r^*^0 and a score of ^l^_" .. achieved_score))
                    end
                end
			end
			if time_g < 240 or time_b < 240 and color_trigger < 1  then
				if (last_collission + 500) < GetGameTimer() then
					time_g = 240
					time_b = 240
				end
			end
		end
	end)
end)
