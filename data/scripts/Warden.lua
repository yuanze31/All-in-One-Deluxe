-- Warden --




function look(who, types, cb, range, justOne)
	local count = 0
	if range == "max" then range = 9999 end
	for k, v in pairs(types) do
		local os = who.GetNearbyObjects(v, range)
		for o, distance in pairs( os ) do
			count = count + 1
			if justOne then
				if cb then
					if cb(o, distance) then
						return o
					end
				else
					return o
				end
			else
				if cb then
					cb(o, distance)
				end
			end
		end
	end
	if justOne then
		return nil
	else
		return count
	end
end


function getObjCell(o)
	return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end




function search(uid, types, center_object, range)
	center_object = center_object or this
	if range == "max" then range = 9999 end

	for k, v in pairs(types) do
		local os = center_object.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			if o.Id.u == uid then
				return o
			end
		end
	end
	return nil
end


function loader(o, types, range)
	local l
	if o.Loaded then
		l = search(o.CarrierId.u, types, o, (range or 1) )
	end
	return l
end




local hourNow
local today
function renewDateTime()
	today = math.floor(World.TimeIndex / 1440) + 1
	hourNow = math.floor(World.TimeIndex / 60) % 24
end


function round(n)
	return math.floor(n+0.5)
end


function extend( t1, t2 )
	if t2 then
		for i, v in pairs(t2) do
			table.insert(t1, v)
		end
	else
	end
	return t1
end


local prefix = "w__"
local miz_last
local miz

function diffMenu(miz)
	if not miz_last then return true end
	for i, v in pairs( miz ) do
		if not miz_last[i] or miz_last[i][1] ~= v[1] then
			return true
		end
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
	-- print('refreshMenu')
	if miz_last then
		for i, t in pairs(miz_last) do
			local cn = t[1]
			if type(cn) == 'table' then cn = cn[1] end
			Interface.RemoveComponent(this, prefix..cn)
		end
	end

	for i, t in pairs(miz) do
		local cn = t[1]
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



function menu()

	local miz = {
		{'ttt', 'Button', ('w__ttt/'..this.ttt), 'T'},
		{'change_sickness_difficulty', 'Button', this.sickness_difficulty, 'N'},
	}

	if World.CheatsEnabled then
		if World.ImmediateObjects then
			extend(miz, {
				{'define_sleep_title'},
				{'sleep_start_at', 'Button', this.sleep_start_at, 'N'},
				{'sleep_end_at', 'Button', this.sleep_end_at, 'N'},
				{'toggle_fast_sleep', 'Button', tostring(this.fast_sleep_enabled), 'B'},
				{'timewarping', nil, tostring(this.timewarping), 'B'},
			})
		else
			extend(miz, {
				{'need_ImmediateObjects'}
			})
		end
	end

	updateMenu(miz)

end









local optsDict = {
	ttt = {'sick', 'rc', 'bp', },
	sleep_start_at = {22, 23, 24},
	sleep_end_at = {5, 6, 7, 8},
}

function nextVal(key)
	local opts = optsDict[key]
	local new
	for i, v in pairs( opts ) do
		if v == this[key] then
			new = opts[i+1]
			break
		end
	end
	if not new then
		new = opts[1]
	end
	this[key] = new
	menu()
end

function  w__sleep_start_atClicked()
	nextVal('sleep_start_at')
	calcNextSleep()
end

function  w__sleep_end_atClicked()
	nextVal('sleep_end_at')
	calcNextSleep()
end


function w__tttClicked()
	nextVal('ttt')
	menu()
	updateTooltip()
end

function w__change_sickness_difficultyClicked()
	this.sickness_difficulty = this.sickness_difficulty * 2
	if this.sickness_difficulty > 32 then
		this.sickness_difficulty = 1
	end
	menu()
end




local total_sp = 0
local total_goodbody = 0
local total_bp = 0
local total_bp_full = 0













local prisoners = {}
local prisoners_last_looked

