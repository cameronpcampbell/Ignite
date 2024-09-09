return {
	CountKeys = function(tble: { [any]: any }): number
		local length = 0
		for _ in tble do length += 1 end
		return length
	end,

	HasItems = function(tble: { [any]: any }): boolean
		for _ in tble do return true end
		return false
	end,

	Take = function<K, V>(tble: { [K]: V }, keyOrIndex: K, default: V?)
		local value = tble[keyOrIndex]
		tble[keyOrIndex] = nil

		if value == nil then return default end
		return value
	end,

	ContainsInst = function(tble: { [any]: any }, className: string)
		for _,value in tble do
			if not (typeof(value) == "Instance" and value.ClassName == className) then continue end
			return true
		end

		return false
	end,

	InsertMany = function(tble: { [any]: any }, ...: any)
		for i = 1, select("#", ...) do table.insert(tble, select(i, ...)) end
	end
}


