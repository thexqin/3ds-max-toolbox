/*********************************************************************
 * 2014.11.14
 * by Xiao Qin
 *
 * Integrated 'Distributed', 'Render Check', 'Channel Setting', and other on-rollout tools
 * Tested: 3ds Max 2011, 2012, 2014; VRay 1.5, 2.0, 3.0
 *********************************************************************/

---------------------------------------------------------------------------------------------------------
--global variable
---------------------------------------------------------------------------------------------------------
try (closeRolloutFloater tbFloater) catch ()
global tbFloater
global msRenderCheck	= "qx_toolbox_render_check_build.mse"
global msChannel		= "qx_toolbox_channel_build.mse"
global msDistributed	= "qx_toolbox_distributed_build.mse"
global msMtl				= "qx_toolbox_vray_material_build.mse"

global errorMsg			= "Please select at least one object"
global errorTitle			= "Empty Selection"
global iniPath				= (sysInfo.tempdir + "vray_setting_temp.ini")
global allSelect			= #() --random selection
global objGround			= undefined --paint
global objArray			= #()
global step				= 1
global glassArray			= #() --glass pass
global glassMatArray	= #()
global listArray			= #("E:\\") --relink bitmap
global dirArray			= #()
global matArray			= #()
global mapArray			= #()
global vrmeshArray		= #()
global vrmeshDumpArray = #()
global missingMapArray= #()
global missingVrmeshArray = #()
global emptyLayer		= #() --purge layer
global selectArray		= #("i.material==undefined","i.gbufferChannel==0","i.primaryVisibility==false","i.primaryVisibility==true","i.boxMode==false","i.boxMode==true","i.wireColor==color 0 0 0") --select by attribute

---------------------------------------------------------------------------------------------------------
--preparation function
---------------------------------------------------------------------------------------------------------
fn isValidSelection =
(
	if selection.count == 0 then
	(
		messageBox errorMsg title:errorTitle
		return false
	)
	else
		return true
)

---------------------------------------------------------------------------------------------------------
--rollout definition
---------------------------------------------------------------------------------------------------------
rollout tbMat "Material"
(
	button btn1 "Remove Mtl" across:3 offset:[-10,0]
	button btn2 "Random Color" offset:[5,0]
	button btn3 "Mtl Check" offset:[15,0]
	
	--remove material
	on btn1 pressed do
	(
		if isValidSelection() do
			undo "Remove Material" on
			(
				$.material = undefined
			)
	)
	--random wirecolor; objects in same group will have same color
	on btn2 pressed do
	(
		if isValidSelection() do
			undo "Random Color" on
			(
				for i in $ do
				(
					if not isGroupMember i do
						i.wirecolor = [(random 0 255),(random 0 255),(random 0 255)]
					if isGroupHead i do
						i.children.wirecolor = [(random 0 255),(random 0 255),(random 0 255)]
				)
			)
	)
	
	on btn3 pressed do
		fileIn msMtl
)

rollout tbRename "Rename Object Series"
(
	button btn1 "Rename" across:3 offset:[-5,0]
	button btn2 "Suggest" offset:[-11,0]
	checkbox cb1 "Unique Name" offset:[-10,3]
	edittext et1
	
	--rename, either unique or not unique; objects in closed groups will not be renamed
	on btn1 pressed do
	(
		if isValidSelection() do
		(
			if et1.text != "" then
				undo "Rename" on
				(
					if cb1.checked then
						for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
							i.name = uniquename et1.text
					else
						for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
							i.name = et1.text
				)
			else
				messageBox "Please enter a new name" title:"Empty Name"
		)
	)
	--suggest name, when a lot of instances were selected
	on btn2 pressed do
	(
		if isValidSelection() do
			et1.text = selection[1].name
	)
)

