# A3XX Pneumatic System
# Joshua Davidson (it0uchpods) and Jonathan Redpath (legoboyvdlp)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

setlistener("/sim/signals/fdm-initialized", func {
	var altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var bleed1_sw = getprop("/controls/pneumatic/switches/bleed1");
	var bleed2_sw = getprop("/controls/pneumatic/switches/bleed2");
	var bleedapu_sw = getprop("/controls/pneumatic/switches/bleedapu");
	var pack1_sw = getprop("/controls/pneumatic/switches/pack1");
	var pack2_sw = getprop("/controls/pneumatic/switches/pack2");
	var hot_air_sw = getprop("/controls/pneumatic/switches/hot-air");
	var ram_air_sw	= getprop("/controls/pneumatic/switches/ram-air");
	var pack_flo_sw = getprop("/controls/pneumatic/switches/pack-flo");
	var xbleed_sw = getprop("/controls/pneumatic/switches/xbleed");
	var eng1_starter = getprop("/systems/pneumatic/eng1-starter");
	var eng2_starter = getprop("/systems/pneumatic/eng2-starter");
	var groundair = getprop("/systems/pneumatic/groundair");
	var groundair_supp = getprop("/controls/pneumatic/switches/groundair");
	var rpmapu = getprop("/systems/apu/rpm");
	var stateL = getprop("/engines/engine[0]/state");
	var stateR = getprop("/engines/engine[1]/state");
	var bleedapu_fail = getprop("/systems/failures/bleed-apu");
	var bleedext_fail = getprop("/systems/failures/bleed-ext");
	var bleedeng1_fail = getprop("/systems/failures/bleed-eng1");
	var bleedeng2_fail = getprop("/systems/failures/bleed-eng2");
	var pack1_fail = getprop("/systems/failures/pack1");
	var pack2_fail = getprop("/systems/failures/pack2");
	var engantiice1 = getprop("/controls/deice/eng1-on");
	var engantiice2 = getprop("/controls/deice/eng2-on");
	var bleed1 = getprop("/systems/pneumatic/bleed1");
	var bleed2 = getprop("/systems/pneumatic/bleed2");
	var bleedapu = getprop("/systems/pneumatic/bleedapu");
	var ground = getprop("/systems/pneumatic/groundair");
	var pack1 = getprop("/systems/pneumatic/pack1");
	var pack2 = getprop("/systems/pneumatic/pack2");
	var pack_psi = getprop("/systems/pneumatic/pack-psi");
	var start_psi = getprop("/systems/pneumatic/start-psi");
	var total_psi = getprop("/systems/pneumatic/total-psi");
	var xbleed = getprop("/systems/pneumatic/xbleed", 0);
	var starting = getprop("/systems/pneumatic/starting");
	var phase = getprop("/FMGC/status/phase");
	var pressmode = getprop("/systems/pressurization/mode");
	var state1 = getprop("/systems/thrust/state1");
	var state2 = getprop("/systems/thrust/state2");
	var wowc = getprop("/gear/gear[0]/wow");
	var wowl = getprop("/gear/gear[1]/wow");
	var wowr = getprop("/gear/gear[2]/wow");
	var deltap = getprop("/systems/pressurization/deltap");
	var outflow = getprop("/systems/pressurization/outflowpos"); 
	var speed = getprop("/velocities/groundspeed-kt");
	var altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var airport_arr_elev_ft = getprop("autopilot/route-manager/destination/field-elevation-ft");
	var vs = getprop("/systems/pressurization/vs-norm");
	var manvs = getprop("/systems/pressurization/manvs-cmd");
	var ditch = getprop("/systems/pressurization/ditchingpb");
	var outflowpos = getprop("/systems/pressurization/outflowpos");
	var cabinalt = getprop("/systems/pressurization/cabinalt");
	var targetalt = getprop("/systems/pressurization/targetalt");
	var targetvs = getprop("/systems/pressurization/targetvs");
	var ambient = getprop("/systems/pressurization/ambientpsi");
	var cabinpsi = getprop("/systems/pressurization/cabinpsi");
	var pause = getprop("/sim/freeze/master");
	var auto = getprop("/systems/pressurization/auto");
	var dcess = getprop("/systems/electrical/bus/dc-ess");
	var acess = getprop("/systems/electrical/bus/ac-ess");
	var fanon = getprop("/systems/ventilation/avionics/fan");
	var eng1on = getprop("/controls/deice/eng1-on");
	var eng2on = getprop("/controls/deice/eng2-on");
	var total_psi_calc = 0;
	var masks = getprop("/controls/oxygen/masksDeployMan");
	var autoMasks = getprop("/controls/oxygen/masksDeploy");
	var guard = getprop("/controls/oxygen/masksGuard");
});

