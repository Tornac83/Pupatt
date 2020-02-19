--[[
* Ashita - Copyright (c) 2014 - 2016 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

_addon.author   = 'tornac';
_addon.name     = 'pupatt';
_addon.version  = '1.01';

---------------------------------
--DO NOT EDIT BELOW THIS LINE
---------------------------------

require 'common'
require 'ffxi.recast'
require 'logging'

--------------------------------------------------------------
-- Create a table for holding the current profile to be written
--------------------------------------------------------------
currentProfile = { };


attachmentQueue = { };  -- Table to hold commands queued for sending
objDelay        = 0.65; -- The delay to prevent spamming packets.
objTimer        = 0;    -- The current time used for delaying packets.
unequip			= 0x00;
pupSub			= 0x00;

currentAttachments = {}; -- table for holding current attachments
pupattProfiles = { }; -- table for holding attachment profiles

---------------------------------------------------------------
--try to load  file when addon is loaded
---------------------------------------------------------------
ashita.register_event('load', function()
    load_pupattSettings();
end);

------------------------------------------------------------------------------------------------
-- desc: Getting pup information.
----------------------------------------------------------------------------------------------------

ashita.register_event('incoming_packet', function(id, size, packet)
	-- Party Member's Status
	if (id == 0x044) then
		DiffPack		= struct.unpack('B', packet, 0x05 + 1);
		equippedOffset = 1; -- Increase by one byte every loop
		if (DiffPack == 0) then
        -- Unpack 14 bytes and set the slotid:attachmentid into currentAttachments table
			for i = 1, 14 do
			  attachmentId = string.format("0x0%X" , struct.unpack('B', packet, 0x08 + equippedOffset));
			  currentAttachments[i] = attachmentId;
			  equippedOffset = equippedOffset + 1;
			end
		end
	end
	return false;
end);

--Pass in a slot ID + hex id of the Attachment
-- Slot ID 1 = Head, 2=frame, 3-14 = attachment slots
function addAttachment(slot, id) 
	slots = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	slots[slot] = id;
	local attach = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, id, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, slots[1],slots[2],slots[3],slots[4],slots[5],slots[6],slots[7],slots[8],slots[9],slots[10],slots[11],slots[12],slots[13],slots[14]):totable();
	table.insert(attachmentQueue, { 0x102, attach});
end;
 
function clearAttachments() 
	local player					= GetPlayerEntity();
	local pet 						= GetEntity(player.PetTargetIndex);
	local recastTimerActivate   	= ashita.ffxi.recast.get_ability_recast_by_id(205);
	local recastTimerDeactivate   	= ashita.ffxi.recast.get_ability_recast_by_id(208);
	local recastTimerdeusex   		= ashita.ffxi.recast.get_ability_recast_by_id(115);
	if (recastTimerDeactivate == 0 and pet ~= nil) then
		AshitaCore:GetChatManager():QueueCommand('/ja "Deactivate" <me>' , 1);
	elseif(recastTimerDeactivate > 0) then
		print('Deactivate is not ready yet please try again later.')
		return true;
	end
	
	if currentAttachments[1] ~= nil and pet == nil then
		print ("Clearing Attachments");
		slots = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
		for slot,id in pairs(currentAttachments) do 
			slots[slot] = id;
		end
		slots[1] = 0x00;
		slots[2] = 0x00;
		for i,id in pairs(slots) do
			print(string.format("Equip ID: 0x%X", id));
		end
		print(string.format("Unequip: 0x%X", unequip));
		local unattach = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, 0x00, 0x00, 0x01, 0x00, 0x12, pupSub, 0x0000, slots[1],slots[2],slots[3],slots[4],slots[5],slots[6],slots[7],slots[8],slots[9],slots[10],slots[11],slots[12],slots[13],slots[14]):totable();
		table.insert(attachmentQueue, { 0x102, unattach});
	else
		print ("Current attachments not loaded, try zoning / equipping an attachment");
	end
end;

----------------------------------------------------------------------------------------------------
-- desc: Pup attachment struct.packing.
----------------------------------------------------------------------------------------------------

function load_pupatt(attachmentSet)

--	if (CurAttHead == nil) then
--		local CurAttOne = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, 0x01, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();
--		AddOutgoingPacket(0x102, CurAttOne);
--		print('please try again, Current pup attachement info not loaded.')
--	else

		local player					= GetPlayerEntity();
		local pet 						= GetEntity(player.PetTargetIndex);
		local recastTimerActivate   	= ashita.ffxi.recast.get_ability_recast_by_id(205);
		local recastTimerDeactivate   	= ashita.ffxi.recast.get_ability_recast_by_id(208);
		local recastTimerdeusex   		= ashita.ffxi.recast.get_ability_recast_by_id(115);
		local MainJob 					= AshitaCore:GetDataManager():GetPlayer():GetMainJob();
		local SubJob	 				= AshitaCore:GetDataManager():GetPlayer():GetSubJob();
		local buffs						= AshitaCore:GetDataManager():GetPlayer():GetBuffs();
		local limitpoints 				= AshitaCore:GetDataManager():GetPlayer():GetLimitPoints();
		local zone_id 					= AshitaCore:GetDataManager():GetParty():GetMemberZone(0);

		--print(MainJob, SubJob, buffs[0], limitpoints, zone_id)

		if (SubJob == 18) then
			local pupSub	= 0x01;
		end

		if (recastTimerDeactivate == 0 and pet ~= nil) then
			AshitaCore:GetChatManager():QueueCommand('/ja "Deactivate" <me>' , 1);
		elseif(recastTimerDeactivate > 0) then
			print('Deactivate is not ready yet please try again later.')
		end
		if (MainJob == 18 or SubJob == 18) then
			for slot,item in ipairs(attachmentSet) do
				if(currentAttachments[slot] ~= attachmentSet[slot]) then
				  addAttachment(slot,item);
				end
			end
		end
