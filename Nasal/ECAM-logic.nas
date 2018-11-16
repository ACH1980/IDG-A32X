# A3XX Electronic Centralised Aircraft Monitoring System
# Jonathan Redpath (legoboyvdlp)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

var messages_priority_3 = func {
	if ((getprop("/position/gear-agl-ft") < 750 and getprop("/gear/gear[1]/position-norm") != 1 and (getprop("/ECAM/warning-phase") <= 3 and getprop("/ECAM/warning-phase") >= 5)) and ((((getprop("/engines/engine[0]/n1-actual") < 75.0 and getprop("/engines/engine[1]/n1-actual") < 75.0)) or ((getprop("/engines/engine[0]/n1-actual") < 77.0 and getprop("/controls/engines/engine[1]/cutoff-switch") == 0) or (getprop("/engines/engine[1]/n1-actual") < 77.0 and getprop("/controls/engines/engine[0]/cutoff-switch") == 0))) or getprop("/controls/flight/flap-pos") > 1)) {
		lg_not_dn.active = 1;
		setprop("/systems/gear/landing-gear-warning-light", 1);
	} else {
		lg_not_dn.active = 0;
		lg_not_dn.noRepeat = 0;
		setprop("/systems/gear/landing-gear-warning-light", 0);
	}
}
var messages_priority_2 = func {
	if ((((getprop("/ECAM/warning-phase") >= 1 and getprop("/ECAM/warning-phase") <= 2) or (getprop("/ECAM/warning-phase") >= 9 and getprop("/ECAM/warning-phase") <= 10) and (wow and getprop("/engines/engine[0]/state") == 3)) or getprop("/ECAM/warning-phase") == 6) and getprop("/systems/failures/pack1") == 1) {
		pack1_fault.active = 1;
	} else {
		pack1_fault.active = 0;
		pack1_fault.noRepeat = 0;
	}
	
	if (pack1_fault.active == 1 and getprop("/controls/pneumatic/switches/pack1") == 1) {
		pack1_fault_subwarn_1.active = 1;
	} else {
		pack1_fault_subwarn_1.active = 0;
		pack1_fault_subwarn_1.noRepeat = 0;
	}
	
	if ((((getprop("/ECAM/warning-phase") >= 1 and getprop("/ECAM/warning-phase") <= 2) or (getprop("/ECAM/warning-phase") >= 9 and getprop("/ECAM/warning-phase") <= 10) and (wow and getprop("/engines/engine[1]/state") == 3)) or getprop("/ECAM/warning-phase") == 6) and getprop("/systems/failures/pack2") == 1) {
		pack2_fault.active = 1;
	} else {
		pack2_fault.active = 0;
		pack2_fault.noRepeat = 0;
	}
	
	if (pack2_fault.active == 1 and getprop("/controls/pneumatic/switches/pack2") == 1) {
		pack2_fault_subwarn_1.active = 1;
	} else {
		pack2_fault_subwarn_1.active = 0;
		pack2_fault_subwarn_1.noRepeat = 0;
	}
	
	if (getprop("/controls/gear/brake-parking") and (getprop("/ECAM/warning-phase") >= 6 and getprop("/ECAM/warning-phase") <= 7)) {
		park_brk_on.active = 1;
	} else {
		park_brk_on.active = 0;
		park_brk_on.noRepeat = 0;
	}
}

var messages_priority_1 = func {}
var messages_priority_0 = func {}

var messages_memo = func {
	if (getprop("/services/fuel-truck/enable") == 1 and getprop("/ECAM/left-msg") != "TO-MEMO" and getprop("/ECAM/left-msg") != "LDG-MEMO") {
		refuelg.active = 1;
	} else {
		refuelg.active = 0;
	}
	
	if (getprop("/controls/flight/speedbrake-arm") == 1 and getprop("/controls/flight/flap-lever") >= 1) {
		gnd_splrs.active = 1;
	} else {
		gnd_splrs.active = 0;
	}
	
	if (getprop("/controls/switches/seatbelt-sign") == 1 and getprop("/ECAM/left-msg") != "TO-MEMO" and getprop("/ECAM/left-msg") != "LDG-MEMO") {
		seatbelts.active = 1;
	} else {
		seatbelts.active = 0;
	}
	
	if (getprop("/controls/switches/no-smoking-sign") == 1 and getprop("/ECAM/left-msg") != "TO-MEMO" and getprop("/ECAM/left-msg") != "LDG-MEMO") {
		nosmoke.active = 1;
	} else {
		nosmoke.active = 0;
	}

	if (getprop("/controls/lighting/strobe") == 0 and getprop("/gear/gear[1]/wow") == 0 and getprop("/ECAM/left-msg") != "TO-MEMO" and getprop("/ECAM/left-msg") != "LDG-MEMO") { # todo: use gear branch properties
		strobe_lt_off.active = 1;
	} else {
		strobe_lt_off.active = 0;
	}

	if (getprop("/consumables/fuel/total-fuel-lbs") < 6000 and getprop("/ECAM/left-msg") != "TO-MEMO" and getprop("/ECAM/left-msg") != "LDG-MEMO") { # assuming US short ton 2000lb
		fob_3T.active = 1;
	} else {
		fob_3T.active = 0;
	}
	
	if (getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override") == 1) {
		gpws_flap_mode_off.active = 1;
	} else {
		gpws_flap_mode_off.active = 0;
	}
	
}