var PNEU = {
	init: func() {
		setprop("/controls/pneumatic/switches/bleed1", 1);
		setprop("/controls/pneumatic/switches/bleed2", 1);
		setprop("/controls/pneumatic/switches/bleedapu", 0);
		setprop("/controls/pneumatic/switches/groundair", 0);
		setprop("/controls/pneumatic/switches/pack1", 1);
		setprop("/controls/pneumatic/switches/pack2", 1);
		setprop("/controls/pneumatic/switches/hot-air", 1);
		setprop("/controls/pneumatic/switches/ram-air", 0);
		setprop("/controls/pneumatic/switches/pack-flo", 9); # LO: 7, NORM: 9, HI: 11.
		setprop("/controls/pneumatic/switches/xbleed", 1); # SHUT: 0, AUTO: 1, OPEN: 2.
		setprop("/systems/pneumatic/bleed1", 0);
		setprop("/systems/pneumatic/bleed2", 0);
		setprop("/systems/pneumatic/bleedapu", 0);
		setprop("/systems/pneumatic/groundair", 0);
		setprop("/systems/pneumatic/total-psi", 0);
		setprop("/systems/pneumatic/start-psi", 0);
		setprop("/systems/pneumatic/pack-psi", 0);	
		setprop("/systems/pneumatic/pack1", 0);
		setprop("/systems/pneumatic/pack2", 0);
		setprop("/systems/pneumatic/start-psi", 0);
		setprop("/systems/pneumatic/eng1-starter", 0);
		setprop("/systems/pneumatic/eng2-starter", 0);
		setprop("/systems/pneumatic/bleed1-fault", 0);
		setprop("/systems/pneumatic/bleed2-fault", 0);
		setprop("/systems/pneumatic/bleedapu-fault", 0);
		setprop("/systems/pneumatic/hotair-fault", 0);
		setprop("/systems/pneumatic/pack1-fault", 0);
		setprop("/systems/pneumatic/pack2-fault", 0);
		setprop("/systems/pneumatic/xbleed", 0);
		setprop("/systems/pneumatic/starting", 0);
		setprop("/FMGC/internal/dep-arpt", "");
		altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		setprop("/systems/pressurization/mode", "GN");
		setprop("/systems/pressurization/vs", "0");
		setprop("/systems/pressurization/targetvs", "0");
		setprop("/systems/pressurization/vs-norm", "0");
		setprop("/systems/pressurization/auto", 1);
		setprop("/systems/pressurization/deltap", "0");
		setprop("/systems/pressurization/outflowpos", "0");
		setprop("/systems/pressurization/deltap-norm", "0");
		setprop("/systems/pressurization/outflowpos-norm", "0");
		setprop("/systems/pressurization/outflowpos-man", "0.5");
		setprop("/systems/pressurization/outflowpos-man-sw", "0");
		setprop("/systems/pressurization/outflowpos-norm-cmd", "0");
		setprop("/systems/pressurization/cabinalt", altitude);
		setprop("/systems/pressurization/targetalt", altitude); 
		setprop("/systems/pressurization/diff-to-target", "0");
		setprop("/systems/pressurization/ditchingpb", 0);
		setprop("/systems/pressurization/targetvs", "0");
		setprop("/systems/pressurization/ambientpsi", "0");
		setprop("/systems/pressurization/cabinpsi", "0");
		setprop("/systems/pressurization/manvs-cmd", "0");
		setprop("/systems/ventilation/cabin/fans", 0); # aircon fans
		setprop("/systems/ventilation/avionics/fan", 0);
		setprop("/systems/ventilation/avionics/extractvalve", "0");
		setprop("/systems/ventilation/avionics/inletvalve", "0");
		setprop("/systems/ventilation/lavatory/extractfan", 0);
		setprop("/systems/ventilation/lavatory/extractvalve", "0");
		setprop("/controls/deice/eng1-on", 0);
		setprop("/controls/deice/eng2-on", 0);
		setprop("/controls/oxygen/masksDeploy", 0);
		setprop("/controls/oxygen/masksDeployMan", 0);
		setprop("/controls/oxygen/masksReset", 0); # this is the TMR RESET pb on the maintenance panel, needs 3D model
		setprop("/controls/oxygen/masksSys", 0);
	},
	loop: func() {
		bleed1_sw = getprop("/controls/pneumatic/switches/bleed1");
		bleed2_sw = getprop("/controls/pneumatic/switches/bleed2");
		bleedapu_sw = getprop("/controls/pneumatic/switches/bleedapu");
		pack1_sw = getprop("/controls/pneumatic/switches/pack1");
		pack2_sw = getprop("/controls/pneumatic/switches/pack2");
		hot_air_sw = getprop("/controls/pneumatic/switches/hot-air");
		ram_air_sw	= getprop("/controls/pneumatic/switches/ram-air");
		pack_flo_sw = getprop("/controls/pneumatic/switches/pack-flo");
		xbleed_sw = getprop("/controls/pneumatic/switches/xbleed");
		eng1_starter = getprop("/systems/pneumatic/eng1-starter");
		eng2_starter = getprop("/systems/pneumatic/eng2-starter");
		groundair = getprop("/systems/pneumatic/groundair");
		groundair_supp = getprop("/controls/pneumatic/switches/groundair");
		rpmapu = getprop("/systems/apu/rpm");
		stateL = getprop("/engines/engine[0]/state");
		stateR = getprop("/engines/engine[1]/state");
		bleedapu_fail = getprop("/systems/failures/bleed-apu");
		bleedext_fail = getprop("/systems/failures/bleed-ext");
		bleedeng1_fail = getprop("/systems/failures/bleed-eng1");
		bleedeng2_fail = getprop("/systems/failures/bleed-eng2");
		pack1_fail = getprop("/systems/failures/pack1");
		pack2_fail = getprop("/systems/failures/pack2");
		engantiice1 = getprop("/controls/deice/eng1-on");
		engantiice2 = getprop("/controls/deice/eng2-on");
		wowc = getprop("/gear/gear[0]/wow");
		wowl = getprop("/gear/gear[1]/wow");
		wowr = getprop("/gear/gear[2]/wow");
		
		ground = getprop("/systems/pneumatic/groundair");
		bleedapu = getprop("/systems/pneumatic/bleedapu");
		
		if (xbleed_sw == 0) {
			setprop("/systems/pneumatic/xbleed", 0);
		} else if (xbleed_sw == 1) {
			if (bleedapu >= 11) {
				setprop("/systems/pneumatic/xbleed", 1);
			} else {
				setprop("/systems/pneumatic/xbleed", 0);
			}
		} else if (xbleed_sw == 2) {
			setprop("/systems/pneumatic/xbleed", 1);
		}
		
		xbleed = getprop("/systems/pneumatic/xbleed", 0);
		
		if (stateL == 3 and bleed1_sw and !bleedeng1_fail) {
			setprop("/systems/pneumatic/bleed1", 31);
		} else {
			setprop("/systems/pneumatic/bleed1", 0);
		}
		
		if (stateR == 3 and bleed2_sw and !bleedeng2_fail) {
			setprop("/systems/pneumatic/bleed2", 32);
		} else {
			setprop("/systems/pneumatic/bleed2", 0);
		}
		
		bleed1 = getprop("/systems/pneumatic/bleed1");
		bleed2 = getprop("/systems/pneumatic/bleed2");
		
		if (bleed1 >= 11 and (stateR != 3 or !bleed2_sw or bleedeng2_fail) and xbleed == 1) {
			setprop("/systems/pneumatic/bleed2", 31);
		}
		
		if (bleed2 >= 11 and (stateL != 3 or !bleed1_sw or bleedeng1_fail) and xbleed == 1) {
			setprop("/systems/pneumatic/bleed1", 32);
		}
		
		bleed1 = getprop("/systems/pneumatic/bleed1");
		bleed2 = getprop("/systems/pneumatic/bleed2");
		
		if (stateL == 1 or stateR == 1 or stateL == 2 or stateR == 2) {
			setprop("/systems/pneumatic/start-psi", 18);
		} else {
			setprop("/systems/pneumatic/start-psi", 0);
		}
		
		if (getprop("/controls/engines/engine-start-switch") == 2 and wowc == 1 and (stateL != 3 or stateR != 3)) {
			setprop("/systems/pneumatic/starting", 1);
		} else if (wowc == 1 and eng1_starter == 1 or eng2_starter == 1) {
			setprop("/systems/pneumatic/starting", 1);
		} else {
			setprop("/systems/pneumatic/starting", 0);
		}
		
		starting = getprop("/systems/pneumatic/starting");
		
		if (pack1_sw == 1 and (bleed1 >= 11 or bleedapu >= 11 or ground >= 11) and starting == 0 and !pack1_fail) {
			setprop("/systems/pneumatic/pack1", pack_flo_sw);
		} else {
			setprop("/systems/pneumatic/pack1", 0);
		}
		
		if (pack2_sw == 1 and (bleed2 >= 11 or (bleedapu >= 11 and xbleed == 1)) and starting == 0 and !pack2_fail) {
			setprop("/systems/pneumatic/pack2", pack_flo_sw);
		} else {
			setprop("/systems/pneumatic/pack2", 0);
		}
		
		pack1 = getprop("/systems/pneumatic/pack1");
		pack2 = getprop("/systems/pneumatic/pack2");
		
		if (pack1_sw == 1 and pack2_sw == 1) {
			setprop("/systems/pneumatic/pack-psi", pack1 + pack2);
		} else if (pack1_sw == 0 and pack2_sw == 0) {
			setprop("/systems/pneumatic/pack-psi", 0);
		} else {
			setprop("/systems/pneumatic/pack-psi", pack1 + pack2 + 5);
		}
		
		pack_psi = getprop("/systems/pneumatic/pack-psi");
		start_psi = getprop("/systems/pneumatic/start-psi");
		
		if ((bleed1 + bleed2 + bleedapu) > 42) {
			setprop("/systems/pneumatic/total-psi", 42);
		} else {
			total_psi_calc = ((bleed1 + bleed2 + bleedapu + ground) - start_psi - pack_psi);
			setprop("/systems/pneumatic/total-psi", total_psi_calc);
		}
		
		if (groundair_supp) {
			setprop("/systems/pneumatic/groundair", 39);
		} else {
			setprop("/systems/pneumatic/groundair", 0);
		}
		
		if (engantiice1 and bleed1 > 20) { # shut down anti-ice if bleed is lost else turn it on
			setprop("/controls/deice/lengine", 0); 
			setprop("/controls/deice/eng1-on", 0);
		}
		
		if (engantiice1) { # else turn it on
			setprop("/controls/deice/lengine", 1); 
		}
		
		if (engantiice2 and bleed2 > 20) {
			setprop("/controls/deice/rengine", 0);
			setprop("/controls/deice/eng2-on", 0);
		}
		
		if (engantiice2) {
			setprop("/controls/deice/rengine", 1);
		}
		
		total_psi = getprop("/systems/pneumatic/total-psi");
		
		phase = getprop("/FMGC/status/phase");
		pressmode = getprop("/systems/pressurization/mode");
		state1 = getprop("/systems/thrust/state1");
		state2 = getprop("/systems/thrust/state2");
		deltap = getprop("/systems/pressurization/deltap");
		outflow = getprop("/systems/pressurization/outflowpos"); 
		speed = getprop("/velocities/groundspeed-kt");
		altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		airport_arr_elev_ft = getprop("autopilot/route-manager/destination/field-elevation-ft");
		vs = getprop("/systems/pressurization/vs-norm");
		manvs = getprop("/systems/pressurization/manvs-cmd");
		ditch = getprop("/systems/pressurization/ditchingpb");
		outflowpos = getprop("/systems/pressurization/outflowpos");
		cabinalt = getprop("/systems/pressurization/cabinalt");
		targetalt = getprop("/systems/pressurization/targetalt");
		targetvs = getprop("/systems/pressurization/targetvs");
		ambient = getprop("/systems/pressurization/ambientpsi");
		cabinpsi = getprop("/systems/pressurization/cabinpsi");
		pause = getprop("/sim/freeze/master");
		auto = getprop("/systems/pressurization/auto");
		
		setprop("/systems/pressurization/diff-to-target", targetalt - cabinalt); 
		setprop("/systems/pressurization/deltap", cabinpsi - ambient); 

		if ((pressmode == "GN") and (pressmode != "CL") and (wowl and wowr) and ((state1 == "MCT") or (state1 == "TOGA")) and ((state2 == "MCT") or (state2 == "TOGA"))) {
			setprop("/systems/pressurization/mode", "TO");
		} else if (((!wowl) or (!wowr)) and (speed > 100) and (pressmode == "TO")) {
			setprop("/systems/pressurization/mode", "CL");	
		}
		
		if (vs != targetvs and !wowl and !wowr) {
			setprop("/systems/pressurization/vs", targetvs);
		}
		
		if (cabinalt != targetalt and !wowl and !wowr and !pause and auto) {
			setprop("/systems/pressurization/cabinalt", cabinalt + ((vs / 60) / 10));
		} else if (!auto and !pause) {
			setprop("/systems/pressurization/cabinalt", cabinalt + ((manvs / 60) / 10));
		}
		
		if (ditch and auto) {
			setprop("/systems/pressurization/outflowpos", "1");
			setprop("/systems/ventilation/avionics/extractvalve", "1");
			setprop("/systems/ventilation/avionics/inletvalve", "1");
		}
		
		dcess = getprop("/systems/electrical/bus/dc-ess");
		acess = getprop("/systems/electrical/bus/ac-ess");
		fanon = getprop("/systems/ventilation/avionics/fan");
		
		if ((dcess > 25) or (acess > 110)) {
			setprop("/systems/ventilation/avionics/fan", 1);
			setprop("/systems/ventilation/lavatory/extractfan", 1);
		} else if ((dcess == 0) and (acess == 0)) {
			setprop("/systems/ventilation/avionics/fan", 0);
			setprop("/systems/ventilation/lavatory/extractfan", 0);
		}
		
		# Fault lights
		if (bleedeng1_fail and bleed1_sw) {
			setprop("/systems/pneumatic/bleed1-fault", 1);
		} else {
			setprop("/systems/pneumatic/bleed1-fault", 0);
		}
		
		if (bleedeng2_fail and bleed2_sw) {
			setprop("/systems/pneumatic/bleed2-fault", 1);
		} else {
			setprop("/systems/pneumatic/bleed2-fault", 0);
		}
		
		if (bleedapu_fail and bleedapu_sw) {
			setprop("/systems/pneumatic/bleedapu-fault", 1);
		} else {
			setprop("/systems/pneumatic/bleedapu-fault", 0);
		}
		
		if ((pack1_fail and pack1_sw) or (pack1_sw and pack1 <= 5)) {
			setprop("/systems/pneumatic/pack1-fault", 1);
		} else {
			setprop("/systems/pneumatic/pack1-fault", 0);
		}
		
		if ((pack2_fail and pack2_sw) or (pack2_sw and pack2 <= 5)) {
			setprop("/systems/pneumatic/pack2-fault", 1);
		} else {
			setprop("/systems/pneumatic/pack2-fault", 0);
		}
		
		# Oxygen
		if (cabinalt > 13500) { 
			setprop("/controls/oxygen/masksDeploy", 1);
			setprop("/controls/oxygen/masksSys", 1);
		}
	},
};

