
addon.name      = 'sneak';
addon.author    = 'arosecra';
addon.version   = '1.0';
addon.desc      = '';
addon.link      = '';

require('common');

ashita.events.register('load', 'sneak_load_callback1', function ()
    print("[sneak] 'load' event was called.");
end);

ashita.events.register('unload', 'sneak_unload_callback1', function ()
    print("[sneak] 'unload' event was called.");
end);

local function is_alpha_first_mage()
    local memoryManager = AshitaCore:GetMemoryManager();
    local party = memoryManager:GetParty();

    local mainjob_mages = 0
    local subjob_mages = 0
    local non_self_sneakers = 0;
    local alphabetically_highest_main_mage_name = nil;
    local alphabetically_highest_sub_mage_name = nil;
    local player_name = party:GetMemberName(0);
    for i=0,5 do
        local name = party:GetMemberName(i);
		local mainjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberMainJob(i));
		local subjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberSubJob(i));
        if mainjob ~= nil then
            print(mainjob)
            if mainjob == "WHM" or
                   mainjob == "RDM" or
                   mainjob == "SCH" then
                mainjob_mages = mainjob_mages + 1

                if alphabetically_highest_main_mage_name == nil or
                   alphabetically_highest_main_mage_name > name then
                    alphabetically_highest_main_mage_name = name;
                end
            end
            if subjob == "WHM" or
               subjob == "RDM" or
               subjob == "SCH" then
                subjob_mages = subjob_mages + 1

                if alphabetically_highest_sub_mage_name == nil or
                   alphabetically_highest_sub_mage_name > name then
                    alphabetically_highest_sub_mage_name = name;
                end
            end
            if mainjob ~= "DNC" and
                subjob ~= "DNC" and
                mainjob ~= "WHM" and
                subjob ~= "WHM" and
                mainjob ~= "RDM" and
                subjob ~= "RDM" and
                mainjob ~= "SCH" and
                subjob ~= "SCH" then
                non_self_sneakers = non_self_sneakers + 1;
            end
        end
    end

    return non_self_sneakers > 0 and 
        (mainjob_mages > 0 and
            alphabetically_highest_main_mage_name == player_name) or
        (mainjob_mages == 0 and
            subjob_mages > 0 and
            alphabetically_highest_sub_mage_name == player_name);
end

local function sneak_invis_DNC()
    AshitaCore:GetChatManager():QueueCommand(1, '/ja "Spectral Jig" <me>');
end

local function sneak_invis_spell(target)
    AshitaCore:GetChatManager():QueueCommand(1, '/ma "Sneak" ' .. target);
    coroutine.sleep(10);
    AshitaCore:GetChatManager():QueueCommand(1, '/ma "Invisible" ' .. target);
end

local function sneak_invis_mage()
    --local non_mages_to_sneak = {};
    
    -- check if i am the alphabetically highest mage in the party
    local need_to_sneak_party = is_alpha_first_mage();
    if(need_to_sneak_party) then
        local memoryManager = AshitaCore:GetMemoryManager();
        local party = memoryManager:GetParty();
        for i=1,5 do
            local name = party:GetMemberName(i);
			local mainjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberMainJob(i));
			local subjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberSubJob(i));
            if mainjob ~= "DNC" and
               subjob ~= "DNC" and
               mainjob ~= "WHM" and
               subjob ~= "WHM" and
               mainjob ~= "RDM" and
               subjob ~= "RDM" and
               mainjob ~= "SCH" and
               subjob ~= "SCH" then
                sneak_invis_spell(name);
                coroutine.sleep(10);
            end
        end
        sneak_invis_spell('<me>');
    else
        sneak_invis_spell('<me>');
    end
end

ashita.events.register('command', 'sneak_command_callback1', function (e)
    if (e.command == '/sneak') then
        local memoryManager = AshitaCore:GetMemoryManager();
        local party = memoryManager:GetParty();
		local mainjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberMainJob(0));
		local subjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberSubJob(0));
        
        if mainjob == "DNC" or
            subjob == "DNC" then
            sneak_invis_DNC();
        elseif mainjob == "WHM" or
            subjob == "WHM" or
            mainjob == "RDM" or
            subjob == "RDM" or
            mainjob == "SCH" or
            subjob == "SCH" then
            sneak_invis_mage();
        end
        e.blocked = true;
    end
end);