rollout tbVRay "VRay Renderer Setting"
(
	button btn1 "Low" across:4 offset:[-18,0]
	button btn2 "Med" offset:[-32,0]
	button btn3 "Render Check" offset:[-23,0]
	button btn4 "Distributed" offset:[3,0]
	
	on btn1 pressed do
	(
		s = (classOf renderers.current) as string
		if not(matchPattern s pattern:"V_Ray*") do
		(
			try (renderers.current = VRay()) catch ()
			s = (classOf renderers.current) as string
		)
		
		if matchPattern s pattern:"V_Ray*" do
		(
			vr = renderers.current
			renderSceneDialog.close()
			
			renderWidth = 640
			renderHeight = 480
			rendSaveFile = false
			rendUseNet = false
			usePreRendScript = false
			preRendScript = ""
			usePostRendScript = false
			postRendScript = ""
			useEnvironmentMap = false
			
			vr.output_on = true
			vr.options_displacement = false
			vr.options_limitDepth = true
			vr.options_maxDepth = 2
			
			vr.imageSampler_type = 0
			vr.fixedRate_subdivs = 1
			vr.twoLevel_baseSubdivs = 1
			vr.twoLevel_fineSubdivs = 4
			
			vr.environment_gi_on = false
			vr.environment_rr_on = false
			vr.colorMapping_gamma = 2.2
			
			vr.gi_on = true
			vr.gi_primary_type = 3
			vr.gi_secondary_type = 3
			vr.lightcache_subdivs = 100
			vr.lightcache_sampleSize = 0.04
			vr.lightcache_storeDirectLight = 1
			vr.lightcache_showCalcPhase = 1
			vr.lightcache_interpSamples = 5

			vr.dmc_earlyTermination_threshold = 0.1
			vr.dmc_subdivs_mult = 0.1
			
			vr.system_raycaster_maxLevels = 80
			vr.system_raycaster_memLimit = 8000
			vr.system_region_sequence = 0
			vr.system_distributedRender = false
			vr.system_vrayLog_show = false
		)
	)
	
	on btn2 pressed do
	(
		s = (classOf renderers.current) as string
		if not(matchPattern s pattern:"V_Ray*") do
		(
			try (renderers.current = VRay()) catch ()
			s = (classOf renderers.current) as string
		)
		
		if matchPattern s pattern:"V_Ray*" do
		(
			vr = renderers.current
			renderSceneDialog.close()
			
			renderWidth = 640
			renderHeight = 480
			rendSaveFile = false
			rendUseNet = false
			usePreRendScript = false
			preRendScript = ""
			usePostRendScript = false
			postRendScript = ""
			useEnvironmentMap = false
			
			vr.output_on = true
			vr.options_displacement = true
			vr.options_limitDepth = false
			
			vr.imageSampler_type = 0
			vr.fixedRate_subdivs = 1
			vr.twoLevel_baseSubdivs = 1
			vr.twoLevel_fineSubdivs = 4
			
			vr.environment_gi_on = false
			vr.environment_rr_on = false
			vr.colorMapping_gamma = 2.2
			
			vr.gi_on = true
			vr.gi_primary_type = 0
			vr.gi_secondary_type = 3
			vr.gi_irradmap_minRate = -4
			vr.gi_irradmap_maxRate = -4
			vr.gi_irradmap_subdivs = 40
			vr.gi_irradmap_interpSamples = 20
			vr.gi_irradmap_colorThreshold = 0.4
			vr.gi_irradmap_normalThreshold = 0.2
			vr.gi_irradmap_distThreshold = 0.1
			vr.gi_irradmap_showCalcPhase = true
			vr.lightcache_subdivs = 100
			vr.lightcache_sampleSize = 0.02
			vr.lightcache_storeDirectLight = 1
			vr.lightcache_showCalcPhase = 1
			vr.lightcache_interpSamples = 10

			vr.dmc_earlyTermination_threshold = 0.1
			vr.dmc_subdivs_mult = 1.0
			
			vr.system_raycaster_maxLevels = 80
			vr.system_raycaster_memLimit = 8000
			vr.system_region_sequence = 0
			vr.system_distributedRender = false
			vr.system_vrayLog_show = false
		)
	)
	
	on btn3 pressed do
		fileIn msRenderCheck
	
	on btn4 pressed do
		fileIn msDistributed
)

rollout tbChannel "Channel Setting"
(
	colorPicker cp1 color:[128,128,128] across:3 offset:[-4,0]
	button btn1 "No Channel" offset:[-20,0]
	button btn2 "Channel Setting"
	
	--channel setting
	on btn1 pressed  do
	(
		if isValidSelection() do
			undo "No Channel" on
			(
				$.wirecolor = cp1.color
				$.gbufferChannel = 0
			)
	)
	on btn2 pressed  do
		fileIn msChannel
)

