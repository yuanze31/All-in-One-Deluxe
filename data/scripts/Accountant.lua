-- Accountant --


function look_around(types, cb, range, justOne)
	local who = this
	if ms and ms.escaping then who = target end
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

function nav(who, to, dx, dy)
	who.NavigateTo((to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end


function getObjCell(o)
	return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end

function SpawnAt(type, to, dx, dy)
	return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end



local today
local hourNow
function renewDateTime()
	today = math.floor(World.TimeIndex / 1440) + 1
	hourNow = math.floor(World.TimeIndex / 60) % 24
end



local Ready = 0
local Delay = 1
local correct_needtime = 10

function Update()
	if not inited then Init() end

	if World.TimeIndex > Ready then
		Ready = World.TimeIndex + Delay

		renewDateTime()

		if this.last_correct_day < today then
			this.last_correct_day = today
			this.correct_count = 0

		end

		updateTT(correctBooks())

	end
end

local inited
function Init()
	inited = true

	if this.correct_count == nil then
		this.correct_count = 0
	end

	renewDateTime()
	if this.last_correct_day == nil then
		this.last_correct_day = today
	end



end

-- local bonus_poss = 0.1 -- possibility of bonus
local bonus_step = 4

function correctBooks()

	if this.Damage >= 1 then
		return 'dead'
	end

	if this.Damage >= 0.7 then
		return 'unconscious'
	end

	-- look_around({'Stack'}, unpackStack, 'max')
	look_around({'AccountingBookFailed'}, replaceBook1, 'max')

	local here = getObjCell(this)
	if this.Office.u ~= here.Room.u then
		return 'outside'
	end

	local b = look_around({'AccountingBookCorrecting'}, ifInOffice, 6, true)

	if not b then
		local b1 = look_around({'AccountingBookFailed2'}, ifInOffice, 6, true)

		if not b1 then return end

		local b = SpawnAt('AccountingBookCorrecting', b1)
		b.Or.x = 0
		b.Or.y = -1
		b1.Delete()
	end

	if not b then return end

	if b.progress == nil then
		b.progress = 1
	else
		b.progress = b.progress + 1
	end

	if b.progress >= (correct_needtime/Delay) then
		local b3 = SpawnAt('AccountingBookFinished', b)
		b.Delete()
		local vx = (1 - 2 * math.random()) * 0.1
		b3.ApplyVelocity(vx, -0.15)

		this.correct_count = this.correct_count + 1
	else
		b.Tooltip = {'ab__failed_tt__progress', math.floor(b.progress/15*100), 'P'}
	end

	-- this.fatigue = this.fatigue + 1
	-- local r = math.random()
	-- if r < this.fatigue then
	-- 	this.Damage = this.Damage + 0.1
	-- end

	return nil
end



function updateTT(problem)
	if problem then
		this.Tooltip = {'ab__accountant_tt__notworking', this.correct_count, 'C', 'ab__accountant_tt__'..problem, 'P'}
	else
		this.Tooltip = {'ab__accountant_tt__count', this.correct_count, 'C'}
	end
end


-- function unpackStack(stack)
-- 	if stack.Contents == 'AccountingBookFailed' then
-- end

function replaceBook1(b)

	if b.Carried > 0 then
		return
	end

	local c = getObjCell(b)
	if this.Office.u ~= c.Room.u then
		return
	end

	local b2 = SpawnAt('AccountingBookFailed2', b)
	b.Or.y = 0
	b.Or.x = -1
	b.Delete()
end


function ifInOffice(b)
	local c = getObjCell(b)
	return (this.Office.u == c.Room.u)
end