local bodyshapes = {
	{name = 'thin', default = 200, bonus=200},
	{name = 'strong', default = 10},
	{name = 'fat', default = 300, bonus=1000},
	{name = 'average', default = 100},
}


function renewAllPrisoners()
	prisoners = this.GetNearbyObjects('Prisoner', 9999)
	for p, distance in pairs( prisoners ) do

		if not p.eval_chance_first then
			local eval_chance_current = round(p.ReoffendingChance * 100)
			p.eval_chance_first = -1
		end

		if not p.sickness_points then
			p.sickness_points = bodyshapes[p.SubType+1].default
		end
		if p.sickness_points_exercised == nil then
			p.sickness_points_exercised = 0
		end
		if p.sickness_points_food == nil then
			p.sickness_points_food = 0
		end
		if p.sickness_points_damaged == nil then
			p.sickness_points_damaged = 0
		end

		if not inited then
			if p.TimeOfLastMisconduct > 0 then
				p.TimeOfLastMisconduct = p.TimeOfLastMisconduct - 1
			end
		end

		-- if p.IsNewIntake then
		-- 	p.entry_date = tod
		-- end
	end
end






local whenNeedUpdateEval = 60 * 12 -- Clock Minutes
local nearbyRange = 10

local bonusStep = 5 -- percentage step/span for each bonus



local each_bonus = 100 -- amount of each bonus

function evaluatePrisoner()
	local time_now = World.TimeIndex

	local ps = this.GetNearbyObjects("Prisoner", nearbyRange)
	for p, distance in pairs( ps ) do
		p.tt__timer = 15
		p.tt = 'rc'

		local eval_time_last = p.eval_time_last
		if eval_time_last == nil or time_now - eval_time_last >= whenNeedUpdateEval then

			local eval_chance_current = round(p.ReoffendingChance * 100)

			if p.eval_chance_first == -1 then
				p.eval_chance_first = eval_chance_current
			end

			if eval_time_last == nil then
				-- if eval_chance_current == 96 then
				-- 	return
				-- end
				p.eval_time_first = time_now

				p.eval_chance_lowest = 100
				p.bonus_count = 0

			elseif time_now - eval_time_last >= whenNeedUpdateEval then
				if not p.eval_chance_first then
					local eval_chance_current = round(p.ReoffendingChance * 100)
					p.eval_chance_first = -1
				end

				local eval_chance_lowest = math.min (p.eval_chance_lowest, eval_chance_current)

				local eval_chance_improved = p.eval_chance_first - eval_chance_lowest
				local bonus_count_expected = math.floor( eval_chance_improved / bonusStep)

				local bonus_count = p.bonus_count or 0
				local bonus_count_diff = bonus_count_expected - bonus_count

				if bonus_count_diff > 0 then
					SpawnBonus(p, bonus_count_diff)
					this.eval_bonus_count = this.eval_bonus_count + bonus_count_diff
					bonus_count = bonus_count_expected
				end

				local eval_days = math.floor( (eval_time_last - p.eval_time_first) / 60 / 24)

				p.eval_chance_lowest = eval_chance_lowest
				p.eval_chance_current = eval_chance_current
				p.eval_chance_improved = eval_chance_improved
				p.bonus_count = bonus_count
				p.eval_days = eval_days

			end

			p.eval_time_last = time_now

			this.eval_count = this.eval_count + 1

		end

	end
end



function SpawnAt(type, to, dx, dy)
	return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end


local SpawnBonus_radius = 0.6

function SpawnBonus(p, count, radius)
	radius = radius or SpawnBonus_radius
	local i = 0
	while i < count do
		local curve = (0.25 + i / count) * 2 * math.pi
		local d_x = math.cos(curve) * SpawnBonus_radius
		local d_y = math.sin(curve) * SpawnBonus_radius
		-- print(d_x, d_y)
		local o = Object.Spawn("MoneyBag100", p.Pos.x + d_x, p.Pos.y + d_y)

		i = i + 1
	end
end


