var messages_right_memo = func {
	if (getprop("/ECAM/warning-phase") >= 3 and getprop("/ECAM/warning-phase") <= 5) {
		to_inhibit.active = 1;
	} else {
		to_inhibit.active = 0;
	}
	
	if (getprop("/ECAM/warning-phase") >= 7 and getprop("/ECAM/warning-phase") <= 7) {
		ldg_inhibit.active = 1;
	} else {
		ldg_inhibit.active = 0;
	}
	
	if ((getprop("/ECAM/warning-phase") >= 2 and getprop("/ECAM/warning-phase") <= 7) and getprop("controls/flight/speedbrake") != 0) {
		spd_brk.active = 1;
	} else {
		spd_brk.active = 0;
	}
	
	if (getprop("/systems/thrust/state1") == "IDLE" and getprop("/systems/thrust/state2") == "IDLE" and getprop("/ECAM/warning-phase") >= 6 and getprop("/ECAM/warning-phase") <= 7) {
		spd_brk.colour = "g";
	} else if ((getprop("/ECAM/warning-phase") >= 2 and getprop("/ECAM/warning-phase") <= 5) or ((getprop("/systems/thrust/state1") != "IDLE" or getprop("/systems/thrust/state2") != "IDLE") and (getprop("/ECAM/warning-phase") >= 6 and getprop("/ECAM/warning-phase") <= 7))) {
		spd_brk.colour = "a";
	}
	
	if (getprop("/controls/gear/brake-parking") == 1 and getprop("/ECAM/warning-phase") != 3) {
		park_brk.active = 1;
	} else {
		park_brk.active = 0;
	}
	if (getprop("/ECAM/warning-phase") >= 4 and getprop("/ECAM/warning-phase") <= 8) {
		park_brk.colour = "a";
	} else {
		park_brk.colour = "g";
	}
	
	if (getprop("/controls/hydraulic/ptu") == 1 and ((getprop("/systems/hydraulic/yellow-psi") < 1450 and getprop("/systems/hydraulic/green-psi") > 1450 and getprop("/controls/hydraulic/elec-pump-yellow") == 0) or (getprop("/systems/hydraulic/yellow-psi") > 1450 and getprop("/systems/hydraulic/green-psi") < 1450))) {
		ptu.active = 1;
	} else {
		ptu.active = 0;
	}
	
	if (getprop("/controls/hydraulic/rat-deployed") == 1) {
		rat.active = 1;
	} else {
		rat.active = 0;
	}
	
	if (getprop("/ECAM/warning-phase") >= 1 and getprop("/ECAM/warning-phase") <= 2) {
		rat.colour = "a";
	} else {
		rat.colour = "g";
	}
	
	if (getprop("/controls/electrical/switches/emer-gen") == 1 and getprop("/controls/hydraulic/rat-deployed") == 1 and !wow) {
		emer_gen.active = 1;
	} else {
		emer_gen.active = 0;
	}
	
	if (getprop("/controls/pneumatic/switches/ram-air") == 1) {
		ram_air.active = 1;
	} else {
		ram_air.active = 0;
	}

	if (getprop("/controls/engines/engine[0]/igniter-a") == 1 or getprop("/controls/engines/engine[0]/igniter-b") == 1 or getprop("/controls/engines/engine[1]/igniter-a") == 1 or getprop("/controls/engines/engine[1]/igniter-b") == 1) {
		ignition.active = 1;
	} else {
		ignition.active = 0;
	}

	if (apu_bleed.active == 0 and getprop("/systems/apu/rpm") >= 95) {
		apu_avail.active = 1;
	} else {
		apu_avail.active = 0;
	}

	if (getprop("/controls/lighting/landing-lights[1]") > 0 or getprop("/controls/lighting/landing-lights[2]") > 0) {
		ldg_lt.active = 1;
	} else {
		ldg_lt.active = 0;
	}

	if (getprop("/controls/switches/leng") == 1 or getprop("/controls/switches/reng") == 1 or getprop("/systems/electrical/bus/dc1") == 0 or getprop("/systems/electrical/bus/dc2") == 0) {
		eng_aice.active = 1;
	} else {
		eng_aice.active = 0;
	}
	
	if (getprop("/controls/switches/wing") == 1) {
		wing_aice.active = 1;
	} else {
		wing_aice.active = 0;
	}
	if (getprop("/instrumentation/comm[2]/frequencies/selected-mhz") != 0 and (getprop("/ECAM/warning-phase") == 1 or getprop("/ECAM/warning-phase") == 2 or getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") == 9 or getprop("/ECAM/warning-phase") == 10)) {
		vhf3_voice.active = 1;
	} else {
		vhf3_voice.active = 0;
	}
	if (getprop("/controls/autobrake/mode") == 1 and (getprop("/ECAM/warning-phase") == 7 or getprop("/ECAM/warning-phase") == 8)) {
		auto_brk_lo.active = 1;
	} else {
		auto_brk_lo.active = 0;
	}

	if (getprop("/controls/autobrake/mode") == 2 and (getprop("/ECAM/warning-phase") == 7 or getprop("/ECAM/warning-phase") == 8)) {
		auto_brk_med.active = 1;
	} else {
		auto_brk_med.active = 0;
	}

	if (getprop("/controls/autobrake/mode") == 3 and (getprop("/ECAM/warning-phase") == 7 or getprop("/ECAM/warning-phase") == 8)) {
		auto_brk_max.active = 1;
	} else {
		auto_brk_max.active = 0;
	}
	
	if (getprop("/systems/fuel/x-feed") == 1 and getprop("controls/fuel/x-feed") == 1) {
		fuelx.active = 1;
	} else {
		fuelx.active = 0;
	}
	
	if (getprop("/ECAM/warning-phase") >= 3 and getprop("/ECAM/warning-phase") <= 5) {
		fuelx.colour = "a";
	} else {
		fuelx.colour = "g";
	}
}