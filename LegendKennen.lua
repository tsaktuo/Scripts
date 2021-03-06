if not VIP_USER or myHero.charName ~= "Kennen" then return end
local SCRIPT_INFO = {
	["Name"] = "LegendKennen",
	["Version"] = 0.005,
	["Author"] = {
		["Turtlebot"] = "http://botoflegends.com/forum/user/18902-"
	},
	["Credits"] = {
		["Pain"] = "http://botoflegends.com/forum/user/2005-"
		},		
}
local SCRIPT_UPDATER = {
	["Activate"] = true,
	["Script"] = SCRIPT_PATH..GetCurrentEnv().FILE_NAME,
	["URL_HOST"] = "raw.github.com",
	["URL_PATH"] = "/LegendBot/Scripts/master/LegendKennen.lua",
	["URL_VERSION"] = "/LegendBot/Scripts/master/Versions/LegendKennen.version"
}
local SCRIPT_LIBS = {
	["SourceLib"] = "https://raw.github.com/LegendBot/Scripts/master/Common/SourceLib.lua",
	["Selector"] = "https://raw.github.com/LegendBot/Scripts/master/Common/Selector.lua",
	["VPrediction"] = "https://raw.github.com/LegendBot/Scripts/master/Common/VPrediction.lua",
	["SOW"] = "https://raw.github.com/LegendBot/Scripts/master/Common/SOW.lua"
}

function PrintMessage(message) 
	print("<font color=\"#00A300\"><b>"..SCRIPT_INFO["Name"]..":</b></font> <font color=\"#FFFFFF\">"..message.."</font>")
