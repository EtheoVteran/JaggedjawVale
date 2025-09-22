/obj/screen/fullscreen/proc/update_for_view(client_view)
	if (screen_loc == "CENTER-7,CENTER-7" && view != client_view)
		var/list/actualview = getviewsize(client_view)
		view = client_view
		transform = matrix(actualview[1]/15, 0, 0, 0, actualview[2]/15, 0)

/obj/screen/fullscreen
	var/view = 7

/obj/item
	//Vorestuff
	var/trash_eatable = FALSE
	var/digest_stage = null
	var/d_mult_old = 1 //digest stage descriptions
	var/d_mult = 1 //digest stage descriptions
	var/d_stage_overlay //digest stage effects
	var/gurgled = FALSE
	var/oldname
	var/cleanname
	var/cleandesc
	var/gurgled_color
	var/digestable = TRUE