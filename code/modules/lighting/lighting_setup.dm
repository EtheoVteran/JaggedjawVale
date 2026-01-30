/proc/create_all_lighting_objects()
	var/count = 0
	for(var/area/A in world)
		if(!IS_DYNAMIC_LIGHTING(A))
			continue

		for(var/turf/T in A)
			if(!IS_DYNAMIC_LIGHTING(T))
				continue

			new/atom/movable/lighting_object(T)
			count++
			// Check tick every 500 lighting objects for faster initialization
			if(count % 500 == 0)
				CHECK_TICK
