--Agent48--

this.SubType = 1 -- Disguised as prisoner

-- Test
-- this.mission_type = 'backstab'
-- this.mission_type = 'scuffle'
-- this.mission_type = 'food'
-- this.mission_type = 'fire'
-- this.mission_type = 'grenade'
-- this.mission_type = 'playdead'
-- this.mission_type = 'outbreak'
-- this.step = 1
--

local nearbyRange = 5
local Delay = 0.1 -- Clock Minutes

-- Utils

function round( n )
	return math.floor(n + 0.5)
end
function tableHas(t, value)
	for k, v in pairs(t) do
		if value == v then return true end
	end
	return false
end

function index(t, value)
	for k, v in pairs(t) do
		if value == v then return k end
	end
	return nil
end

function extend( t1, t2 )
	if t2 then
		for i, v in pairs(t2) do
			table.insert(t1, v)
		end
	end
	return t1
end

function sizeOf(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end




local target
local marker
local targetDirIndicator
local ms -- mission step table
local need_range_between_target_and_you = 1 -- mission step table


local types_guard = {"Guard", "ArmedGuard", "DogHandler", "Sniper"}
local types_door = {"StaffDoor", "JailDoor", "JailDoorLarge", "JailDoorXL","SolitaryDoor", "RoadGate"}


function look_around(types, cb, range, justOne)
	local who = this
	if ms and ms.escaping and target then
		who = target
	end
	local count = 0
	if range == "max" then range = 9999 end
	for k, v in pairs(types) do
		local os = who.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			count = count + 1
			if cb then
				cb(o)
			else
			end
			if justOne then return o end
		end
	end
	if justOne then
		return nil
	else
		return count
	end
end


function search(uid, types, center_object, range)
	center_object = center_object or this
	if range == "max" then range = 9999 end

	for k, v in pairs(types) do
		local os = center_object.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			if o.Id.u == uid then
				-- print("Found object "..v.." #"..uid)
				return o
			end
		end
	end
	return nil
end


function deleteO( o )
	o.Delete()
end
function still( o )
	return (o.Vel.x == 0 and o.Vel.y == 0)
end
function makeStill( o )
	o.ApplyVelocity(0, 0)
	-- o.Vel.x = 0
	-- o.Vel.y = 0
end

function dist( from, to )
	return math.pow(math.pow( (from.Pos.x - to.Pos.x), 2) + math.pow( (from.Pos.y - to.Pos.y), 2) , 0.5)
end


function angleOf( x, y )
	return math.floor(math.atan2(x, y)/math.pi*180 + 0.5)
end




function makeVigilent(g)
	if g.Hidden then return end
	if g.Damage < 0.7 then
		if g.TargetObject.u <= 0 and g.Carrying.u <= 0 and canSee(g, target) then
			-- print('Coming after target!')
			target.Sound("Guard", "AlertBegin") --
			makeAttack(g, target)
		end
		local d = dist(g, target)
		if d < 1 then
			target.Sound("_Tools", "HitBy_Baton") --
			target.Damage = target.Damage + (0.1 * Delay)
			g.Vel.x = 0
			g.Vel.y = 0
		end
		if g.TargetObject.u == target.Id.u then
				guardGo(g, target)
		end
	end
end


function pursuitYou(g)
	if dist(g, this) < 1.2 then
		this.Sound("_Tools", "HitBy_Baton") --
		this.Damage = this.Damage + (0.1 * Delay)
	else
		nav(g, this)
	end
end

function openDoor(o)
	local g = Object.Spawn("Guard", o.Pos.x, o.Pos.y)
	g.Hidden = true
	g.CreateJob("OpenDoor")
end

function makeAttack(from, to)
	from.TargetObject.u = to.Id.u
	from.TargetObject.i = to.Id.i
	if from.Type == 'Prisoner' then
		from.Misbehavior = 5
	else
		-- Guard won't fight, but will shackle `to` if they get close enough.
	end
end


function setFire(o)
	local fire = Object.Spawn("Fire", o.Pos.x, o.Pos.y)
	fire.Fuel = 20
	fire.Intensity = 0.5
	return fire
end

function escape(o)
	o.Misbehavior = 2
end

function Flee()
	this.LeaveMap()
	att = this.Attacker
end


function farFromTarget( other_than_target )
	return dist(this, target) > need_range_between_target_and_you
end

function needPrisonersAroundTarget( need_count, range )
	local count = 0
	local pz = target.GetNearbyObjects("Prisoner", range)
	for p, dist in pairs(pz) do
		count = count + 1
	end

	local passed = (count >= need_count)

	return {
		caption = {'prisoners_around_target', 'Caption', count, "C", need_count, "N", tostring(passed), "B"},
		failed = not passed
	}
end



local targetmarker_range = 1.4

function markTarget()
	if this.target_id then
		-- Scan whole map
		target = search(this.target_id, {"Prisoner"}, this, "max")
		if target then
			if this.target_id == target.Id.u and target.Damage < 1 then
				-- a good match and not dead
			else
				-- renew target_id
				this.target_id = target.Id.u
			end
		else
			-- No such target prisoner
			this.target_id = nil
		end
	else
		target = look_around({"Prisoner"}, nil, targetmarker_range, true)

		if target then
			if target.Damage >= 0.7 or target.Shackled then
				target = nil
			else
				this.Sound("Doctor", "Place") -- Q
				this.target_id = target.Id.u
			end
		end
	end

	if target then
		marker = look_around({"HitmanMarker"}, nil, 'max', true) or Object.Spawn("HitmanMarker", target.Pos.x, target.Pos.y)
		marker.target_id = target.Id.u
		targetDirIndicator = Object.Spawn("TargetDirection", target.Pos.x, target.Pos.y)
	end
end












-- this.mission_type
-- this.mission_step


local success_rate = 0
this.weapon = this.weapon or "Pianowire"


local disguisez = {"Prisoner", "Janitor", "Workman", "Doctor", "Guard"}
local accessz = {
	{
	},
	{ -- Janitor
		Knife = 100,
		Scissors = 50,
		Poison = 100,
		Flammable = 50,
		Ingredient = 80,
		-- GuardUniform = 40,
	},
	{ -- Workman
		FakeExtinguisher = 100,
		Knife = 10,
		Shank = 100,
		Lighter = 50,
		MobilePhone = 50,
		Flammable = 100,
	},
	{ -- Doctor
		Poison = 100,
		Scissors = 50,
		MobilePhone = 100,
		Dynamite = 30,
		Lighter = 30,
		Medicine = 100,
		Ingredient = 50,
	},
	{ --Guard
		MobilePhone = 100,
		Dynamite = 100,
		FakeExtinguisher = 50,
		Lighter = 100,
		-- GuardUniform = 100,
	},
}

local weapon_powerz = {
	Pianowire = 10,
	Knife = 30,
	Shank = 40,
}







-- witness and exposure rate --

local can_get_item_name = nil

-- this.weapon = "Pianowire"

local witness_types = {"Prisoner", "Janitor", "Workman", "Doctor", "Guard", "DogHandler", "ArmedGuard", "Sniper", "Cctv"}
local witness_range = 6
local focused_target = nil
local ter = 0 -- total exposure rate


-- prepare enough sight markers
local sightmarkerz = {}

local sightmarker_used_count = 0 -- How many to show
local sightmarker_posz = {} -- Positions for markers. No duplicate.


function markSightAt(x, y)
	sightmarker_posz[x][y] = true
	sightmarker_used_count = sightmarker_used_count + 1
	local m = sightmarkerz[sightmarker_used_count]
	if m then
		m.Pos.x = x
		m.Pos.y = y
	end
end

function relativeAngle(from, to)
	local angle_t = angleOf(from.Or.x, from.Or.y)
	local angle_x = to.Pos.x-from.Pos.x
	local angle_y = to.Pos.y-from.Pos.y
	local angle_me = angleOf(angle_x, angle_y)
	local angle = (angle_t - angle_me) % 360
	return angle
end

function keepClose(from, to, max_dist)
	max_dist = max_dist or 0.8
	local d = dist(from, to)
	if d > max_dist then
		from.Pos.x = (from.Pos.x - to.Pos.x)/d*max_dist + to.Pos.x
		from.Pos.y = (from.Pos.y - to.Pos.y)/d*max_dist + to.Pos.y
	end
end

function followMe()
	local d = dist(target, this)
	if d > 1.2 then
		target.AvatarControl = false
		nav(target, this)
	else
		target.AvatarControl = true
	end
end

function reachFocusedTarget(miz)
	local angle = relativeAngle(focused_target, this)
	local penalty = math.abs(angle - 180)

	table.insert(miz, {"view_angle", "Caption", angle, "X"})
	table.insert(miz, {"view_penalty", "Caption", penalty, "X"})
	return penalty
end

function witnessed()
	local witness_number = 0
	local cctv_number = 0
	local exposure_rate = 0
	local os
	local miz = {}

	sightmarker_posz = {}
	sightmarker_used_count = 0

	-- Prisoners or staff
	for k, v in pairs(witness_types) do
		os = this.GetNearbyObjects(v, witness_range)
		for o, distance in pairs( os ) do
			if focused_target and o.Id.u == focused_target.Id.u then
				local focused_target_exposure_rate = (ms.exposure or reachFocusedTarget)(miz)
				exposure_rate = exposure_rate + focused_target_exposure_rate
			elseif o.AvatarControl then
				--
			elseif (this.mission_type == 'playdead' or this.mission_type == 'outbreak') and o.Id.u == target.Id.u then
				--
			elseif canSee(o, this) then
				witness_number = witness_number + 1
				exposure_rate = exposure_rate + 100 * (1 - distance/witness_range)
			end
		end
	end

	for i, m in pairs(sightmarkerz) do
		if i <= sightmarker_used_count then
			m.Hidden = false
		else
			m.Pos.x = sightmarker_used_count
			m.Pos.y = 1
			m.Hidden = true
		end
	end

	extend (miz, {
		{"witness_number", "Caption", witness_number, "X"},
	})

	if can_get_item_name then
		-- print('can_get_item_name')
		-- print(can_get_item_name)
		-- print(accessz[this.SubType])
		local disguise_access = accessz[this.SubType][can_get_item_name] or 0
		-- print(disguise_access)
		exposure_rate = exposure_rate - disguise_access
		if disguise_access > 0 then
			table.insert(miz, {"disguise_access", "Caption", disguise_access, "X"})
		else
			table.insert(miz, {"disguise_access_none", "Caption"})
		end
	end

	table.insert(miz, {"exposure_rate", "Caption", ter, "X"})
	table.insert(miz, {"sep", "Caption"})

	ter = math.floor(exposure_rate)
	return miz
end





-- Only walls can be checked as things to block view.
local walltypes = {'BrickWall', 'ConcreteWall', 'PerimeterWall'}
-- Doors are completely different and thus very difficulty for me to do the same check.

-- from (x, y) some witness candidate may see you
function canSee(from, to)
	if from.Damage >= 0.7 then
		return false
	end

	local from_x = from.Pos.x
	local from_y = from.Pos.y-0.5
	local to_x = to.Pos.x
	local to_y = to.Pos.y-0.5
	local steps = witness_range*5
	local step_x = (to_x - from_x)/steps
	local step_y = (to_y - from_y)/steps
	if math.abs(to_x - from_x) < 0.7 and math.abs(to_y - from_y) < 0.7 then return true end

	local x = from_x
	local y = from_y
	local marked_x_last
	local marked_y_last

	while steps > 0 do
		steps = steps - 1
		x = x + step_x
		y = y + step_y
		if math.abs(x - to_x) < 0.7 and math.abs(y - to_y) < 0.7 then return true end
		local marked_x = round(x) + 0.5
		local marked_y = round(y) + 0.5
		if marked_x_last == marked_x and marked_y_last == marked_y then
			-- nothing
		else
			local mat = Object.GetMaterial(marked_x, marked_y)
			if tableHas(walltypes, mat) then
				-- print('----------VIEW BLOCKED----------')
				return false
			end
			marked_x_last = marked_x
			marked_y_last = marked_y
			local spx = sightmarker_posz[marked_x]
			if spx then
				if spx[marked_y] then
				else
					markSightAt(marked_x, marked_y)
				end
			else
				sightmarker_posz[marked_x] = {}
				markSightAt(marked_x, marked_y)
			end

		end
	end

	return true
end


local disguise_subtype = nil

function needDisgise()
	local subtype = index(disguisez, ms.need_disguise)
	if subtype then
		disguise_subtype = subtype
		return true
	end
	return false
end

function menu_disguise()
	local miz = {}
	if disguise_subtype and this.SubType ~= disguise_subtype then
		table.insert(miz, {"disguise_required", "Caption", 'object_'..disguisez[disguise_subtype], "X"})
	end
	extend (miz, witnessed())
	if not focused_target and not can_get_item_name then
		table.insert(miz, {"action_disguise", "Button"})
	end
	return miz
end


function UiAct( failed, notTarget, actionName )
	actionName = actionName or this.mission_type
	local cmp_action = {"action_"..actionName, "Button"}
	if failed then
		cmp_action = {"action_requirement_failed", "Caption"}
	elseif not notTarget and farFromTarget() then
		cmp_action = {"far_from_target", "Caption"}
	end
	return cmp_action
end









-- You can take items at related sources

local itemSourcez = {
	backstab = {
		Knife = {
			'Cooker',
			'MorgueSlab',
		},
		Shank = {
			'WorkshopSaw',
		},
	},
	food = {
		Ingredient = {
			'Cooker',
			'MorgueSlab',
		},
		Poison = {
			'Bleach',
			'MedicalBed',
		},
	},
	fire = {
		Flammable = {
			'Cooker',
			'PowerStation',
		},
		Lighter = {
			'OfficeDesk',
		},
	},
	grenade = {
		Dynamite = {
			'WeaponRack',
			'ShopShelf',
		},
		Lighter = {
			'OfficeDesk',
		},
		Scissors = {
			'MorgueSlab',
			'SortingTable',
			'MedicalBed',
		},
	},

	playdead = {
		Medicine = {
			'MedicalBed',
		},
	},
	outbreak = {
		MobilePhone = {
			'FilingCabinet',
			'VisitorTable',
			'SofaChairDouble',
		},
		FakeExtinguisher = {
			'TruckDriver',
		},
	},
}


local oItemIcon

function checkSource()
	local miz = {}
	-- if oItemIcon then
	-- 	-- oItemIcon.Hidden = true
	-- end
	can_get_item_name = nil


	local dict = itemSourcez[this.mission_type]
	if dict then
		for itemName, sourcez in pairs(dict) do
			if this['has_item_'..itemName] then
				table.insert(miz, {"has_item", 'Caption', "object_icon_"..itemName, 'X'})
			else
				table.insert(miz, { {"need_item"..itemName, "need_item"}, 'Caption', "object_icon_"..itemName, 'X'})
				for i, sourceName in pairs(sourcez) do
					if can_get_item_name then
						table.insert(miz, {{"item_source_"..sourceName, "item_source"}, 'Caption', "object_"..sourceName, 'X'})
					else
						-- print(sourceName)
						local o = look_around({sourceName}, nil, 2, true)
						if o then
							-- print('A source is nearby!')
							local icontype = 'Icon_'..itemName
							-- print(icontype)
							if oItemIcon then
								if oItemIcon.Type == icontype then
									oItemIcon.Pos.x = o.Pos.x
									local dy = (3 - math.floor(World.TimeIndex * 5) % 6) / 10
									oItemIcon.Pos.y = o.Pos.y - 0.7 + dy
								else
									oItemIcon.Delete()
									oItemIcon = Object.Spawn(icontype, o.Pos.x, o.Pos.y - 0.7)
								end
							else
								oItemIcon = Object.Spawn(icontype, o.Pos.x, o.Pos.y - 0.7)
							end
							oItemIcon.item_name = itemName
							can_get_item_name = itemName
							table.insert(miz, {"take_item", 'Button', "object_icon_"..itemName, 'X'})
						else
							table.insert(miz, {{"item_source_"..sourceName, "item_source"}, 'Caption', "object_"..sourceName, 'X'})
  							-- checkSourceOne(miz, sourceName)
						end
					end
				end
			end
		end
	end

	if oItemIcon and not can_get_item_name then
		oItemIcon.Delete()
		oItemIcon = nil
	end

	return miz
end
















-- for backstab
local bodyLevelz = {0, 2, 3, 1}

-- for scuffle
local scuffle_count = 8
local scuffle_range = 3

local meal
local cough_span = 6

local itemPrisonerUniform
local itemBedForUniform
local itemFlammableUniform
local obj_fire
local cry_span = 2

local pursuit_guard_range = 10


local mission_order = {'backstab', 'scuffle', 'food', 'fire', 'grenade', 'playdead', 'outbreak'}

local missions = {

-- Assassinate --
	backstab = {
		{
			main = function()
				local weapon_power = weapon_powerz[this.weapon]
				local target_strength = 10 + bodyLevelz[target.SubType+1] * 5
				local miz = checkSource()

				return extend(miz, {
					{"target_strength", "Caption", target_strength, "X"},
					{"weapon", "Caption", "equipment_"..this.weapon, "X"},
					{"weapon_power", "Caption", weapon_power, "X"},
					{"skip_step", "Button"},
				})
			end
		},
		{
			goback = true,
			main = function()
				focused_target = target
				local weapon_power = weapon_powerz[this.weapon]
				local target_strength = 10 + bodyLevelz[target.SubType+1] * 5
				success_rate = 100 - ter + weapon_power - target_strength
				checkSource()
				return {
					{"target_strength", "Caption", target_strength, "X"},
					{"weapon", "Caption", "equipment_"..this.weapon, "X"},
					{"weapon_power", "Caption", weapon_power, "X"},
					{"success_rate", "Caption", success_rate, "X"},
					UiAct(),
				}
			end
		},
		{
			keep_disguise = true,
			main = function()
				local miz = {
					{'damage', 'Caption', math.floor(target.Damage * 100), 'X'}
				}
				if target.Damage >= 1 then
					target.Sound("_Reports", "FireStaff") -- Hofp
					finishStep()
					return miz
				end
				if this.weapon == 'Pianowire' then
					keepClose(target, this)
				end
				target.Damage = target.Damage + (0.15 * Delay)
				return miz
			end
		}
	},

	scuffle = {
		{
			need_disguise = 'Guard'
		},
		{
			goback = true,
			keep_disguise = true,
			main = function()
				local miz = {}
				local failed
				if target.Shackled then
					failed = true
					table.insert(miz, {'shackled', 'Caption'})
				else
					need_range_between_target_and_you = 2
					local npat = needPrisonersAroundTarget(scuffle_count, scuffle_range)
					failed = npat.failed
					table.insert(miz, npat.caption)
				end
				table.insert(miz, UiAct(failed))
				return miz
			end
		},
		{
			keep_disguise = true,
			takedownTarget = function(g)
				g.WeaponDrawn = 5
				makeAttack(g, target)
			end,
			main = function()
				local miz = {
					{'damage', 'Caption', math.floor(target.Damage * 100), 'X'}
				}
				if target.Damage >= 1 then
					target.Sound("_Reports", "FireStaff") -- Hofp
					finishStep()
					return miz
				end

				if target.Shackled then
					reverseStep()
					return miz
					-- Try later
				end

				if target.Damage >= 0.5 then
					target.StatusEffects.wounded = target.Damage * 100
					target.Damage = target.Damage + (0.1 * Delay)
					table.insert(miz, {"target_bleeding", "Caption"})
				else
					target.Misbehavior = 5
					target.StatusEffects.tazed = 0
					look_around({'ArmedGuard'}, ms.takedownTarget)
					table.insert(miz, {"more_scuffle", "Button"})
				end
				return miz
			end
		},
	},


	food = {
		{
			main = function()
				local miz = checkSource()
				return miz
			end
		},
		{
			need_disguise = 'Prisoner'
		},
		{
			goback = true,
			keep_disguise = true,
			main = function()
				local miz = {}
				local failed = true
				if target.Carrying.u > 0 then
					if not meal then
						meal = search(target.Carrying.u, {'Meal'}, target, 2)
					end
				else
					meal = nil
				end
				failed = true
				if target.Shackled then
					table.insert(miz, {'shackled', 'Caption'})
				elseif not meal then
					table.insert(miz, {"need_meal", "Caption"})
				elseif not still(target) then
					table.insert(miz, {"need_eating", "Caption"})
				else
					failed = false
				end
				table.insert(miz, UiAct(failed))
				return miz
			end
		},
		{
			keep_disguise = true,
			main = function()
				local miz = {
					{'damage', 'Caption', math.floor(target.Damage * 100), 'X'}
				}
				if target.Carrying.u <= 0 then
					-- Has finished eating
					finishStep()
				else
					table.insert(miz, {"wait_target_eat", "Caption"})
				end
				return miz
			end
		},
		{
			keep_disguise = true,
			main = function()
				if target.Damage >= 1 then
					target.Sound("_Reports", "FireStaff") -- Hofp
					finishStep()
					return {}
				end
				if this.last_cough and Game.Time() < (this.last_cough + cough_span) then
				else
					-- print('Game.Time()')
					-- print(Game.Time())
					if target.Damage < 0.7 then
						target.Sound("__FoodFamily", "Coughing")
						this.last_cough = Game.Time()
					else
						this.last_cough = Game.Time() + 100 * cough_span
					end
				end
				target.StatusEffects.foodpoisoning = 500
				-- target.StatusEffects.virus = 1
				target.StatusEffects.withdrawal = 1000
				target.Damage = target.Damage + (0.03 * Delay)
				local miz = {
					{"target_poisoned", "Caption"}
				}
				return miz
			end
		}
	},


	fire = {
		{
			main = function()
				local miz = checkSource()
				return miz
			end
		},
		{
			need_disguise = 'Janitor'
		},
		{
			keep_disguise = true,
			main = function()
				local miz = {}
				itemPrisonerUniform = look_around({'PrisonerUniform'}, nil, 1.2, true)
				if itemPrisonerUniform then
					table.insert(miz, {"take_PrisonerUniform", "Button"})
				else
					table.insert(miz, {"need_PrisonerUniform", "Caption"})
				end
				return miz
			end
		},
		{
			goback = true,
			keep_disguise = true,
			main = function()
				local miz = {}
				itemBedForUniform = look_around({'Bed', 'BunkBed'}, nil, 1.2, true)
				if itemBedForUniform then
					table.insert(miz, {"putdown_PrisonerUniform", "Button"})
				else
					table.insert(miz, {"need_BedForUniform", "Caption"})
					table.insert(miz, {"need_BedForUniform_hint", "Caption"})
				end
				return miz
			end
		},
		{
			keep_disguise = true,
			main = function()
				-- wait
				local miz = {}
				local distance = dist(target, itemFlammableUniform)
				if distance <= 2 then
					target_puton_PrisonerUniform()
				else
					table.insert(miz, {"wait_target_puton", "Caption"})
				end
				return miz
			end
		},
		{
			goback = true,
			keep_disguise = true,
			main = function()
				focused_target = target
				local miz = {}
				table.insert(miz, UiAct())
				return miz
			end
		},
		{
			keep_disguise = true,
			main = function()
				local miz = {
					{'damage', 'Caption', math.floor(target.Damage * 100), 'X'}
				}

				if this.last_cry and Game.Time() < (this.last_cry + cry_span) then
				else
					if target.Damage < 0.7 then
						target.Sound("Guard", "Damage") -- whooerrr
						this.last_cry = Game.Time()
					else
						this.last_cry = Game.Time() + 100 * cry_span
					end
				end

				if target.Damage >= 1 then
					target.Sound("_Reports", "FireStaff") -- Hofp
					this.fire_id = nil
					finishStep()
					return miz
				end
				return miz
			end
		},
	},


	grenade = {
		{
			main = function()
				local miz = checkSource()
				return miz
			end
		},
		{
			goback = true,
			keep_disguise = true,
			main = function()
				local miz = {}
				local d = dist(target, this)
				if not canSee(target, this) then
					table.insert(miz, {"need_see_target", "Caption"})
				elseif d > 7 then
					table.insert(miz, {"grenade_too_far", "Caption"})
				elseif d < 4 then
					table.insert(miz, {"grenade_too_near", "Caption"})
				else
					table.insert(miz, {"throw_grenade", "Button"})
				end
				return miz
			end
		},
		{
			avoid_guard = true,
			main = function()
				local miz = {}
				table.insert(miz, {"hot_pursuit", "Caption"})
				return miz
			end
		},
	},

-- Rescue --
	playdead = {
		{
			main = function()
				local miz = checkSource()
				return miz
			end
		},
		{
			goback = true,
			keep_disguise = true,
			main = function()
				local miz = {}
				if dist(target, this) > 2 then
					table.insert(miz, {"too_far", "Caption"})
				else
					table.insert(miz, {"give_potion_to_playdead", "Button"})
				end
				return miz
			end
		},
	},


	outbreak = {
		{
			main = function()
				local miz = checkSource()
				return miz
			end
		},
		{
			need_disguise = 'Workman',
		},
		{
			keep_disguise = true,
			init = function()
				this.bomb_remaining = 3
			end,
			main = function()
				local miz = {
					{'bomb_remaining', 'Caption', this.bomb_remaining, 'X'}
				}
				if look_around({'FakeExtinguisher'}, nil, 1, true) then
					table.insert(miz, {"uninstall_bomb", "Button"})
				else
					table.insert(miz, {"install_bomb", "Button"})
				end
				return miz
			end
		},
		{
			keep_disguise = true,
			goback = true,
			main = function()
				local miz = {}
				if dist(target, this) > 6 then
					table.insert(miz, {"too_far", "Caption"})
				else
					table.insert(miz, {'pas_de_deux', 'Button'})
				end
				return miz
			end
		},
		{
			keep_disguise = true,
			pas_de_deux = true,
			init = function()
				target.AvatarControl = true
				this.followed = true
			end,
			main = function()
				local miz = {}
				table.insert(miz, {'followed', 'Button', 'a48__am__following_'..tostring( this.followed ), 'B'})

				local failed

				local guard_count = look_around(types_guard, nil, 1.2)
				if guard_count > 1 then
					failed = true
					table.insert(miz, {'more_than_one_guard', 'Caption'})
				elseif guard_count == 0 then
					failed = true
					table.insert(miz, {'you_must_reach_guard', 'Caption'})
				else
					local guard = look_around(types_guard, nil, 1.2, true)

					if math.abs(relativeAngle(guard, this) - 180) > 45 then
						failed = true
						table.insert(miz, {'guard_must_not_face_you', 'Caption'})
					end

					if math.abs(relativeAngle(guard, target) - 180) < 120 then
						failed = true
						table.insert(miz, {'guard_must_face_target', 'Caption'})
					end

					if not canSee(guard, target) then
						failed = true
						table.insert(miz, {'guard_must_cansee_target', 'Caption'})
					end

				end
				table.insert(miz, UiAct(failed, true))

				return miz
			end
		},
		{
			escaping = true,
			keep_disguise = true,
			init = function()
				this.SubType = 0
				target.AvatarControl = true
				local clothes = SpawnAt('A48Clothes', this)
				clothes.Tooltip = 'a48__target_info__outbreak'
				-- this.Hidden = true
			end,
			main = function()
				if target.Damage > 0.7 or target.Shackled then
					target.AvatarControl = false
					-- this.Hidden = false
					missionFailed()
					return {}
				end
				local miz = {
					{'damage', 'Caption', math.floor(target.Damage * 100), 'X'},
					{'to_borders', 'Caption'}
				}
				look_around({'Prisoner'}, makeEscape, 10)
				look_around(types_guard, makeVigilent, 5)

				-- Hack to open doors since I am unable to equip the target with jail keys
				look_around(types_guard, deleteHiddenGuard, 2.5)
				look_around(types_door, openDoor, 1.5)

				-- this.Pos.x = target.Pos.x
				-- this.Pos.y = target.Pos.y

				if nearBorder() then
					this.Pos.x = target.Pos.x
					this.Pos.y = target.Pos.y
					target.AvatarControl = false
					target.Misbehavior = 2
					finishStep()
					this.Delete()
					return {}
				end

				return miz
			end
		},
	},
}

extend(missions.playdead, missions.scuffle)



function nearBorder()
	if (World.NumCellsY - target.Pos.y < 2) or (World.NumCellsX - target.Pos.x < 2) or (target.Pos.x < 2) or (target.Pos.y < 2) then
		return true
	else
		return false
	end
end



if this.mission_type then
	ms = missions[this.mission_type][this.step]
	-- ms.main()
end


function startMission(type)
	this.Sound("__FoodFamily", "InfirmaryMusic2") -- Western/Marfia Theme
	Interface.RemoveComponent(this, "a48__am__select_mission_option_title")
	for i, type in pairs(mission_order) do
		Interface.RemoveComponent(this, "a48__am__select_mission_option_"..type)
	end
	this.mission_type = type
	this.step = 1
	ms = missions[type][1]
	if ms.init then ms.init() end
	UpdateAll()
end

function reverseStep()
	this.step = this.step - 1
	ms = missions[this.mission_type][this.step]
end

function finishStep()
	this.step = this.step + 1
	local nextms = missions[this.mission_type][this.step]
	if nextms then
		ms = nextms
		print(ms)
		if ms.init then ms.init() end
		UpdateAll()
	else
		if this.mission_type == 'playdead' then
			marker.continued = true
			target.a48__play_dead__in_progress = true
		end
		SpawnReward()
	end
end


local prefix = "a48__am__"
local miz_last = nil
local miz = nil

function diffMenu(miz)
	if not miz_last then return true end
	local index = 0
	for i, v in pairs( miz ) do
		index = i
		if not miz_last[i] then
			return true
		elseif type(miz_last[i][1]) == 'table' and miz_last[i][1][1] ~= v[1][1] then
			return true
		elseif type(miz_last[i][1]) ~= 'table' and miz_last[i][1] ~= v[1] then
			return true
		end
	end
	if miz_last[index+1] then
		return true
	end
	return false
end

function updateMenu(miz)
	miz = miz or {}
	if diffMenu(miz) then
		refreshMenu(miz)
	else
		setCaptions(miz)
	end
end

function setCaptions(miz)
	for i, t in pairs(miz) do
		local cn = t[1]
		local translation = t[1]
		t[2] = t[2] or 'Caption'
		if type(cn) == 'table' then
			cn = t[1][1]
			translation = t[1][2]
		end
		Interface.SetCaption(this, prefix..cn, prefix..translation, t[3], t[4], t[5], t[6], t[7], t[8])
	end
end

function refreshMenu(miz)
	if miz_last then
		for i, t in pairs(miz_last) do
			local cn = t[1]
			if type(cn) == 'table' then cn = cn[1] end
			Interface.RemoveComponent(this, prefix..cn)
		end
	end

	for i, t in pairs(miz) do
		local cn = t[1]
		-- print(cn) --
		local translation = t[1]
		t[2] = t[2] or 'Caption'
		if type(cn) == 'table' then
			cn = t[1][1]
			translation = t[1][2]
		end
		Interface.AddComponent(this, prefix..cn, t[2], prefix..translation, t[3], t[4], t[5], t[6], t[7], t[8])
	end
	miz_last = miz
end



function UpdateAll()
	if ms and ms.escaping then
		this.Pos.x = 0
		this.Pos.y = 0
		this.Hidden = true
	end

	if this.Damage >= 1 then
		missionFailed('dead')
	end

	if this.failed then
		this.Tooltip = {"a48__at__failed"}
		updateMenu({
			{'abort', 'Button'},
		})
		return
	elseif target then
		if ms then
			local miz = {
				{'abort', 'Button'},
				{"title_name", "Caption", "a48__mission_name_"..this.mission_type, "N"},
				{"title_step", "Caption", this.step, "S"},
			}
			local at_desc = "a48__at__desc_"..this.mission_type.."_"..this.step

			if ms.avoid_guard then
				if this.Damage >= 0.7 then
					missionFailed('pursuit')
					return
				else
					look_around(types_guard, pursuitYou, pursuit_guard_range)
				end
			end
			if ms.pas_de_deux then
				if this.followed then
					followMe()
				else
					makeStill(target)
				end
			end

			if ms.keep_disguise then
				extend(miz, ms.main() )
			else
				if needDisgise() then
					if disguise_subtype == this.SubType then
						finishStep()
						return {}
					end
					extend(miz, menu_disguise())
					at_desc = "a48__at__need_disguise"
				else
					extend(miz, menu_disguise())
					extend(miz, ms.main() )
				end
			end

			if target.Damage >= 1 and not ms.avoid_guard then
				this.Tooltip = {"a48__at__target_dead"}
				updateMenu({
					{'abort', 'Button'},
				})
				return
			else
				updateMenu(miz)
			end

			this.Tooltip = {"a48__at__desc", "a48__mission_name_"..this.mission_type, "N", this.step, "S", at_desc, "D"}

		else
			this.Tooltip = {"a48__at__need_select_mission"}
			-- this.Tooltip = {"a48__at__", this.target_id, "I", this.task, "T"}
			Interface.AddComponent(this, "a48__am__abort", "Button", "a48__am__abort")
			Interface.AddComponent(this, "a48__am__select_mission_option_title", "Caption", "a48__am__select_mission_option_title")
			for i, type in pairs(mission_order) do
				Interface.AddComponent(this, "a48__am__select_mission_option_"..type, "Button", "a48__mission_name_"..type)
			end
		end
	else
		if target then
			this.SetInterfaceCaption("a48__menu__target_status", "a48__menu__target_status__yes", this.target_id, "I", this.task, "T")

			this.SetInterfaceCaption("a48__menu__kill_action", "a48__menu__kill_action", 50, "R")
		else
			this.SetInterfaceCaption("a48__menu__target_status", "a48__menu__target_status__no")
			this.Tooltip = {"a48__menu__target_status__no"}
			Interface.AddComponent(this, "a48__am__abort", "Button", "a48__am__abort")
		end
	end
end





function a48__am__take_itemClicked()
	if math.random(100) <= ter then
		this.Sound("_Contraband", "ContrabandFound") --
		SpawnFine("take_item")
	else
		this['has_item_'..can_get_item_name] = true
		this.Sound("_EscapeMode", "ContrabandStolen") --
		if this.mission_type == 'backstab' then
			this.weapon = can_get_item_name
			if can_get_item_name == 'Shank' then
				finishStep()
			end
		else
			local dict = itemSourcez[this.mission_type]
			local has_all = true
			for itemname, sourcez in pairs(dict) do
				if not this['has_item_'..itemname] then
					has_all = false
					break
				end
			end
			if has_all then finishStep() end
		end
		can_get_item_name = nil
		UpdateAll()
	end
end

function a48__am__skip_stepClicked()
	finishStep()
end


function a48__am__action_disguiseClicked()
	if math.random(100) <= ter then
		-- this.Sound("_Contraband", "PrisonerSearchComplaint") --
		this.Sound("__ConvictionHeist", "HeistMusic5") -- Warning Horn
		SpawnFine("disguise")
	else
		if disguise_subtype then
			this.SubType = disguise_subtype
			finishStep()
		else
			if this.SubType >= 5 then
				this.SubType = 1
			else
				this.SubType = this.SubType + 1
			end
			if ms.avoid_guard then
				this.Sound("Guard", "RadioBleepAlertEnd") -- Abort Alert
				finishStep()
			end
		end
	end
end


function a48__am__select_mission_option_backstabClicked()
	startMission("backstab")
end
function a48__am__select_mission_option_scuffleClicked()
	startMission("scuffle")
end
function a48__am__select_mission_option_foodClicked()
	startMission("food")
end
function a48__am__select_mission_option_fireClicked()
	startMission("fire")
end
function a48__am__select_mission_option_grenadeClicked()
	startMission("grenade")
end
function a48__am__select_mission_option_playdeadClicked()
	startMission("playdead")
end
function a48__am__select_mission_option_outbreakClicked()
	startMission("outbreak")
end



function a48__am__action_backstabClicked()
	if math.random(100) <= success_rate then
		if this.weapon == 'Pianowire' then
			target.Sound("__FoodFeud", "Feud_1o") -- Pianowire
			-- target.StatusEffects.tazed = 1000
			target.Damage = math.max(target.Damage+0.1, 0.3)
		else
			target.Sound("__FoodFeud", "Feud_1s") -- Stab and Ahhh
			target.StatusEffects.wounded = 100
			target.Damage = math.max(target.Damage+0.4, 0.7)
		end
		finishStep()
	else
		target.Damage = target.Damage + weapon_powerz[this.weapon]/200
		if target.Damage > 1 then
			target.Damage = 1
		else
			this.Sound("Soldier", "ShoutWarning") -- Hey!
			makeAttack(target, this)
			missionFailed()
		end
	end
end


function a48__am__action_scuffleClicked()
	local pz = target.GetNearbyObjects("Prisoner", scuffle_range)
	for p, dist in pairs(pz) do
		if p == target then
			p.Misbehavior = 5
		else
			p.Misbehavior = 4
		end
		p.StatusEffects.riledup = 1000
		p.Sound("_Contraband", "PrisonerSearchComplaint") -- Hey!!
	end
	-- UpdateAll()
	this.Sound("Guard", "Damage") -- whooerrr
	finishStep()
end

function moreScuffle(p)
	if not p.Misbehavior ~= 'None' and not p.Shackled then
		p.Misbehavior = 4
		p.StatusEffects.riledup = 100
		p.Sound("_Contraband", "PrisonerSearchComplaint") -- Hey!!
	end
end

function a48__am__more_scuffleClicked()
	look_around({'Prisoner'}, moreScuffle)
end




function a48__am__action_foodClicked()
	finishStep()
end

function a48__am__take_PrisonerUniformClicked()
	itemPrisonerUniform.Delete()
	finishStep()
end

function a48__am__putdown_PrisonerUniformClicked()
	this.Sound("Guard", "Place") -- whoosh
	itemFlammableUniform = SpawnAt('FlammableUniform', itemBedForUniform)
	this.flammableuniform_id = itemFlammableUniform.Id.u
	finishStep()
end

-- This is NOT a button click event
function target_puton_PrisonerUniform()
	this.flammableuniform_id = nil
	itemFlammableUniform.Delete()
	finishStep()
end


function a48__am__action_fireClicked()
	obj_fire = setFire(target)
	obj_fire.Fuel = 20
	this.fire_id = obj_fire.Id.u
	finishStep()
end


function a48__am__throw_grenadeClicked()
	SpawnAt('Explosion', target, 0, 0.2)
	this.Sound("__RiotAssault", "Breach2") -- Action Film!
	finishStep()
end


function a48__am__give_potion_to_playdeadClicked()
	finishStep()
end



a48__am__action_playdeadClicked = a48__am__action_scuffleClicked


function a48__am__install_bombClicked()
	this.bomb_remaining = this.bomb_remaining - 1
	SpawnAt('FakeExtinguisher', this)
	this.Sound("Drain", "Place") -- Install Metal
	if this.bomb_remaining == 0 then
		finishStep()
	else
		UpdateAll()
	end
end

function a48__am__uninstall_bombClicked()
	local fe = look_around({'FakeExtinguisher'}, nil, 1, true)
	this.Sound("Guard", "Place") -- Fffoww
	if not fe.to_be_deleted then
		fe.to_be_deleted = true
		fe.Delete()
		this.bomb_remaining = this.bomb_remaining + 1
		UpdateAll()
	end
end

function a48__am__pas_de_deuxClicked()
	this.Sound("_EscapeModeInterface", "FollowModeOn")
	finishStep()
end

function a48__am__followedClicked()
	this.followed = not this.followed
	if this.followed then
		this.Sound("_EscapeModeInterface", "FollowModeOn")
	else
		this.Sound("_EscapeModeInterface", "FollowModeOff")
	end
end

function makeEscape(p)
	if (p.Id.u ~= this.target_id) and not (p.Shackled) and not (p.Damage >= 0.7) then
		p.Misbehavior = 2
	end
end

function ExplodeO(o)
	SpawnAt('Explosion', o)
	o.Delete()
end


function a48__am__action_outbreakClicked()
	this.followed = nil
	local guard = look_around(types_guard, nil, 1.3, true)
	disarm(guard, true)

	look_around({'FakeExtinguisher'}, ExplodeO, 'max')
	-- target.Misbehavior = 2

	look_around({'Prisoner'}, makeEscape, 10)
	this.Sound("__RiotAssault", "Breach2") -- Action Film

	finishStep()
end

function a48__am__abortClicked()
	this.Delete()
	if target then
		target.AvatarControl = false
	end
end


function Go()

	if not this.target_id then
		markTarget()
	end


	-- if true then
	-- 	look_around({"Prisoner"}, testP)
	-- 	look_around(types_guard, testG)
	-- end

	UpdateAll()
end










function SpawnAt(type, to, dx, dy)
	return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end



function guardGo(who, to, dx, dy)
	who.PlayerOrderPos.x = to.Pos.x + (dx or 0)
	who.PlayerOrderPos.y = to.Pos.y + (dy or 0)
end
function nav(who, to, dx, dy)
	who.NavigateTo((to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end












function testP(o)
	-- o.SnitchTimer = o.SnitchTimer or 0
	-- o.Shackled = true
	-- o.Shackled = false
	-- o.Misbehavior = 5
end



function disarm(o, critical)
	if o.Damage >= 1 then
		return
	end
	if o.Equipment ~= "None" then
		o.Equipment = 0
		o.SecondaryEquipment = 0
		this.Sound("_Tools", "HitBy_Fists") --
		if critical and o.Damage < 0.8 then
			o.Damage = 0.8
		else
			o.Energy = -100
			o.Damage = o.Damage + 0.2
			if o.Damage < 0.7 then
				local fake_guard = Object.Spawn(o.Type, o.Pos.x, o.Pos.y)
				fake_guard.Damage = 1
				fake_guard.Hidden = true
			end
		end
	end
end

function deleteHiddenGuard(g)
	if g.Hidden then
		g.Delete()
	end
end




function missionFailed(failure_type)
	this.failed = true
	this.SubType = 0
	this.Sound("_EscapeModeInterface", "Surrender")
	SpawnFine(failure_type)
end


local fine = 500
function SpawnFine(failure_type, v1, v2, v3, v4)
	local who = this
	if ms.escaping then
		who = target
	end
	local o = Object.Spawn("HitmanFine", who.Pos.x, who.Pos.y)
	o.Tooltip = {"a48__fine__"..(failure_type or this.mission_type), v1, v2, v3, v4}
	if ms.escaping then
		this.Pos.x = target.Pos.x
		this.Pos.y = target.Pos.y
		this.Delete()
	end
end

function SpawnReward()
	this.Sound("_Finance", "ReceivePayment")
	this.Sound("__DeathRowConfession", "FadeToPrison") -- Bell
	local who = target
	if ms and ms.avoid_guard then
		who = this
	end
	local o = Object.Spawn("HitmanReward", who.Pos.x, who.Pos.y+0.3)
	o.Tooltip = {"a48__reward__"..this.mission_type, v1, v2, v3, v4}
	Clear()
end


















function Clear()
	-- target = nil
	if not marker.continued then
		marker.Delete()
	end
	marker = nil
	if targetDirIndicator then
		targetDirIndicator.Delete()
	end
	-- this.target_id = nil
	for i, m in pairs(sightmarkerz) do
		m.Delete()
	end
	this.Delete()
end


local Ready = 0
local Ready1 = 0
local Delay1 = 0.01
local resumed = false

function Update()
	if not resumed then
		Resume()
	end

	if World.TimeIndex > Ready1 then
		Ready1 = World.TimeIndex + Delay1
		if target and targetDirIndicator then
			if ms and ms.goback then
				local d = dist(target, this)
				if d > 3 then
					targetDirIndicator.Hidden = false

					local this_x = this.Pos.x
					local this_y = this.Pos.y
					local target_x = target.Pos.x
					local target_y = target.Pos.y

					targetDirIndicator.Pos.x = this_x - 0.05 * (this_x - target_x) / d
					targetDirIndicator.Pos.y = this_y - 0.05 * (this_y - target_y) / d
					targetDirIndicator.Or.x = (this_x - target_x) / d
					targetDirIndicator.Or.y = (this_y - target_y) / d
				else
					-- targetDirIndicator.Pos.x = 0.5
					-- targetDirIndicator.Pos.y = 3
					targetDirIndicator.Hidden = true
				end
			else
				targetDirIndicator.Hidden = true
			end
		end
	end


	if obj_fire then
		obj_fire.Intensity = 2
		obj_fire.Pos.x = target.Pos.x
		obj_fire.Pos.y = target.Pos.y
	end


	if oItemIcon then
		if this['has_item_'..oItemIcon.item_name] then
			oItemIcon.Delete()
			oItemIcon = nil
		end
	end

	if World.TimeIndex > Ready then
		Ready = World.TimeIndex + Delay
		Go()
	end
end



-- 'A48Clothes', 'GuardUniform',
local iconz = {'MobilePhone', 'Shank', 'Knife', 'Dynamite', 'Poison', 'Ingredient', 'Medicine', 'FakeExtinguisher', 'Flammable', 'Lighter', 'Scissors'}
local icon_fullnamez = {}
for i, v in pairs(iconz) do
	table.insert(icon_fullnamez, "Icon_"..v)
end


function Resume()
	resumed = true
	if this.mission_type then
		ms = missions[this.mission_type][this.step]
		look_around(icon_fullnamez, deleteO, 3)
	end

	look_around({"SightMarker", "TargetDirection"}, deleteO, "max")
  markTarget()

  if this.flammableuniform_id and not itemFlammableUniform then
	  itemFlammableUniform = search(this.flammableuniform_id, {'FlammableUniform'}, this, 'max')
	end

  if this.fire_id and not obj_fire then
	  obj_fire = search(this.fire_id, {'Fire'}, this, 'max')
	end

	local i = 1
	sightmarkerz = {}
	while i <= witness_range * witness_range * 2 do
		local m = Object.Spawn("SightMarker", i, 1)
		m.Hidden = true
		table.insert(sightmarkerz, m)
		i = i + 1
	end
	i = nil

end


function Create()
	if look_around({"Avatar"}, nil, "max") > 1 then
		this.Delete()
	else
		-- Resume()
	end
end