function calcNextSleep()
	local now = parseTime()

	this.next_start = calcTime(now.d-1, this.sleep_start_at) -- Yesterday night
	this.next_morning = calcTime(now.d, this.sleep_end_at) -- Today morning

	if this.next_morning < World.TimeIndex then
		this.next_start = calcTime(now.d, this.sleep_start_at) -- Today night
		this.next_morning = calcTime(now.d+1, this.sleep_end_at) -- Tomorrow morning
	end
end

function  w__toggle_fast_sleepClicked()
	this.fast_sleep_enabled = not this.fast_sleep_enabled
	if this.fast_sleep_enabled then
		calcNextSleep()
	else
		stopTimeWarp()
	end
	checkTimeWarp()
	menu()
end



function checkTimeWarp()
	if not World.ImmediateObjects then
		return
	end

	if this.fast_sleep_enabled then
		if World.TimeIndex > this.next_start and World.TimeIndex <= this.next_morning then
			if not this.timewarping then
				startTimeWarp()
			end
		else
			if this.timewarping then
				stopTimeWarp()
			end
		end
	end
end

function parseTime()
	local n = World.TimeIndex
	local pt = {}
	pt.d = math.floor(n / 1440) + 1
	pt.h = math.floor((n % 1440) / 60)
	pt.m = math.floor(n % 60)
	return pt
end

function calcTime(d, h, m)
	m = m or 0
	return 1440 * (d - 1) + 60 * h + m
end

function startTimeWarp()
	local now = parseTime()
	this.next_morning = calcTime(now.d, this.sleep_end_at) -- Today morning
	if this.next_morning < World.TimeIndex then
		this.next_morning = calcTime(now.d+1, this.sleep_end_at) -- Tomorrow morning
	end

	this.timewarping = true
	addNeedModifer()
	World.TimeWarpFactor = 6
	menu()

end

function stopTimeWarp()
	removeNeedModifer()
	World.TimeWarpFactor = 1
	this.timewarping = false

	-- Continue at next sleep (if enabled)
	local now = parseTime()
	this.next_start = calcTime(now.d, this.sleep_start_at) -- Today night
	this.next_morning = calcTime(now.d+1, this.sleep_end_at) -- Today morning
	if this.next_start < World.TimeIndex then
		this.next_start = calcTime(now.d+1, this.sleep_start_at) -- Tomorrow night
		this.next_morning = calcTime(now.d+2, this.sleep_end_at) -- Today morning
	end
	menu()

end

function  w__startClicked()
	startTimeWarp()
end

function  w__stopClicked()
	stopTimeWarp()
end

function  w__continueClicked()
	continueTimeWarp()
end

function placeModifier(o)
	local nm = Object.Spawn("TimeWarpNeedModifier", o.Pos.x+0.5*o.Or.x, o.Pos.y+0.5*o.Or.y)
end

function addNeedModifer()
	-- print('addNeedModifer')
	for o, v in pairs( this.GetNearbyObjects('Bed', 9999) ) do
		placeModifier(o)
	end
	for o, v in pairs( this.GetNearbyObjects('BunkBed', 9999) ) do
		placeModifier(o)
	end
	this.add_modifiers = true
end

function removeNeedModifer()
	-- let world.lua know
	this.remove_modifiers = true
end


















function checkIfPrisonersExist()
	population = 0

	for p, distance in pairs( prisoners ) do
		if p.Category == nil then
			prisoners[p] = nil
			print('Remove a prisoner: no longer exists')
		elseif p.Damage >= 1 then
			prisoners[p] = nil
			print('Remove a prisoner: dead')
		else
			population = population + 1
		end
	end
end

function DetectMisconduct()

	for p, distance in pairs( prisoners ) do

		if World.TimeIndex - p.TimeOfLastMisconduct <= 1 then
			-- print('Misconduct!!')
			-- print(p.TimeOfLastMisconduct)
			-- print(World.TimeIndex - p.TimeOfLastMisconduct)
			-- print('')

			local markers = p.GetNearbyObjects("MisconductMarker", 4)
			local already_marked = false
			for marker, distance in pairs( markers ) do
				if marker.target_id == p.Id.u then
					already_marked = true
					-- print('___already_marked____')
					break
				end
			end

			if not already_marked then
				local marker = Object.Spawn("MisconductMarker", p.Pos.x, p.Pos.y - 2.2)
				marker.target_id = p.Id.u
				-- print('Marker added!')
				-- print('')
			end
		end

	end
