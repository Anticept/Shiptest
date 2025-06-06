//Dogs.

/mob/living/simple_animal/pet/dog
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	faction = list("neutral")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	ai_controller = /datum/ai_controller/dog
	stop_automated_movement = TRUE

	footstep_type = FOOTSTEP_MOB_CLAW

//Corgis and pugs are now under one dog subtype

/mob/living/simple_animal/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	held_state = "corgi"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	childtype = list(/mob/living/simple_animal/pet/dog/corgi/puppy = 95, /mob/living/simple_animal/pet/dog/corgi/puppy/void = 5)
	animal_species = /mob/living/simple_animal/pet/dog
	collar_type = "corgi"
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/shaved = FALSE
	var/nofur = FALSE 		//Corgis that have risen past the material plane of existence.

/mob/living/simple_animal/pet/dog/corgi/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_back)
	return ..()

/mob/living/simple_animal/pet/dog/corgi/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		update_corgi_fluff()
		regenerate_icons()
	if(A == inventory_back)
		inventory_back = null
		update_corgi_fluff()
		regenerate_icons()
	return ..()


/mob/living/simple_animal/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/food/meat/slab/pug = 3)
	collar_type = "pug"
	held_state = "pug"

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as it is colorful!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	animal_species = /mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	nofur = TRUE

/mob/living/simple_animal/pet/dog/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_HOLDABLE, INNATE_TRAIT)
	var/dog_area = get_area(src)
	for(var/obj/structure/bed/dogbed/D in dog_area)
		if(!D.owner)
			D.update_owner(src)
			break

/mob/living/simple_animal/pet/dog/corgi/Initialize()
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/Initialize()
		. = ..()
		var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/show_inv(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	user.set_machine(src)
	var/list/dat = list()

	dat += "<table>"
	dat += "<tr><td><B>Head:</B></td><td><A href='byond://?src=[REF(src)];[inventory_head ? "remove_inv=head'>[inventory_head]" : "add_inv=head'><font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>Back:</B></td><td><A href='byond://?src=[REF(src)];[inventory_back ? "remove_inv=back'>[inventory_back]" : "add_inv=back'><font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>Collar:</B></td><td><A href='byond://?src=[REF(src)];[pcollar ? "remove_inv=collar'>[pcollar]" : "add_inv=collar'><font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>ID Card:</B></td><td><A href='byond://?src=[REF(src)];[access_card ? "remove_inv=card'>[access_card]" : "add_inv=card'><font color=grey>Empty</font>"]</A></td></tr>"
	dat += {"</table>
	<A href='byond://?src=[REF(user)];mach_close=mob[REF(src)]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob[REF(src)]", "[src]", 440, 510)
	popup.set_content(dat.Join())
	popup.open()

/mob/living/simple_animal/pet/dog/corgi/getarmor(def_zone, type)
	var/armorval = 0

	if(def_zone)
		if(def_zone == BODY_ZONE_HEAD)
			if(inventory_head)
				armorval = inventory_head.armor.getRating(type)
		else
			if(inventory_back)
				armorval = inventory_back.armor.getRating(type)
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.armor.getRating(type)
		if(inventory_back)
			armorval += inventory_back.armor.getRating(type)
	return armorval*0.5

/mob/living/simple_animal/pet/dog/corgi/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/razor))
		if (shaved)
			to_chat(user, span_warning("You can't shave this corgi, it's already been shaved!"))
			return
		if (nofur)
			to_chat(user, span_warning("You can't shave this corgi, it doesn't have a fur coat!"))
			return
		user.visible_message(span_notice("[user] starts to shave [src] using \the [O]."), span_notice("You start to shave [src] using \the [O]..."))
		if(do_after(user, 50, target = src))
			user.visible_message(span_notice("[user] shaves [src]'s hair using \the [O]."))
			playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)
			shaved = TRUE
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return
	..()
	update_corgi_fluff()

