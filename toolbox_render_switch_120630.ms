---------------------------------------------------------------------------------------------------------
--global variable
---------------------------------------------------------------------------------------------------------
try (closeRolloutFloater renderSwitchFloater) catch ()
global vr	= renderers.current
global s		= (classOf vr) as string

---------------------------------------------------------------------------------------------------------
--preparation function
---------------------------------------------------------------------------------------------------------
fn isVRay arg =
(
	return ((matchPattern arg pattern:"*VRay*") or (matchPattern arg pattern:"*V_Ray*"))
)

fn sysRollout =
(
	sys = rolloutCreator "sys" "Output Setting"
	sys.begin()
	--begin
	
	reFb = vr.output_on
	reSave = rendSaveFile

	sys.addText "group \"Options\" ("
	sys.addControl #checkbox #cb1 "Enable Frame Buffer" paramStr:("checked:"+reFb as string+" across:2")
	sys.addControl #checkbox #cb2 "Save File" paramStr:("checked:"+reSave as string+" enabled:false")
	sys.addText ")"
	
	sys.addHandler #cb1 #changed paramStr:"arg " codeStr:"if arg then vr.output_on=true; else vr.output_on = false;" --max 2012 weird extra space behind "arg"
	
	--end
	sys.end()
)

fn giRollout =
(
	gi = rolloutCreator "gi" "GI Setting"
	gi.begin()
	--begin
	
	vr.gi_on = true
	
	--primary / secondary
	reFirst = vr.gi_primary_type
	reIrMin = vr.gi_irradmap_minRate
	reIrMax = vr.gi_irradmap_maxRate
	reIrSub = vr.gi_irradmap_subdivs
	reIrInterp = vr.gi_irradmap_interpSamples
	reSecond = vr.gi_secondary_type
	reLightSub = vr.lightcache_subdivs
	reLightSize = vr.lightcache_sampleSize
	reLightDir = case vr.lightcache_storeDirectLight of (0: false; 1: true)

	gi.addText "group \"Primary / Secondary\" ("
	gi.addControl #button #btn1 "Low" paramStr:"across:2 align:#left"
	gi.addControl #button #btn2 "Medium" paramStr:"align:#left offset:[-90,0]"
	gi.addControl #dropdownlist #ddl1 "" paramStr:("items:#(\"Irradiance map\",\"Photon map\",\"Brute Force\",\"Light cache\") selection:"+(reFirst+1) as string+" width:120")
	gi.addControl #spinner #sp1 "Min rate: " paramStr:("range:[-10,10,"+reIrMin as string+"] width:100 align:#left type:#integer across:2")
	gi.addControl #spinner #sp3 "HSph. subdivs:  " paramStr:("range:[1,200,"+reIrSub as string+"] width:120 align:#right offset:[5,0] type:#integer")
	gi.addControl #spinner #sp2 "Max rate:" paramStr:("range:[-10,10,"+reIrMax as string+"] width:100 align:#left type:#integer across:2")
	gi.addControl #spinner #sp4 "Interp. samples:" paramStr:("range:[1,200,"+reIrInterp as string+"] width:120 align:#right offset:[5,0] type:#integer")
	gi.addControl #dropdownlist #ddl2 "" paramStr:("items:#(\"Irradiance map\",\"Photon map\",\"Brute Force\",\"Light cache\") selection:"+(reSecond+1) as string+" width:120")
	gi.addControl #spinner #sp5 "Subdivs:      " paramStr:("range:[1,4000,"+reLightSub as string+"] width:100 align:#left type:#integer across:2")
	gi.addControl #checkbox #cb1 "Store direct light" paramStr:("checked:"+reLightDir as string+" align:#right offset:[5,0]")
	gi.addControl #spinner #sp6 "Sample size:" paramStr:("range:[0,1,"+reLightSize as string+"] scale:0.01 width:77 align:#left type:#float")
	gi.addText ")"
	
	--custom function
	gi.addText "fn setSpinner = (if ddl1.selection==1 then (sp1.visible=true;sp2.visible=true;sp3.visible=true;sp4.visible=true;) else (sp1.visible=false;sp2.visible=false;sp3.visible=false;sp4.visible=false;); if ddl2.selection==4 then (sp5.visible=true;sp6.visible=true;cb1.visible=true;) else (sp5.visible=false;sp6.visible=false;cb1.visible=false;);)"
	gi.addHandler #gi #open codeStr:"setSpinner();"
	gi.addHandler #ddl1 #selected paramStr:"arg " codeStr:"vr.gi_primary_type=ddl1.selection-1;setSpinner();"
	gi.addHandler #sp1 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_minRate=arg;"
	gi.addHandler #sp2 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_maxRate=arg;"
	gi.addHandler #sp3 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_subdivs=arg;"
	gi.addHandler #sp4 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_interpSamples=arg;"
	gi.addHandler #ddl2 #selected paramStr:"arg " codeStr:"vr.gi_secondary_type=ddl2.selection-1;setSpinner();"
	gi.addHandler #sp5 #changed paramStr:"arg " codeStr:"vr.lightcache_subdivs=arg;"
	gi.addHandler #sp6 #changed paramStr:"arg " codeStr:"vr.lightcache_sampleSize=arg;"
	gi.addHandler #cb1 #changed paramStr:"arg " codeStr:"vr.lightcache_storeDirectLight=case arg of (false: 0; true: 1;);"
	gi.addHandler #btn1 #pressed codeStr:"ddl1.selection=1; ddl2.selection=4; sp1.value=-4.0; sp2.value=-4.0; sp3.value=50.0; sp4.value=25.0; sp5.value=100.0; sp6.value= 0.02; vr.gi_primary_type=0; vr.gi_secondary_type=3; vr.gi_irradmap_minRate=-4; vr.gi_irradmap_maxRate=-4; vr.gi_irradmap_subdivs=50; vr.gi_irradmap_interpSamples=25; vr.lightcache_subdivs=100; vr.lightcache_sampleSize=0.02; setSpinner(); vr.gi_irradmap_colorThreshold=0.4; vr.gi_irradmap_normalThreshold=0.3; vr.gi_irradmap_distThreshold=0.1;"
	gi.addHandler #btn2 #pressed codeStr:"ddl1.selection=1; ddl2.selection=4; sp1.value=-3.0; sp2.value=-1.0; sp3.value=60.0; sp4.value=30.0; sp5.value=1500.0; sp6.value= 0.02; vr.gi_primary_type=0; vr.gi_secondary_type=3; vr.gi_irradmap_minRate=-3; vr.gi_irradmap_maxRate=-1; vr.gi_irradmap_subdivs=60; vr.gi_irradmap_interpSamples=30; vr.lightcache_subdivs=1500; vr.lightcache_sampleSize=0.02; setSpinner(); vr.gi_irradmap_colorThreshold=0.4; vr.gi_irradmap_normalThreshold=0.2; vr.gi_irradmap_distThreshold=0.1;"
	
	--end
	gi.end()
)

