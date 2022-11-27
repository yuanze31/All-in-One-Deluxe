-- Chief --



function sizeOf(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
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



function SpawnAt(type, to, dx, dy)
	return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

function nav(who, to, dx, dy)
	who.NavigateTo((to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

function dist( from, to )
	return math.pow(math.pow( (from.Pos.x - to.Pos.x), 2) + math.pow( (from.Pos.y - to.Pos.y), 2) , 0.5)
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


function makeAttack(from, to)
	from.TargetObject.u = to.Id.u
	from.TargetObject.i = to.Id.i
	from.Misbehavior = 5
end

function getObjCell(o)
	return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end


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






local hourNow
local today
function renewDateTime()
	today = math.floor(World.TimeIndex / 1440) + 1
	hourNow = math.floor(World.TimeIndex / 60) % 24
end





local all_guards
local overall_level
local corrupt_guards = {}

local inited


function Init()
	inited = true
	if this.corruption_enabled == nil then
		this.corruption_enabled = false
	end
	if this.investigation_count == nil then
		this.investigation_count = 0
	end
	if this.found_guard == nil then
		this.found_guard = 0
	end
	if this.chief__tt__fc_on == nil then
		this.chief__tt__fc_on = 0
	end
	if this.next_may_add == nil then
		this.next_may_add = 0
	end
	if this.corruption_difficulty == nil then
		this.corruption_difficulty = 2
	end

	all_guards = this.GetNearbyObjects('Guard', 9999)
	for g, distance in pairs( all_guards ) do

		if g.corrupt then
			corrupt_guards[g] = true
		end
	end

	look(this, {'DiciplineBonus'}, updateDiciplineBonus, 'max')

	Interface.AddComponent(this, "fc__toggle_corruption", 'Button', "fc__toggle_corruption", tostring(this.corruption_enabled), 'B')
	Interface.AddComponent(this, "fc__change_corruption_difficulty", 'Button', "fc__change_corruption_difficulty", this.corruption_difficulty, 'N')
	if World.CheatsEnabled then
		Interface.AddComponent(this, "fc__add_corrupt_guard", 'Button', "fc__add_corrupt_guard")
		Interface.AddComponent(this, "fc__muster_corrupt_guards", 'Button', "fc__muster_corrupt_guards")
	end
end


function fc__toggle_corruptionClicked()
	this.corruption_enabled = not this.corruption_enabled
	Interface.SetCaption(this, "fc__toggle_corruption", "fc__toggle_corruption", tostring(this.corruption_enabled), 'B')
	updateTooltip()
end


function fc__change_corruption_difficultyClicked()
	this.corruption_difficulty = this.corruption_difficulty * 2
	if this.corruption_difficulty > 8 then
		this.corruption_difficulty = 1
	end
	Interface.SetCaption(this, "fc__change_corruption_difficulty", "fc__change_corruption_difficulty", this.corruption_difficulty, 'N')
end


function fc__add_corrupt_guardClicked()
	addCorruptGuard()
	Interface.SetCaption(this, "fc__add_corrupt_guard", "fc__add_corrupt_guard")
	updateTooltip()
end

function fc__muster_corrupt_guardsClicked()
	musterCorruptGuards()
	Interface.SetCaption(this, "fc__muster_corrupt_guards", "fc__muster_corrupt_guards")
end



local Delay = 1
local Ready = 0
function Update()
	if not inited then Init() end

	if World.TimeIndex > Ready then
		Ready = World.TimeIndex + Delay * World.TimeWarpFactor
		renewDateTime()
		corruption()
		updateTooltip()
	end
end



--------------


function corruption()
	if this.corruption_enabled then
		local gs = this.GetNearbyObjects('Guard', 7)
		for g, d in pairs( gs ) do
			if g.Damage >= 0.7 or (g.last_investigation and g.last_investigation + 60 * 4 > World.TimeIndex)
				then
			else
				local c = getObjCell(g)
				if this.Office.u == c.Room.u then
					this.investigation_count = this.investigation_count + 1
					if g.corrupt then
						this.found_guard = this.found_guard + 1
						this.Sound("__ConvictionHeist", "HeistMusic5") -- Warning Horn
						disciplineGuard(g)
					else
						this.Sound("_EscapeModeInterface", "Surrender") --
						g.Energy = 1
						g.last_investigation = World.TimeIndex
					end
				end
			end
		end
		overall_level = 0
		eachCG(keepCorrupt)
		mayAddCG()
		-- updateTooltip()

	end
end



function mayAddCG()
	if World.TimeIndex >= this.next_may_add  then
		this.next_may_add = World.TimeIndex + 60 -- every hour

		all_guards = this.GetNearbyObjects('Guard', 9999)
		local guard_total = sizeOf(all_guards)
		if guard_total == 0 then
			return
		end
		if sizeOf(corrupt_guards) >= guard_total * 0.8 then
			print('Too many corrupt guards! No more!')
			return
		end
		--
		-- overall_level = 200
		--
		local chance = (40 + overall_level * 0.1) * 100 * (guard_total / 30) * this.corruption_difficulty * 0.5 / 24

		-- print('overall_level')
		-- print(overall_level)
		-- print('guard_total')
		-- print(guard_total)
		-- print('chance')
		-- print(chance)
		if math.random(10000) < chance then
			addCorruptGuard()
		end
		-- print('')
	end
end

function addCorruptGuard()
	for g, distance in pairs( all_guards ) do
		if g.corrupt or g.Damage >= 1 then
		else
			g.corrupt = true
			g.extortion_count = 0
			g.beat_count = 0
			g.fight_count = 0
			g.money = 0
			corrupt_guards[g] = true
			g.hunting_cooldown = 0
			print('A corrupt guard is added')
			print('Now there are:')
			print(sizeOf(corrupt_guards))
			print('')
			return
		end
	end
end

function musterCorruptGuards()
	eachCG(_callG)
end


function _callG(g)
	if g.Damage >= 0.7 or g.JobId > 0 or g.Carrying.u > 0 then return end
	g.PlayerOrderPos.x, g.PlayerOrderPos.y = this.Pos.x, this.Pos.y
end

function updateDiciplineBonus(b)
	b.Tooltip = {'fc__tt__bonus', b.level, 'L', b.extortion_count, 'X', b.beat_count, 'B', b.fight_count, 'F', b.money, 'M'}
end

function disciplineGuard(g)

	local b = SpawnAt('DiciplineBonus', g)
	b.extortion_count = g.extortion_count
	b.beat_count = g.beat_count
	b.fight_count = g.fight_count
	b.money = g.money
	b.level = calcLevel(g)
	updateDiciplineBonus(b)

	corrupt_guards[g] = nil
	g.Delete()
end


function eachCG(cb)
	for g, d in pairs( corrupt_guards ) do
		if g.Damage == nil then
			corrupt_guards[g] = nil
			print('A corrupt guard is removed.')
		elseif g.Damage >= 1 then
			g.currupt = nil
			corrupt_guards[g] = nil
			print('A corrupt guard is dead.')
		else
			cb(g, d)
		end
	end
end

function startHunt(g)
	if g.hunting_id then
		-- print('already hunting..')
	else
		-- print('start hunting')
		g.hunting_id = -1
	end
end


function cgSeekTarget(g)
	if g.Damage >= 0.7 or g.JobId > 0 or g.Carrying.u > 0 then return end

	local richest_prisoner = {
		AvailableMoney = 0
	}

	local ps = g.GetNearbyObjects('Prisoner', 8)
	for p, distance in pairs( ps ) do
		if p.Id.u == g.last_id or p.Damage >= 0.7 or (p.last_extortion and World.TimeIndex < p.last_extortion + 20 * 60) then
			-- skip
		elseif p.AvailableMoney and p.AvailableMoney > richest_prisoner.AvailableMoney then
			richest_prisoner = p
		end
	end

	if richest_prisoner.Id then
		g.hunting_id = richest_prisoner.Id.u
		g.last_id = g.hunting_id
		nav(g, richest_prisoner)
	end

end





-- local m_pc = 0.4
-- local m_pd = 0.6
local m_pc = 0.3
local m_bp = 0.3
local m_pd = 0.4
local pow_to_b = 1.2
local pow_from_b = 0.8
local max = 0.6

function decideFightBack(p, difficulty)
	if p.Shackled then return false end

	local rc = p.ReoffendingChance
	local pc = math.pow(rc, pow_to_b)
	local bp = math.pow(1 - p.BoilingPoint / 100, pow_to_b)
 	local pd = math.pow(difficulty, pow_to_b)
	-- if pc == 96 then
	--     pc = math.floor(rc * 100)
	-- end
	-- print(pc)
	-- print(bp)
	-- local n = pc - p.BoilingPoint
	-- print(n)
	local b = pc * m_pc + bp * m_bp + pd * m_pd
	-- local b = pc * m_pc + pd * m_pd
	-- print(b)
	local c = math.floor(100 * max * math.pow(b, pow_from_b) )
	local r = math.random(100)
	-- print('      '..tostring(c))
	-- print('  '..tostring(c)..'  '..tostring(r))
	-- print(p.ReoffendingChance)
	-- print(p.BoilingPoint)
	-- print(math.floor(pd * 100))
	-- print(c)
	-- print(r)
	if r < c then
		return true
	else
		return false
	end
end

function extort(g, p)
	p.last_extortion = World.TimeIndex

	if p.money_taken == nil then
		p.money_taken = 0
	end
	if p.extortion_count == nil then
		p.extortion_count = 0
	end
	if p.fight_count == nil then
		p.fight_count = 0
	end
	p.extortion_count = p.extortion_count + 1

	g.extortion_count = g.extortion_count + 1
	g.last_id = g.hunting_id
	g.hunting_id = nil
	g.Energy = g.Energy - 20




	-- SpawnAt('MoneyBag10', p)
	print('')
	print('-- extort --')

	-- if true then return end

	p.AvailableMoney = p.AvailableMoney or 0

	local share = (p.AvailableMoney * 0.2 + g.level * 0.05 ) / 2
	local difficulty = math.min(1, share / p.AvailableMoney)

	print(share)
	print(p.AvailableMoney)
	print(tostring(math.floor(difficulty * 100))..'%')
	print('')
	p.StatusEffects.angst = 720
	p.StatusEffects.riledup = 720

	if decideFightBack(p, difficulty) then

		print('~~~~~ Fight Back ~~~~~~')
		-- print(p.Pos.x)
		-- print(p.Pos.y)
		-- print('')

		makeAttack(p, g)
		p.fight_count = p.fight_count + 1
		g.fight_count = g.fight_count + 1
		g.Sound("Guard", "Damage") -- whooerrr
	else
		local hit = math.random() * difficulty * 3
		-- if WorkQueue then
		-- 	WorkQueue.Request('SearchObject', p)
		-- end
		if hit > 5 then
			g.beat_count = g.beat_count + 1
			p.Damage = p.Damage + hit
			g.Sound("_Tools", "HitBy_Baton")
			p.StatusEffects.riledup = 1440
		else
			p.Sound("_Contraband", "PrisonerSearchComplaint") -- Hey!!
		end
		p.StatusEffects.angst = 1440
		takeMoney(g, p, share)
	end


	-- print('')
end



function takeMoney(g, p, share)
	share = math.min(share, p.AvailableMoney)
	share = math.floor(share * 100) / 100
	-- print('share')
	-- print(share)
	g.money = g.money + share
	p.AvailableMoney = p.AvailableMoney - share
	p.money_taken = p.money_taken + share
end


local day_starts_at = 9
local day_ends_at = 23


function keepCorrupt(g, d)
	-- g.WeaponDrawn = 1

	if g.hunting_id then

		-- print('hunting..')
		if g.hunting_id == -1 then
			cgSeekTarget(g)
		end

		if g.hunting_id ~= -1 then

			local target = search(g.hunting_id, {'Prisoner'}, g, 20)
			if target then
				if target.Damage >= 0.7 or (target.last_extortion and World.TimeIndex < target.last_extortion + 20 * 60) then
					-- give up
					g.last_id = g.hunting_id
					g.hunting_id = -1
				elseif dist(g, target) <= 2 then
					extort(g, target)
				else
					nav(g, target)
				end
			else
				g.last_id = g.hunting_id
				g.hunting_id = -1
			end

		end

	else
		if hourNow >= day_starts_at and hourNow < day_ends_at then
			g.hunting_cooldown = g.hunting_cooldown - Delay
			if g.hunting_cooldown <= 0 then
				g.hunting_cooldown = 30
				startHunt(g)
			else
			end
		end
		-- print('waiting next hunt')
	end

	g.level = calcLevel(g)
	overall_level = overall_level + g.level

	--
	-- g.Tooltip = {'fc__tt__bonus', g.level, 'L', g.extortion_count, 'X', g.beat_count, 'B', g.fight_count, 'F', g.money, 'M'}
end




function updateTooltip()

	if this.corruption_enabled then

		local cr
		if this.investigation_count > 0 then
			cr = math.floor(this.found_guard / this.investigation_count * 100)
		else
			cr = 0
		end

		-- print('tt')
		-- print(sizeOf(corrupt_guards))
		-- print(overall_level)
		-- print('')

		this.Tooltip = {'chief__tt__fc_on', sizeOf(corrupt_guards), 'N', overall_level, 'L', this.investigation_count, 'I', this.found_guard, 'G', cr, 'R', }
	else
		this.Tooltip = {'chief__tt__fc_off'}
	end
end


function calcLevel(g)
	return 3 * g.extortion_count - 2 * g.beat_count - 6 * g.fight_count
end

