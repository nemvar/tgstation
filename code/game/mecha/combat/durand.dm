/obj/mecha/combat/durand
	desc = "An aging combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "\improper Durand"
	icon_state = "durand"
	step_in = 4
	max_integrity = 400
	deflect_chance = 20
	armor = list("melee" = 40, "bullet" = 35, "laser" = 15, "energy" = 10, "bomb" = 20, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand
	///Is being given to the player on GrantActions.
	var/datum/action/innate/mecha/mech_defence_mode/defense_action = new

/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Remove(user)

/obj/mecha/combat/durand/domove(direction)
	if(defense_action.defence_mode)
		if(world.time - last_message > 20)
			occupant_message("<span class='danger'>Unable to move while in defence mode</span>")
			last_message = world.time
		return 0
	. = ..()

/obj/mecha/combat/durand/get_stats_part()
	. = ..()
	. += defense_action.owner ? "<b>Defence Mode: </b> [defense_action.defence_mode ? "Enabled" : "Disabled"]<br>" : ""

///Toggles the defense move for durands
/datum/action/innate/mecha/mech_defence_mode
	name = "Toggle Defence Mode"
	button_icon_state = "mech_defense_mode_off"
	var/defence_mode = FALSE
	var/extra_deflect_chance = 25

/datum/action/innate/mecha/mech_defence_mode/Activate(forced_state)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		defence_mode = forced_state
	else
		defence_mode = !defence_mode
	button_icon_state = "mech_defense_mode_[defence_mode ? "on" : "off"]"
	if(defence_mode)
		chassis.deflect_chance += extra_deflect_chance
		chassis.occupant_message("<span class='notice'>You enable [chassis] defence mode.</span>")
		chassis.log_message("Defence mode enabled.", LOG_MECHA)
	else
		chassis.deflect_chance -= extra_deflect_chance
		chassis.occupant_message("<span class='danger'>You disable [chassis] defence mode.</span>")
		chassis.log_message("Defence mode disabled.", LOG_MECHA)
	UpdateButtonIcon()
