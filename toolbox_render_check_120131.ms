---------------------------------------------------------------------------------------------------------
--global variable
---------------------------------------------------------------------------------------------------------
try (closeRolloutFloater renderCheckFloater) catch ()
global renderCheckFloater --main rollout floater
global frameBuffer, element, common, sampler, colorMap, gi, sys, congrat --8 main rollouts
global isFrameBuffer=false, isCommon=false, isSampler=false, isColorMap=false, isGi=false, isSys=false --whether 6 rollouts are displayed
global vr				= renderers.current
global s					= (classOf vr) as string
global re				= maxOps.GetCurRenderElementMgr();
global reComplete	= #("VRayExtraTex","VRayRawGlobalIllumination","VRayRawLighting","VRayRawReflection","VRayRawRefraction","VRayRawShadow","VRaySpecular","VRayZDepth")
global reComplete1 = #("MultiMatteElement","VRayAlpha","VRayAtmosphere","VRayBackground","VRayBumpNormals","VRayCaustics","VRayDiffuseFilter","VRayExtraTex","VRayGlobalIllumination","VRayIlluminance","VRayLighting","VRayMatteShadow","VRayMtlID","VRayMtlSelect","VRayNormals","VRayObjectID","VRayObjectSelect","VRayRawGlobalIllumination","VRayRawLighting","VRayRawReflection","VRayRawRefraction","VRayRawShadow","VRayRawTotalLighting","VRayReflection","VRayReflectionFilter","VRayRefraction","VRayRefractionFilter","VRayRenderID","VRaySampleRate","VRaySamplerInfo","VRaySelfIllumination","VRayShadows","VRaySpecular","VRaySSS2","VRayTotalLighting","VRayUnclampedColor","VRayVelocity","VRayWireColor","VRayZDepth")
global reCompleteName1 = #(MultiMatteElement,VRayAlpha,VRayAtmosphere,VRayBackground,VRayBumpNormals,VRayCaustics,VRayDiffuseFilter,VRayExtraTex,VRayGlobalIllumination,VRayIlluminance,VRayLighting,VRayMatteShadow,VRayMtlID,VRayMtlSelect,VRayNormals,VRayObjectID,VRayObjectSelect,VRayRawGlobalIllumination,VRayRawLighting,VRayRawReflection,VRayRawRefraction,VRayRawShadow,VRayRawTotalLighting,VRayReflection,VRayReflectionFilter,VRayRefraction,VRayRefractionFilter,VRayRenderID,VRaySampleRate,VRaySamplerInfo,VRaySelfIllumination,VRayShadows,VRaySpecular,VRaySSS2,VRayTotalLighting,VRayUnclampedColor,VRayVelocity,VRayWireColor,VRayZDepth)
global reActive		= #()
global reInActive		= deepCopy reComplete
global reChannel		= #()

---------------------------------------------------------------------------------------------------------
--preparation function
---------------------------------------------------------------------------------------------------------
fn isVRay arg =
(
	return ((matchPattern arg pattern:"*VRay*") or (matchPattern arg pattern:"*V_Ray*"))
)

fn frameBufferRollout =
(
	frameBuffer = rolloutCreator "frameBuffer" "V-Ray:: Frame buffer"
	frameBuffer.begin()
	--begin
	
	reFb = vr.output_on
	if reFb do
	(
	isFrameBuffer = true
	frameBuffer.addText "group \"Output\" ("
	frameBuffer.addControl #label #lbl1 "VRay frame buffer is on, turn off?" paramStr:"align:#left"
	frameBuffer.addControl #checkbox #cb1 "Enable built-in Frame Buffer" paramStr:("checked:"+reFb as string+" across:2")
	frameBuffer.addControl #imgTag #it1 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[30,4]"
	frameBuffer.addText ")"
	
	frameBuffer.addHandler #cb1 #changed paramStr:"arg " codeStr:"if arg then (vr.output_on=true; it1.visible=true;) else (vr.output_on = false; it1.visible=false;)" --max 2012 weird extra space behind "arg"
	)
	
	--end
	frameBuffer.end()
)