end
--{ Initiate Script (Checks for updates)
	function Initiate()
		for LIBRARY, LIBRARY_URL in pairs(SCRIPT_LIBS) do
			if FileExist(LIB_PATH..LIBRARY..".lua") then
				require(LIBRARY)
			else
				DOWNLOADING_LIBS = true
				PrintMessage("Missing Library! Downloading "..LIBRARY..". If the library doesn't download, please download it manually.")
				DownloadFile(LIBRARY_URL,LIB_PATH..LIBRARY..".lua",function() PrintMessage("Successfully downloaded "..LIBRARY) end)
			end
		end
		if DOWNLOADING_LIBS then return true end
		if SCRIPT_UPDATER["Activate"] then
			SourceUpdater("<font color=\"#00A300\">"..SCRIPT_INFO["Name"].."</font>", SCRIPT_INFO["Version"], SCRIPT_UPDATER["URL_HOST"], SCRIPT_UPDATER["URL_PATH"], SCRIPT_UPDATER["Script"], SCRIPT_UPDATER["URL_VERSION"]):CheckUpdate()
		end
	end
	if Initiate() then return end
	PrintMessage("Loaded")
--}
--{ Initiate Data Load
	local Kennen = {
		Q = {range = 950, speed = 1700, delay = 0.7, width = 50, collision = true, DamageType = _MAGIC, BaseDamage = 55, DamagePerLevel = 40, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = 0.75, Extra = function() return (myHero:CanUseSpell(_Q) == READY) end},
		W = {range = 900, speed = math.huge, delay = 0.5, DamageType = _MAGIC, BaseDamage = 65, DamagePerLevel = 30, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = 0.55, Extra = function() return (myHero:CanUseSpell(_W) == READY) end},
		E = {range = myHero.range + 50, DamageType = _MAGIC, BaseDamage = 85, DamagePerLevel = 40, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = 0.6, Extra = function() return (myHero:CanUseSpell(_E) == READY) end},
		R = {range = 550, speed = math.huge, delay = 0.5, collision = false, DamageType = _MAGIC, BaseDamage = 80, DamagePerLevel = 65, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = .4, Extra = function() return (myHero:CanUseSpell(_R) == READY) end}
	}
--}
--{ Script Load
	function OnLoad()
		--{ Variables
		    IsMarked = false
		    EActive = false
			VP = VPrediction(true)
			OW = SOW(VP)
			OW:RegisterAfterAttackCallback(AutoAttackReset)
			TS = SimpleTS(STS_LESS_CAST_MAGIC)
			Selector.Instance()
			SpellQ = Spell(_Q, Kennen.Q["range"]):SetSkillshot(VP, SKILLSHOT_LINEAR, Kennen.Q["width"], Kennen.Q["delay"], Kennen.Q["speed"], Kennen.Q["collision"])
			SpellW = Spell(_W, Kennen.W["range"])
			SpellE = Spell(_E, Kennen.E["range"])
			SpellR = Spell(_R, Kennen.R["range"])
			EnemyMinions = minionManager(MINION_ENEMY, Kennen.Q["range"], myHero, MINION_SORT_MAXHEALTH_DEC)
		--}
		--{ DamageCalculator
			DamageCalculator = DamageLib()
			DamageCalculator:RegisterDamageSource(_Q, Kennen.Q["DamageType"], Kennen.Q["BaseDamage"], Kennen.Q["DamagePerLevel"], Kennen.Q["ScalingStat"], Kennen.Q["PercentScaling"], Kennen.Q["Condition"], Kennen.Q["Extra"])
			DamageCalculator:RegisterDamageSource(_W, Kennen.W["DamageType"], Kennen.W["BaseDamage"], Kennen.W["DamagePerLevel"], Kennen.W["ScalingStat"], Kennen.W["PercentScaling"], Kennen.W["Condition"], Kennen.W["Extra"])
			DamageCalculator:RegisterDamageSource(_E, Kennen.E["DamageType"], Kennen.E["BaseDamage"], Kennen.E["DamagePerLevel"], Kennen.E["ScalingStat"], Kennen.E["PercentScaling"], Kennen.E["Condition"], Kennen.E["Extra"])
			DamageCalculator:RegisterDamageSource(_R, Kennen.R["DamageType"], Kennen.R["BaseDamage"], Kennen.R["DamagePerLevel"], Kennen.R["ScalingStat"], Kennen.R["PercentScaling"], Kennen.R["Condition"], Kennen.R["Extra"])
		--}
		--{ Initiate Menu
			Menu = scriptConfig("Kennen","LegendKennen")
			Menu:addParam("Author","Author: Turtle",5,"")
			Menu:addParam("Version","Version: "..SCRIPT_INFO["Version"],5,"")
			--{ General/Key Bindings
				Menu:addSubMenu("Kennen: General","General")
				Menu.General:addParam("Combo","Combo",2,false,32)
				Menu.General:addParam("Harass","Harass",2,false,string.byte("C"))
				Menu.General:addParam("LastHit","Last Hit Creeps",2,false,string.byte("X"))
			--}
			--{ Target Selector			
				Menu:addSubMenu("Kennen: Target Selector","TS")
				Menu.TS:addParam("TS","Target Selector",7,2,{ "AllClass", "SourceLib", "Selector (Disabled)", "SAC:Reborn", "MMA" })
				ts = TargetSelector(8,Kennen.R["range"],1,false)
				ts.name = "AllClass TS"
				Menu.TS:addTS(ts)				
			--}
			--{ Orbwalking
				Menu:addSubMenu("Kennen: Orbwalking","Orbwalking")
				OW:LoadToMenu(Menu.Orbwalking)
				Menu.Orbwalking.Mode0 = false
			--}
			--{	Combo Settings
				Menu:addSubMenu("Kennen: Combo","Combo")
				Menu.Combo:addParam("Q","Use Q in 'Combo'",1,true)
				Menu.Combo:addParam("W","Use W in 'Combo'",1,true)
				Menu.Combo:addParam("E","Use E in 'Combo'",1,true)
				Menu.Combo:addParam("R","Use R in 'Combo'",1,true)
			--}
			--{ Harass Settings
				Menu:addSubMenu("Kennen: Harass","Harass")
				Menu.Harass:addParam("Q","Use Q in 'Harass'",1,true)
				Menu.Harass:addParam("W","Use W in 'Harass'",1,true)
				Menu.Harass:addParam("E","Use E in 'Harass'",1,false)
			--}
			--{ Farm Settings
				Menu:addSubMenu("Kennen: Farm","Farm")
				Menu.Farm:addParam("Energy","Minimum Energy Percentage",4,70,0,100,0)
				Menu.Farm:addParam("Q","Use Q in 'Farm'",1,true)
			--}
			--{ Extra Settings
				Menu:addSubMenu("Kennen: Extra","Extra")
				Menu.Extra:addParam("Tick","Tick Suppressor (Tick Delay)",4,20,1,50,0)
				Menu.Extra:addParam("RCount","Enemies in range to Ulti",7,2,{"One Enemy","Two Enemies","Three Enemies","Four Enemies","Five Enemies"})
			--}
			--{ Draw Settings
				Menu:addSubMenu("Kennen: Draw","Draw")
				DrawHandler = DrawManager()
				DrawHandler:CreateCircle(myHero,Kennen.Q["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "Q Range", true, true, true):LinkWithSpell(SpellQ, true)
				DrawHandler:CreateCircle(myHero,Kennen.W["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "W Range", true, true, true):LinkWithSpell(SpellW, true)
				DrawHandler:CreateCircle(myHero,Kennen.E["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "E Range", true, true, true):LinkWithSpell(SpellE, true)
				DrawHandler:CreateCircle(myHero,Kennen.R["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "R Range", true, true, true):LinkWithSpell(SpellR, true)
				DamageCalculator:AddToMenu(Menu.Draw,{_Q,_W,_E,_R,_AA})
			--}
						--{ Perma Show Settings
				Menu:addSubMenu("Kennen: Perma Show","Perma")
				Menu.Perma:addParam("INFO","The following options require a restart [F9 x2] to take effect",5,"")
				Menu.Perma:addParam("GC","Perma Show 'General > Combo'",1,true)				
				Menu.Perma:addParam("GF","Perma Show 'General > Farm'",1,true)
				Menu.Perma:addParam("GH","Perma Show 'General > Harass'",1,true)
				if Menu.Perma.GC then Menu.General:permaShow("Combo") end
				if Menu.Perma.GF then Menu.General:permaShow("LastHit") end
				if Menu.Perma.GH then Menu.General:permaShow("Harass") end
				Menu.Perma:addParam("CQ","Perma Show 'Combo > Q'",1,false)
				Menu.Perma:addParam("CW","Perma Show 'Combo > W'",1,false)
				Menu.Perma:addParam("CE","Perma Show 'Combo > E'",1,false)
				Menu.Perma:addParam("CR","Perma Show 'Combo > R'",1,false)
				if Menu.Perma.CQ then Menu.Combo:permaShow("Q") end
				if Menu.Perma.CW then Menu.Combo:permaShow("W") end
				if Menu.Perma.CE then Menu.Combo:permaShow("E") end
				if Menu.Perma.CR then Menu.Combo:permaShow("R") end
				Menu.Perma:addParam("HQ","Perma Show 'Harass > Q'",1,false)
				Menu.Perma:addParam("HW","Perma Show 'Harass > W'",1,false)
				Menu.Perma:addParam("HE","Perma Show 'Harass > E'",1,false)
				Menu.Perma:addParam("HR","Perma Show 'Harass > R'",1,false)
				if Menu.Perma.HQ then Menu.Harass:permaShow("Q") end
				if Menu.Perma.HW then Menu.Harass:permaShow("W") end
				if Menu.Perma.HE then Menu.Harass:permaShow("E") end
				if Menu.Perma.HR then Menu.Harass:permaShow("R") end
				Menu.Perma:addParam("FQ","Perma Show 'Farm > Q'",1,false)
				if Menu.Perma.FQ then Menu.Farm:permaShow("Q") end
				Menu.Perma:addParam("ET","Perma Show 'Extra > Tick Delay'",1,false)
				Menu.Perma:addParam("ER","Perma Show 'Extra > R Count'",1,false)
				if Menu.Perma.ET then Menu.Extra:permaShow("Tick") end
				if Menu.Perma.ER then Menu.Extra:permaShow("RCount") end
			--}
		--}
	end
--}
--{ Script Loop
	function OnTick()
		--{ Tick Manager
			if GetTickCount() < (TickSuppressor or 0) then return end
			TickSuppressor = GetTickCount() + Menu.Extra.Tick
		--}
		--{ Variables
			QMANA = GetSpellData(_Q).mana
			WMANA = GetSpellData(_W).mana
			EMANA = GetSpellData(_E).mana
			RMANA = GetSpellData(_R).mana
			Farm = Menu.General.LastHit and Menu.Farm.Energy <= myHero.mana / myHero.maxMana * 100
			Combat = Menu.General.Combo or Menu.General.Harass
			QREADY = (SpellQ:IsReady() and ((Menu.General.Combo and Menu.Combo.Q) or (Menu.General.Harass and Menu.Harass.Q) or (Farm and Menu.Farm.Q) ))
			WREADY = IsMarked and (SpellW:IsReady() and ((Menu.General.Combo and Menu.Combo.W) or (Menu.General.Harass and Menu.Harass.W) or (Farm and Menu.Farm.W) ))
			EREADY = not EActive and (SpellE:IsReady() and ((Menu.General.Combo and Menu.Combo.E) or (Menu.General.Harass and Menu.Harass.E) or (Farm and Menu.Farm.E) ))
			RREADY = (SpellR:IsReady() and ((Menu.General.Combo and Menu.Combo.R) ) and Menu.Extra.RCount <= CountEnemyHeroInRange(Kennen.R["range"], myHero))
			Target = GrabTarget()
		--}	
		--{ Combo and Harass
		
			if Combat and Target then				
				if DamageCalculator:IsKillable(Target,{_Q,_E,_W,_R,_AA}) then
					if DamageCalculator:IsKillable(Target,{_Q}) and QREADY then
						SpellQ:Cast(Target) 
					elseif DamageCalculator:IsKillable(Target,{_Q,_W}) and QREADY and WREADY then
						SpellQ:Cast(Target) 
						SpellW:Cast(Target)
						--
					elseif DamageCalculator:IsKillable(Target,{_Q,_W,_E}) and QREADY and WREADY and EREADY then
				    	SpellQ:Cast(Target) 
					    SpellW:Cast(Target)
						SpellE:Cast(Target)
						--
					elseif DamageCalculator:IsKillable(Target,{_Q,_W,_E,_R}) and QREADY and WREADY and RREADY then
				    	SpellQ:Cast(Target) 
					    SpellW:Cast(Target)
					    SpellE:Cast(Target)
						SpellR:Cast(Target)
					else
						if QREADY then
							SpellQ:Cast(Target) 
						end
						if WREADY then
							SpellW:Cast(Target)
						end
						if EREADY then
							SpellE:Cast(Target)
						end
						if RREADY then
							SpellR:Cast(Target)
						end
					end
				else
					if QREADY then
						SpellQ:Cast(Target) 
					end
					if WREADY then
						SpellW:Cast(Target)
					end
					if EREADY then
						SpellE:Cast(Target)
					end
					if RREADY then
						SpellR:Cast(Target)
					end
				end
				if Menu.Orbwalking.Enabled and (Menu.Orbwalking.Mode0 or Menu.Orbwalking.Mode1) then
					OW:ForceTarget(Target)
				end
			end
		--}
		--{ Farming
			if Farm then
				EnemyMinions:update()
				for i, Minion in pairs(EnemyMinions.objects) do
					if ValidTarget(Minion) then
						if QREADY and DamageCalculator:IsKillable(Minion,{_Q}) then
							SpellQ:Cast(Minion)
						end
					end
				end
			end
		--}
	end
--}

--{ Target Selector
	function GrabTarget()
		if _G.MMA_Loaded and Menu.TS.TS == 5 then
			return _G.MMA_ConsideredTarget(MaxRange()) 
		elseif _G.AutoCarry and Menu.TS.TS == 4 then
			return _G.AutoCarry.Crosshair:GetTarget()
		elseif _G.Selector_Enabled and Menu.TS.TS == 3 then
			return Selector.GetTarget(SelectorMenu.Get().mode, 'AP', {distance = MaxRange()})
		elseif Menu.TS.TS == 2 then
			return TS:GetTarget(MaxRange())
		elseif Menu.TS.TS == 1 then
			ts.range = MaxRange()
			ts:update()
			return ts.target
		end
	end
--}
--{ Target Selector Range
	function MaxRange()
		if QREADY then
			return Kennen.Q["range"]
		end
		if WREADY then
			return Kennen.W["range"]
		end
		if RREADY then
			return Kennen.R["range"]
		end
		
		if EREADY then
			return Kennen.E["range"]
		end		
		return myHero.range + 50
	end
--}
--{ Buff Manager
    function OnGainBuff(unit,buff)
        -- Lightning Rush active
        if unit.isMe and buff.name == "KennenLightningRush" 
        then EActive = true 
            DelayAction(function() EActive = false end, 2) end
        -- Mark gained
       	for i = 1, heroManager.iCount do
       		local hero = heroManager:GetHero(i)
       		if ValidTarget(hero) and GetDistance(myHero,hero) <= Kennen.Q["range"] then
       			if unit == hero and buff.name == "kennenmarkofstorm" then 
       				IsMarked = true
       				break
       			end
       		end
       	end
    end
    function OnLoseBuff(unit,buff)
        -- Lightning Rush ended
        if unit.isMe and buff.name == "KennenLightningRush" then EActive = false end
        -- Mark lost
        for i = 1, heroManager.iCount do
       		local hero = heroManager:GetHero(i)
   			if unit == hero and buff.name == "kennenmarkofstorm" then 
   				IsMarked = false
   				break
       		end
       	end
    end
--}