rollout tbTransform "Lock Transform"
(
	button btn1 "Lock" across:3 offset:[-10,0]
	button btn2 "Unlock" offset:[-15,0]
	button btn3 "Center Pivot"
	
	--lock and unlock tranform
	on btn1 pressed do
	(
		if isValidSelection() do
		(
			$.boxMode = true
			setTransformLockFlags $ #all
		)
	)
	on btn2 pressed do
	(
		if isValidSelection() do
		(
			$.boxMode = false
			setTransformLockFlags $ #none
		)
	)
	--center pivot
	on btn3 pressed do
	(
		if isValidSelection() do
			undo "Center Pivot" on
			(
				for i in $ where isGroupHead i do
					setGroupOpen i true
				
				CenterPivot $ --centerpivot can not be done when group is closed
				
				for i in $ where isGroupHead i do
					setGroupOpen i false
			)
	)
)

rollout tbRandomSelection "Random Selection"
(
	spinner sp1 "%" range:[0,100,50] type:#integer width:50 across:3 offset:[-13,2]
	checkbutton btn1 "Random"
	button btn2 "Apply" enabled:false
	
	--random select
	on btn1 changed arg do --"arg" was got from the callback function; equals "state" or "isChecked"
	(
		if arg then
		(
			if not(isValidSelection()) then
			(
				btn1.checked = false
				btn1.text = "Random"
				btn2.enabled = false
			)
			else
			(
				allSelect = getCurrentSelection() --selection as array
				toSelect = #()
				for i in $ do
				(
					rmd = random 0.0 1.0
					if rmd <= sp1.value/100.0 do
						append toSelect i
				)
				clearSelection()
				select toSelect
				btn1.checked = true
				btn1.text = "Restore"
				btn2.enabled = true
			)
		)
		else
		(
			clearSelection()
			try
				select allSelect
			catch
				messageBox "Can not restore selection because some objects were deleted" title:errorTitle
			btn1.checked = false
			btn1.text = "Random"
			btn2.enabled = false
		)
	)
	on btn2 pressed do
	(
		btn1.checked = false
		btn1.text = "Random"
		btn2.enabled = false
	)
)

rollout tbRandomTransform "Random Transform"
(
	spinner sp1a "Rotate" range:[-180,0,-15] type:#integer fieldwidth:30 across:6 align:#left offset:[-8,2]
	spinner sp1b "~" range:[0,180,15] type:#integer fieldwidth:30 offset:[49,2]
	button btn1a "X" offset:[45,0]
	button btn1b "Y" offset:[34,0]
	button btn1c "Z" offset:[23,0]
	button btn1d "All" offset:[14,0]
	spinner sp2a "Move  " range:[-100,0,-15] type:#integer fieldwidth:30 across:6 align:#left offset:[-8,2]
	spinner sp2b "~" range:[0,100,15] type:#integer fieldwidth:30 offset:[49,2]
	button btn2a "X" offset:[45,0]
	button btn2b "Y" offset:[34,0]
	button btn2c "Z" offset:[23,0]
	button btn2d "All" offset:[14,0]
	spinner sp3a "Scale  " range:[0.1,10,0.1] type:#float fieldwidth:30 across:6 align:#left offset:[-8,2]
	spinner sp3b "~" range:[0.1,10,3] type:#float fieldwidth:30 offset:[49,2]
	button btn3a "X" offset:[45,0]
	button btn3b "Y" offset:[34,0]
	button btn3c "Z" offset:[23,0]
	button btn3d "Uni" offset:[16,0]
	
	--random rotate
	on btn1a pressed do
	(
		if isValidSelection() do
			undo "Random Rotate X" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp1a.value sp1b.value
					rotate i (eulerAngles rmd 0 0)
				)
			)
	)
	on btn1b pressed do
	(
		if isValidSelection() do
			undo "Random Rotate Y" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp1a.value sp1b.value
					rotate i (eulerAngles 0 rmd 0)
				)
			)
	)
	on btn1c pressed do
	(
		if isValidSelection() do
			undo "Random Rotate Z" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp1a.value sp1b.value
					rotate i (eulerAngles 0 0 rmd)
				)
			)
	)
	on btn1d pressed do
	(
		if isValidSelection() do
			undo "Random Rotate All" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmdX = random sp1a.value sp1b.value
					rmdY = random sp1a.value sp1b.value
					rmdZ = random sp1a.value sp1b.value
					rotate i (eulerAngles rmdX rmdY rmdZ)
				)
			)
	)
	--random move
	on btn2a pressed do
	(
		if isValidSelection() do
			undo "Random Move X" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp2a.value sp2b.value
					move i [rmd,0,0]
				)
			)
	)
	on btn2b pressed do
	(
		if isValidSelection() do
			undo "Random Move Y" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp2a.value sp2b.value
					move i [0,rmd,0]
				)
			)
	)
	on btn2c pressed do
	(
		if isValidSelection() do
			undo "Random Move Z" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp2a.value sp2b.value
					move i [0,0,rmd]
				)
			)
	)
	on btn2d pressed do
	(
		if isValidSelection() do
			undo "Random Move All" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmdX = random sp2a.value sp2b.value
					rmdY = random sp2a.value sp2b.value
					rmdZ = random sp2a.value sp2b.value
					move i [rmdX,rmdY,rmdZ]
				)
			)
	)
	--random scale
	on btn3a pressed do
	(
		if isValidSelection() do
			undo "Random Scale X" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp3a.value sp3b.value
					scale i [rmd,1,1]
				)
			)
	)
	on btn3b pressed do
	(
		if isValidSelection() do
			undo "Random Scale Y" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp3a.value sp3b.value
					scale i [1,rmd,1]
				)
			)
	)
	on btn3c pressed do
	(
		if isValidSelection() do
			undo "Random Scale Z" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp3a.value sp3b.value
					scale i [1,1,rmd]
				)
			)
	)
	on btn3d pressed do
	(
		if isValidSelection() do
			undo "Random Scale Uniform" on
			(
				for i in $ where (not isGroupMember i) or (isOpenGroupMember i) do
				(
					rmd = random sp3a.value sp3b.value
					scale i [rmd,rmd,rmd]
				)
			)
	)
)

