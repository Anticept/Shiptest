/datum/surgery/brain_surgery
	name = "Brain surgery"
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/fix_brain,
	/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = 0

/datum/surgery_step/fix_brain
	name = "fix brain"
	implements = list(
		TOOL_HEMOSTAT = 85,
		TOOL_SCREWDRIVER = 40,
		/obj/item/pen = 5) //don't worry, pouring some alcohol on their open brain will get that chance to 100 //will it? i don't know.
	repeatable = TRUE
	time = 10 SECONDS //long and complicated
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	experience_given = 0 // per_trauma
	fuckup_damage = 15

/datum/surgery/brain_surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/fix_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to fix [target]'s brain..."),
		span_notice("[user] begins to fix [target]'s brain."),
		span_notice("[user] begins to perform surgery on [target]'s brain."))

/datum/surgery_step/fix_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, span_notice("You succeed in fixing [target]'s brain."),
		span_notice("[user] successfully fixes [target]'s brain!"),
		span_notice("[user] completes the surgery on [target]'s brain."))
	if(target.mind?.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	target.setOrganLoss(ORGAN_SLOT_BRAIN, target.getOrganLoss(ORGAN_SLOT_BRAIN) - 50)	//we set damage in this case in order to clear the "failing" flag
	var/cured_num = target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	experience_given = (MEDICAL_SKILL_EASY*2*cured_num)
	if(target.getOrganLoss(ORGAN_SLOT_BRAIN) > 0)
		to_chat(user, "[target]'s brain looks like it could be fixed further.")
	return ..()

/datum/surgery_step/fix_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, span_warning("You screw up, causing more damage!"),
			span_warning("[user] screws up, causing brain damage!"),
			span_notice("[user] completes the surgery on [target]'s brain."))
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
	else
		user.visible_message(span_warning("[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore."), span_warning("You suddenly notice that the brain you were working on is not there anymore."))
	return FALSE
