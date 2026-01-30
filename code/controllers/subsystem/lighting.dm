SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 0
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER
	priority = FIRE_PRIORITY_DEFAULT
	var/static/list/sources_queue = list() // List of lighting sources queued for update.
	var/static/list/corners_queue = list() // List of lighting corners queued for update.
	var/static/list/objects_queue = list() // List of lighting objects queued for update.
	processing_flag = PROCESSING_LIGHTING

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[length(sources_queue)]|C:[length(corners_queue)]|O:[length(objects_queue)]")


/datum/controller/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		if(CONFIG_GET(flag/starlight))
			for(var/I in GLOB.sortedAreas)
				var/area/A = I
				if(A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
					A.luminosity = 0

		create_all_lighting_objects()
		initialized = TRUE

	// During init, process all queued items with higher limits for speed
	fire(FALSE, TRUE)

	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/list/queue = sources_queue
	var/processed = 0
	// Higher init limit for faster startup, lower runtime limit for stability
	var/max_process = init_tick_checks ? 50000 : 1000  // Safety limit
	var/check_every = init_tick_checks ? 500 : 50
	while(processed < max_process && queue.len)
		var/datum/light_source/L = queue[1]
		queue[1] = queue[queue.len]
		queue.len--
		if(!L)
			continue

		L.update_corners()
		L.needs_update = LIGHTING_NO_UPDATE
		processed++

		if(init_tick_checks && (processed % check_every == 0))
			CHECK_TICK
		else if (!init_tick_checks && MC_TICK_CHECK)
			break

	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = corners_queue
	processed = 0
	while(processed < max_process && queue.len)
		var/datum/lighting_corner/C = queue[1]
		queue[1] = queue[queue.len]
		queue.len--
		if(!C)
			continue

		C.update_objects()
		C.needs_update = FALSE
		processed++
		if(init_tick_checks && (processed % check_every == 0))
			CHECK_TICK
		else if (!init_tick_checks && MC_TICK_CHECK)
			break


	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = objects_queue
	processed = 0
	while(processed < max_process && queue.len)
		var/atom/movable/lighting_object/O = queue[1]
		queue[1] = queue[queue.len]
		queue.len--
		if(!O)
			continue

		// Remove deleted objects from the queue and count as processed
		if (QDELETED(O))
			processed++
			continue

		O.update()
		O.needs_update = FALSE
		processed++
		if(init_tick_checks && (processed % check_every == 0))
			CHECK_TICK
		else if (!init_tick_checks && MC_TICK_CHECK)
			break


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
