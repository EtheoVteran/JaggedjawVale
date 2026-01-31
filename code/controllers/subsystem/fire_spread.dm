///this isn't processing because we run through it current run style like pollution

GLOBAL_LIST_INIT(active_fires, list())

SUBSYSTEM_DEF(fire_spread)
	name = "Fire Spread"
	init_order = INIT_ORDER_AIR
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS

	var/list/current_run = list()

/datum/controller/subsystem/fire_spread/fire(resumed = FALSE)
	if (!resumed)
		var/list/active_list = GLOB.active_fires
		src.current_run = active_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.current_run

	while(currentrun.len)
		var/obj/effect/hotspot/fire = currentrun[currentrun.len]
		--currentrun.len

		if (QDELETED(fire))
			GLOB.active_fires -= fire
			continue

		if(MC_TICK_CHECK)
			return
		fire.handle_automatic_spread()
