--CameraMan--


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

function dist( from, to )
	return math.pow(math.pow( (from.Pos.x - to.Pos.x), 2) + math.pow( (from.Pos.y - to.Pos.y), 2) , 0.5)
end

function SpawnAt(type, to, dx, dy)
	return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

function nav(who, to, dx, dy)
	who.NavigateTo((to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

local host

local Delay  = 3 -- Clock Minutes
local Ready  = 0

function Update()
	if World.TimeIndex > Ready then
		Ready = World.TimeIndex + Delay

		if this.Damage >= 0.7 then
			this.Tooltip = ''
			if this.Damage >= 1 and not this.spawned_fine then
				this.spawned_fine = true
				SpawnAt('DeathFine', this)
			end
			return
		end

		if this.Damage >= 0.1 and this.Damage < 1 then
			if this.last_call == nil then
				this.last_call = 0
			end
			if World.TimeIndex - this.last_call > 60 then
				this.last_call = World.TimeIndex
				this.CreateJob('DoctorCalled')
			end
		end

		-- this.PermitPlayerControl = true

		host = look(this, {'BoldHost'}, isfree, 5, true) or look(this, {'BoldHost'}, isfree, 10, true) or look(this, {'BoldHost'}, isfree, 'max', true)

		if host then
			if host.Office.u == getObjCell(host).Room.u then
				if host.Office.u == getObjCell(this).Room.u then
					-- already arrived
					if dist(this, host) > 2.5 then
						this.NavigateTo( (this.Pos.x * 0.7 + host.Pos.x * 0.3), (this.Pos.y * 0.7 + host.Pos.y * 0.3))
					end
				else
					nav(this, host)
				end
			end
			host.cameraman_id = this.Id.u
		else
			this.LeaveMap()
		end

		if this.LeavingMap then
			this.Tooltip = "dangerous_meeting__cameraman_LeavingMap"
		elseif host then
			if host.Office.u == getObjCell(host).Room.u then
				this.Tooltip = "dangerous_meeting__cameraman_sees_host__Yes"
			else
				this.Tooltip = 'dangerous_meeting__cameraman_waits_for_host'
			end
		else
			this.Tooltip = "dangerous_meeting__cameraman_sees_host__No"
		end

	end
end


function isfree(host)
	return (host.Damage < 1 and host.Office.u > 0 and ((not host.cameraman_id) or host.cameraman_id == this.Id.u))
end



		-- 	if host.Damage >= 1 then
		-- 		-- this.PermitPlayerControl = false
		-- 		this.LeaveMap()
		-- 	elseif host.Damage >= 0.7 then
		-- 		-- nothing
		-- 	-- elseif this.LeavingMap then
		-- 	-- 	this.LeaveMap()
		-- 		-- nothing
		-- 	elseif dist(this, host) > 2 then
		-- 		local c = getObjCell(this)
		-- 		if host.Office.u == c.Room.u then
		-- 			-- this.NavigateTo( (this.Pos.x * 0.7 + host.Pos.x * 0.3), (this.Pos.y * 0.7 + host.Pos.y * 0.3))
		-- 		else
		-- 			nav(this, host)
		-- 		end
		-- 	end
		-- 	local os = this.GetNearbyObjects('BoldHost', 9999)
		-- 	for o, distance in pairs( os ) do
		-- 		if o.Damage < 1 and not o.cameraman then
		-- 			host = o
		-- 			this.PermitPlayerControl = true
		-- 			this.NavigateTo( host.Pos.x, host.Pos.y)
		-- 			host.cameraman_id = true
		-- 			break
		-- 		end
		-- 	end
		-- 	if not host then
		-- 		-- this.PermitPlayerControl = false
		-- 	end
		-- end
