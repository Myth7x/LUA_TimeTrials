--[[
    PrTn's-Racing [SERVER]
]]


--[[
    PrTn's-Racing [SERVER] Events
]]
local print_log = false -- Enable Log on Server Console/Cmd

-- Drop Player
RegisterServerEvent("pRace:Need2DropPlayer")
AddEventHandler("pRace:Need2DropPlayer", function(reason)
	DropPlayer(source, reason)
end)

-- Load Record
RegisterServerEvent("pRace:LoadRecord")
AddEventHandler("pRace:LoadRecord", function(course)
    local record_string = ""


    -- Read Time Record File
    local time_file = io.open("DATA/trial_records/" .. course .. "_time_record.txt", "r")
    if time_file then
        record_string = time_file:read()
        if print_log then print("[PW] - Got time records: " .. record_string) end
    else
        if print_log then print("[PW] - Could not load time record file!") end
    end
    time_file:close()

    -- Read Drift Record File
    --local drift_file = io.open("DATA/trial_records/" .. course .. "_drift_record.txt", "r")
    --if drift_file then
     --   record_string = record_string .. "," .. drift_file:read()
        --if print_log then print("[PW] - Got drift records: " .. record_string) end
    --else
    --    if print_log then print("[PW] - Could not load drift record file!") end
    --end
    --drift_file:close()

    local record_table = split(record_string, ",")

    TriggerClientEvent("pRace:" .. course .. "GetRecord", source, record_table)
end)

-- Save Record
RegisterServerEvent("pRace:SaveRecord")
AddEventHandler("pRace:SaveRecord", function(record_type, course, player_name, record_value, car_name)
	if record_type == 0 then
		-- Write Time Record File
		local time_file = io.open("DATA/trial_records/" .. course .. "_time_record.txt", "w")
		if time_file then
			time_file:write(player_name .. "," .. record_value .. "," .. car_name)
			if print_log then print("[PW] - Saved time record for Course: " .. course .. " - " .. player_name .. "," .. record_value .. ", " .. car_name) end
			print("[Trials Rekord] - Race: " .. course .. ", User: " .. player_name .. ", Time: " .. record_value .. ", Car: " .. car_name)
		else
			if print_log then print("[PW] - Could not save time record file!") end
		end
		time_file:close()
	elseif record_type == 1 then
		-- Write Drift Record File
		local drift_file = io.open("DATA/trial_records/" .. course .. "_drift_record.txt", "w")
		if drift_file then
			drift_file:write(player_name .. "," .. record_value)
			if print_log then print("[PW] - Saved drift record for Course: " .. course .. " - " .. player_name .. "," .. record_value) end
			print("[Trials Rekord] - Race: " .. course .. ", User: " .. player_name .. ", Time: " .. record_value)
		else
			if print_log then print("[PW] - Could not save drift record file!") end
		end
		drift_file:close()
	else
		if print_log then print("[PW] - Cannot save with given arguments!") end
	end
end)

--[[
    PrTn's-Racing [SERVER] Functions
]]
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