fn dmcRollout =
(
	dmc = rolloutCreator "dmc" "DMC Setting"
	dmc.begin()
	--begin
	
	reNoise = vr.dmc_earlyTermination_threshold
	reMinSample = vr.dmc_earlyTermination_minSamples
	reDynMem = vr.system_raycaster_memLimit
	reGloSubMul = vr.dmc_subdivs_mult
	reMaxTree = vr.system_raycaster_maxLevels

	dmc.addText "group \"Noise\" ("
	dmc.addControl #button #btn1 "Low" paramStr:"across:2 align:#left"
	dmc.addControl #button #btn2 "Medium" paramStr:"align:#left offset:[-90,0]"
	dmc.addControl #spinner #sp1 "Noise threshold:" paramStr:("range:[0,1,"+reNoise as string+"] width:110 align:#left type:#float scale:0.01 across:2")
	dmc.addControl #spinner #sp2 "Min samples:     " paramStr:("range:[1,50,"+reMinSample as string+"] width:110 align:#left offset:[5,0] type:#integer")
	dmc.addControl #spinner #sp3 "Memory limit:     " paramStr:("range:[1,10000,"+reDynMem as string+"] width:110 align:#left type:#integer across:2")
	dmc.addControl #spinner #sp4 "Global multiplier:" paramStr:("range:[0.1,5,"+reGloSubMul as string+"] width:110 align:#left offset:[5,0] type:#float")
	dmc.addControl #spinner #sp5 "Max tree depth:" paramStr:("range:[1,100,"+reMaxTree as string+"] width:80 align:#left type:#integer")
	dmc.addText ")"

	dmc.addHandler #sp1 #changed paramStr:"arg " codeStr:"vr.dmc_earlyTermination_threshold=arg;"
	dmc.addHandler #sp2 #changed paramStr:"arg " codeStr:"vr.dmc_earlyTermination_minSamples=arg;"
	dmc.addHandler #sp3 #changed paramStr:"arg " codeStr:"vr.system_raycaster_memLimit=arg;"
	dmc.addHandler #sp4 #changed paramStr:"arg " codeStr:"vr.dmc_subdivs_mult=arg;"
	dmc.addHandler #sp5 #changed paramStr:"arg " codeStr:"vr.system_raycaster_maxLevels=arg;" --vrayEditDRSettings() for VRay 2.0
	dmc.addHandler #btn1 #pressed codeStr:"sp1.value=0.1; sp2.value=8.0; sp3.value=8000.0; sp4.value=0.1; sp5.value=80.0; vr.dmc_earlyTermination_threshold=0.1; vr.dmc_earlyTermination_minSamples=8; vr.system_raycaster_memLimit=8000; vr.dmc_subdivs_mult=0.1; vr.system_raycaster_maxLevels=80;"
	dmc.addHandler #btn2 #pressed codeStr:"sp1.value=0.01; sp2.value=8.0; sp3.value=8000.0; sp4.value=1.0; sp5.value=80.0; vr.dmc_earlyTermination_threshold=0.01; vr.dmc_earlyTermination_minSamples=8; vr.system_raycaster_memLimit=8000; vr.dmc_subdivs_mult=1.0; vr.system_raycaster_maxLevels=80;"
	
	--end
	dmc.end()
)

---------------------------------------------------------------------------------------------------------
--rollout definition
---------------------------------------------------------------------------------------------------------
if not(isVRay s) do
(
	renderers.current = VRay()
	vr = renderers.current
)

renderSceneDialog.close()
renderSwitchFloater = newRolloutFloater "TOOLBOX RENDER SWITCH" 300 450

--sys setting
sysRollout()
addRollout sys renderSwitchFloater

--gi setting
giRollout()
addRollout gi renderSwitchFloater

--dmc setting
dmcRollout()
addRollout dmc renderSwitchFloater