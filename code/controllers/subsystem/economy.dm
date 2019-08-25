#define SSE_BUDGET_POOL 35000

#define SSE_MAX_GRANT_CIV 2500
#define SSE_MAX_GRANT_ENG 3000
#define SSE_MAX_GRANT_SCI 5000
#define SSE_MAX_GRANT_SECMEDSRV 3000

#define SSE_ALIVE_HUMANS_BOUNTY 100
#define SSE_CREW_SAFETY_BOUNTY 1500
#define SSE_MONSTER_BOUNTY 150
#define SSE_MOOD_BOUNTY 100

SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	init_order = INIT_ORDER_ECONOMY
	runlevels = RUNLEVEL_GAME
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/generated_accounts = list()
	var/full_ancap = FALSE // Enables extra money charges for things that normally would be free, such as sleepers/cryo/cloning.
							//Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
	var/list/slime_bounty = list("grey" = 10,
							// tier 1
							"orange" = 100,
							"metal" = 100,
							"blue" = 100,
							"purple" = 100,
							// tier 2
							"dark purple" = 500,
							"dark blue" = 500,
							"green" = 500,
							"silver" = 500,
							"gold" = 500,
							"yellow" = 500,
							"red" = 500,
							"pink" = 500,
							// tier 3
							"cerulean" = 750,
							"sepia" = 750,
							"bluespace" = 750,
							"pyrite" = 750,
							"light pink" = 750,
							"oil" = 750,
							"adamantine" = 750,
							// tier 4
							"rainbow" = 1000)
	var/list/bank_accounts = list() //List of normal accounts (not department accounts)
	var/list/dep_cards = list()

/datum/controller/subsystem/economy/Initialize(timeofday)
	var/budget_to_hand_out = round(SSE_BUDGET_POOL / department_accounts.len)
	for(var/A in department_accounts)
		new /datum/bank_account/department(A, budget_to_hand_out)
	return ..()

/datum/controller/subsystem/economy/fire(resumed = 0)
	eng_payout()  // Payout based on nothing. What will replace it? Surplus power, powered APC's, air alarms? Who knows.
	civ_payout() // Payout based on ??? Profit
	secmedsrvsci_payout() // Payout based on crew safety, health, slimes and mood.
	for(var/A in bank_accounts)
		var/datum/bank_account/B = A
		B.payday(1)


/datum/controller/subsystem/economy/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D

/datum/controller/subsystem/economy/proc/eng_payout()
	var/engineering_cash = SSE_MAX_GRANT_ENG
	var/datum/bank_account/D = get_dep_account(ACCOUNT_ENG)
	if(D)
		D.adjust_money(engineering_cash)

/datum/controller/subsystem/economy/proc/civ_payout()
	var/civ_cash = (rand(1,5) * SSE_MAX_GRANT_CIV * 0.2)
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CIV)
	if(D)
		D.adjust_money(min(civ_cash, SSE_MAX_GRANT_CIV))

///This mess of a proc gets how much money medical, service, security and science should receive. This is all in one proc because that way we only need to run through GLOB.mob_list once.
/datum/controller/subsystem/economy/proc/secmedsrvsci_payout()
	var/crew
	var/alive_crew
	var/dead_monsters
	var/security_payout
	var/medical_payout
	var/service_payout
	var/science_payout
	for(var/_m in GLOB.mob_list)
		CHECK_TICK
		var/mob/m = _m
		if(!m) //mob_list is notorious for having some nulls in there.
			continue
		if(isnewplayer(m))
			continue
		if(m.mind)
			if(isbrain(m) || iscameramob(m))
				continue
			if(ishuman(m))
				crew++
				if(m.stat == DEAD)
					continue
				var/mob/living/carbon/human/H = m
				alive_crew++
				//Service
				var/datum/component/mood/mood = H.GetComponent(/datum/component/mood) //REE
				if(mood)
					service_payout += (mood.sanity / SANITY_NEUTRAL) * SSE_MOOD_BOUNTY
				//Medical
				medical_payout += (H.health / H.maxHealth) * SSE_ALIVE_HUMANS_BOUNTY
				continue
		if(ishostile(m))
			//Security
			if(m.stat == DEAD)
				if(m.z in SSmapping.levels_by_trait(ZTRAIT_STATION))
					dead_monsters++
				continue
			//Science
		if(isslime(m))
			if(m.stat == DEAD)
				continue
			var/mob/living/simple_animal/slime/S = m
			science_payout += slime_bounty[S.colour]
	var/living_ratio = crew ? round(alive_crew / crew) : 0
	security_payout = (SSE_CREW_SAFETY_BOUNTY * living_ratio) + (SSE_MONSTER_BOUNTY * dead_monsters)
	//Actual payout stuff.
	var/datum/bank_account/D
	D = get_dep_account(ACCOUNT_SEC)
	if(D)
		D.adjust_money(min(security_payout, SSE_MAX_GRANT_SECMEDSRV))
	D = get_dep_account(ACCOUNT_MED)
	if(D)
		D.adjust_money(min(medical_payout, SSE_MAX_GRANT_SECMEDSRV))
	D = get_dep_account(ACCOUNT_SRV)
	if(D)
		D.adjust_money(min(service_payout, SSE_MAX_GRANT_SECMEDSRV))
	D = get_dep_account(ACCOUNT_SCI)
	if(D)
		D.adjust_money(min(science_payout, SSE_MAX_GRANT_SCI))

#undef SSE_BUDGET_POOL

#undef SSE_MAX_GRANT_CIV
#undef SSE_MAX_GRANT_ENG
#undef SSE_MAX_GRANT_SCI
#undef SSE_MAX_GRANT_SECMEDSRV

#undef SSE_ALIVE_HUMANS_BOUNTY
#undef SSE_CREW_SAFETY_BOUNTY
#undef SSE_MONSTER_BOUNTY
#undef SSE_MOOD_BOUNTY
