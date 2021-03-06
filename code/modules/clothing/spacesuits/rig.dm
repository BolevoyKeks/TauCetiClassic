//Regular rig suits
/obj/item/clothing/head/helmet/space/rig
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 20)

	action_button_name = "Toggle Helmet Light"
	allowed = list(/obj/item/device/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	item_color = "engineering" //Determines used sprites: rig[on]-[color] and rig[on]-[color]2 (lying down sprite)
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

	//Species-specific stuff.
	species_restricted = list("exclude" , UNATHI , TAJARAN , SKRELL , DIONA , VOX)
	sprite_sheets_refit = list(
		UNATHI = 'icons/mob/species/unathi/helmet.dmi',
		TAJARAN = 'icons/mob/species/tajaran/helmet.dmi',
		SKRELL = 'icons/mob/species/skrell/helmet.dmi',
		)
	sprite_sheets_obj = list(
		UNATHI = 'icons/obj/clothing/species/unathi/hats.dmi',
		TAJARAN = 'icons/obj/clothing/species/tajaran/hats.dmi',
		SKRELL = 'icons/obj/clothing/species/skrell/hats.dmi',
		)

/obj/item/clothing/head/helmet/space/rig/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc]")//To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "rig[on]-[item_color]"
//	item_state = "rig[on]-[color]"
	usr.update_inv_head()

	if(on)	set_light(brightness_on)
	else	set_light(0)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

/obj/item/clothing/suit/space/rig
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 1
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

	species_restricted = list("exclude" , UNATHI , TAJARAN , DIONA , VOX)
	sprite_sheets_refit = list(
		UNATHI = 'icons/mob/species/unathi/suit.dmi',
		TAJARAN = 'icons/mob/species/tajaran/suit.dmi',
		SKRELL = 'icons/mob/species/skrell/suit.dmi',
		)
	sprite_sheets_obj = list(
		UNATHI = 'icons/obj/clothing/species/unathi/suits.dmi',
		TAJARAN = 'icons/obj/clothing/species/tajaran/suits.dmi',
		SKRELL = 'icons/obj/clothing/species/skrell/suits.dmi',
		)
	var/magpulse = 0

	//Breach thresholds, should ideally be inherited by most (if not all) hardsuits.
	breach_threshold = 18
	can_breach = 1

	//Component/device holders.
	var/obj/item/weapon/stock_parts/gloves = null     // Basic capacitor allows insulation, upgrades allow shock gloves etc.

	var/attached_boots = 1                            // Can't wear boots if some are attached
	var/obj/item/clothing/shoes/magboots/boots = null // Deployable boots, if any.
	var/attached_helmet = 1                           // Can't wear a helmet if one is deployable.
	var/obj/item/clothing/head/helmet/helmet = null   // Deployable helmet, if any.

	var/list/max_mounted_devices = 0                  // Maximum devices. Easy.
	var/list/can_mount = null                         // Types of device that can be hardpoint mounted.
	var/list/mounted_devices = null                   // Holder for the above device.
	var/obj/item/active_device = null                 // Currently deployed device, if any.

/obj/item/clothing/suit/space/rig/equipped(mob/M)
	..()

	var/mob/living/carbon/human/H = M

	if(!istype(H)) return

	if(H.wear_suit != src)
		return

/obj/item/clothing/suit/space/rig/dropped()
	..()

	var/mob/living/carbon/human/H

	if(helmet)
		H = helmet.loc
		if(istype(H))
			if(helmet && H.head == helmet)
				helmet.canremove = 1
				H.drop_from_inventory(helmet)
				helmet.loc = src

	if(boots)
		H = boots.loc
		if(istype(H))
			if(boots && H.shoes == boots)
				boots.canremove = 1
				H.drop_from_inventory(boots)
				boots.loc = src

