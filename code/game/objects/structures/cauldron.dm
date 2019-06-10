/obj/structure/cauldron
	name = "Cauldron"
	desc = "A large cauldron."
	icon = 'icons/obj/cauldron.dmi'
	icon_state = "cauldron_off"
	can_buckle = TRUE
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	max_buckled_mobs = 1
	buckle_lying = FALSE
	buckle_prevents_pull = TRUE
	var/burning = FALSE

/obj/structure/cauldron/Initialize()
	create_reagents(200, OPENCONTAINER)
	. = ..()

/obj/structure/cauldron/attackby(obj/item/W, mob/user, params)
	if(W.is_hot())
		Ignite()

/obj/structure/cauldron/do_climb(atom/movable/A)
	. = ..()
	var/mob/living/L = A
	if(istype(L))
		buckle_mob(L)

/obj/structure/cauldron/post_buckle_mob(mob/living/M)
	M.pixel_y += 7
	..()

/obj/structure/cauldron/post_unbuckle_mob(mob/living/buckled_mob)
	buckled_mob.pixel_y -= 7
	..()

/obj/structure/cauldron/attack_hand(mob/living/user)
	if(Adjacent(user) && user.pulling)
		var/mob/living/L = user.pulling
		if(istype(L))
			if(L.buckled)
				to_chat(user, "<span class='warning'>[L] is buckled to [L.buckled]!</span>")
				return
			if(user.a_intent == INTENT_GRAB)
				if(user.grab_state < GRAB_AGGRESSIVE)
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
					return
				L.setDir(2)
				L.forceMove(drop_location())
				buckle_mob(L)
				return
	..()

/obj/structure/cauldron/fire_act(exposed_temperature, exposed_volume)
	Ignite()

/obj/structure/cauldron/proc/Ignite()
	burning = TRUE
	set_light(2)
	for(var/mob/living/L in buckled_mobs)
		to_chat(L, "<span class='warning'>It is getting awefully hot in here!</span>")
	update_icon()
	START_PROCESSING(SSobj, src)

/obj/structure/cauldron/proc/Extinguish()
	burning = FALSE
	set_light(0)
	update_icon()
	STOP_PROCESSING(SSobj, src)

/obj/structure/cauldron/process()
	reagents.expose_temperature(600, 0.25)

/obj/structure/cauldron/on_reagent_change(changetype)
	update_icon()

/obj/structure/cauldron/update_icon()
	cut_overlays()
	icon_state = "cauldron_off"
	if(burning)
		icon_state = "cauldron_on"

	var/colour = mix_color_from_reagents(reagents.reagent_list)
	if(reagents.total_volume >= 50)
		var/mutable_appearance/water = mutable_appearance(icon, "water")
		water.color = colour
		add_overlay(water)
		/*if(reagents.chem_temp > 374)
			var/mutable_appearance/bubbles = mutable_appearance(icon, "bubbles")
			bubbles.color = colour
			add_overlay(bubbles)*/