rollout tbPaint "Paint"
(
	spinner sp1a "RotateZ" range:[-180,0,-15] type:#integer fieldwidth:30 across:3 align:#left offset:[-8,2]
	spinner sp1b "~" range:[0,180,15] type:#integer fieldwidth:30 offset:[-12,2]
	button btn1 "Pick Ground"
	spinner sp2a "ScaleAll " range:[0.1,5,0.8] type:#float fieldwidth:30 across:3 align:#left offset:[-8,2]
	spinner sp2b "~" range:[0.1,5,1.2] type:#float fieldwidth:30 offset:[-12,2]
	button btn2 "Pick Obj"
	spinner sp3 "Step" range:[1,20,5] type:#integer fieldwidth:30 across:3 align:#left offset:[-8,2]
	checkbox cb1 "Normal" checked:true offset:[0,3]
	checkbutton btn3 "Paint" enabled:false
	label lbl1 "N/A" across:2 align:#left width:85 offset:[-8,0]
	label lbl2 "N/A" offset:[-10,0] width:130
	
	--paint function
	fn callback_fn msg ir obj faceNum shift ctrl alt =
	(
		if obj != undefined and ir != undefined and msg == #mouseMove do
		(
			if step != sp3.value then
				step = step + 1
			else
			(
				idx = random 1 objArray.count
				o = instance objArray[idx]
				o.pivot = [o.center.x, o.center.y, o.min.z] --put pivot at center bottom
				rmdR = random sp1a.value sp1b.value
				rmdS = random sp2a.value sp2b.value
				step = 1
				if cb1.checked then --along surface normal
				(
					--rotation is special "quat" format, dir is "point3"
					--quat q = {x,y,z,w} = {vx*sin(T/2), vy*sin(T/2), vz*sin(T/2), cos(T/2)}
					--o.rotation = (inverse(matrixfromNormal ir.dir)) as EulerAngles
					o.dir = ir.dir
					rotate o (angleaxis rmdR o.dir)
					scale o [rmdS,rmdS,rmdS]
					o.pos = ir.pos
				)
				else
				(
					rotate o (eulerAngles 0 0 rmdR)
					scale o [rmdS,rmdS,rmdS]
					o.pos = ir.pos
				)
			)
		)
		
		if msg != #mouseAbort then
			return #continue
		else
			btn3.checked =false
			return undefined
	)
	fn callback_exit =
	(
		return undefined
	)
	on btn1 pressed do
	(
		if selection.count > 1 then
			messageBox errorMsg title:errorTitle
		else if isValidSelection() do
		(
			objGround = $
			lbl1.text = objGround.name
		)
		
		if objGround != undefined and objArray.count != 0 do
			btn3.enabled = true
	)
	on btn2 pressed do
	(
		if isValidSelection() do
		(
			lbl2.text = ""
			for i = 1 to selection.count do
			(
				objArray = #()
				append objArray selection[i]
				if i != selection.count then
					lbl2.text += selection[i].name + ","
				else
					lbl2.text += selection[i].name
			)
		)
		
		if objGround != undefined and objArray.count != 0 do
			btn3.enabled = true
	)
	on btn3 changed arg do
	(
		if arg then
			undo "Paint Object" on
			(
				mouseTrack on:objGround prompt:"Painting. Right click to finish" trackCallback:callback_fn
			)
		else
			mouseTrack trackCallback:callback_exit
	)
)

