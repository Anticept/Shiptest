/obj/machinery/vending/games
	name = "\improper Good Clean Fun"
	desc = "Vends things that the Captain and Head of Personnel are probably not going to appreciate you fiddling with instead of your job..."
	product_ads = "Escape to a fantasy world!;Fuel your gambling addiction!;Ruin your friendships!;Roll for initiative!;Elves and dwarves!;Paranoid computers!;Fun times forever!"
	icon_state = "games"
	products = list(
		/obj/item/toy/cards/deck = 5,
		/obj/item/storage/pill_bottle/dice = 10,
		/obj/item/toy/cards/deck/cas = 3,
		/obj/item/toy/cards/deck/cas/black = 3,
		/obj/item/toy/cards/deck/kotahi = 3,
		/obj/item/toy/cards/deck/tarot = 3,
		/obj/item/hourglass = 2,
		/obj/item/instrument/piano_synth/headphones = 4,
		/obj/item/camera = 3,
		/obj/item/dyespray = 3)
	premium = list(
		/obj/item/skateboard/pro = 3,
		/obj/item/skateboard/hoverboard = 1)
	refill_canister = /obj/item/vending_refill/games
	default_price = 50
	extra_price = 250
	light_mask = "games-light-mask"

/obj/item/vending_refill/games
	machine_name = "\improper Good Clean Fun"
	icon_state = "refill_games"
