/obj/mecha/combat/phazon
	desc = "This is a Phazon exosuit. The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge bluespace technology and expensive materials."
	name = "\improper Phazon"
	icon_state = "phazon"
	step_in = 2
	step_energy_drain = 3
	max_integrity = 200
	deflect_chance = 30
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100)
	max_temperature = 25000
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/phazon
	add_req_access = 1
	internal_damage_threshold = 25
	force = 15
	max_equip = 3
	phase_state = "phazon-phase"
	///If the phazon is phasing.
	var/phasing = FALSE
	///How much energy it drains to be in phasing mode.
	var/phasing_energy_drain = 200
	///Is being given to the player on GrantActions.
	var/datum/action/innate/mecha/mech_toggle_phasing/phasing_action = new
	///Is being given to the player on GrantActions.
	var/datum/action/innate/mecha/mech_switch_damtype/switch_damtype_action = new

/obj/mecha/combat/phazon/GrantActions(mob/living/user, human_occupant = 0)
	..()
	switch_damtype_action.Grant(user, src)
	phasing_action.Grant(user, src)

/obj/mecha/combat/phazon/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	switch_damtype_action.Remove(user)
	phasing_action.Remove(user)

/obj/mecha/combat/phazon/check_click_target_viability(atom/target, mob/user, params)
	if(phasing)
		occupant_message("Unable to interact with objects while phasing")
		return
	. = ..()

/obj/mecha/combat/phazon/get_stats_part()
	. = ..()
	. += switch_damtype_action.owner ? "<b>Damtype: </b> [damtype]<br>" : ""
	. += phasing_action.owner ? "<b>Phase Modulator: </b> [phasing ? "Enabled" : "Disabled"]<br>" : ""

/obj/mecha/combat/phazon/Bump(var/atom/obstacle)
	if(phasing_action.phasing && get_charge() >= phasing_energy_drain && !throwing)
		spawn()
			if(can_move)
				can_move = 0
				if(phase_state)
					flick(phase_state, src)
				forceMove(get_step(src,dir))
				use_power(phasing_energy_drain)
				sleep(step_in*3)
				can_move = 1
	else
		. = ..()

///Switches the damage type of the mech around. Order is TOX > BRUTE > BURN > TOX.
/datum/action/innate/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/innate/mecha/mech_switch_damtype/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/new_damtype
	switch(chassis.damtype)
		if(TOX)
			new_damtype = BRUTE
			chassis.occupant_message("Your exosuit's hands form into fists.")
		if(BRUTE)
			new_damtype = BURN
			chassis.occupant_message("A torch tip extends from your exosuit's hand, glowing red.")
		if(BURN)
			new_damtype = TOX
			chassis.occupant_message("A bone-chillingly thick plasteel needle protracts from the exosuit's palm.")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, 1)
	UpdateButtonIcon()

///Toggles phazing of the mech.
/datum/action/innate/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"
	var/phasing = FALSE

/datum/action/innate/mecha/mech_toggle_phasing/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	phasing = !phasing
	button_icon_state = "mech_phasing_[phasing ? "on" : "off"]"
	chassis.occupant_message("<font color=\"[phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")
	UpdateButtonIcon()