fn elementRollout =
(
	element = rolloutCreator "element" "Render Elements"
	element.begin()
	--begin
	
	reEleActive = re.GetElementsActive()
	--active group
	if not reEleActive do
	(
	element.addText "group \"Active\" ("
	element.addControl #label #lbl1 "Render elements are off, turn on?" paramStr:"align:#left"
	element.addControl #checkbox #cb1 "Elements Active" paramStr:("checked:"+reEleActive as string+" across:2")
	element.addControl #imgTag #it1 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[-25,4]"
	element.addText ")"
	
	element.addHandler #cb1 #changed paramStr:"arg " codeStr:"if arg then (re.SetElementsActive true; it1.visible=false;) else (re.SetElementsActive false; it1.visible=true;)"
	)
	
	--element group
	for i = 0 to re.NumRenderElements()-1 do --0 based
	(
		reElement = re.GetRenderElement i
		reElement.enabled = true --automatically turn on individual elements
		reName = reElement.elementName
		
		if isVRay reName then
		(
			append reActive reName
			
			idx = findItem reInActive reName
			if idx != 0 do
				deleteItem reInActive idx
		)
		else if matchPattern reName pattern:"*Obj*" then
		(
			append reChannel reName
		)
	)
	
	updateElement = "toDelete=#(); for i = 0 to re.NumRenderElements()-1 where isVRayLocal ((re.GetRenderElement i) as string) do append toDelete (re.GetRenderElement i); for j in toDelete do re.RemoveRenderElement j; for k in reActive do re.AddRenderElement (reCompleteName1[findItem reComplete1 k] elementname:k);"
	element.addText "group \"Element\" ("
	element.addControl #multilistbox #mlb1 "Active" paramStr:"across:4 width:120 height:7 items:reActive"
	element.addControl #button #btn1 "<<" paramStr:"width:20 offset:[34,30]"
	element.addControl #button #btn2 ">>" paramStr:"width:20 offset:[-31,70]"
	element.addControl #multilistbox #mlb2 "Inactive" paramStr:"width:120 height:7 offset:[-53,0] items:reInActive"
	element.addControl #multilistbox #mlb3 "" paramStr:"width:120 height:5 offset:[0,-10] items:reChannel across:3"
	--channel
	element.addControl #radiobuttons #rb2 "" paramStr:"labels:#(\"3\",\"5\",\"7\",\"10\") columns:4 offset:[72,20]"
	element.addControl #button #btn3 "MultiMatteElement" paramStr:"offset:[-15,40]"
	element.addText ")"
	
	element.addText "fn isVRayLocal arg = (return ((matchPattern arg pattern:\"*VRay*\") or (matchPattern arg pattern:\"*V_Ray*\"));)" --max 2011 doesn't recognize the global "isVRay" function, so have to define it locally
	element.addHandler #btn1 #pressed codeStr:("arg=mlb2.selection; sel=deepCopy mlb2.items; if arg!=0 do (for i in arg do (append reActive sel[i]; deleteItem reInActive (findItem reInActive sel[i]);)); mlb1.items=reActive; mlb2.items=reInActive;"+updateElement) --have to use deepCopy, as mlb2.items is a reference of reInActive
	element.addHandler #btn2 #pressed codeStr:("arg=mlb1.selection; sel=deepCopy mlb1.items; if arg!=0 do (for i in arg do (append reInActive sel[i]; deleteItem reActive (findItem reActive sel[i]);)); mlb1.items=reActive; mlb2.items=reInActive;"+updateElement) --have to use deepCopy, as mlb1.items is a reference of reActive
	element.addHandler #btn3 #pressed codeStr:"toDelete=#(); reChannel=#(); for i = 0 to re.NumRenderElements() where (classOf (re.GetRenderElement i)==MultiMatteElement) do append toDelete (re.GetRenderElement i); for j in toDelete do re.RemoveRenderElement j; num = case rb2.state of (1: 3; 2: 5; 3: 7; 4: 10;); for k = 1 to num do (n=(\"ObjCh_\"+k as string+\"_MultiMatteElement\"); re.AddRenderElement (MultiMatteElement elementname:n R_gbufIDOn:true G_gbufIDOn:true B_gbufIDOn:true R_gbufID:(k*3-2) G_gbufID:(k*3-1) B_gbufID:(k*3)); append reChannel n;); mlb3.items=reChannel;"
	
	--end
	element.end()
)