/mob/living/simple_animal/pet/dog/corgi/Topic(href, href_list)
	if(!(iscarbon(usr) || iscyborg(usr)) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		usr << browse(null, "window=mob[REF(src)]")
		usr.unset_machine()
		return

	//Removing from inventory
	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if(BODY_ZONE_HEAD)
				if(inventory_head)
					usr.put_in_hands(inventory_head)
					inventory_head = null
					update_corgi_fluff()
					regenerate_icons()
				else
					to_chat(usr, span_warning("There is nothing to remove from its [remove_from]!"))
					return
			if("back")
				if(inventory_back)
					usr.put_in_hands(inventory_back)
					inventory_back = null
					update_corgi_fluff()
					regenerate_icons()
				else
					to_chat(usr, span_warning("There is nothing to remove from its [remove_from]!"))
					return
			if("collar")
				if(pcollar)
					usr.put_in_hands(pcollar)
					pcollar = null
					update_corgi_fluff()
					regenerate_icons()
			if("card")
				if(access_card)
					usr.put_in_hands(access_card)
					access_card = null

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("collar")
				var/obj/item/clothing/neck/petcollar/P = usr.get_active_held_item()
				if(!istype(P))
					to_chat(usr,span_warning("That's not a collar."))
					return
				add_collar(P, usr)
				update_corgi_fluff()

			if(BODY_ZONE_HEAD)
				place_on_head(usr.get_active_held_item(),usr)

			if("back")
				if(inventory_back)
					to_chat(usr, span_warning("It's already wearing something!"))
					return
				else
					var/obj/item/item_to_add = usr.get_active_held_item()

					if(!item_to_add)
						usr.visible_message(span_notice("[usr] pets [src]."), span_notice("You rest your hand on [src]'s back for a moment."))
						return

					if(!usr.temporarilyRemoveItemFromInventory(item_to_add))
						to_chat(usr, span_warning("\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s back!"))
						return

					if(istype(item_to_add, /obj/item/grenade/c4)) // last thing he ever wears, I guess
						item_to_add.afterattack(src,usr,1)
						return

					//The objects that corgis can wear on their backs.
					var/allowed = FALSE
					if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/back))
						allowed = TRUE

					if(!allowed)
						to_chat(usr, span_warning("You set [item_to_add] on [src]'s back, but it falls off!"))
						item_to_add.forceMove(drop_location())
						if(prob(25))
							step_rand(item_to_add)
						dance_rotate(src, set_original_dir=TRUE)
						return

					item_to_add.forceMove(src)
					inventory_back = item_to_add
					update_corgi_fluff()
					regenerate_icons()
			if("card")
				if(access_card)
					to_chat(usr, span_warning("[src] already has \an [access_card] pinned to [p_them()]!"))
					return
				var/obj/item/item_to_add = usr.get_active_held_item()
				if(!usr.temporarilyRemoveItemFromInventory(item_to_add))
					to_chat(usr, span_warning("\The [item_to_add] is stuck to your hand, you cannot pin it to [src]!"))
					return
				if(!istype(item_to_add, /obj/item/card/id))
					to_chat(usr, span_warning("You can't pin [item_to_add] to [src]!"))
					return
				item_to_add.forceMove(src)
				access_card = item_to_add

		show_inv(usr)
	else
		return ..()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed

/mob/living/simple_animal/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/c4)) // last thing he ever wears, I guess
		INVOKE_ASYNC(item_to_add, TYPE_PROC_REF(/obj/item, afterattack), src, user, 1)
		return

	if(inventory_head)
		if(user)
			to_chat(user, span_warning("You can't put more than one hat on [src]!"))
		return
	if(!item_to_add)
		user.visible_message(span_notice("[user] pets [src]."), span_notice("You rest your hand on [src]'s head for a moment."))
		if(flags_1 & HOLOGRAM_1)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		return

	if(user && !user.temporarilyRemoveItemFromInventory(item_to_add))
		to_chat(user, span_warning("\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!"))
		return 0

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, span_notice("There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()]."))
		else if(user)
			user.visible_message(span_notice("[user] puts [item_to_add] on [real_name]'s head. [src] looks at [user] and barks once."),
				span_notice("You put [item_to_add] on [real_name]'s head. [src] gives you a peculiar look, then wags [p_their()] tail once and barks."),
				span_hear("You hear a friendly-sounding bark."))
		item_to_add.forceMove(src)
		src.inventory_head = item_to_add
		update_corgi_fluff()
		regenerate_icons()
	else
		to_chat(user, span_warning("You set [item_to_add] on [src]'s head, but it falls off!"))
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		dance_rotate(src, set_original_dir=TRUE)

	return valid