rollout tbPass "Object Pass"
(
	checkbutton btn1 "Object Pass" across:3 offset:[-4,0]
	checkbutton btn2 "Glass Pass" offset:[0,0]
	checkbutton btn3 "Shadow Pass" offset:[6,0]
	
	--object pass
	on btn1 changed arg do
	(
		s = (classOf renderers.current) as string
		if not(isValidSelection()) then
			btn1.checked = false
		else if not(matchPattern s pattern:"V_Ray*") then
		(
			messageBox "Please change your renderer to V-Ray" title:"Error"
			renderSceneDialog.open()
			btn1.checked = false
		)
		else
		(
			if arg then
			(
				--object pass
				sceneStateMgr.Delete "temp"
				sceneStateMgr.Capture "temp" #{3} --Object Properties
				
				a = $
				setUserProp a "VRay_Matte_Alpha" 1
				setUserProp a "VRay_Matte_Enable" false
				setUserProp a "VRay_Matte_GI_OtherMattes" true
				setUserProp a "VRay_Matte_ReflectionAmount" 1
				setUserProp a "VRay_Matte_RefractionAmount" 1
				
				--actionMan.executeAction 0 "40044" --select invert
				max select invert
				if $ != undefined do
				(
					b = $
					b.boxMode = true
					setUserProp b "VRay_Matte_Alpha" -1
					setUserProp b "VRay_Matte_Enable" true
					setUserProp b "VRay_Matte_GI_OtherMattes" false
					setUserProp b "VRay_Matte_ReflectionAmount" -1
					setUserProp b "VRay_Matte_RefractionAmount" -1
				)
				--actionMan.executeAction 0 "40044"
				max select invert

				btn1.text = "Restore"
			)
			else
			(
				--restore
				sceneStateMgr.Restore "temp" #{3}
				sceneStateMgr.Delete "temp"
				btn1.text = "Object Pass"
			)
		)
	)
	--glass pass
	on btn2 changed arg do
	(
		s = (classOf renderers.current) as string
		if not(isValidSelection()) then
			btn2.checked = false
		else if not(matchPattern s pattern:"V_Ray*") then
		(
			messageBox "Please change your renderer to V-Ray" title:"Error"
			renderSceneDialog.open()
			btn2.checked = false
		)
		else
		(
			if arg then
			(
				--glass pass
				sceneStateMgr.Delete "temp"
				sceneStateMgr.Capture "temp" #{3} --Object Properties
				
				a = $
				glassArray = selection as array
				glassMatArray = for i in $ collect i.material
				mirrorMat = VRayMtl()
				mirrorMat.diffuse = [0,0,0]
				mirrorMat.reflection= [255,255,255]
				
				a.material = mirrorMat
				setUserProp a "VRay_Matte_Alpha" 1
				setUserProp a "VRay_Matte_Enable" false
				setUserProp a "VRay_Matte_GI_OtherMattes" true
				setUserProp a "VRay_Matte_ReflectionAmount" 1
				setUserProp a "VRay_Matte_RefractionAmount" 1
				a.castShadows = false
				a.secondaryVisibility = false --no shadow & reflection on itself
				
				max select invert
				if $ != undefined do
				(
					b = $
					b.boxMode = true
					setUserProp b "VRay_Matte_Alpha" -1
					setUserProp b "VRay_Matte_Enable" true
					setUserProp b "VRay_Matte_GI_OtherMattes" false
					setUserProp b "VRay_Matte_ReflectionAmount" -1
					setUserProp b "VRay_Matte_RefractionAmount" -1
				)
				max select invert

				btn2.text = "Restore"
			)
			else
			(
				--restore
				sceneStateMgr.Restore "temp" #{3}
				sceneStateMgr.Delete "temp"
				if glassArray.count != 0 do
				(
					for i = 1 to glassArray.count do
						glassArray[i].material = glassMatArray[i]
					glassArray = #()
					glassMatArray = #()
				)
				btn2.text = "Glass Pass"
			)
		)
	)
	--shadow pass
	on btn3 changed arg do
	(
		s = (classOf renderers.current) as string
		if not(isValidSelection()) then
			btn3.checked = false
		else if not(matchPattern s pattern:"V_Ray*") then
		(
			messageBox "Please change your renderer to V-Ray" title:"Error"
			renderSceneDialog.open()
			btn3.checked = false
		)
		else
		(
			if arg then
			(
				--object pass
				sceneStateMgr.Delete "temp"
				sceneStateMgr.Capture "temp" #{3} --Object Properties
				
				a = $
				a.primaryVisibility = false
				setUserProp a "VRay_Matte_Alpha" 1
				setUserProp a "VRay_Matte_Enable" false
				setUserProp a "VRay_Matte_GI_OtherMattes" true
				setUserProp a "VRay_Matte_ReflectionAmount" 1
				setUserProp a "VRay_Matte_RefractionAmount" 1
				
				max select invert
				if $ != undefined do
				(
					b = $
					b.boxMode = true
					b.castShadows = false
				)
				max select invert
				
				vr = renderers.current
				vr.options_reflectionRefraction = false
				vr.gi_on = false
				backgroundColor = color 0 0 0
				useEnvironmentMap = false
				
				btn3.text = "Restore"
			)
			else
			(
				--restore
				sceneStateMgr.Restore "temp" #{3}
				sceneStateMgr.Delete "temp"
				btn3.text = "Shadow Pass"
			)
		)
	)
	on tbPass close do
	(
		if btn1.checked or btn2.checked or btn3.checked do
		(
			--restore
			sceneStateMgr.Restore "temp" #{3}
			sceneStateMgr.Delete "temp"
			if glassArray.count != 0 do
			(
				for i = 1 to glassArray.count do
					glassArray[i].material = glassMatArray[i]
			)
		)
	)
)