setlistener("/controls/pneumatic/switches/pack1", func {
	pack1_sw = getprop("/controls/pneumatic/switches/pack1");
	if (pack1_sw) {
		setprop("/systems/pneumatic/pack1-fault", 1);
	}
});

setlistener("/controls/pneumatic/switches/pack2", func {
	pack2_sw = getprop("/controls/pneumatic/switches/pack2");
	if (pack2_sw) {
		setprop("/systems/pneumatic/pack2-fault", 1);
	}
});

setlistener("/controls/deice/eng1-on", func {
	eng1on = getprop("/controls/deice/eng1-on");
	if (eng1on) {
		flashfault1();
	}
});

setlistener("/controls/deice/eng2-on", func {
	eng2on = getprop("/controls/deice/eng2-on");
	if (eng2on) {
		flashfault2();
	}
});

var flashfault1 = func {
	setprop("/controls/deice/eng1-fault", 1);
	settimer(func {
		setprop("/controls/deice/eng1-fault", 0);
	}, 0.5);
}

var flashfault2 = func {
	setprop("/controls/deice/eng2-fault", 1);
	settimer(func {
		setprop("/controls/deice/eng2-fault", 0);
	}, 0.5);
}

# Oxygen (Cabin)

setlistener("/controls/oxygen/masksDeployMan", func {
	guard = getprop("/controls/oxygen/masksGuard");
	masks = getprop("/controls/oxygen/masksDeployMan");
	
	if (guard and masks) {
		setprop("/controls/oxygen/masksDeployMan", 0);
	} else if (!guard and masks) {
		setprop("/controls/oxygen/masksDeployMan", 1);
		setprop("/controls/oxygen/masksDeploy", 1);
		setprop("/controls/oxygen/masksSys", 1);
	}
});

setlistener("/controls/oxygen/masksDeployMan", func {
	masks = getprop("/controls/oxygen/masksDeployMan");
	autoMasks = getprop("/controls/oxygen/masksDeploy");
	if (!masks) { 
		setprop("/controls/oxygen/masksDeployMan", 1);
	}
});

setlistener("/controls/oxygen/masksDeploy", func {
	masks = getprop("/controls/oxygen/masksDeployMan");
	autoMasks = getprop("/controls/oxygen/masksDeploy");
	if (!autoMasks) { 
		setprop("/controls/oxygen/masksDeploy", 1);
	}
});