/mob/living/simple_animal/pet/dog/corgi/proc/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	desc = initial(desc)
	set_light(0)

	if(inventory_head && inventory_head.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	unique_pet = TRUE
	var/age = 0
	var/record_age = 1
	var/memory_saved = FALSE
	var/saved_head //path

/mob/living/simple_animal/pet/dog/corgi/Ian/Initialize()
	. = ..()
	//parent call must happen first to ensure IAN
	//is not in nullspace when child puppies spawn
	Read_Memory()
	if(age == 0)
		var/turf/target = get_turf(loc)
		if(target)
			var/mob/living/simple_animal/pet/dog/corgi/puppy/P = new /mob/living/simple_animal/pet/dog/corgi/puppy(target)
			P.name = "Ian"
			P.real_name = "Ian"
			P.gender = MALE
			P.desc = "It's the HoP's beloved corgi puppy."
			Write_Memory(FALSE)
			return INITIALIZE_HINT_QDEL
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		held_state = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age], Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		turns_per_move = 20

/mob/living/simple_animal/pet/dog/corgi/Ian/Life()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE)
		memory_saved = TRUE
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/death()
	if(!memory_saved)
		Write_Memory(TRUE)
	if(lastattacker)
		SSredbot.send_discord_message("admin","Ian has been killed: Last attacked by [lastattacker]([lastattackerckey]) in [get_area_name(src)].")
	else
		SSredbot.send_discord_message("admin","Ian has been killed in [get_area_name(src)].")
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/Read_Memory()
	if(fexists("data/npc_saves/Ian.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
		S["age"] 		>> age
		S["record_age"]	>> record_age
		S["saved_head"] >> saved_head
		fdel("data/npc_saves/Ian.sav")
	else
		var/json_file = file("data/npc_saves/Ian.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		age = json["age"]
		record_age = json["record_age"]
		saved_head = json["saved_head"]
	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1
	if(saved_head)
		place_on_head(new saved_head)

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Ian.json")
	var/list/file_data = list()
	if(!dead)
		file_data["age"] = age + 1
		if((age + 1) > record_age)
			file_data["record_age"] = record_age + 1
		else
			file_data["record_age"] = record_age
		if(inventory_head)
			file_data["saved_head"] = inventory_head.type
		else
			file_data["saved_head"] = null
	else
		file_data["age"] = 0
		file_data["record_age"] = record_age
		file_data["saved_head"] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/simple_animal/pet/dog/corgi/regenerate_icons()
	..()
	if(inventory_head)
		var/image/head_icon
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_head.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_head.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_head.color

		if(health <= 0)
			head_icon = DF.get_overlay(dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = DF.get_overlay()

		add_overlay(head_icon)

	if(inventory_back)
		var/image/back_icon
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_back.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_back.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_back.color

		if(health <= 0)
			back_icon = DF.get_overlay(dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = turn(back_icon.transform, 180)
		else
			back_icon = DF.get_overlay()
		add_overlay(back_icon)

	return



/mob/living/simple_animal/pet/dog/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_type = "puppy"

//puppies cannot wear anything.
/mob/living/simple_animal/pet/dog/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, span_warning("You can't fit this on [src]!"))
		return
	..()


/mob/living/simple_animal/pet/dog/corgi/puppy/void		//Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = TRUE
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	held_state = "void_puppy"

/mob/living/simple_animal/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0)
	return 1	//Void puppies can navigate space.


//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "She's tearing you apart."
	unique_pet = TRUE
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	held_state = "lisa"
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/pet/dog/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, span_warning("[src] already has a cute bow!"))
		return
	..()

/mob/living/simple_animal/pet/dog/corgi/Lisa/Life()
	..()

	make_babies()

/mob/living/simple_animal/pet/dog/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1,M)
		if("harm")
			wuv(-1,M)

/mob/living/simple_animal/pet/dog/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the dog) is dead to fix issue 2454
				new /obj/effect/temp_visual/heart(loc)
				manual_emote("yaps happily!")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				manual_emote("growls!")