end








local day_starts_at = 7
local day_ends_at = 20
local sickness_damage_poss_base = 0.05

local damage_inr_each = 0.5 / 60

function sickness()
	if hourNow >= day_starts_at and hourNow < day_ends_at then
		damage_inr_each = 0.5 / 60
	else
		damage_inr_each = 0.1 / 60
	end

	sickness_damage_poss = sickness_damage_poss_base * this.sickness_difficulty / 60 / 24

	for p, distance in pairs( prisoners ) do

		-- If loaded like sitting, and if damaged, the prisoner will not decrease needs like comfort even though he is still sitting...
		if (not p.Loaded) and p.Damage < 0.3 and math.random() < (sickness_damage_poss * p.sickness_points / 100) then
			local dmg = 0.1 + 0.5 * math.min(1, p.sickness_points / 200) * math.random()
			print('sickness damage')
			print(dmg)
			p.sickness_last_damage = dmg
			p.sickness_last_date = today
			p.Damage = math.min(0.9, p.Damage + dmg)
		end

		-- p.Damage = 0.8

		if p.Damage > 0 then
			p.sickness_points_damaged = p.sickness_points_damaged + damage_inr_each
			p.sickness_points = p.sickness_points + damage_inr_each
		end
		-- p.SubType = 1
	end
end



local exercise_each = 9 / 60

function exercise()
	for p, distance in pairs( prisoners ) do
		local l = loader(p, {'WeightsBench'})
		if l then
			-- print('exe!')
			p.tt__timer = 15
			p.tt = 'sick'
			local exer = math.min(p.sickness_points, exercise_each)
			p.sickness_points_exercised = p.sickness_points_exercised - exer
			p.sickness_points = p.sickness_points - exer
			tryReshape(p)
		end
	end
end

function tryReshape(p)
	if (p.SubType == 0 or p.SubType == 2) and p.sickness_points <= 100 then
		reshape(p, 3)
	end
	-- if p.SubType == 3 and p.sickness_points <= 10 then
	-- 	p.SubType = 3
		-- reshape(p, 1)
	-- end
end

local bb_drop_radius = 0.3

function reshape(p, newSubtype)

	local curve = math.random() * 2 * math.pi
	local vx = math.cos(curve) * bb_drop_radius
	local vy = math.sin(curve) * bb_drop_radius

	local bb = SpawnAt('BodyBonus'..tostring( p.SubType ), p, vx, vy)
	local t = bodyshapes[p.SubType+1]
	bb.o = 'bodytype_' .. t.name
	bb.m = t.bonus
	bb.n = 'bodytype_' .. bodyshapes[newSubtype+1].name
	bbTT(bb)

	local bag_count = t.bonus/100
	SpawnBonus(bb, bag_count, 0.5 + 0.05*bag_count)

	p.SubType = newSubtype
end


function bbTT(bb)
	bb.Tooltip = {'BodyBonus_tt', bb.o, 'O', bb.n, 'N', bb.m, 'M'}
end


local food_rating
local food_rating_last
local sickness_delta_by_food
local sickness_delta_by_food_text
local sickness_delta_by_food_each

function foodForHealth()
	food_rating = World.FoodQuantity * 2 + World.FoodVariation * 3

	sickness_delta_by_food = (10 - food_rating) * 2

	if sickness_delta_by_food > 0 then
		sickness_delta_by_food_text = '+'
	else
		sickness_delta_by_food_text = ''
	end
	sickness_delta_by_food_text = sickness_delta_by_food_text .. tostring( sickness_delta_by_food )

	if food_rating_last ~= food_rating then
		food_rating_last = food_rating
		look(this, {'ServingTable'}, stTT, 'max')
	end

	sickness_delta_by_food_each = sickness_delta_by_food / 60 / 24

	for p, distance in pairs( prisoners ) do
		local d = sickness_delta_by_food_each
		if sickness_delta_by_food_each + p.sickness_points < 0 then
			d = p.sickness_points
		end
		p.sickness_points = p.sickness_points + d
		p.sickness_points_food = p.sickness_points_food + d
	end