fn commonRollout =
(
	common = rolloutCreator "common" "Common Parameters"
	common.begin()
	--begin
	
	--output settings
	reType = getRenderType()
	reArea = case reType of (#view: 1; #region: 2; #crop: 3; default: 4)
	reWidth = renderWidth as float
	reHeight = renderHeight as float
	reAspect = reWidth/reHeight
	if reArea == 3 or reArea == 4 or reWidth < 3000 or reHeight < 3000 do
	(
	isCommon = true
	if reArea == 4 do
		setRenderType #view --automatically set render area to view if not "#view, #region, #crop"
	common.addText "group \"Output Size\" ("
	common.addControl #label #lbl1 "Please check output settings" paramStr:"align:#left across:2"
	common.addControl #button #btn1 "recommend" paramStr:"offset:[30,-2]"
	common.addControl #dropdownlist #ddl1 "" paramStr:("items:#(\"View\",\"Region\",\"Crop\") selection:"+reArea as string+" width:120 across:2")
	common.addControl #imgTag #it1 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[0,4]"
	common.addControl #spinner #sp1 "Width: " paramStr:("range:[0,20000,"+reWidth as string+"] width:120 align:#left type:#integer across:2")
	common.addControl #imgTag #it2 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[0,4]"
	common.addControl #spinner #sp2 "Height:" paramStr:("range:[0,20000,"+reHeight as string+"] width:120 align:#left type:#integer across:2")
	common.addControl #imgTag #it3 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[0,4]"
	common.addText ")"
	
	common.addText "fn setImg1 = (if ddl1.selection==3 then it1.visible=true else it1.visible=false; if sp1.value<3000 then it2.visible=true else it2.visible=false; if sp2.value<3000 then it3.visible=true else it3.visible=false;)"
	common.addHandler #common #open codeStr:"setImg1();"
	common.addHandler #ddl1 #selected paramStr:"arg " codeStr:"setRenderType (ddl1.selected as name); setImg1();"
	common.addHandler #sp1 #changed paramStr:"arg " codeStr:"renderWidth=arg; setImg1();"
	common.addHandler #sp2 #changed paramStr:"arg " codeStr:"renderHeight=arg; setImg1();"
	common.addHandler #btn1 #pressed codeStr:("ddl1.selection=1; sp1.value=5000.0; sp2.value="+(5000.0/reAspect) as string+"; setRenderType #view; renderWidth=5000; renderHeight=sp2.value; setImg1();")
	)
	
	--save file settings
	reSave = rendSaveFile
	reNet = rendUseNet
	if not reSave or not reNet do
	(
	isCommon = true
	common.addText "group \"Render Output\" ("
	common.addControl #label #lbl2 "Please check file settings" paramStr:"align:#left"
	common.addControl #checkbox #cb1 "Save File" paramStr:("across:4 checked:"+reSave as string)
	common.addControl #imgTag #it4 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[10,4]"
	common.addControl #checkbox #cb2 "Net Render" paramStr:("checked:"+reNet as string)
	common.addControl #imgTag #it5 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[20,4]"
	common.addText ")"
	
	common.addText "fn setImg2 = (if cb1.checked then it4.visible=false else it4.visible=true; if cb2.checked then it5.visible=false else it5.visible=true;)"
	common.addHandler #common #open codeStr:"setImg2();"
	common.addHandler #cb1 #changed paramStr:"arg " codeStr:"rendSaveFile=arg; if arg then (f = getSaveFileName caption:\"Render Output File:\" filename:\"base.exr\" types:\"OpenEXR(*.exr)|*.exr|Targa(*.tga)|*.tga|All|*.*|\"; if f!=undefined then rendOutputFilename=f; else (cb1.checked=false; rendSaveFile=false; rendOutputFilename=\"\")); setImg2();"
	common.addHandler #cb2 #changed paramStr:"arg " codeStr:"rendUseNet=arg; setImg2();"
	)
	
	--end
	common.end()
)

fn samplerRollout =
(
	sampler = rolloutCreator "sampler" "V-Ray:: Image sampler"
	sampler.begin()
	--begin
	
	--displacement
	reDis = vr.options_displacement
	if not reDis do
	(
	isSampler = true
	sampler.addText "group \"Geometry\" ("
	sampler.addControl #label #lbl1 "Displacement is off, turn on?" paramStr:"align:#left "
	sampler.addControl #checkbox #cb1 "Displacement" paramStr:("checked:"+reDis as string+" across:2")
	sampler.addControl #imgTag #it1 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[-35,4]"
	sampler.addText ")"
	
	sampler.addHandler #cb1 #changed paramStr:"arg " codeStr:"if arg then (vr.options_displacement=true; it1.visible=false;) else (vr.options_displacement=false; it1.visible=true;)"
	)
	
	--image sampler
	reSampler = vr.imageSampler_type --0, 1, 2
	reFixSub = vr.fixedRate_subdivs
	reAdapSubMin = vr.twoLevel_baseSubdivs
	reAdapSubMax = vr.twoLevel_fineSubdivs
	if (reSampler == 0 and reFixSub < 4) or (reSampler == 1 and reAdapSubMax < 4) or reSampler == 2 do
	(
	isSampler = true
	sampler.addText "group \"Image sampler\" ("
	sampler.addControl #label #lbl2 "Please check image sampler settings" paramStr:"align:#left across:2"
	sampler.addControl #button #btn1 "recommend" paramStr:"offset:[30,-2]"
	sampler.addControl #dropdownlist #ddl1 "" paramStr:("items:#(\"Fixed\",\"Adaptive DMC\",\"Adaptive subdivision\") selection:"+(reSampler+1) as string+" width:120 across:2")
	sampler.addControl #imgTag #it2 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[0,4]"
	sampler.addControl #spinner #sp1 "Subdivs:" paramStr:("range:[1,10,"+reFixSub as string+"] width:120 align:#left type:#integer across:2")
	sampler.addControl #imgTag #it3 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[0,4]"
	sampler.addControl #spinner #sp2 "Min subdivs: " paramStr:("range:[1,10,"+reAdapSubMin as string+"] width:120 align:#left type:#integer offset:[0,-21]")
	sampler.addControl #spinner #sp3 "Max subdivs:" paramStr:("range:[1,10,"+reAdapSubMax as string+"] width:160 align:#left type:#integer across:2")
	sampler.addControl #imgTag #it4 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[25,4]"
	sampler.addText ")"
	
	--custom function
	sampler.addText "fn setImg = (if ddl1.selection==3 do (it2.visible=true;it3.visible=false;it4.visible=false;); if ddl1.selection==2 do (it2.visible=false;it3.visible=false; if sp3.value<4 then it4.visible=true else it4.visible=false;); if ddl1.selection==1 do (it2.visible=false;it4.visible=false; if sp1.value<4 then it3.visible=true else it3.visible=false;))"
	sampler.addText "fn setSpinner = (if ddl1.selection==1 do (sp1.visible=true;sp2.visible=false;sp3.visible=false;); if ddl1.selection==2 do (sp1.visible=false;sp2.visible=true;sp3.visible=true;); if ddl1.selection==3 do (sp1.visible=false;sp2.visible=false;sp3.visible=false;);)"
	sampler.addHandler #sampler #open codeStr:"setSpinner(); setImg();"
	sampler.addHandler #ddl1 #selected paramStr:"arg " codeStr:"vr.imageSampler_type=ddl1.selection-1;setSpinner(); setImg();"
	sampler.addHandler #sp1 #changed paramStr:"arg " codeStr:"vr.fixedRate_subdivs=arg; setImg();"
	sampler.addHandler #sp2 #changed paramStr:"arg " codeStr:"vr.twoLevel_baseSubdivs=arg;"
	sampler.addHandler #sp3 #changed paramStr:"arg " codeStr:"vr.twoLevel_fineSubdivs=arg; setImg();"
	sampler.addHandler #btn1 #pressed codeStr:"ddl1.selection=1; sp1.value=4.0; sp2.value=1.0; sp3.value=4.0; vr.imageSampler_type=0; vr.fixedRate_subdivs=4; vr.twoLevel_baseSubdivs=1; vr.twoLevel_fineSubdivs=4; setSpinner(); setImg();"
	)
	
	--end
	sampler.end()
)

fn colorMapRollout =
(
	colorMap = rolloutCreator "colorMap" "V-Ray:: Color mapping"
	colorMap.begin()
	--begin
	
	reGamma = vr.colorMapping_gamma
	reSubPixel = vr.colorMapping_subpixel
	reClamp = vr.colorMapping_clampOutput
	if reGamma != 2.2 or reSubPixel or reClamp do
	(
	isColorMap = true
	colorMap.addText "group \"Gamma\" ("
	colorMap.addControl #label #lbl1 "Please check color mapping settings" paramStr:"align:#left across:2"
	colorMap.addControl #button #btn1 "recommend" paramStr:"offset:[30,-2]"
	colorMap.addControl #spinner #sp1 "Gamma:" paramStr:("range:[1,10,"+reGamma as string+"] width:120 align:#left type:#float across:2")
	colorMap.addControl #imgTag #it1 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[-5,4]"
	colorMap.addControl #checkbox #cb1 "Sub-pixel mapping" paramStr:("across:4 checked:"+reSubPixel as string)
	colorMap.addControl #imgTag #it2 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[45,4]"
	colorMap.addControl #checkbox #cb2 "Clamp output" paramStr:("checked:"+reClamp as string)
	colorMap.addControl #imgTag #it3 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[25,4]"
	colorMap.addText ")"
	
	colorMap.addText "fn setImg = (if sp1.value!=2.2 then it1.visible=true else it1.visible=false; if cb1.checked then it2.visible=true else it2.visible=false; if cb2.checked then it3.visible=true else it3.visible=false;)"
	colorMap.addHandler #colorMap #open codeStr:"setImg();"
	colorMap.addHandler #sp1 #changed paramStr:"arg " codeStr:"vr.colorMapping_gamma=arg; setImg();"
	colorMap.addHandler #cb1 #changed paramStr:"arg " codeStr:"vr.colorMapping_subpixel=arg; setImg();"
	colorMap.addHandler #cb2 #changed paramStr:"arg " codeStr:"vr.colorMapping_clampOutput=arg; setImg();"
	colorMap.addHandler #btn1 #pressed codeStr:"sp1.value=2.2; cb1.checked=false; cb2.checked=false; vr.colorMapping_gamma=2.2; vr.colorMapping_subpixel=false; vr.colorMapping_clampOutput=false; setImg();"
	)
	
	--end
	colorMap.end()
)

fn giRollout =
(
	gi = rolloutCreator "gi" "V-Ray:: Indirect illumination"
	gi.begin()
	--begin
	
	--gi
	reGI = vr.gi_on
	if not reGI do
	(
	isGi = true
	gi.addText "group \"GI\" ("
	gi.addControl #label #lbl1 "GI is off, turn on?" paramStr:"align:#left"
	gi.addControl #checkbox #cb1 "On" paramStr:("checked:"+reGI as string+" across:2")
	gi.addControl #imgTag #it1 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[-90,4]"
	gi.addText ")"
	
	gi.addHandler #cb1 #changed paramStr:"arg " codeStr:"vr.gi_on=arg; if arg then it1.visible=false else it1.visible=true;"
	)
	
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
	if reFirst != 0 or reSecond != 3 or reIrMin < -3 or reIrMax < -1 or reIrSub < 50 or reIrInterp < 25 or reLightSub < 1200 or reLightSize > 0.02 do
	(
	isGi = true
	gi.addText "group \"Primary / Secondary\" ("
	gi.addControl #label #lbl2 "Please check GI settings" paramStr:"align:#left across:3"
	gi.addControl #button #btn1 "Medium" paramStr:"offset:[65,-2]"
	gi.addControl #button #btn2 "High" paramStr:"offset:[25,-2]"
	gi.addControl #dropdownlist #ddl1 "" paramStr:("items:#(\"Irradiance map\",\"Photon map\",\"Brute Force\",\"Light cache\") selection:"+(reFirst+1) as string+" width:120 across:2")
	gi.addControl #imgTag #it2 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[0,4]"
	gi.addControl #spinner #sp1 "Min rate: " paramStr:("range:[-10,10,"+reIrMin as string+"] width:80 align:#left type:#integer across:4")
	gi.addControl #imgTag #it3 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[25,4]"
	gi.addControl #spinner #sp3 "HSph. subdivs:  " paramStr:("range:[1,200,"+reIrSub as string+"] width:160 align:#left offset:[-10,0] type:#integer")
	gi.addControl #imgTag #it4 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	gi.addControl #spinner #sp2 "Max rate:" paramStr:("range:[-10,10,"+reIrMax as string+"] width:80 align:#left type:#integer across:4")
	gi.addControl #imgTag #it5 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[25,4]"
	gi.addControl #spinner #sp4 "Interp. samples:" paramStr:("range:[1,200,"+reIrInterp as string+"] width:160 align:#left offset:[-10,0] type:#integer")
	gi.addControl #imgTag #it6 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	gi.addControl #dropdownlist #ddl2 "" paramStr:("items:#(\"Irradiance map\",\"Photon map\",\"Brute Force\",\"Light cache\") selection:"+(reSecond+1) as string+" width:120 across:2")
	gi.addControl #imgTag #it7 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[0,4]"
	gi.addControl #spinner #sp5 "Subdivs:      " paramStr:("range:[1,4000,"+reLightSub as string+"] width:135 align:#left type:#integer across:4")
	gi.addControl #imgTag #it8 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[50,4]"
	gi.addControl #checkbox #cb2 "Store direct light" paramStr:("checked:"+reLightDir as string+" offset:[20,0]")
	gi.addControl #imgTag #it9 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	gi.addControl #spinner #sp6 "Sample size:" paramStr:("range:[0,1,"+reLightSize as string+"] scale:0.01 width:90 align:#left type:#float across:2")
	gi.addControl #imgTag #it10 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[-15,4]"
	gi.addText ")"
	
	--custom function
	gi.addText "fn setSpinner = (if ddl1.selection==1 then (sp1.visible=true;sp2.visible=true;sp3.visible=true;sp4.visible=true;) else (sp1.visible=false;sp2.visible=false;sp3.visible=false;sp4.visible=false;); if ddl2.selection==4 then (sp5.visible=true;sp6.visible=true;cb2.visible=true;) else (sp5.visible=false;sp6.visible=false;cb2.visible=false;);)"
	gi.addText "fn setImg = (if ddl1.selection==1 then (it2.visible=false; if sp1.value<-3 then it3.visible=true else it3.visible=false; if sp3.value<50 then it4.visible=true else it4.visible=false; if sp2.value<-1 then it5.visible=true else it5.visible=false; if sp4.value<25 then it6.visible=true else it6.visible=false;) else (it2.visible=true;it3.visible=false;it4.visible=false;it5.visible=false;it6.visible=false;); if ddl2.selection==4 then (it7.visible=false; if sp5.value<1200 then it8.visible=true else it8.visible=false; if cb2.checked then it9.visible=false else it9.visible=true; if sp6.value>0.02 then it10.visible=true else it10.visible=false;) else (it7.visible=true;it8.visible=false;it8visible=false;it10.visible=false;))"
	gi.addHandler #gi #open codeStr:"setSpinner(); setImg();"
	gi.addHandler #ddl1 #selected paramStr:"arg " codeStr:"vr.gi_primary_type=ddl1.selection-1;setSpinner(); setImg();"
	gi.addHandler #sp1 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_minRate=arg; setImg();"
	gi.addHandler #sp2 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_maxRate=arg; setImg();"
	gi.addHandler #sp3 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_subdivs=arg; setImg();"
	gi.addHandler #sp4 #changed paramStr:"arg " codeStr:"vr.gi_irradmap_interpSamples=arg; setImg();"
	gi.addHandler #ddl2 #selected paramStr:"arg " codeStr:"vr.gi_secondary_type=ddl2.selection-1;setSpinner(); setImg();"
	gi.addHandler #sp5 #changed paramStr:"arg " codeStr:"vr.lightcache_subdivs=arg; setImg();"
	gi.addHandler #sp6 #changed paramStr:"arg " codeStr:"vr.lightcache_sampleSize=arg; setImg();"
	gi.addHandler #cb2 #changed paramStr:"arg " codeStr:"vr.lightcache_storeDirectLight=case arg of (false: 0; true: 1;); setImg();"
	gi.addHandler #btn1 #pressed codeStr:"ddl1.selection=1; ddl2.selection=4; sp1.value=-3.0; sp2.value=-1.0; sp3.value=60.0; sp4.value=30.0; sp5.value=1500.0; sp6.value= 0.02; cb2.checked=true; vr.gi_primary_type=0; vr.gi_secondary_type=3; vr.gi_irradmap_minRate=-3; vr.gi_irradmap_maxRate=-1; vr.gi_irradmap_subdivs=60; vr.gi_irradmap_interpSamples=30; vr.lightcache_subdivs=1500; vr.lightcache_sampleSize=0.02; vr.lightcache_storeDirectLight=1; setSpinner(); vr.gi_irradmap_colorThreshold=0.4; vr.gi_irradmap_normalThreshold=0.2; vr.gi_irradmap_distThreshold=0.1; lbl2.text=\"Please check GI settings ->  Medium\"; setImg();"
	gi.addHandler #btn2 #pressed codeStr:"ddl1.selection=1; ddl2.selection=4; sp1.value=-3.0; sp2.value=0.0; sp3.value=60.0; sp4.value=30.0; sp5.value=1500.0; sp6.value= 0.02; cb2.checked=true; vr.gi_primary_type=0; vr.gi_secondary_type=3; vr.gi_irradmap_minRate=-3; vr.gi_irradmap_maxRate=0; vr.gi_irradmap_subdivs=60; vr.gi_irradmap_interpSamples=30; vr.lightcache_subdivs=1500; vr.lightcache_sampleSize=0.02; vr.lightcache_storeDirectLight=1; setSpinner(); vr.gi_irradmap_colorThreshold=0.3; vr.gi_irradmap_normalThreshold=0.1; vr.gi_irradmap_distThreshold=0.1; lbl2.text=\"Please check GI settings ->  High\"; setImg();"
	)
	
	--end
	gi.end()
)

fn sysRollout =
(
	sys = rolloutCreator "sys" "V-Ray:: System"
	sys.begin()
	--begin
	
	reNoise = vr.dmc_earlyTermination_threshold
	reMinSample = vr.dmc_earlyTermination_minSamples
	reDynMem = vr.system_raycaster_memLimit
	reGloSubMul = vr.dmc_subdivs_mult
	reMaxTree = vr.system_raycaster_maxLevels
	reDistribute = vr.system_distributedRender
	if reNoise > 0.01 or reMinSample < 8 or reDynMem < 6000 or reGloSubMul < 1.0 or reMaxTree < 80 or reDistribute do
	(
	isSys = true
	sys.addText "group \"System\" ("
	sys.addControl #label #lbl1 "Please check system settings" paramStr:"align:#left across:2"
	sys.addControl #button #btn1 "recommend" paramStr:"offset:[30,-2]"
	sys.addControl #spinner #sp1 "Noise threshold:" paramStr:("range:[0,1,"+reNoise as string+"] width:150 align:#left type:#float scale:0.01 across:4")
	sys.addControl #imgTag #it1 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	sys.addControl #spinner #sp2 "Min samples:     " paramStr:("range:[1,50,"+reMinSample as string+"] width:120 align:#left offset:[10,0] type:#integer")
	sys.addControl #imgTag #it2 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	sys.addControl #spinner #sp3 "Memory limit:     " paramStr:("range:[1,10000,"+reDynMem as string+"] width:150 align:#left type:#integer across:4")
	sys.addControl #imgTag #it3 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	sys.addControl #spinner #sp4 "Global multiplier:" paramStr:("range:[0.1,5,"+reGloSubMul as string+"] width:120 align:#left offset:[10,0] type:#float")
	sys.addControl #imgTag #it4 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	sys.addControl #spinner #sp5 "Max tree depth:" paramStr:("range:[1,100,"+reMaxTree as string+"] width:150 align:#left type:#integer across:4")
	sys.addControl #imgTag #it5 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	sys.addControl #checkbox #cb1 "Distributed render" paramStr:("checked:"+reDistribute as string+" offset:[10,0]")
	sys.addControl #imgTag #it6 "" paramStr:"bitmap:(bitmap 10 10 color:red) offset:[60,4]"
	sys.addText ")"
	
	sys.addText "fn setImg = (if sp1.value>0.01 then it1.visible=true else it1.visible=false; if sp2.value<8 then it2.visible=true else it2.visible=false; if sp3.value<6000 then it3.visible=true else it3.visible=false; if sp4.value<1.0 then it4.visible=true else it4.visible=false; if sp5.value<80 then it5.visible=true else it5.visible=false; if cb1.checked then it6.visible=true else it6.visible=false;)"
	sys.addHandler #sys #open codeStr:"setImg();"
	sys.addHandler #sp1 #changed paramStr:"arg " codeStr:"vr.dmc_earlyTermination_threshold=arg; setImg();"
	sys.addHandler #sp2 #changed paramStr:"arg " codeStr:"vr.dmc_earlyTermination_minSamples=arg; setImg();"
	sys.addHandler #sp3 #changed paramStr:"arg " codeStr:"vr.system_raycaster_memLimit=arg; setImg();"
	sys.addHandler #sp4 #changed paramStr:"arg " codeStr:"vr.dmc_subdivs_mult=arg; setImg();"
	sys.addHandler #sp5 #changed paramStr:"arg " codeStr:"vr.system_raycaster_maxLevels=arg; setImg();"
	sys.addHandler #cb1 #changed paramStr:"arg " codeStr:"vr.system_distributedRender=arg; setImg();" --vrayEditDRSettings() for VRay 2.0
	sys.addHandler #btn1 #pressed codeStr:"sp1.value=0.01; sp2.value=8.0; sp3.value=8000.0; sp4.value=1.0; sp5.value=80.0; cb1.checked=false; vr.dmc_earlyTermination_threshold=0.01; vr.dmc_earlyTermination_minSamples=8; vr.system_raycaster_memLimit=8000; vr.dmc_subdivs_mult=1.0; vr.system_raycaster_maxLevels=80; vr.system_distributedRender=false; setImg();"
	)
	
	--end
	sys.end()
)

fn congratRollout =
(
	congrat = rolloutCreator "congrat" "Congratulations"
	congrat.begin()
	--begin
	
	congrat.addText "group \"Ready\" ("
	congrat.addControl #label #lbl1 "Having checked all the above, you are ready to render:)"
	congrat.addControl #label #lbl2 "Note: this will delete / re-create all the render elements"
	congrat.addControl #button #btn1 "Open Render Scene Dialog"
	congrat.addText ")"
	
	congrat.addText "fn isVRayLocal arg = (return ((matchPattern arg pattern:\"*VRay*\") or (matchPattern arg pattern:\"*V_Ray*\"));)" --max 2011 doesn't recognize the global "isVRay" function, so have to define it locally
	
	congrat.addHandler #btn1 #pressed codeStr:"closeRolloutFloater renderCheckFloater; renderSceneDialog.open(); toDelete=#(); toMultiMatte=#(); toZ=false; toZMin=0.0; toZMax=0.0; toT=false; toTex=undefined; \
	for i = 0 to re.NumRenderElements()-1 where isVRayLocal ((re.GetRenderElement i) as string) and not (classOf (re.GetRenderElement i)==VRayZDepth) and not (classOf (re.GetRenderElement i)==VRayExtraTex) do (append toDelete (re.GetRenderElement i).elementName;); \
	for i = 0 to re.NumRenderElements()-1 where (classOf (re.GetRenderElement i)==MultiMatteElement) do append toMultiMatte i; toMultiMatteCount=toMultiMatte.count; \
	for i = 0 to re.NumRenderElements()-1 where classOf (re.GetRenderElement i)==VRayZDepth do (toZ=true; toZMin=(re.GetRenderElement i).zdepth_min; toZMax=(re.GetRenderElement i).zdepth_max;); \
	for i = 0 to re.NumRenderElements()-1 where classOf (re.GetRenderElement i)==VRayExtraTex do (toT=true; toTex=(re.GetRenderElement i).texture;); \
	re.RemoveAllRenderElements(); \
	for j in toDelete do re.AddRenderElement (reCompleteName1[findItem reComplete1 j] elementname:j); \
	for j = 1 to toMultiMatteCount do (n=(\"ObjCh_\"+j as string+\"_MultiMatteElement\"); re.AddRenderElement (MultiMatteElement elementname:n R_gbufIDOn:true G_gbufIDOn:true B_gbufIDOn:true R_gbufID:(j*3-2) G_gbufID:(j*3-1) B_gbufID:(j*3));); \
	if toZ do re.AddRenderElement (VRayZDepth elementname:\"VRayZDepth\" zdepth_min:toZMin zdepth_max:toZMax); \
	if toT do re.AddRenderElement (VRayExtraTex elementname:\"VRayExtraTex\" texture:toTex);" --will automatically eliminate multimatte when there's no multimatte (for loop won't go from 1 to 0; reversely); will automatically skip if there's no element at all (if array.count==0)
	
	--end
	congrat.end()
)

---------------------------------------------------------------------------------------------------------
--rollout definition
---------------------------------------------------------------------------------------------------------
if not(isVRay s) then
(
	messageBox "Please change your renderer to V-Ray" title:"Error"
	renderSceneDialog.open()
)
else
(
	renderSceneDialog.close()
	renderCheckFloater = newRolloutFloater "TOOLBOX RENDER CHECK" 300 800
	
	--frame buffer
	frameBufferRollout()
	if isFrameBuffer do
		addRollout frameBuffer renderCheckFloater
	
	--render elements
	elementRollout()
	addRollout element renderCheckFloater
	
	--general settings
	commonRollout()
	if isCommon do
		addRollout common renderCheckFloater
	
	--image sampler
	samplerRollout()
	if isSampler do
		addRollout sampler renderCheckFloater
	
	--color mapping
	colorMapRollout()
	if isColorMap do
		addRollout colorMap renderCheckFloater
	
	--irradiance map / light cache
	giRollout()
	if isGi do
		addRollout gi renderCheckFloater
	
	--system
	sysRollout()
	if isSys do
		addRollout sys renderCheckFloater
	
	--submit
	congratRollout()
	addRollout congrat renderCheckFloater
)