rollout tbRelink "Relink Map and Vrmesh"
(
	button btn1 "Relink" across:4
	checkbox cb1 "Sub Folder" checked:true offset:[10,3]
	button btn2 "+" offset:[30,0]
	button btn3 "-" offset:[10,0]
	listbox lb1 "" items:listArray selection:0 height:2
	
	--relink missing bitmaps
	--get folders / subfolders from query string
	fn getDirRecursive dir =
	(
		append dirArray dir
		d = getDirectories (dir+"*") --note "getDirectories" always returns "c:\xx\", with "\" at the end
		for i in d do --the action automatically eliminates empty array
		(
			getDirRecursive i
		)
	)
	--get all scene materials, deeper into multi/sub-object materials
	fn getMatRecursive mat =
	(
		if mat != undefined do
		(
			count = getNumSubMtls mat
		
			if count > 0 then
				for i = 1 to count do
					getMatRecursive (getSubMtl mat i)
			else
				append matArray mat --put all materials into matArray
		)
	)
	--get all missing maps
	fn getMapRecursive mat =
	(
		if mat != undefined do
		(
			count = getNumSubTexmaps mat
		
			if count > 0 do
				for i = 1 to count do
				(
					submap = getSubTexmap mat i
					if classof submap == bitmapTexture then
						if (submap.fileName != undefined) and not(doesFileExist submap.fileName) do
							append mapArray submap --put all missing bitmaps into mapArray
					else
						getMapRecursive submap
				)
		)
	)
	on btn1 pressed do
	(
		if listArray.count == 0 then
		(
			messageBox "Please select at least one path" title:errorTitle
		)
		else
		(
			timeStart = timeStamp()
			btn1.enabled = false
			
			--create folders / subfolders
			if cb1.checked then
			(
				for i in listArray do
					getDirRecursive i
			)
			else
			(
				for i in listArray do
					append dirArray i --note "FolderBrowserDialog" returns no "\" at the end, except for "v:\", "d:\", etc
			)
			
			--get all scene bitmaptexture maps / vrmeshes
			for i in sceneMaterials where superClassOf i == material do --do not deal with maps in the scene, such as VRaySky
				getMatRecursive i
			for i in matArray do
				getMapRecursive i
			for i in geometry where classOf i == VRayProxy do
			(
				if not(doesFileExist i.fileName) and i.fileName != "" and findItem vrmeshDumpArray i == 0 do
				(
					append vrmeshArray i
					InstanceMgr.GetInstances i &instances
					for j in instances do
						append vrmeshDumpArray j
				)
			)
			
			--try to fix missing maps
			progressStart "Loading maps" --progressBar
			countMapCurr = 1
			countMapAll = mapArray.count
			
			for i in mapArray do
			(
				longName = i.fileName
				cleanName = filenameFromPath longName
				isMissing = true --set to false to prevent redundant searching after the map has been found
				j = 1
				
				while isMissing and j <= dirArray.count do
				(
					if doesFileExist (dirArray[j]+cleanName) do
					(
						i.fileName = dirArray[j]+cleanName
						isMissing = false
					)
					j = j + 1
				)
				
				if isMissing do
					append missingMapArray longName
				
				progressUpdate ((countMapCurr as float)/(countMapAll as float)*100)
				countMapCurr += 1
			)
			progressEnd() --progressBar
			
			--try to fix missing vrmeshes
			progressStart "Loading vrmeshes"
			countVrmeshCurr = 1
			countVrmeshAll = vrmeshArray.count
			
			for i in vrmeshArray do
			(
				longName = i.fileName
				cleanName = filenameFromPath longName
				isMissing = true --set to false to prevent redundant searching after the map has been found
				j = 1
				
				while isMissing and j <= dirArray.count do
				(
					if doesFileExist (dirArray[j]+cleanName) do
					(
						i.fileName = dirArray[j]+cleanName
						isMissing = false
					)
					j = j + 1
				)
				
				if isMissing do
					append missingVrmeshArray longName
				
				progressUpdate ((countVrmeshCurr as float)/(countVrmeshAll as float)*100)
				countVrmeshCurr += 1
			)
			progressEnd()
			timeEnd = timeStamp()
			timeSpent = ((timeEnd - timeStart)/1000.0) as string
			
			--message after the work is done
			if missingMapArray.count == 0 then
				messageBox ("Time used: "+timeSpent+"s\nAll missing maps were fixed") title:"Done"
			else
			(
				strMap = ""
				for i in missingMapArray do
					strMap += i + "\n"
				messageBox ("Time used: "+timeSpent+"s\nMaps still missing:\n"+strMap) title:"Done"
			)
			if missingVrmeshArray.count == 0 then
				messageBox "All missing vrmeshes were fixed" title:"Done"
			else
			(
				strVrmesh = ""
				for i in missingVrmeshArray do
					strVrmesh += i + "\n"
				messageBox ("Vrmeshes still missing:\n"+strVrmesh) title:"Done"
			)
			dirArray = #()
			matArray = #()
			mapArray = #()
			missingMapArray = #()
			missingVrmeshArray = #()
			btn1.enabled = true
		)
	)
	on btn2 pressed do
	(
		/* bad dotnet file browser
		
		o = dotNetObject "System.Windows.Forms.FolderBrowserDialog"
		oResult = o.ShowDialog()
		
		if oResult.ToString() == "OK" do
		(
			if matchPattern o.SelectedPath pattern:"*\\" then
			(
				append listArray o.SelectedPath --note "FolderBrowserDialog" returns no "\" at the end, except for "v:\", "d:\", etc
				lb1.items = listArray
			)
			else
			(
				append listArray (o.SelectedPath+"\\") --note "FolderBrowserDialog" returns no "\" at the end, except for "v:\", "d:\", etc
				lb1.items = listArray
			)
		)
		
		*/
		
		oResult = getSavePath caption:"Select the work path" initialDir:"V:"
		if oResult != undefined do
		(
			if matchPattern oResult pattern:"*\\" then
			(
				append listArray oResult
				lb1.items = listArray
			)
			else
			(
				append listArray (oResult+"\\")
				lb1.items = listArray
			)
		)
	)
	on btn3 pressed do
	(
		if listArray.count > 0 and lb1.selection > 0 do
		(
			deleteItem listArray lb1.selection
			lb1.items = listArray
		)
	)
)