end

function stTT(o)
	o.Tooltip = {'food_st_tt', food_rating, 'R', sickness_delta_by_food_text, 'D'}
end



















local inited
function Init()
	this.sleep_start_at = this.sleep_start_at or 22
	this.sleep_end_at = this.sleep_end_at or 6

	if this.fast_sleep_enabled == nil then
		this.fast_sleep_enabled = false
	end

	if this.timewarping == nil then
		this.timewarping = false
	end

	renewDateTime()
	if this.last_day == nil then
		this.last_day = today
	end

	if this.eval_count == nil then
		this.eval_count = 0
	end

	if this.eval_bonus_count == nil then
		this.eval_bonus_count = 0
	end

	if this.med_expense == nil then
		this.med_expense = 0
	end


	if this.detect_misconduct == nil then
		this.detect_misconduct = true
	end

	if this.investigation_count == nil then
		this.investigation_count = 0
	end
	if this.found_guard == nil then
		this.found_guard = 0
	end


	if this.sickness_difficulty == nil then
		this.sickness_difficulty = 4
	end

	if this.ttt == nil then
		this.ttt = 'sick'
		this.ttt = 'rc'
	end

	renewAllPrisoners()
	prisoners_last_looked = math.floor(World.TimeIndex / 60 / 24) - 1

	look(this, {'BodyBonus0', 'BodyBonus2', 'BodyBonus3', }, bbTT, 'max')



	menu()

	inited = true

end




local Ready1 = 0
local Ready2 = 0
local Ready3 = World.TimeIndex + 1
local Ready4 = 0

local last_io = World.ImmediateObjects


function Update()
	if not inited then
		Init()
		return
	end

	if World.TimeIndex <= Ready1 then
		return
	end
	Ready1 = World.TimeIndex + 1

	checkIfPrisonersExist()
	renewDateTime()

	if math.floor(World.TimeIndex / 60 / 24) > prisoners_last_looked then
		if hourNow == 10 then
			print('New Intake!----------------------------')
			-- print(sizeOf(prisoners))
			renewAllPrisoners()
			prisoners_last_looked = math.floor(World.TimeIndex / 60 / 24)
		end
	end

	if this.detect_misconduct then
		DetectMisconduct()
	end

	if last_io ~= World.ImmediateObjects then
		last_io = World.ImmediateObjects
		menu()
	end


	if World.TimeIndex > Ready2 then
		Ready2 = World.TimeIndex + 3

		sickness()
		exercise()
		foodForHealth()

		local c = getObjCell(this)

		if this.last_day < today then
			this.last_day = today
			this.eval_count = 0
			this.eval_bonus_count = 0
			this.med_expense = 0
		end

		if this.Office.u == c.Room.u then
		else
			evaluatePrisoner()
		end

	end


	if World.TimeIndex > Ready3 then
		Ready3 = World.TimeIndex + 5
		checkTimeWarp()
	end

	updateTooltip()
end


function updateTooltip()
	updateTooltipAllPrisoners()

	if this.ttt == 'sick' then
		local sp_avg = round(total_sp/population)
		local goodbody_ratio = round(total_goodbody/population*100)

		this.Tooltip = {'w__tt/sick', sp_avg, 'A', goodbody_ratio, 'G', this.med_expense, 'H'}

	elseif this.ttt == 'rc' then

		local c = getObjCell(this)
		if this.Office.u == c.Room.u then
			this.Tooltip = {"w__tt/rc/no", this.eval_count, "X", this.eval_bonus_count * each_bonus, "Y"}
		else
			this.Tooltip = {"w__tt/rc/outside", this.eval_count, "X", this.eval_bonus_count * each_bonus, "Y"}
		end

	elseif this.ttt == 'bp' then
		local bp_avg = round(total_bp/population)
		local bp_full_ratio = round(total_bp_full/population*100)
		this.Tooltip = {'w__tt/bp', bp_avg, 'A', bp_full_ratio, 'F'}
	end
