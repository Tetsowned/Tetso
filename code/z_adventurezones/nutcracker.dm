/* -----------------------------------------------------------------------------*\
CONTENTS:
NUTCRACKER AREAS
NUTCRACKER ID CARD
NUTCRACKER TOUR BOT SHIT
PAPERS AND AUDIO LOGS !! (LORE)
\*----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------*\
TODO:
Informational/sign up booth area
Make tour bot work!!!
Hand Scanner like polaris and find arm or like, a blood sample? that takes blood to open door
make the outside snow
change area noises
make a room with the TV, that just plays a loud static noise in the surrounding area
scary monster?
giant rat outbreak, big beartrap area to catch them
\*----------------------------------------------------------------------------- */

//card upgrader
/obj/card_upgrader/
	name = "Card Upgrader"
	desc = "A card upgrader. It can upgrade ID cards to have additional access levels."
	icon = 'icons/obj/card_upgraders.dmi'
	icon_state = "null"
	anchored = ANCHORED

	var/target_access = access_nutcracker_maint
	var/list/upgrade_sounds = list('sound/machines/glitch1.ogg', 'sound/machines/glitch2.ogg', 'sound/machines/glitch3.ogg', 'sound/machines/glitch4.ogg')

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/C = W

			if (src.target_access in C.access)
				boutput(user, SPAN_ALERT("[C] already has been upgraded!"))
				return

			C.access += src.target_access

			var/chosen_sound = pick(src.upgrade_sounds)
			playsound(src.loc, chosen_sound, 50, 1)

			user.visible_message(SPAN_NOTICE("[user] swipes [C] through [src]."), SPAN_NOTICE("You upgrade [C]'s access!"))
			return

		else
			return ..()

/obj/card_upgrader/orange
	name = "Factory Card Upgrader - Orange"
	desc = "A card upgrader. It can upgrade ID cards to have additional access levels."
	icon_state = "orange_upgrader"
	target_access = access_nutcracker_orange

/obj/card_upgrader/red
	name = "Factory Card Upgrader - Red"
	desc = "A card upgrader. It can upgrade ID cards to have additional access levels."
	icon_state = "red_upgrader"
	target_access = access_nutcracker_red

/obj/card_upgrader/blue
	name = "Factory Card Upgrader - Blue"
	desc = "A card upgrader. It can upgrade ID cards to have additional access levels."
	icon_state = "blue_upgrader"
	target_access = access_nutcracker_blue

/obj/card_upgrader/purple
	name = "Factory Card Upgrader - Purple"
	desc = "A card upgrader. It can upgrade ID cards to have additional access levels."
	icon_state = "purple_upgrader"
	target_access = access_nutcracker_purple

// ID CARDS!!!!!!!!!!!
/obj/item/card/id/factorymaint
	icon_state = "id_eng"
	access = list(access_nutcracker_maint)
	registered = null
	assignment = null

//Factory APC
/obj/machinery/power/apc/factory
	noalerts = 1
	start_charge = 0
	req_access = list(access_nutcracker_maint)

//Tourbot
/obj/machinery/bot/guardbot/old/tourguide/factory
	name = "Gilbert"
	desc = "A PR-4 Robuddy. These are pretty old, guess the museum doesn't change often.  This one has a little name tag on the front labeled 'Gilbert'. It has peanut butter on it's screen."
	setup_default_startup_task = /datum/computer/file/guardbot_task/tourguide/factory
	no_camera = 1
	setup_charge_maximum = 3000
	setup_charge_percentage = 100
	flashlight_lum = 4

	New()
		..()

		SPAWN(1 SECOND)
			if (src.botcard)
				src.botcard.access += access_nutcracker_tour

/datum/computer/file/guardbot_task/tourguide/factory

	wait_for_guests = 1

//shameless stolen from lunar
/obj/machinery/navbeacon/factory
	name = "tour beacon"
	freq = 1441

	tour0
		name = "tour beacon - start"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Huh? What are you doing here? This factory closed years ago.. How did you even get inside? Was it that stupid telepad?"

	tour1
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=PUT WORDS HERE!!!"

