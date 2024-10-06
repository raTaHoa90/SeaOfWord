local hached = {} 

function H(str)
	if types.is_hash(str) then
		if hached[str] == nil then
			hached[str] = str
		end
		return str
	else
		local h = hash(str)
		hached[h] = str
		return h
	end
end

function hash_to_str(h)
	return hached[h] or ""
end


function getProperty(go_id, scriptname, property)
	local url = msg.url(go_id)
	url.fragment = scriptname
	local value = go.get(url, property)
	if types.is_hash(value) then
		return hash_to_str(value)
	else
		return value
	end
end

function setProperty(go_id, scriptname, property, value)
	local url = msg.url(go_id)
	url.fragment = scriptname
	if type(value) == 'string' then
		value = H(value)
	end
	go.set(url, property, value)
end

function dist2d(point1, point2)
	return ((point2.x - point1.x)^2 + (point2.y - point1.y)^2)^0.5
end

function angle_between_two_points(point1, point2) 
	return math.atan2(point2.y - point1.y, point2.x - point1.x) 
end

