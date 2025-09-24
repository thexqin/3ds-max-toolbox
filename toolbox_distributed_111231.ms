---------------------------------------------------------------------------------------------------------
--global variable
---------------------------------------------------------------------------------------------------------
try (closeRolloutFloater distributedFloater) catch ()
renderSceneDialog.close()
global distributedFloater
global distributed = rolloutCreator  "distributed" "Distributed Setting"
global fixRollout
global man = NetRender.GetManager()
man.connect #automatic "255.255.255.0"
global allServer = man.GetServers()
fn compareFn v1 v2 =
(
	case of
	(
	(v1.name < v2.name): -1
	(v1.name > v2.name): 1
	default: 0
	)
)
qsort allServer compareFn

global serverName = #() --"qbox15, qbox14..."
global serverState = #() --"#busy, #idle, #absent"
global serverIdle = #() --"qbox15, qbox14..."
for i in allServer do
(
	append serverName i.name
	append serverState i.state
)

global code = ""
for i = 1 to serverState.count do
(
	code += "lbl"+i as string+"b.caption=(serverState["+i as string+"] as string);"
	code += "if serverState["+i as string+"]==#Idle then cb"+i as string+".checked=true else cb"+i as string+".checked=false;"
)
global code2 = "serverIdle=#();" --clear array
for i = 1 to serverName.count do
	code2 += "if cb"+i as string+".checked==true do append serverIdle serverName["+i as string+"];"
---------------------------------------------------------------------------------------------------------
--rollout definition
---------------------------------------------------------------------------------------------------------
distributed.begin()
--begin

for i = 1 to serverName.count do
(
	distributed.addControl #checkbox ("cb"+i as string) "" paramStr:"across:3"
	distributed.addControl #label ("lbl"+i as string+"a") serverName[i] paramStr:"offset:[-20,0]"
	distributed.addControl #label ("lbl"+i as string+"b") (serverState[i] as string)
)

distributed.addControl #button #btn1 "Check" paramStr:"across:2 offset:[40,0]"
distributed.addControl #button #btn2 "Apply"
distributed.addHandler #distributed #open codeStr:"btn2.visible=false;"
distributed.addHandler #btn1 #pressed codeStr:("for i in allServer do i.GetUpdate(); serverState=#(); for j in allServer do append serverState j.state;"+code)
distributed.addHandler #btn2 #pressed codeStr:code2

--end
distributed.end()

--CAN NOT use rolloutCreator because c:\x.qin can not be recognized anyway, works fine in regular rollout
rollout fixRollout "Apply"
(
	button btn1 "Apply and Open Render Dialog"
	on btn1 pressed do
	(
		vr = renderers.current
		vr.system_distributedRender=true
		distributed.btn2.pressed()
		toWrite = ""
		for i in serverIdle do
			toWrite += (i as string) + " 1 \n"
		toWrite += "restart_slaves 1\nlist_in_scene 1"
		f=fopen ("C:\\Users\\"+sysInfo.username+"\\AppData\\Local\\Autodesk\\3dsmax\\2011 - 64bit\\enu\\plugcfg\\vray_dr.cfg") "wt"
		WriteString f toWrite
		FClose f
		closeRolloutFloater distributedFloater
		renderSceneDialog.open()
	)
)

---------------------------------------------------------------------------------------------------------
--rollout floater definition
---------------------------------------------------------------------------------------------------------
distributedFloater = newRolloutFloater "TOOLBOX DISTRIBUTED" 200 900
addRollout distributed distributedFloater
addRollout fixRollout distributedFloater