//////////// LORE !!!!! Papers, audio logs
/obj/item/paper/nutcracker/w2
    name = "paper - 'Form W-2'"
    icon_state = "paper"
    info = {"<p>Form W-2 Wage and Tax Statement for the fiscal period of 2047.</p>
        <h1 id="employer-information">Employer Information</h1>
        <p><strong>Employer Name:</strong> Nutcracker Co.</p>
        <p><strong>Location:</strong> Ligma Sector 21</p>
        <h1 id="employee-information">Employee Information</h1>
        <p><strong>Employee Name:</strong> Joe Mama</p>
        <p><strong>Employee ID:</strong> 02167</p>
        <h1 id="financial-statement">Financial Statement</h1>
        <h2 id="gross-earnings">Gross Earnings</h2>
        <p>32930 credits</p>
        <h2 id="deductions">Deductions</h2>
        <p>5840 credits</p>
        <h2 id="net-earnings">Net Earnings</h2>
        <p>27090.0000001 credits</p>"}

//////////////////////// DOORS, WALLS, BLAST DOOOOOOOOOOOORS
/obj/machinery/door/poddoor/blast/factory
	name = "security door"
	desc = "A security door used to separate museum compartments."
	autoclose = FALSE
	req_access = null
	object_flags = BOTS_DIRBLOCK

/obj/machinery/door/poddoor/blast/factory/tour // ALSO shamelessly stolen from lunar lol

	isblocked()
		return (src.density && src.operating == -1)

	open(var/obj/callerDoor)
		if (src.operating == 1) //doors can still open when emag-disabled
			return
		if (!density)
			return 0

		for (var/obj/machinery/door/poddoor/blast/factory/tourDoor in orange(1, src))
			if (tourDoor == callerDoor)
				continue

			SPAWN(0)
				tourDoor.open(src)

		if(!src.operating) //in case of emag
			src.operating = 1
		FLICK("bdoor[doordir]c0", src)
		src.icon_state = "bdoor[doordir]0"
		SPAWN(1 SECOND)
			src.set_density(0)
			src.set_opacity(0)
			update_nearby_tiles()

			if(operating == 1) //emag again
				src.operating = 0
			if(autoclose)
				sleep(15 SECONDS)
				autoclose()
		return 1


	close(var/obj/callerDoor)
		if (src.operating)
			return
		if (src.density)
			return
		src.operating = 1

		for (var/obj/machinery/door/poddoor/blast/factory/tour/tourDoor in orange(1, src))
			if (tourDoor == callerDoor)
				continue

			SPAWN(0)
				tourDoor.close(src)

		FLICK("bdoor[doordir]c1", src)
		src.icon_state = "bdoor[doordir]1"
		src.set_density(1)
		if (src.visible)
			src.set_opacity(1)
		update_nearby_tiles()

		sleep(1 SECOND)
		src.operating = 0
		return

	attackby(obj/item/C, mob/user)
		src.add_fingerprint(user)
		return

//Factory Areas
var/list/nutcracker_sounds = list('sound/effects/gust.ogg','sound/ambience/owlzone/owlsfx1.ogg','sound/ambience/owlzone/owlsfx2.ogg','sound/ambience/owlzone/owlsfx3.ogg','sound/ambience/owlzone/owlsfx4.ogg','sound/ambience/owlzone/owlsfx5.ogg')

/area/nutcracker
	name = "Nutcracker Factory"
	force_fullbright = 0
	sound_group = "nutcracker"
	teleport_blocked = AREA_TELEPORT_BLOCKED
	sound_environment = 12

	New()
		..()
		SPAWN(1 SECOND)
			process()

	proc/process()
		while(current_state < GAME_STATE_FINISHED)
			sleep(10 SECONDS)
			if (current_state == GAME_STATE_PLAYING && length(population))
				if(!played_fx_2 && prob(15))
					sound_fx_2 = pick(nutcracker_sounds)
					for(var/mob/M in src)
						if (M.client)
							M.client.playAmbience(src, AMBIENCE_FX_2, 50)

/area/nutcracker/outside
	name = "Factory Exterior"
	force_fullbright = 0
	icon_state = "purple"
	sound_loop = 'sound/ambience/owlzone/owlbanjo.ogg'
	sound_group = "factory_outside"

/area/nutcracker/entrance
	name = "Discount Dan's Nut Cracker Factory Entrance"
	icon_state = "green"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/main
	name = "Discount Dan's Nut Cracker Factory Tour Room"
	icon_state = "blue"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/security
	name = "Discount Dan's Nut Cracker Factory Security Office"
	icon_state = "security"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/maintenance
	name = "Discount Dan's Nut Cracker Factory Maintenance"
	icon_state = "purple"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/disposals
	name = "Discount Dan's Nut Cracker Factory Disposals"
	icon_state = "disposal"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/office
	name = "Discount Dan's Nut Cracker Factory Office"
	icon_state = "yellow"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/engineering
	name = "Discount Dan's Nut Cracker Factory Engineering"
	icon_state = "orange"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/janitorial
	name = "Discount Dan's Nut Cracker Factory Janitorial Closet"
	icon_state = "janitor"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/information
	name = "Discount Dan's Nut Cracker Factory Information Desk"
	icon_state = "red"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"

/area/nutcracker/breakroom
	name = "Discount Dan's Nut Cracker Factory Break Room"
	icon_state = "crew_lounge"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "factory_amb1"