rollout tbUtility "Utility"
(
	spinner sp1 "Render width: " range:[0,20000,renderWidth] align:#left type:#integer width:150 offset:[-5,0] across:2
	button btn1 "Overscan" offset:[25,-3]
	button btn2 "Get Material" across:3 offset:[-4,0]
	button btn3 "Purge Scene" offset:[8,0]
	button btn4 "Select N" offset:[10,0]
	edittext et1 text:"i.material==undefined" width:130 across:2 offset:[-10,2]
	dropdownlist ddl1 items:selectArray width:85 align:#right offset:[10,0]
	
	--overscan, increase/decrease render area while preserving perspective
	on btn1 pressed do
	(
		cam = getActiveCamera()
		if cam != undefined then
		(
			renderSceneDialog.close()
			local aw_h = getRendApertureWidth() * 0.5
			local old_f = aw_h / (tan(cam.fov*0.5))
			local new_f = old_f * (renderWidth/(sp1.value as float))
			cam.fov = 2 * atan (aw_h / new_f)
			renderWidth = sp1.value
		)
		else
			messageBox "Active viewport is not a camera viewport" title:"Error"
	)
	--get material to the active material slot from the first object in the selection
	on btn2 pressed do
	(
		if isValidSelection() do
		(
			--"selection" is always selection array; "$" is a single object when selecting only 1 object
			temp = selection[1].material
			if temp == undefined then
				messageBox "Object does not have material" title:"Empty Material"
			else
			(
				for i in meditMaterials where i==temp do
					meditMaterials[findItem meditMaterials i] = standard()
				meditMaterials[activeMeditSlot] = temp
			)
		)
	)
	--delete empty layers and clean scene
	on btn3 pressed do
	(
		emptyLayer = #()
		
		for i = 0 to layerManager.count-1 do
		(
			layer = LayerManager.getLayer i
			layerName = layer.name
			layerRT = layer.layerAsRefTarg
			nodeTemp = refs.dependentNodes layerRT
			--layerRT.Nodes &nodeTemp
			if nodeTemp.count == 0 and not(layer.current) do
				append emptyLayer layerName
		)
		
		if emptyLayer.count != 0 do
			for i in emptyLayer do
				layerManager.deleteLayerByName i
			
		usePreRendScript = false
		preRendScript = ""
		usePostRendScript = false
		postRendScript = ""
		
		useEnvironmentMap = false
		
		hideByCategory.geometry = false
		hideByCategory.shapes = false
		hideByCategory.lights = true
		hideByCategory.cameras = true
		hideByCategory.helpers = true
		hideByCategory.spacewarps = true
		hideByCategory.particles = true
		hideByCategory.bones = true
		displayColor.wireframe = #object
		displayColor.shaded = #object
		
		reactor.clearStoredCollisions()
	)
	--select by certain attributes
	on btn4 pressed do
	(
		if isValidSelection() do
		(
			str = "toSelect = #(); for i in $ where " + et1.text + " and not(isGroupHead i) do append toSelect i; clearSelection(); select toSelect; if toSelect.count == 0 do messageBox \"Nothing selected\" title:errorTitle"
			execute str
		)
	)
	on ddl1 selected arg do
		et1.text = ddl1.selected
)

