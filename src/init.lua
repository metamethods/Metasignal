local Metasignal = {}
Metasignal.__index = Metasignal

function Metasignal.new()
	return setmetatable({
		_callback = nil :: (...any) -> (...any) | nil,
		_next = false :: Metasignal | false,
	}, Metasignal)
end

function Metasignal.Connect(
	self: Metasignal,
	callback: (...any) -> (...any)
)
	if self._next then 
		return self._next:Connect(callback)
	end

	self._callback = callback
	self._next = Metasignal.new()

	return self
end

function Metasignal.Once(
	self: Metasignal,
	callback: (...any) -> (...any)
)
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		return callback(...)
	end)

	return self
end
	

function Metasignal.Fire(
	self: Metasignal,
	...: any
)
	if self._callback then
		task.spawn(self._callback, ...)
	end

	if self._next then 
		return self._next:Fire(...)
	end
end

function Metasignal.Disconnect(
	self: Metasignal
)
	self._callback = nil
end

function Metasignal.Wait(
	self: Metasignal
)
	local waiting = coroutine.running()
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		coroutine.resume(waiting, ...)
	end)

	return coroutine.yield()
end

type Metasignal = typeof(Metasignal.new(table.unpack(...)))

return Metasignal