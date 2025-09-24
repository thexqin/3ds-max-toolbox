---------------------------------------------------------------------------------------------------------
--global variable
---------------------------------------------------------------------------------------------------------
try (closeRolloutFloater vrayMtlFloater) catch ()
global vrayMtlFloater
global matsArray			= #() --to differentiate 'matArray' and 'mapArray' in the main Toolbox script, in case they are used simultaneously
global mapsArray		= #()
global matPropsArray1	= #("i.reflection_glossiness==1.0","i.reflection_subdivs==8","i.reflection_maxDepth==5","i.reflection_useInterpolation==off","i.refraction_glossiness==1.0","i.refraction_subdivs==8","i.refraction_maxDepth==5","i.refraction_useInterpolation==off")
global matPropsArray2	= #("i.multiplier==1.0","i.directLight_on==off")
global matPropsArray3	= #("i.prepass_rate==-2")
global mapPropsArray	= #("i.coords.blur==0.1","i.filtering==0","i.fileName==undefined or not(doesFileExist i.fileName)")

rollout tbMtl "Vray Material Setting"
(
	group "Material"
	(
		edittext et1 text:"i.reflection_subdivs==8"
		radiobuttons rb1 labels:#("VrayMtl","VrayLightMtl","VrayFastSSS(2)") across:2
		dropdownlist ddl1 items:matPropsArray1 width:105
		button btn1 "Set all" across:2
		button btn2 "Get to slots"
	)
	
	group "Map"
	(
		edittext et2 text:"i.coords.blur==0.1" width:130 across:2 offset:[-10,2]
		dropdownlist ddl2 items:mapPropsArray width:85 align:#right offset:[10,0]
		button btn3 "Set all" across:2
		button btn4 "Get to slots"
	)
	
	fn getMatRecursive mat isAll:false =
	(
		if mat != undefined do
		(
			count = getNumSubMtls mat
		
			if count > 0 then --multi/sub-object, vrayblend, composit, etc
				for i = 1 to count do
					getMatRecursive (getSubMtl mat i)
			else --single material
			(
				if isAll then
					append matsArray mat --put all materials into matsArray
				else
					case rb1.state of
					(
						1: if classOf mat == VRayMtl do append matsArray mat --put vray materials into matsArray
						2: if classOf mat == VrayLightMtl do append matsArray mat
						3: if classOf mat == VrayFastSSS or classOf mat == VrayFastSSS2 do append matsArray mat
					)
			)
		)
	)
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
						append mapsArray submap --put all bitmaps into mapsArray
					else
						getMapRecursive submap
				)
		)
	)
	fn updateMatParam paramStr =
	(
		for i in sceneMaterials where superClassOf i == material do --do not deal with maps in the scene, such as VRaySky
			getMatRecursive i
		/* for i in matsArray do
			getMapRecursive i */
		
		safeParamStr = substituteString paramStr "==" "="
		strMat = "for i in matsArray do " + safeParamStr
		try (execute strMat) catch (messageBox "Please check expression" title:"Error")

		matsArray = #()
		mapsArray = #()
	)
	fn checkMatParam paramStr =
	(
		for i in sceneMaterials where superClassOf i == material do --do not deal with maps in the scene, such as VRaySky
			getMatRecursive i
		/* for i in matsArray do
			getMapRecursive i */
		
		strMat = "countMat = 1; for i in matsArray do ( if " + paramStr + " and countMat <= 24 do ( meditMaterials[countMat]=i; countMat += 1; ) ); countMat = 0;"
		try (execute strMat) catch (messageBox "Please check expression" title:"Error")

		matsArray = #()
		mapsArray = #()
	)
	fn updateMapParam paramStr =
	(
		for i in sceneMaterials where superClassOf i == material do --do not deal with maps in the scene, such as VRaySky
			getMatRecursive i isAll:true
		for i in matsArray do
			getMapRecursive i
		
		safeParamStr = substituteString paramStr "==" "="
		strMap = "for i in mapsArray do " + safeParamStr
		try (execute strMap) catch (messageBox "Please check expression" title:"Error")

		matsArray = #()
		mapsArray = #()
	)
	fn checkMapParam paramStr =
	(
		for i in sceneMaterials where superClassOf i == material do --do not deal with maps in the scene, such as VRaySky
			getMatRecursive i isAll:true
		for i in matsArray do
			getMapRecursive i
		
		strMap = "countMap = 1; for i in mapsArray do ( if " + paramStr + " and countMap <= 24 do ( meditMaterials[countMap]=i; countMap += 1; ) ); countMap = 0;"
		try (execute strMap) catch (messageBox "Please check expression" title:"Error")

		matsArray = #()
		mapsArray = #()
	)
	fn clearMatSlots =
	(
		for i = 1 to 24 do
		(
			meditMaterials[i] = VrayMtl()
			meditMaterials[i].name = ("VrayMtl" + i as string)
		)
	)
	
	on rb1 changed arg do
	(
		case arg of
		(
			1: ( ddl1.items = matPropsArray1; ddl1.selection = 1; et1.text = matPropsArray1[1] )
			2: ( ddl1.items = matPropsArray2; ddl1.selection = 1; et1.text = matPropsArray2[1] )
			3: ( ddl1.items = matPropsArray3; ddl1.selection = 1; et1.text = matPropsArray3[1] )
		)
	)
	
	on ddl1 selected arg do
		et1.text = ddl1.selected
	
	on btn1 pressed do
		updateMatParam et1.text
	
	on btn2 pressed do
		if queryBox "Are you sure to reset material editor slots?" do
		(
			clearMatSlots()
			checkMatParam et1.text
		)
		
	on ddl2 selected arg do
		et2.text = ddl2.selected
	
	on btn3 pressed do
		updateMapParam et2.text
	
	on btn4 pressed do
		if queryBox "Are you sure to reset material editor slots?" do
		(
			clearMatSlots()
			checkMapParam et2.text
		)
)

---------------------------------------------------------------------------------------------------------
--rollout floater definition
---------------------------------------------------------------------------------------------------------
vrayMtlFloater = newRolloutFloater "TOOLBOX VRAY MATERIAL" 240 240
addRollout tbMtl vrayMtlFloater