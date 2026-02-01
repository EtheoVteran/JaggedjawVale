/proc/create_all_lighting_objects()
	var/count = 0
	var/list/valid_areas = list()
	
	// Pre-filter areas to avoid repeated checks
	for(var/area/A in world)
		if(A.dynamic_lighting)
			valid_areas += A
	
	for(var/area/A in valid_areas)
		for(var/turf/T in A)
			if(!T.dynamic_lighting)
				continue

			new/atom/movable/lighting_object(T)
			count++
			// Check tick every 1000 lighting objects for even faster initialization
			if(count % 1000 == 0)
				CHECK_TICK