rollout tbHelp "Help"
(
	label lbl1 "1. Material and color" align:#left
	label lbl1a "-objects in same group have same color" align:#left
	label lbl2 "2. Rename and unique name" align:#left
	label lbl2a "-only objects in opened group / outside" align:#left
	label lbl3 "3. Vray renderer setting - Low / Medium" align:#left
	label lbl3a "-V_Ray_Adv_1_50_SP6" align:#left
	label lbl4 "4. Channel setting" align:#left
	label lbl5 "5. Lock and unlock transform" align:#left
	label lbl6 "6. Random select objects" align:#left
	label lbl7 "7. Random transform objects" align:#left
	label lbl8 "8. Paint objects" align:#left
	label lbl8a "-work best if ground is editable mesh" align:#left
	label lbl9 "9. Object / glass / shadow pass" align:#left
	label lbl10 "10. Relink missing maps" align:#left
	label lbl11 "11. Other utilities" align:#left height:25
	label lbl97 "\"Undo\" is available for all operations" align:#left
	label lbl98 "-either by \"ctrl-z\" or by \"Restore\"" align:#left  height:25
	label lbl99 "Updated Dec 31, 2014 Xiao Qin" align:#left across:2
	button btn1 "Close" offset:[35,-3]
	
	on btn1 pressed do
		closeRolloutFloater tbFloater
)

---------------------------------------------------------------------------------------------------------
--rollout floater definition
---------------------------------------------------------------------------------------------------------
tbFloater = newRolloutFloater "TOOLBOX" 240 875
addRollout tbMat tbFloater
addRollout tbRename tbFloater
addRollout tbVRay tbFloater
addRollout tbChannel tbFloater
addRollout tbTransform tbFloater
addRollout tbRandomSelection tbFloater
addRollout tbRandomTransform tbFloater
addRollout tbPaint tbFloater
addRollout tbPass tbFloater
addRollout tbRelink tbFloater
addRollout tbUtility tbFloater
addRollout tbHelp tbFloater rolledUp:true