/obj/item/clothing/suit/space/rig/verb/toggle_helmet()

	set name = "Toggle Helmet"
	set category = "Object"
	set src in usr

	if(!istype(src.loc,/mob/living)) return

	if(!helmet)
		to_chat(usr, "There is no helmet installed.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.stat) return
	if(H.wear_suit != src) return

	if(H.head == helmet)
		helmet.canremove = 1
		H.drop_from_inventory(helmet)
		helmet.loc = src
		to_chat(H, "\blue You retract your hardsuit helmet.")
	else
		if(H.head)
			to_chat(H, "\red You cannot deploy your helmet while wearing another helmet.")
			return
		//TODO: Species check, skull damage for forcing an unfitting helmet on?
		helmet.loc = H
		H.equip_to_slot(helmet, slot_head)
		helmet.canremove = 0
		to_chat(H, "\blue You deploy your hardsuit helmet, sealing you off from the world.")

/obj/item/clothing/suit/space/rig/verb/toggle_magboots()

	set name = "Toggle Space Suit Magboots"
	set category = "Object"
	set src in usr

	if(!istype(src.loc,/mob/living)) return

	if(!boots)
		to_chat(usr, "\The [src] does not have any boots installed.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.stat) return
	if(H.wear_suit != src) return

	if(magpulse)
		flags &= ~NOSLIP
		src.slowdown = initial(slowdown)
		magpulse = 0
		to_chat(H, "You disable \the [src] the mag-pulse traction system.")
	else
		flags |= NOSLIP
		src.slowdown += boots.slowdown_off
		magpulse = 1
		to_chat(H, "You enable the mag-pulse traction system.")

/obj/item/clothing/suit/space/rig/attackby(obj/item/W, mob/user)

	if(!istype(user,/mob/living)) return

	if(user.a_intent == "help")

		if(istype(src.loc,/mob/living) && !istype(W, /obj/item/weapon/patcher))
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return

		var/target_zone = user.zone_sel.selecting

		if(target_zone == BP_HEAD)

			//Installing a component into or modifying the contents of the helmet.
			if(!attached_helmet)
				to_chat(user, "\The [src] does not have a helmet mount.")
				return

			if(istype(W,/obj/item/weapon/screwdriver))
				if(!helmet)
					to_chat(user, "\The [src] does not have a helmet installed.")
				else
					to_chat(user, "You detatch \the [helmet] from \the [src]'s helmet mount.")
					helmet.loc = get_turf(src)
					src.helmet = null
				return
			else if(istype(W,/obj/item/clothing/head/helmet/space))
				if(helmet)
					to_chat(user, "\The [src] already has a helmet installed.")
				else
					to_chat(user, "You attach \the [W] to \the [src]'s helmet mount.")
					user.drop_item()
					W.loc = src
					src.helmet = W
				return
			else
				return ..()

		else if(target_zone == BP_L_LEG || target_zone == BP_R_LEG || target_zone == BP_L_FOOT || target_zone == BP_R_FOOT)

			//Installing a component into or modifying the contents of the feet.
			if(!attached_boots)
				to_chat(user, "\The [src] does not have boot mounts.")
				return

			if(istype(W,/obj/item/weapon/screwdriver))
				if(!boots)
					to_chat(user, "\The [src] does not have any boots installed.")
				else
					to_chat(user, "You detatch \the [boots] from \the [src]'s boot mounts.")
					boots.loc = get_turf(src)
					boots = null
				return
			else if(istype(W,/obj/item/clothing/shoes/magboots))
				if(boots)
					to_chat(user, "\The [src] already has magboots installed.")
				else
					to_chat(user, "You attach \the [W] to \the [src]'s boot mounts.")
					user.drop_item()
					W.loc = src
					boots = W
			else
				return ..()

		else //wat
			return ..()

	..()

/obj/item/clothing/suit/space/rig/examine(mob/user)
	..()
	to_chat(user, "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"].")

//Engineering rig
/obj/item/clothing/head/helmet/space/rig/engineering
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 80)
	siemens_coefficient = 0

/obj/item/clothing/suit/space/rig/engineering
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding. Heavy insulation layer adds additional weight"
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 3
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	siemens_coefficient = 0

//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/engineering/chief
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig0-chief"
	item_state = "ce_helm"
	item_color = "chief"
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	sprite_sheets = null
	sprite_sheets_refit = list(SKRELL = 'icons/mob/species/skrell/helmet.dmi')
	sprite_sheets_obj = list(SKRELL = 'icons/obj/clothing/species/skrell/hats.dmi')

/obj/item/clothing/suit/space/rig/engineering/chief
	icon_state = "rig-chief"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	slowdown = 1
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	sprite_sheets = null
	sprite_sheets_refit = list(SKRELL = 'icons/mob/species/skrell/suit.dmi')
	sprite_sheets_obj = list(SKRELL = 'icons/obj/clothing/species/skrell/suits.dmi')

//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	item_color = "mining"
	armor = list(melee = 60, bullet = 5, laser = 10,energy = 5, bomb = 55, bio = 100, rad = 20)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "mining_hardsuit"
	armor = list(melee = 90, bullet = 5, laser = 10,energy = 5, bomb = 55, bio = 100, rad = 20)
	breach_threshold = 26


//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced helmet designed for work in special operations. Property of Gorlex Marauders."
	icon_state = "rig0-syndie"
	item_color = "syndie" // used for adjust helmet
	armor = list(melee = 60, bullet = 65, laser = 55,energy = 45, bomb = 50, bio = 100, rad = 60)
	var/obj/machinery/camera/camera
	var/up = 0
	species_restricted = list("exclude" , UNATHI , TAJARAN , SKRELL , VOX)

/obj/item/clothing/head/helmet/space/rig/syndi/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.replace_networks(list("NUKE"))
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		to_chat(user, "\blue User scanned as [camera.c_tag]. Camera activated.")

/obj/item/clothing/head/helmet/space/rig/syndi/verb/toggle()
	set category = "Object"
	set name = "Adjust helmet"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(up)
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			item_color = initial(item_color)
			to_chat(usr, "You closed helmet")
		else
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			item_color += "-up"
			to_chat(usr, "You opened helmet")
		icon_state = "rig[on]-[item_color]"
		up = !up
		usr.update_inv_head()

/obj/item/clothing/head/helmet/space/rig/syndi/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "This helmet has a built-in camera. It's [camera ? "" : "in"]active.")

