/datum/component/footstep
	var/steps = 0
	var/volume
	var/e_range
	var/footstep_type
	///This can be a list OR a soundfile OR null. Determines whatever sound gets played.
	var/footstep_sounds

///Explanation of the args.
///volume determines the extra volume of the footstep. This is multiplied by the base volume, should there be one.
///e_range stands for extra range - aka how far the sound can be heard. This is added to the base value and ignored if there isn't one.
///footstep_type is a define which determines what kind of sounds should get chosen.
/datum/component/footstep/Initialize(footstep_type_ = FOOTSTEP_MOB_BAREFOOT, volume_ = 0.5, e_range_ = -1)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	footstep_type = footstep_type_
	switch(footstep_type)
		if(FOOTSTEP_MOB_HUMAN)
			if(!ishuman(parent))
				return COMPONENT_INCOMPATIBLE
			RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_humanstep)
			return
		if(FOOTSTEP_MOB_CLAW)
			footstep_sounds = GLOB.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			footstep_sounds = GLOB.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			footstep_sounds = GLOB.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			footstep_sounds = GLOB.footstep
		if(FOOTSTEP_MOB_SLIME)
			footstep_sounds = 'sound/effects/footstep/slime1.ogg'
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_footstep) //Note that this doesn't get called for humans.

/datum/component/footstep/proc/play_footstep()
	var/turf/open/T = get_turf(parent)
	if(!istype(T))
		return FALSE

	var/mob/living/LM = parent
	if(!T.footstep || LM.buckled || LM.lying || !CHECK_MULTIPLE_BITFIELDS(LM.mobility_flags, MOBILITY_STAND | MOBILITY_MOVE) || LM.throwing || LM.movement_type & (VENTCRAWLING | FLYING))
		if (LM.lying && !LM.buckled && !(!T.footstep || LM.movement_type & (VENTCRAWLING | FLYING))) //play crawling sound if we're lying
			playsound(T, 'sound/effects/footstep/crawl1.ogg', 15 * volume)
		return FALSE

	if(iscarbon(LM))
		var/mob/living/carbon/C = LM
		if(!C.get_bodypart(BODY_ZONE_L_LEG) && !C.get_bodypart(BODY_ZONE_R_LEG))
			return FALSE
		if(C.m_intent == MOVE_INTENT_WALK)
			return FALSE// stealth
	steps++

	if(steps >= 6)
		steps = 0

	if(steps % 2)
		return FALSE

	if(!LM.has_gravity(T) && steps != 0) // don't need to step as often when you hop around
		return FALSE

	if(footstep_sounds)
		if(isfile(footstep_sounds))
			playsound(T, footstep_sounds, volume)
			return TRUE
		var/turf_footstep
		switch(footstep_type)
			if(FOOTSTEP_MOB_CLAW)
				turf_footstep = T.clawfootstep
			if(FOOTSTEP_MOB_BAREFOOT)
				turf_footstep = T.barefootstep
			if(FOOTSTEP_MOB_HEAVY)
				turf_footstep = T.heavyfootstep
			if(FOOTSTEP_MOB_SHOE)
				turf_footstep = T.footstep
		if(!turf_footstep)
			return
		playsound(T, pick(footstep_sounds[turf_footstep][1]), footstep_sounds[turf_footstep][2] * volume, TRUE, footstep_sounds[turf_footstep][3] + e_range)
	return TRUE

/datum/component/footstep/proc/play_humanstep()
	if(!play_footstep())
		return
	var/mob/living/carbon/human/H = parent
	var/turf/open/T = get_turf(H) //We know this is an open turf, otherwise play_footstep wouldn't have returned TRUE.
	var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

	if(H.shoes || feetCover) //are we wearing shoes
		playsound(T, pick(GLOB.footstep[T.footstep][1]),
			GLOB.footstep[T.footstep][2] * volume,
			TRUE,
			GLOB.footstep[T.footstep][3] + e_range)
	else
		if(H.dna.species.special_step_sounds)
			playsound(T, pick(H.dna.species.special_step_sounds), 50, TRUE)
		else
			playsound(T, pick(GLOB.barefootstep[T.barefootstep][1]),
				GLOB.barefootstep[T.barefootstep][2] * volume,
				TRUE,
				GLOB.barefootstep[T.barefootstep][3] + e_range)
