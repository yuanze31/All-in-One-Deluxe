-- SwapOfficeMarker --

function search(uid, types, center_object, range)
	center_object = center_object or this
	if range == "max" then range = 9999 end

	for k, v in pairs(types) do
		local os = center_object.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			if o.Id.u == uid then
				print("Found object "..v.." #"..uid)
				return o
			end
		end
	end
	return nil
end




local prefix = "swapoffice_marker__"
local miz_last = nil
local miz = nil

local adminTypes = {"Warden", "Chief", "Foreman", "Psychologist", "Accountant", "Lawyer", "BoldHost", }

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
		t[2] = t[2] or 'Caption'
		if type(cn) == 'table' then
			cn = t[1][1]
			translation = t[1][2]
		end
		Interface.SetCaption(this, prefix..cn, prefix..translation, t[3], t[4], t[5], t[6], t[7], t[8])
	end
end

function refreshMenu(miz)
	print('refreshMenu')
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















local target

function trackTarget()
	if target == nil or target.Damage == nil then
		this.Delete()
		return
	end

	this.Pos.x = target.Pos.x + target.Or.x * 0.2
	local dy = 0.1 - (Game.Time() % 0.6) / 6
	-- local dy = (3 - math.floor(Game.Time() * 5) % 6) / 15
	this.Pos.y = target.Pos.y - 0.7 - dy
end









local Ready = 0

function Update()
	if not target then
		if this.target_id then
			target = search(this.target_id, adminTypes, this, 2)
			menu()
		else
			this.Delete()
		end
	end

	if Game.Time() > Ready then
		Ready = Game.Time() + 0.01
		if target.Pos.x == nil then
			this.Delete()
		else
			trackTarget()
		end
	end

end




function deleteO( o )
	o.Pos.x = 0
	o.Pos.y = 0
	o.Delete()
end




function extend( t1, t2 )
	if t2 then
		for i, v in pairs(t2) do
			table.insert(t1, v)
		end
	end
	return t1
end


function menu()

	local miz = {
		{'delete', 'Button'},
	}

	updateMenu(miz)
end

function attention_marker__deleteClicked()
	deleteO(this)
	updateMenu({})
end