--	end
end;

---------------------------------------------------------------------------------------------------
-- func: new_profile
-- desc: Creates new profile with current objectives
---------------------------------------------------------------------------------------------------
function new_profile(profileName)
	print("Saving current attachments to profile " .. profileName)
	newProfile = {}
	for k,v in pairs (currentAttachments) do
		convv = string.format("0x%X",v)
		if (__debug) then
			print(string.format("slot id and attachmentId: %d, 0x%X", k, v));
			print(convk)
			print(convv)
		end
		table.insert(newProfile, convv)
	end
	pupattProfiles[profileName] = newProfile;
end;

---------------------------------------------------------------------------------------------------
-- func: list_profiles
-- desc: Lists saved profiles
---------------------------------------------------------------------------------------------------
function list_profiles()
	print("Current Profiles:\n")
	printProfiles = ashita.settings.JSON:encode_pretty(pupattProfiles, nil, {pretty = true, indent = "->    " });
	print(printProfiles);
end;

----------------------------------------------------------------------------------------------------
-- func: process_queue
-- desc: Processes the packet queue to be sent.
----------------------------------------------------------------------------------------------------
function process_queue()
    if  (os.time() >= (objTimer + objDelay)) then
        objTimer = os.time();

        -- Ensure the queue has something to process..
        if (#attachmentQueue > 0) then
            -- Obtain the first queue entry..
            local data = table.remove(attachmentQueue, 1);

            -- Send the queued object..
            AddOutgoingPacket(data[1], data[2]);
        end
    end
end

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Process the objectives packet queue..
    process_queue();
end);


---------------------------------------------------------------------------------------------------
-- func: load_pupattSettings
-- desc: load pup attachments from a file
---------------------------------------------------------------------------------------------------
function load_pupattSettings()
    local tempCommands = ashita.settings.load(_addon.path .. '/settings/pupattProfiles.json');
	if tempCommands ~= nil then
		print('Stored objective profiles found.');
		pupattProfiles = tempCommands;
	else
		print('pupatt profiles could not be loaded. Creating empty lists.');
		pupattProfiles = { };
	end
end;

---------------------------------------------------------------------------------------------------
-- func: save_pupattProfile
-- desc: saves current pup attachment profiles to a file
---------------------------------------------------------------------------------------------------
function save_profiles()
	print("Writing saved profiles to file settings/pupattProfiles.json");
	-- Save the addon settings to a file (from the addonSettings table)
	ashita.settings.save(_addon.path .. '/settings'  
						 .. '/pupattProfiles.json' , pupattProfiles);
end;

ashita.register_event('command', function(command, ntype)
    -- Get the arguments of the command..
    local args = command:args();

    if (args[1] ~= '/pupatt') then
        return false;
    end

    if (#args == 3 and args[2] == 'newprofile') then
  		new_profile(args[3])
  		return true;
  	end

    if (#args >= 2 and args[2] == 'list') then
  		list_profiles()
  		return true;
  	end
	
    if (#args >= 2 and args[2] == 'current') then
		currentAtt = ashita.settings.JSON:encode_pretty(currentAttachments, nil, {pretty = true, indent = "->    " });
		print(currentAtt);
  		return true;
  	end
	
    if (#args >= 2 and args[2] == 'save') then
  		save_profiles()
  		return true;
  	end
	
    if (#args >= 2 and args[2] == 'clear') then
  		clearAttachments()
  		return true;
  	end
	
	if (#args >= 2 and args[2] == 'loadprofile') then
  		print("Loading " .. args[3]);
		if pupattProfiles[args[3]] then
			clearAttachments();
			load_pupatt(pupattProfiles[args[3]]);
		else
			print (args[3] .. " profile not found");
		end
  		return true;
  	end

	if (#args >= 2 and args[2] == 'dd') then
		--try to load pupatt file when called.
		load_pupatt('0x02','0x22','0x03','0x0B','0x11','0x05','0x12','0x0F','0x50','0x46','0x49','0xC6','0xCE','0xCD');
		--print("hello World")
		return true;
	end

	if (#args >= 2 and args[2] == '60') then
		--try to load pupatt file when called.
		load_pupatt('0x02','0x21','0xCA','0xA7','0x46','0x49','0xC6','0x64','0x6A','0x84','0x87','0x04','0x0A','0xA2');
		return true;
	end
end);
