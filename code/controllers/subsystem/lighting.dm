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
		if (CONFIG_GET(flag/starlight))
			for(var/I in GLOB.sortedAreas)
				var/area/A = I
				if (A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
					A.luminosity = 0

		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)

	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/list/queue = sources_queue
	var/processed = 0
	while(length(queue))
		var/datum/light_source/L = KEYBYINDEX(queue, 1)
		if(!L)
			break

		L.update_corners()
		L.needs_update = LIGHTING_NO_UPDATE
		processed++

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (processed)
		queue.Cut(1, processed)
		processed = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = corners_queue
	processed = 0
	while(length(queue))
		var/datum/lighting_corner/C = KEYBYINDEX(queue, 1)
		if(!C)
			break

		C.update_objects()
		C.needs_update = FALSE
		processed++
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (processed)
		queue.Cut(1, processed)
		processed = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = objects_queue
	processed = 0
	while(length(queue))
		var/atom/movable/lighting_object/O = KEYBYINDEX(queue, 1)
		if(!O)
			break

		// Remove deleted objects from the queue and count as processed
		if (QDELETED(O))
			processed++
			continue

		O.update()
		O.needs_update = FALSE
		processed++
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (processed)
		queue.Cut(1, processed)


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
