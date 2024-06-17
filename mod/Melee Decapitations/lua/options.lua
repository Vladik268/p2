MeleeDecap.MenuOptions = MeleeDecap.MenuOptions or {}
MeleeDecap.MenuOptions.Menu = {

	[ "MeleeDecapMenuMainOptions" ] = {
		"more_options_main_options_menu_title",
		"more_options_main_options_menu_desc",
		1
	},
	
	[ "MeleeDecapMenuGoreOptions" ] = {
		"more_options_gore_options_menu_title",
		"more_options_gore_options_menu_desc"
	}

}
MeleeDecap.MenuOptions.Toggle = {

	[ "Decapitation" ] = {
		"MeleeDecapMenuGoreOptions",
		"more_options_toggle_decapitation_title",
		"more_options_toggle_decapitation_desc",
		true
	},
	
	[ "TrueDecapitation" ] = {
		"MeleeDecapMenuGoreOptions",
		"more_options_toggle_true_decapitation_title",
		"more_options_toggle_true_decapitation_desc",
		false
	},
	
	[ "RealisticGore" ] = {
		"MeleeDecapMenuGoreOptions",
		"more_options_toggle_realistic_gore_title",
		"more_options_toggle_realistic_gore_desc",
		false
	},
	
	[ "BluntForceTrauma" ] = {
		"MeleeDecapMenuGoreOptions",
		"more_options_toggle_blunt_force_trauma_title",
		"more_options_toggle_blunt_force_trauma_desc",
		false
	}

}
MeleeDecap.MenuOptions.Slider = {

	[ "BluntForceMultiplier" ] = {
		"MeleeDecapMenuGoreOptions",
		"more_options_slider_blunt_force_multiplier_title",
		"more_options_slider_blunt_force_multiplier_desc",
		1,
		10,
		0.5,
		1
	}
	
}
MeleeDecap.MenuOptions.MultipleChoice = {
	
	[ "SpurtEffect" ] = {
		"MeleeDecapMenuGoreOptions",
		"more_options_choice_spurt_effect_title",
		"more_options_choice_spurt_effect_desc",
		{
			{ "more_options_choice_spurt_effect_a" },
			{ "more_options_choice_spurt_effect_b" , "effects/payday2/particles/impacts/blood/blood_tendrils" , 1 },
			{ "more_options_choice_spurt_effect_c" , "effects/particles/bullet_hit/flesh/bullet_hit_blood" , 2 }
		},
		1
	}

}

MeleeDecap.BluntWeapons = {
	"weapon",
	"fists",
	"brass_knuckles",
	"moneybundle",
	"barbedwire",
	"boxing_gloves",
	"whiskey",
	"alien_maul",
	"shovel",
	"baton",
	"dingdong",
	"baseballbat",
	"briefcase",
	"model24",
	"shillelagh",
	"hammer",
	"spatula",
	"tenderizer",
	"branding_iron",
	"microphone",
	"oldbaton",
	"detector",
	"micstand",
	"hockey",
	"slot_lever",
	"croupier_rake",
	"taser",
	"fight",
	"buck",
	"morning",
	"cutters",
	"selfie",
	"stick",
	"zeus",
	"road",
	"brick",
	"cs",
	"road"
}

MeleeDecap.SmallBladedWeapons = {
	"kabartanto",
	"toothbrush",
	"chef",
	"kabar",
	"rambo",
	"kampfmesser",
	"gerber",
	"becker",
	"x46",
	"bayonet",
	"bullseye",
	"cleaver",
	"fairbair",
	"meat_cleaver",
	"fork",
	"poker",
	"scalper",
	"bowie",
	"switchblade",
	"tiger",
	"cqc",
	"twins",
	"pugio",
	"boxcutter",
	"shawn",
	"scoutknife",
	"nin",
	"ballistic",
	"wing",
	"catch",
	"sword",
	"agave",
	"ostry",
	"grip"
}