end




function updateTooltipAllPrisoners()
	total_sp = 0
	total_goodbody = 0
	total_bp = 0
	total_bp_full = 0
	for p, distance in pairs( prisoners ) do
		updateTooltipP(p)
	end
end

function updateTooltipP(p)
	if p.Damage > 1 then
		p.Damage = 1
	end
	if p.a48__play_dead__in_progress and p.Damage == 1 then
		return
	end

	local BoilingPoint_current = math.floor(p.BoilingPoint)

	if p.last_extortion then
		local ago = round(World.TimeIndex - p.last_extortion)
		if ago < 60 then
			p.Tooltip = {'fc__tt__p', p.extortion_count, 'X', p.fight_count, 'F', p.money_taken, 'M', ago, 'L', p.BoilingPoint_lowest, "A", BoilingPoint_current, "B"}
			return
		end
	end

	local ttt = this.ttt
	if p.tt__timer and p.tt__timer > 0 then
		ttt = p.tt
		p.tt__timer = p.tt__timer - 1
	else
		p.tt__timer = nil
	end

	if ttt == 'sick' then
		-- if p.sickness_last_damage == nil then
		-- 	p.sickness_last_damage = 0
		-- end

		if p.sickness_last_date then
			p.Tooltip = {'ptt/sick/damaged', round(p.sickness_points), 'P', round(p.sickness_points_exercised), 'X', round(p.sickness_points_food), 'F', round(p.sickness_points_damaged), 'L', math.floor(p.sickness_last_damage*100+0.5), 'D', (today - p.sickness_last_date), 'A', }
		else
			p.Tooltip = {'ptt/sick/init', round(p.sickness_points), 'P', round(p.sickness_points_exercised), 'X', round(p.sickness_points_food), 'F', round(p.sickness_points_damaged), 'L'}
		end



	elseif ttt == 'rc' then

		if not p.eval_time_last then
			p.Tooltip = {"ptt/rc/no"}
		elseif p.eval_chance_lowest == 100 then
			p.Tooltip = {"ptt/rc/first", p.eval_chance_first, "F"}
		elseif p.bonus_count > 0 then
			p.Tooltip = {"ptt/rc/bonus", p.eval_chance_first, "F", p.eval_chance_lowest, "L", p.eval_days, "D", p.eval_chance_improved, "I", p.bonus_count, "B"}
		else
			p.Tooltip = {"ptt/rc/no_bonus", p.eval_chance_first, "F", p.eval_chance_lowest, "L", p.eval_days, "D", p.eval_chance_improved, "I"}
		end


	elseif ttt == 'bp' then

		if p.BoilingPoint_lowest == nil then
			p.BoilingPoint_lowest = 100
		end
		p.BoilingPoint_lowest = math.min (p.BoilingPoint_lowest, BoilingPoint_current)

		total_bp = total_bp + BoilingPoint_current
		if BoilingPoint_current == 100 then
			total_bp_full = total_bp_full + 1
		end

	end







	-- statistics
	if this.ttt == 'sick' then
		total_sp = total_sp + p.sickness_points
		if p.SubType == 1 or p.SubType == 3 then
			total_goodbody = total_goodbody + 1
		end

	elseif this.ttt == 'bp' then

		if p.BoilingPoint_lowest == 100 then
			p.Tooltip = {"ptt/bp/always_full", p.BoilingPoint_lowest, "A"}
		else
		local BoilingPoint_current = math.floor(p.BoilingPoint)
			p.Tooltip = {"ptt/bp/other", p.BoilingPoint_lowest, "A", BoilingPoint_current, "B"}
		end
	end


end


