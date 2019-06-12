/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "largebins"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE
	delivery_icon = null
	y_offset = 2

/obj/structure/closet/crate/bin/Initialize()
	. = ..()
	update_icon()

/obj/structure/closet/crate/bin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/bag/trash) && (opened || open(user)))
		addtimer(CALLBACK(src, .proc/close, user), 10)
		return TRUE
	else
		return ..()

/obj/structure/closet/crate/bin/open(mob/living/user)
	. = ..()
	if(.)
		playsound(loc, open_sound, 15, 1, -3)

/obj/structure/closet/crate/bin/close(mob/living/user)
	. = ..()
	if(.)
		playsound(loc, close_sound, 15, 1, -3)