/obj/item/clothing/head/helmet/space/rig/syndi/attackby(obj/item/W, mob/living/carbon/human/user)
	if(!istype(user) || user.species.flags[IS_SYNTHETIC])
		return
	if(!istype(W, /obj/item/weapon/reagent_containers/pill))
		return
	if(up && user.head == src)
		var/obj/item/weapon/reagent_containers/pill/P = W
		P.reagents.trans_to_ingest(user, W.reagents.total_volume)
		to_chat(user, "<span class='notice'>[src] consumes [W] and injected reagents to you!</span>")
		qdel(W)

/obj/item/clothing/suit/space/rig/syndi
	icon_state = "rig-syndie"
	name = "blood-red hardsuit"
	desc = "An advanced suit that protects against injuries during special operations. Property of Gorlex Marauders."
	item_state = "syndie_hardsuit"
	slowdown = 1.4
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 45, bomb = 50, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs)
	breach_threshold = 28
	species_restricted = list("exclude" , UNATHI , TAJARAN , SKRELL , VOX)

//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state = "wiz_helm"
	item_color = "wiz"
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 33, laser = 33,energy = 33, bomb = 33, bio = 100, rad = 66)

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	slowdown = 1
	unacidable = 1
	armor = list(melee = 40, bullet = 33, laser = 33,energy = 33, bomb = 33, bio = 100, rad = 66)

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	item_color = "medical"
	armor = list(melee = 30, bullet = 5, laser = 10,energy = 5, bomb = 25, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	item_state = "medical_hardsuit"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 30, bullet = 5, laser = 10,energy = 5, bomb = 25, bio = 100, rad = 50)

	//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	item_color = "sec"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 30, bomb = 65, bio = 100, rad = 10)

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 30, bomb = 65, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton)
	breach_threshold = 20
	slowdown = 1.4

//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	item_color = "atmos"
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/rig/atmos
	desc = "A special suit that protects against hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	icon_state = "rig-atmos"
	name = "atmos hardsuit"
	item_state = "atmos_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
