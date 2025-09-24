---------------------------------------------------------------------------------------------------------
--global variable
---------------------------------------------------------------------------------------------------------
try (closeRolloutFloater channelFloater) catch ()
global channelFloater
global channels 			= rolloutCreator "channels" "Channel Setting" --main rollout
global errorMsg			= "Please select at least one object"
global errorTitle			= "Empty Selection"
global colorDefault		= #([83,0,0] , [83, 35, 0]  ,  [83, 55, 0] , [83, 69, 0] , [83, 83 ,0]  ,  [69,83,0] , [55, 83 ,0], [35, 83, 0], [0, 83, 0], [0, 83, 35], [0, 83, 55], [0, 83, 69], [0, 83,83], [0, 69, 83], [0, 55, 83], [0, 35, 83], [0, 0, 83], [35, 0, 83], [55, 0, 83], [69, 0, 83] , [83, 0,83], [83, 0, 69], [83, 0, 55], [176, 26, 26], [225, 143 ,87], [225, 198, 87], [143, 225, 87], [87, 225, 143], [140, 88, 225], [166, 229, 229],    [90,0,0],[90,0,30],[90,0,60], [90,0,90],[90,0,120],[90,0,150], [90,30,150],[90,60,150],[90,90,150], [90,120,150],[90,150,150],[120,150,150], [150,150,150],[180,150,150],[180,150,180])
global usedArray			= #() --store all used channel number
global code				= ""
global channelNum		= 45 --colorDefault.count
for i = 1 to channelNum do --has to do it here because can not do loop inside a string
	code += "if(findItem usedArray "+i as string+") !=0 then (lbl"+i as string+".caption=\"X\") else (lbl"+i as string+".caption=\"\");"

---------------------------------------------------------------------------------------------------------
--rollout definition
---------------------------------------------------------------------------------------------------------
channels.begin()
--begin

for i in geometry do
(
	if i.gbufferChannel != 0 do
		appendifunique usedArray i.gbufferChannel
)
for i = 1 to channelNum do --channelNum
(
	cp = "cp" + i as string
	cpColor = colorDefault[i] as string
	chBtn = "btn" + i as string + "a"
	chName = "Ch" + i as string
	selBtn = "btn" + i as string + "b"
	selName = "Select"
	checkLbl = "lbl" + i as string
	if (findItem usedArray i) != 0 then
		checkName = "X"
	else
		checkName = ""
	
	if mod i 3 == 1.0 do
	(
		passNum = "Pass " + ((i+2)/3) as string
		channels.addText ("group @"+passNum+"@ (")
	)
	channels.addControl #colorPicker cp "" paramStr:("color:"+cpColor+"across:4")
	channels.addControl #button chBtn chName
	channels.addControl #button selBtn selName
	channels.addControl #label checkLbl checkName paramStr:"style_sunkenedge:true width:12"
	if mod i 3 == 0.0 do
		channels.addText ")"
)
for i = 1 to channelNum do ----channelNum
(
	cp = "cp" + i as string
	chBtn = "btn" + i as string + "a"
	selBtn = "btn" + i as string + "b"
	checkLbl = "lbl" + i as string
	
	channels.addHandler chBtn #pressed codeStr:("if selection.count == 0 then messageBox \""+errorMsg+"\" title:\""+errorTitle+"\" else ($.wirecolor = "+cp+".color; $.gbufferChannel = "+i as string+"); usedArray = #(); for k in geometry do (if k.gbufferChannel != 0 do appendifunique usedArray k.gbufferChannel)"+code)
	channels.addHandler selBtn #pressed codeStr:("clearselection(); toSelect=#(); for j in geometry do (if j.gbufferChannel == "+i as string+" do append toSelect j); select toSelect")
)

channels.addControl #button #assignBtn "Assign Render Elements"
channels.addHandler #assignBtn #pressed codeStr:("try (renderSceneDialog.close(); re = maxOps.GetCurRenderElementMgr(); toDelete = #(); for i = 0 to re.NumRenderElements() where (classOf (re.GetRenderElement i) == MultiMatteElement) do append toDelete (re.GetRenderElement i); for i in toDelete do re.RemoveRenderElement i; for j = 1 to 15 do re.AddRenderElement (MultiMatteElement elementname:(\"ObjCh_\"+j as string+\"_MultiMatteElement\") R_gbufIDOn:true G_gbufIDOn:true B_gbufIDOn:true R_gbufID:(j*3-2) G_gbufID:(j*3-1) B_gbufID:(j*3));) catch (); closeRolloutFloater channelFloater;") --GetRenderElement is 0-based; can not delete all elements once, perhaps a system bug, so had to use another "toDelete" array

--end
channels.end()

---------------------------------------------------------------------------------------------------------
--rollout floater definition
---------------------------------------------------------------------------------------------------------
channelFloater = newRolloutFloater "TOOLBOX CHANNEL" 220 800
addRollout channels channelFloater