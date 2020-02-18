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
_addon.version  = '1.00';

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


objectivesQueue = { };  -- Table to hold commands queued for sending
objDelay        = 0.65; -- The delay to prevent spamming packets.
objTimer        = 0;    -- The current time used for delaying packets.
unequip			= 0x00;
pupSub			= 0x00;

---------------------------------------------------------------
--try to load objectives file when addon is loaded
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
			if (DiffPack == 0) then
				CurAttHead		= string.format("0x0%X" , struct.unpack('B', packet, 0x08 + 1));
				CurAttBody 		= string.format("0x%X" ,struct.unpack('B', packet, 0x09 + 1));
				CurAttOne 		= struct.unpack('B', packet, 0x0A + 1);
				CurAttTwo 		= struct.unpack('B', packet, 0x0B + 1);
				CurAttThree 	= struct.unpack('B', packet, 0x0C + 1);
				CurAttFour 		= struct.unpack('B', packet, 0x0D + 1);
				CurAttFive 		= struct.unpack('B', packet, 0x0E + 1);
				CurAttSix 		= struct.unpack('B', packet, 0x0F + 1);
				CurAttSeven 	= struct.unpack('B', packet, 0x10 + 1);
				CurAttEight 	= struct.unpack('B', packet, 0x11 + 1);
				CurAttNine 		= struct.unpack('B', packet, 0x12 + 1);
				CurAttTen 		= struct.unpack('B', packet, 0x13 + 1);
				CurAttEleven 	= struct.unpack('B', packet, 0x14 + 1);
				CurAttTwelve 	= struct.unpack('B', packet, 0x15 + 1);
				--print(CurAttHead, CurAttBody, CurAttOne, CurAttTwo, CurAttThree, CurAttFour, CurAttFive, CurAttSix, CurAttSeven, CurAttEight, CurAttNine, CurAttTen, CurAttEleven, CurAttTwelve);
				--print(tonumber("0xCE"));
				--print(string.format(CurAttHead))
				--print(string.len(CurAttHead))
				--print(CurAttHead, CurAttBody)
			end
	end
	return false;
end);

print(CurAttHead)

----------------------------------------------------------------------------------------------------
-- desc: Pup attachment struct.packing.
----------------------------------------------------------------------------------------------------

function load_pupatt(eqAttHead, eqAttBody, eqAttOne, eqAttTwo, eqAttThree, eqAttFour, eqAttFive, eqAttSix, eqAttSeven, eqAttEight, eqAttNine, eqAttTen, eqAttEleven, eqAttTwelve)

	if (CurAttHead == nil) then
		local CurAttOne = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, 0x01, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();
		AddOutgoingPacket(0x102, CurAttOne);
		print('please try again, Current pup attachement info not loaded.')
	else

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

		--Attachement Head	
			
			print(CurAttHead, eqAttHead)
			
			if (CurAttHead == eqAttHead) then
			print('same')
			else
				head = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttHead, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, eqAttHead, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

				table.insert(objectivesQueue, { 0x102, head});
			end

		--Attachement Frame

			if (CurAttBody == eqAttBody) then
			print('same')
			else
				local frame = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttBody, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, eqAttBody, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

				table.insert(objectivesQueue, { 0x102, frame});
			end
			
		--Attachement One

			local attOne = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttOne, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, eqAttOne, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attOne});
			
			--Attachment Two


			local attTwo = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttTwo, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, eqAttTwo, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attTwo});

			--Attachement Three


			local attThree = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttThree, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, eqAttThree, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attThree});

			--Attachement Four

			local attFour = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttFour, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttFour, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attFour});

			--Attachement Five

			local attFive = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttFive, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttFive, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attFive});

			--Attachement Six

			local attSix = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttSix, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttSix, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attSix});

			--Attachement Seven

			local attSeven = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttSeven, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttSeven, 0x00, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attSeven});

			--Attachment Eight

			local attEight = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttEight, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttEight, 0x00, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attEight});

			--Attachement Nine

			local attNine = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttNine, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttNine, 0x00, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attNine});

			--Attachement Ten
			
			local attTen = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttTen, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttTen, 0x00, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attTen});

			--Attachement Eleven

			local attEleven = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttEleven, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttEleven, 0x00):totable();

			table.insert(objectivesQueue, { 0x102, attEleven});

			--Attachement Twelve

			local attTwelve = struct.pack('I2I2BBBBBBI2BBBBBBBBBBBBBB', 0x5302, 0x0000, eqAttTwelve, 0x00, unequip, 0x00, 0x12, pupSub, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, eqAttTwelve):totable();

			table.insert(objectivesQueue, { 0x102, attTwelve});
			
	end

end;
	
----------------------------------------------------------------------------------------------------
-- func: process_queue
-- desc: Processes the packet queue to be sent.
----------------------------------------------------------------------------------------------------
function process_queue()
    if  (os.time() >= (objTimer + objDelay)) then
        objTimer = os.time();

        -- Ensure the queue has something to process..
        if (#objectivesQueue > 0) then
            -- Obtain the first queue entry..
            local data = table.remove(objectivesQueue, 1);

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
-- func: load_objectives
-- desc: load RoE objectives from a file
---------------------------------------------------------------------------------------------------
function load_pupattSettings()
    local tempCommands = ashita.settings.load(_addon.path .. '/settings/pupatt.json');
	if tempCommands ~= nil then
		print('Stored objective profiles found.');
		pupattProfiles = tempCommands;		
	else
		print('pupatt profiles could not be loaded. Creating empty lists.');
		pupattProfiles = { };
	end
end;
	
	--AddOutgoingPacket(0x102, attchange);
	--Send a unity ranking menu packet to look natural like we opened the menu?
	--local testequip = struct.pack('BBI2BB', 0x50, 0x04, 0x0000, 0x03, 0x06):totable();
	--AddOutgoingPacket(0x050, testequip);

ashita.register_event('command', function(command, ntype)
    -- Get the arguments of the command..
    local args = command:args();

    if (args[1] ~= '/pupatt') then
        return false;
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
