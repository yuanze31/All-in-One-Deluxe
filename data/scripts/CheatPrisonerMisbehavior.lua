-- CheatPrisonerMisbehavior --




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


local miz_last = nil
local miz = nil
local prefix = "cpm__"

function diffMenu(miz)
	if not miz_last then return true end
	local index = 0
	for i, v in pairs( miz ) do
		index = i
		if not miz_last[i] or miz_last[i][1] ~= v[1] then
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
		if type(cn) == 'table' then
			cn = t[1][1]
			translation = t[1][2]
		end
		t[2] = t[2] or 'Caption'
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







local inited

function Update(timePassed)
	if not inited then Init() end
end

function Create()
	Init()
end

function Init()
	inited = true
	this.Tooltip = 'cpm__tt'
	this.range = this.range or 999
	local miz = {
		{"range", "Button", this.range, "R"},
		{"destroy", "Button"},
		{"escape", "Button"},
		{"fight", "Button"},
		{"riot", "Button"},
	}
	updateMenu(miz)
end

function cpm__rangeClicked()
	if this.range == 999 then
		this.range = 20
	else
		this.range = 999
	end
	Interface.SetCaption(this, "cpm__range", "cpm__range", this.range, "R")
end


function destroy(p)
	p.Misbehavior = 3
end
function escape(p)
	p.Misbehavior = 2
end
function fight(p)
	p.Misbehavior = 5
end
function riot(p)
	p.Misbehavior = 6
end


function cpm__destroyClicked()
	look_around({'Prisoner'}, destroy, this.range)
end

function cpm__escapeClicked()
	look_around({'Prisoner'}, escape, this.range)
end

function cpm__fightClicked()
	look_around({'Prisoner'}, fight, this.range)
end

function cpm__riotClicked()
	look_around({'Prisoner'}, riot, this.range)
end



