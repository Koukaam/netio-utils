local function blink_slowly(output, seconds)
	-- blink given output slowly for given time
	local function iteration(output, end_time, blink_count)
		local now = os.time()
		if now >= end_time then
			devices.system.SetOut{output=output, value=false}
			return
		end
	
		local wait_time
		if blink_count % 2 == 0 then
			-- should turn on now
			devices.system.SetOut{output=output, value=true}
			wait_time = 60 -- wait for a minute on
			if now + wait_time > end_time then
				wait_time = end_time - now
			end
		else
			-- should turn off now
			devices.system.SetOut{output=output, value=false}
			wait_time = 5 * 60 -- wait for 5 minutes off
		end
		
		delay(wait_time, function() iteration(output, end_time, blink_count + 1) end)
	end
	
	iteration(output, os.time() + seconds, 0)
end

-- slowly blink on port 2 for 15 minutes
blink_slowly(2, 15 * 60)
