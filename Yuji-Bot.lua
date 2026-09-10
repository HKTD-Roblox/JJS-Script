local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = {
	targeting = {
		maxDist = 360,
		retargetDist = 32,
		teamCheck = true,
		targetNPCs = true,
		priorityHealth = true,
		updateRate = 0.09,
		predictive = true,
		predictionTime = 0.33,
		switchOnLowHP = true,
		lowHPSwitchThreshold = 22,
	},
	combat = {
		attackRange = 7.5,
		minRange = 1.95,
		optimalMin = 3.0,
		optimalMax = 7.3,
		m1Delay = 0.155,
		m1BreakDelay = 0.138,
		behindOffset = 1.45,
		blackFlashRepeat = 3,
		blackFlashGap = 0.28,
		ghostChance = 0.29,
		pressureChance = 0.33,
		retimerChance = 0.44,
		sideDashAttackChance = 0.38,
		sideDashAttackRange = 21.5,
		sideDashAttackCD = 1.12,
		tightComboChance = 0.55,
		interruptedChance = 0.42,
		comboResetTime = 1.65,
		maxM1InString = 3,
		comboRoutes = 5,
	},
	movement = {
		dashCD = 0.62,
		sideDashCD = 0.66,
		baitCD = 1.02,
		microWSInterval = 0.09,
		diagonalChance = 0.63,
		obstacleCheck = 8.5,
		jumpDelay = 0.105,
		rotationSpeed = 0.48,
		lerpSpeed = 0.37,
		zigzagAmplitude = 0.35,
		strafeSpeed = 0.28,
	},
	defense = {
		blockRange = 17.0,
		blockMin = 0.14,
		blockMax = 0.55,
		blockCD = 0.28,
		counterRange = 16.0,
		lowHPThreshold = 33,
		escapeHP = 24,
		blockBreakRange = 15.0,
		blockBreakCD = 1.1,
		perfectBlockWindow = 0.18,
		holdBlockUntilClear = true,
	},
	ragdoll = {
		escapeCD = 0.32,
		jumpChance = 0.42,
		diagonalChance = 0.55,
		randomAngle = true,
		doubleDashChance = 0.28,
	},
	skills = {
		globalCD = 0.68,
		rCD = 1.95,
		[1] = {name = "DivergentFist", cd = 1.80, last = 0, key = Enum.KeyCode.One},
		[2] = {name = "CrushingBlow", cd = 2.20, last = 0, key = Enum.KeyCode.Two},
		[3] = {name = "BlackFlash", cd = 1.60, last = 0, key = Enum.KeyCode.Three},
		[4] = {name = "ManjiKick", cd = 3.20, last = 0, key = Enum.KeyCode.Four},
	},
	perf = {
		baseM1Delay = 0.155,
		pingFactorMin = 0.80,
		pingFactorMax = 1.25,
		fpsLowThreshold = 35,
		fpsSafeThreshold = 50,
	},
}

local STATE = {
	active = false,
	target = {
		root = nil, hum = nil, name = "", dist = 999, lastSeen = 0,
		vel = Vector3.zero, isStunned = false, isBlocking = false,
		isAttacking = false, isSkill = false, predicted = Vector3.zero,
		lastHP = 100, threatLevel = 0, attackEndTime = 0,
	},
	player = {
		root = nil, hum = nil, char = nil, hp = 100, maxhp = 100,
		pos = Vector3.zero, vel = Vector3.zero, isRagdoll = false,
		lastHP = 100,
	},
	input = {
		W = false, A = false, S = false, D = false,
		F = false, Space = false, Q = false, R = false,
	},
	combat = {
		lock = false, comboActive = false, m1Count = 0, lastM1 = 0,
		bfCount = 0, bfActive = false, behindMode = false, lastBehind = 0,
		punishReady = false, ghostReady = false, pressureMode = false,
		lastR = 0, skillWindup = false, currentSkill = 0,
		sideDashAttacking = false, lastSideDashAttack = 0,
		comboRoute = 0, lastComboRoute = 0, lastComboEnd = 0,
		stringCount = 0, lastStringReset = 0,
	},
	defense = {
		blocking = false, blockStart = 0, blockEnd = 0,
		countering = false, lastCounter = 0,
		escaping = false, lastEscape = 0,
		lastBlockBreak = 0, perfectBlock = false,
		holdingBlock = false, lastEnemyAttack = 0,
	},
	move = {
		lastDash = 0, lastSide = 0, lastBait = 0, lastJump = 0,
		microClock = 0, strafeDir = 1, mode = "neutral",
		zigzagClock = 0, zigzagNext = 0.38, lastStrafeSwitch = 0,
		lastRagdollEscape = 0,
	},
	skills = {globalLast = 0, inProgress = false, rLast = 0},
	stats = {
		m1 = 0, skills = 0, s1 = 0, s2 = 0, s3 = 0, s4 = 0, rCancel = 0,
		blocks = 0, counters = 0, breaks = 0, punishes = 0, bfCombos = 0,
		escapes = 0, baits = 0, ghost = 0, pressure = 0,
		sideDashAtk = 0, ragdollEsc = 0, perfectBlocks = 0, startTime = 0,
		combo1 = 0, combo2 = 0, combo3 = 0, combo4 = 0, combo5 = 0,
	},
	cache = {lastScan = 0, nearby = 0, lastPingUpdate = 0, lastThreatUpdate = 0},
	perf = {dt = 0.016, fps = 60, ping = 50, m1Delay = 0.155, safeMode = false},
}

local function sendKey(down, key)
	pcall(function()
		VIM:SendKeyEvent(down, key, false, game)
	end)
end

local function sendClick(down)
	pcall(function()
		VIM:SendMouseButtonEvent(0, 0, 0, down, game, 1)
	end)
end

local function press(key, flag)
	if not STATE.input[flag] then
		sendKey(true, key)
		STATE.input[flag] = true
	end
end

local function release(key, flag)
	if STATE.input[flag] then
		sendKey(false, key)
		STATE.input[flag] = false
	end
end

local function releaseAll()
	release(Enum.KeyCode.W, "W")
	release(Enum.KeyCode.A, "A")
	release(Enum.KeyCode.S, "S")
	release(Enum.KeyCode.D, "D")
	release(Enum.KeyCode.F, "F")
	release(Enum.KeyCode.Space, "Space")
	release(Enum.KeyCode.Q, "Q")
	release(Enum.KeyCode.R, "R")
	STATE.combat.lock = false
	STATE.combat.comboActive = false
	STATE.combat.bfActive = false
	STATE.combat.behindMode = false
	STATE.combat.pressureMode = false
	STATE.combat.skillWindup = false
	STATE.combat.currentSkill = 0
	STATE.combat.sideDashAttacking = false
	STATE.defense.blocking = false
	STATE.defense.holdingBlock = false
	STATE.defense.countering = false
	STATE.defense.escaping = false
	STATE.move.mode = "neutral"
end

local function getRoot()
	if STATE.player.char then
		local r = STATE.player.char:FindFirstChild("HumanoidRootPart")
		if r then return r end
	end
	local c = LP.Character
	if c then
		STATE.player.char = c
		return c:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function getHum()
	if STATE.player.char then
		local h = STATE.player.char:FindFirstChildOfClass("Humanoid")
		if h then return h end
	end
	local c = LP.Character
	if c then
		STATE.player.char = c
		return c:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

local function clamp(v, a, b)
	return math.max(a, math.min(b, v))
end

local function randomFloat(a, b)
	return a + math.random() * (b - a)
end

local function updatePingAdaptive()
	local now = tick()
	if now - STATE.cache.lastPingUpdate < 0.45 then return end
	STATE.cache.lastPingUpdate = now
	local factor = clamp(STATE.perf.ping / 80, CFG.perf.pingFactorMin, CFG.perf.pingFactorMax)
	STATE.perf.m1Delay = CFG.perf.baseM1Delay * factor
	if STATE.perf.fps < CFG.perf.fpsLowThreshold then
		STATE.perf.safeMode = true
		STATE.perf.m1Delay = STATE.perf.m1Delay * 1.08
	elseif STATE.perf.fps > CFG.perf.fpsSafeThreshold then
		STATE.perf.safeMode = false
	end
end

local ANIM = {
	attack = {"attack", "swing", "punch", "slash", "m1", "hit", "strike", "combo", "jab", "smash", "uppercut", "kick", "beat", "pummel", "blow"},
	skill = {"skill", "technique", "curse", "domain", "special", "ability", "ultimate", "barrage", "blast", "power", "divergent", "crushing", "manji"},
	stun = {"stun", "hitstun", "stagger", "downed", "knockback", "launch", "ragdoll", "tumble", "hurt", "flinch", "fall", "airborne", "dizzy"},
	block = {"block", "guard", "parry", "deflect", "defend", "shield", "brace"},
	ragdoll = {"ragdoll", "stagger", "knockback", "launch", "tumble", "fall", "downed", "hitstun", "flung"},
}

local function matchAnim(hum, list)
	if not hum then return false end
	local ok, tracks = pcall(function() return hum:GetPlayingAnimationTracks() end)
	if not ok or not tracks then return false end
	for _, t in ipairs(tracks) do
		if t.IsPlaying and t.Animation then
			local id = (t.Animation.AnimationId or ""):lower()
			local nm = (t.Name or ""):lower()
			for _, p in ipairs(list) do
				if id:find(p, 1, true) or nm:find(p, 1, true) then
					return true
				end
			end
		end
	end
	return false
end

local function isAttacking(h) return matchAnim(h, ANIM.attack) end
local function isSkill(h) return matchAnim(h, ANIM.skill) end
local function isBlocking(h) return matchAnim(h, ANIM.block) end

local function isStunned(h, r)
	if matchAnim(h, ANIM.stun) or matchAnim(h, ANIM.ragdoll) then return true end
	if h and (h.PlatformStand or h.Sit) then return true end
	if r then
		local v = r.AssemblyLinearVelocity or Vector3.zero
		if Vector2.new(v.X, v.Z).Magnitude > 35 then return true end
		if math.abs(v.Y) > 35 then return true end
	end
	return false
end

local function isRagdoll(r, h)
	if not r or not h then return false end
	local v = r.AssemblyLinearVelocity or Vector3.zero
	if Vector2.new(v.X, v.Z).Magnitude > 35 then return true end
	if math.abs(v.Y) > 35 then return true end
	if h.PlatformStand or h.Sit then return true end
	return matchAnim(h, ANIM.ragdoll)
end

local function sameTeam(plr)
	if not CFG.targeting.teamCheck then return false end
	return LP.Team and plr.Team == LP.Team
end

local function validTarget(model, from)
	local h = model:FindFirstChildOfClass("Humanoid")
	local r = model:FindFirstChild("HumanoidRootPart")
	if not h or not r or h.Health <= 0 then return false end
	if model == LP.Character then return false end
	local p = Players:GetPlayerFromCharacter(model)
	if p and sameTeam(p) then return false end
	local d = (from - r.Position).Magnitude
	if d > CFG.targeting.maxDist then return false end
	return true, h, r, d
end

local function priority(h, r, d)
	local p = (CFG.targeting.maxDist - d) / CFG.targeting.maxDist * 100
	if CFG.targeting.priorityHealth then
		p = p + (1 - h.Health / h.MaxHealth) * 60
	end
	if isStunned(h, r) then p = p + 85 end
	if isBlocking(h) then p = p - 30 end
	if isSkill(h) then p = p + 25 end
	return p
end

local function scanTargets()
	local my = getRoot()
	if not my then return end
	local now = tick()
	if STATE.target.root and STATE.target.hum and STATE.target.hum.Health > 0 then
		local d = (my.Position - STATE.target.root.Position).Magnitude
		if d < CFG.targeting.retargetDist then
			if CFG.targeting.switchOnLowHP and STATE.target.hum.Health < CFG.targeting.lowHPSwitchThreshold then
			else
				STATE.target.dist = d
				STATE.target.lastSeen = now
				return
			end
		end
	end
	local bestP, best = -1e9, {root = nil, hum = nil, name = "", dist = 999}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local ok, h, r, d = validTarget(plr.Character, my.Position)
			if ok then
				local pr = priority(h, r, d)
				if pr > bestP then
					bestP = pr
					best = {root = r, hum = h, name = plr.Name, dist = d}
				end
			end
		end
	end
	if CFG.targeting.targetNPCs then
		for _, obj in ipairs(workspace:GetChildren()) do
			if not Players:GetPlayerFromCharacter(obj) then
				local ok, h, r, d = validTarget(obj, my.Position)
				if ok then
					local pr = priority(h, r, d)
					if pr > bestP then
						bestP = pr
						best = {root = r, hum = h, name = obj.Name or "NPC", dist = d}
					end
				end
			end
		end
	end
	if best.root then
		STATE.target.root = best.root
		STATE.target.hum = best.hum
		STATE.target.name = best.name
		STATE.target.dist = best.dist
		STATE.target.lastSeen = now
		STATE.target.lastHP = best.hum.Health
	else
		STATE.target.root = nil
		STATE.target.hum = nil
		STATE.target.name = ""
		STATE.target.dist = 999
	end
end

local function countNearby(radius)
	local my = getRoot()
	if not my then return 0 end
	local n = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local r = plr.Character:FindFirstChild("HumanoidRootPart")
			local h = plr.Character:FindFirstChildOfClass("Humanoid")
			if r and h and h.Health > 0 then
				if (my.Position - r.Position).Magnitude <= radius then
					n = n + 1
				end
			end
		end
	end
	return n
end

local function predictPos(root, t)
	if not root then return Vector3.zero end
	local v = root.AssemblyLinearVelocity or Vector3.zero
	return root.Position + v * (t or CFG.targeting.predictionTime)
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function obstacleFront(root, dist)
	if not root then return false end
	local ex = {}
	if LP.Character then table.insert(ex, LP.Character) end
	if STATE.target.root and STATE.target.root.Parent then table.insert(ex, STATE.target.root.Parent) end
	rayParams.FilterDescendantsInstances = ex
	local res = workspace:Raycast(root.Position, root.CFrame.LookVector * (dist or CFG.movement.obstacleCheck), rayParams)
	return res and res.Instance and res.Instance.CanCollide
end

local function canSkill(idx)
	if not idx or idx < 1 or idx > 4 then return false end
	local now = tick()
	local s = CFG.skills[idx]
	if not s then return false end
	if (now - s.last) < s.cd then return false end
	if (now - STATE.skills.globalLast) < CFG.skills.globalCD then return false end
	if STATE.skills.inProgress then return false end
	if STATE.perf.safeMode and idx == 1 then
		if (now - s.last) < (s.cd * 1.05) then return false end
	end
	return true
end

local function canR()
	return (tick() - STATE.skills.rLast) >= CFG.skills.rCD
end

local function castR()
	if not canR() then return false end
	sendKey(true, Enum.KeyCode.R)
	task.wait(0.026)
	sendKey(false, Enum.KeyCode.R)
	STATE.skills.rLast = tick()
	STATE.stats.rCancel = STATE.stats.rCancel + 1
	STATE.combat.skillWindup = false
	STATE.combat.currentSkill = 0
	return true
end

local function castSkill(idx)
	if not canSkill(idx) then return false end
	local s = CFG.skills[idx]
	STATE.skills.inProgress = true
	STATE.combat.skillWindup = true
	STATE.combat.currentSkill = idx
	sendKey(true, s.key)
	task.wait(0.07)
	sendKey(false, s.key)
	s.last = tick()
	STATE.skills.globalLast = tick()
	STATE.stats.skills = STATE.stats.skills + 1
	if idx == 1 then STATE.stats.s1 = STATE.stats.s1 + 1
	elseif idx == 2 then STATE.stats.s2 = STATE.stats.s2 + 1
	elseif idx == 3 then STATE.stats.s3 = STATE.stats.s3 + 1
	elseif idx == 4 then STATE.stats.s4 = STATE.stats.s4 + 1 end
	task.delay(0.17, function()
		STATE.skills.inProgress = false
		STATE.combat.skillWindup = false
		STATE.combat.currentSkill = 0
	end)
	return true
end

local function doM1()
	sendClick(true)
	task.wait(0.009)
	sendClick(false)
	STATE.combat.lastM1 = tick()
	STATE.stats.m1 = STATE.stats.m1 + 1
	STATE.combat.m1Count = STATE.combat.m1Count + 1
	STATE.combat.stringCount = STATE.combat.stringCount + 1
end

local function doDash()
	local now = tick()
	if (now - STATE.move.lastDash) < CFG.movement.dashCD then return false end
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.046, function() sendKey(false, Enum.KeyCode.Q) end)
	STATE.move.lastDash = now
	return true
end

local function sideDash(dir)
	local now = tick()
	if (now - STATE.move.lastSide) < CFG.movement.sideDashCD then return false end
	local my = getRoot()
	if not my or not STATE.target.root then return false end
	local to = (STATE.target.root.Position - my.Position).Unit
	local right = Vector3.new(-to.Z, 0, to.X)
	local side = (dir == "right") and right or -right
	my.CFrame = CFrame.lookAt(my.Position, my.Position + side)
	task.wait(0.023)
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.048, function()
		sendKey(false, Enum.KeyCode.Q)
		if STATE.target.root and my then
			my.CFrame = CFrame.lookAt(my.Position, STATE.target.root.Position)
		end
	end)
	STATE.move.lastSide = now
	return true
end

local function sideDashAttack()
	local now = tick()
	if (now - STATE.combat.lastSideDashAttack) < CFG.combat.sideDashAttackCD then return false end
	if STATE.combat.sideDashAttacking or STATE.combat.lock then return false end
	local my = getRoot()
	if not my or not STATE.target.root then return false end
	local dist = STATE.target.dist
	if dist > CFG.combat.sideDashAttackRange or dist < 6.5 then return false end
	if math.random() > CFG.combat.sideDashAttackChance then return false end
	STATE.combat.sideDashAttacking = true
	STATE.combat.lastSideDashAttack = now
	STATE.stats.sideDashAtk = STATE.stats.sideDashAtk + 1
	task.spawn(function()
		local to = (STATE.target.root.Position - my.Position).Unit
		local right = Vector3.new(-to.Z, 0, to.X)
		local side = math.random() > 0.5 and right or -right
		my.CFrame = CFrame.lookAt(my.Position, my.Position + side * 5.5)
		task.wait(0.035)
		sendKey(true, Enum.KeyCode.Q)
		task.wait(0.05)
		sendKey(false, Enum.KeyCode.Q)
		task.wait(0.07)
		if STATE.target.root and my and STATE.active then
			my.CFrame = CFrame.lookAt(my.Position, STATE.target.root.Position)
			task.wait(0.035)
			doM1()
			task.wait(0.045)
			doM1()
		end
		STATE.combat.sideDashAttacking = false
	end)
	return true
end

local function dashBait()
	local now = tick()
	if (now - STATE.move.lastBait) < CFG.movement.baitCD then return false end
	if STATE.target.dist > 9.5 or STATE.target.dist < 3.4 then return false end
	press(Enum.KeyCode.W, "W")
	task.wait(0.055)
	release(Enum.KeyCode.W, "W")
	press(Enum.KeyCode.S, "S")
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.045, function()
		sendKey(false, Enum.KeyCode.Q)
		release(Enum.KeyCode.S, "S")
	end)
	STATE.move.lastBait = now
	STATE.stats.baits = STATE.stats.baits + 1
	return true
end

local function goBehind()
	local my = getRoot()
	if not my or not STATE.target.root then return false end
	local cf = STATE.target.root.CFrame * CFrame.new(0, 0, CFG.combat.behindOffset)
	my.CFrame = CFrame.lookAt(cf.Position, STATE.target.root.Position)
	my.AssemblyLinearVelocity = Vector3.zero
	my.AssemblyAngularVelocity = Vector3.zero
	STATE.combat.behindMode = true
	STATE.combat.lastBehind = tick()
	return true
end

local function smartBlockBreak()
	local now = tick()
	if (now - STATE.defense.lastBlockBreak) < CFG.defense.blockBreakCD then return false end
	if not STATE.target.isBlocking then return false end
	if STATE.target.dist > CFG.defense.blockBreakRange then return false end
	if STATE.combat.lock then return false end
	STATE.defense.lastBlockBreak = now
	STATE.stats.breaks = STATE.stats.breaks + 1
	task.spawn(function()
		sendKey(true, Enum.KeyCode.Space)
		task.wait(0.10)
		sendKey(false, Enum.KeyCode.Space)
		task.wait(0.055)
		if canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		elseif canSkill(3) then
			castSkill(3)
		end
	end)
	return true
end

local function ghostStrike()
	if STATE.combat.lock or not canR() then return false end
	if STATE.perf.safeMode then return false end
	if math.random() > CFG.combat.ghostChance then return false end
	if not canSkill(1) and not canSkill(3) then return false end
	STATE.combat.lock = true
	STATE.stats.ghost = STATE.stats.ghost + 1
	task.spawn(function()
		doM1()
		task.wait(0.07)
		doM1()
		task.wait(0.06)
		local sk = canSkill(1) and 1 or 3
		castSkill(sk)
		task.wait(0.08)
		if castR() then
			task.wait(0.10)
			if STATE.target.root and STATE.target.hum and STATE.target.hum.Health > 0 then
				local d = STATE.perf.m1Delay
				doM1()
				task.wait(d)
				doM1()
				task.wait(d)
				doM1()
			end
		end
		task.wait(0.13)
		STATE.combat.lock = false
	end)
	return true
end

local function infinitePressure()
	if STATE.combat.lock or not canR() then return false end
	if STATE.perf.safeMode then return false end
	if math.random() > CFG.combat.pressureChance then return false end
	STATE.combat.lock = true
	STATE.combat.pressureMode = true
	STATE.stats.pressure = STATE.stats.pressure + 1
	task.spawn(function()
		local d = STATE.perf.m1Delay
		doM1()
		task.wait(d)
		doM1()
		task.wait(d)
		doM1()
		task.wait(0.06)
		local sk = 2
		if canSkill(1) then sk = 1
		elseif canSkill(3) then sk = 3
		elseif canSkill(2) then sk = 2 end
		if castSkill(sk) then
			task.wait(0.07)
			castR()
			task.wait(0.09)
			doM1()
			task.wait(d)
			doM1()
			task.wait(d)
			doM1()
		end
		task.wait(0.15)
		STATE.combat.lock = false
		STATE.combat.pressureMode = false
	end)
	return true
end

local function blackFlashRetimer()
	if not STATE.combat.skillWindup then return false end
	if STATE.combat.currentSkill ~= 1 and STATE.combat.currentSkill ~= 3 then return false end
	if not canR() then return false end
	if STATE.perf.safeMode then return false end
	if math.random() > CFG.combat.retimerChance then return false end
	if castR() then
		task.wait(0.05)
		if canSkill(1) then
			castSkill(1)
			task.wait(0.26)
			if canSkill(1) then
				castSkill(1)
			end
		end
		return true
	end
	return false
end

local function blackFlashCombo()
	if STATE.combat.bfActive or STATE.combat.lock then return end
	if countNearby(11.5) > 0 then return end
	if not canSkill(1) then return end
	STATE.combat.bfActive = true
	STATE.combat.lock = true
	STATE.combat.bfCount = 0
	STATE.combat.comboRoute = 1
	STATE.stats.combo1 = STATE.stats.combo1 + 1
	task.spawn(function()
		for i = 1, CFG.combat.blackFlashRepeat do
			if not STATE.active or not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then break end
			if countNearby(11) > 0 then break end
			local d = STATE.perf.m1Delay
			doM1()
			task.wait(d * 0.88)
			doM1()
			task.wait(d * 0.88)
			doM1()
			task.wait(0.05)
			goBehind()
			task.wait(0.03)
			if castSkill(1) then
				task.wait(CFG.combat.blackFlashGap)
				if canSkill(1) then
					castSkill(1)
				elseif canR() and not STATE.perf.safeMode then
					castR()
					task.wait(0.04)
					if canSkill(1) then castSkill(1) end
				end
				STATE.combat.bfCount = STATE.combat.bfCount + 1
			end
			task.wait(0.14)
		end
		if STATE.combat.bfCount >= 3 then
			STATE.stats.bfCombos = STATE.stats.bfCombos + 1
		end
		STATE.combat.bfActive = false
		STATE.combat.lock = false
		STATE.combat.behindMode = false
		STATE.combat.lastComboEnd = tick()
	end)
end

local function comboRoute2()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	local dist = STATE.target.dist
	if dist < CFG.combat.minRange or dist > CFG.combat.attackRange then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	STATE.combat.comboRoute = 2
	STATE.stats.combo2 = STATE.stats.combo2 + 1
	task.spawn(function()
		local d = STATE.perf.m1Delay
		doM1()
		task.wait(d)
		doM1()
		task.wait(d)
		doM1()
		task.wait(0.08)
		if canSkill(2) then
			castSkill(2)
		elseif canSkill(1) then
			castSkill(1)
		elseif canSkill(3) then
			castSkill(3)
		end
		task.wait(0.19)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
		STATE.combat.lastComboEnd = tick()
	end)
end

local function comboRoute3()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	local dist = STATE.target.dist
	if dist < CFG.combat.minRange or dist > CFG.combat.attackRange then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	STATE.combat.comboRoute = 3
	STATE.stats.combo3 = STATE.stats.combo3 + 1
	task.spawn(function()
		local d = STATE.perf.m1Delay
		doM1()
		task.wait(d)
		doM1()
		task.wait(CFG.combat.m1BreakDelay)
		doM1()
		task.wait(0.09)
		if canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		end
		task.wait(0.18)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
		STATE.combat.lastComboEnd = tick()
	end)
end

local function comboRoute4()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	local dist = STATE.target.dist
	if dist < CFG.combat.minRange or dist > 9 then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	STATE.combat.comboRoute = 4
	STATE.stats.combo4 = STATE.stats.combo4 + 1
	task.spawn(function()
		local d = STATE.perf.m1Delay
		doM1()
		task.wait(d * 0.9)
		doM1()
		task.wait(0.06)
		if canSkill(3) then
			castSkill(3)
		elseif canSkill(1) then
			castSkill(1)
		end
		task.wait(0.16)
		doM1()
		task.wait(d)
		doM1()
		task.wait(0.15)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
		STATE.combat.lastComboEnd = tick()
	end)
end

local function comboRoute5()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	local dist = STATE.target.dist
	if dist < 2.5 or dist > 10 then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	STATE.combat.comboRoute = 5
	STATE.stats.combo5 = STATE.stats.combo5 + 1
	task.spawn(function()
		sideDash(math.random() > 0.5 and "left" or "right")
		task.wait(0.12)
		local d = STATE.perf.m1Delay
		doM1()
		task.wait(d)
		doM1()
		task.wait(d)
		doM1()
		task.wait(0.07)
		if canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		end
		task.wait(0.17)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
		STATE.combat.lastComboEnd = tick()
	end)
end

local function tight3M1Skill()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	local dist = STATE.target.dist
	if dist < CFG.combat.minRange or dist > CFG.combat.attackRange then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	task.spawn(function()
		local d = STATE.perf.m1Delay
		doM1()
		task.wait(d)
		doM1()
		task.wait(d)
		doM1()
		task.wait(0.085)
		if countNearby(10.5) == 0 and canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		elseif canSkill(3) then
			castSkill(3)
		elseif canSkill(1) then
			castSkill(1)
		end
		task.wait(0.20)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
		STATE.combat.lastComboEnd = tick()
	end)
end

local function interruptedM1()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	task.spawn(function()
		local d = STATE.perf.m1Delay
		doM1()
		task.wait(d)
		doM1()
		task.wait(CFG.combat.m1BreakDelay)
		doM1()
		task.wait(0.095)
		if countNearby(10) == 0 and canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		elseif canSkill(3) then
			castSkill(3)
		end
		task.wait(0.21)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
		STATE.combat.lastComboEnd = tick()
	end)
end

local function selectCombo()
	local r = math.random(1, 100)
	if r <= 28 then
		return 1
	elseif r <= 50 then
		return 2
	elseif r <= 68 then
		return 3
	elseif r <= 84 then
		return 4
	else
		return 5
	end
end

local function executeCombo()
	local route = selectCombo()
	if route == 1 and countNearby(11.5) == 0 and canSkill(1) then
		blackFlashCombo()
	elseif route == 2 then
		comboRoute2()
	elseif route == 3 then
		comboRoute3()
	elseif route == 4 then
		comboRoute4()
	elseif route == 5 then
		comboRoute5()
	else
		tight3M1Skill()
	end
end

local function emergencyEscape()
	local now = tick()
	if (now - STATE.defense.lastEscape) < 0.95 then return false end
	if STATE.defense.escaping then return false end
	STATE.defense.escaping = true
	STATE.defense.lastEscape = now
	STATE.stats.escapes = STATE.stats.escapes + 1
	releaseAll()
	local side = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
	sendKey(true, side)
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.055, function()
		sendKey(false, Enum.KeyCode.Q)
		sendKey(false, side)
		if STATE.player.hp < CFG.defense.escapeHP then
			press(Enum.KeyCode.F, "F")
			task.delay(0.28, function() release(Enum.KeyCode.F, "F") end)
		end
		STATE.defense.escaping = false
	end)
	return true
end

local function handleBlock()
	if not STATE.target.hum then return end
	local now = tick()
	local dist = STATE.target.dist
	local atk = isAttacking(STATE.target.hum)
	local sk = isSkill(STATE.target.hum)
	local st = STATE.target.isStunned

	if atk or sk then
		STATE.defense.lastEnemyAttack = now
		STATE.target.attackEndTime = 0
	else
		if STATE.defense.lastEnemyAttack > 0 and STATE.target.attackEndTime == 0 then
			STATE.target.attackEndTime = now
		end
	end

	if st then
		if STATE.defense.blocking or STATE.defense.holdingBlock then
			release(Enum.KeyCode.F, "F")
			STATE.defense.blocking = false
			STATE.defense.holdingBlock = false
			STATE.defense.blockEnd = now
			STATE.combat.punishReady = true
		end
		return
	end

	if CFG.defense.holdBlockUntilClear then
		if (atk or sk) and dist < CFG.defense.blockRange then
			if not STATE.defense.blocking and not STATE.defense.holdingBlock then
				if (now - STATE.defense.blockEnd) > CFG.defense.blockCD then
					press(Enum.KeyCode.F, "F")
					STATE.defense.blocking = true
					STATE.defense.holdingBlock = true
					STATE.defense.blockStart = now
					STATE.stats.blocks = STATE.stats.blocks + 1
				end
			end
		else
			if STATE.defense.holdingBlock then
				local clearTime = 0.12
				if STATE.target.attackEndTime > 0 and (now - STATE.target.attackEndTime) >= clearTime then
					release(Enum.KeyCode.F, "F")
					STATE.defense.blocking = false
					STATE.defense.holdingBlock = false
					STATE.defense.blockEnd = now
					STATE.combat.punishReady = true
					if math.random() < 0.4 then
						STATE.defense.perfectBlock = true
						STATE.stats.perfectBlocks = STATE.stats.perfectBlocks + 1
					end
				end
			end
		end
	else
		if atk and dist < CFG.defense.blockRange then
			if (now - STATE.defense.blockEnd) > CFG.defense.blockCD then
				if not STATE.defense.blocking then
					press(Enum.KeyCode.F, "F")
					STATE.defense.blocking = true
					STATE.defense.blockStart = now
					STATE.stats.blocks = STATE.stats.blocks + 1
					task.delay(CFG.defense.blockMin, function()
						if STATE.defense.blocking then
							release(Enum.KeyCode.F, "F")
							STATE.defense.blocking = false
							STATE.defense.blockEnd = tick()
							STATE.combat.punishReady = true
						end
					end)
				elseif (now - STATE.defense.blockStart) > CFG.defense.blockMax then
					release(Enum.KeyCode.F, "F")
					STATE.defense.blocking = false
					STATE.defense.blockEnd = now
				end
			end
		else
			if STATE.defense.blocking and (now - STATE.defense.blockStart) >= CFG.defense.blockMin then
				release(Enum.KeyCode.F, "F")
				STATE.defense.blocking = false
				STATE.defense.blockEnd = now
			end
		end
	end
end

local function handleCounter()
	if not STATE.target.hum then return end
	local dist = STATE.target.dist
	if (isAttacking(STATE.target.hum) or isSkill(STATE.target.hum)) and dist < CFG.defense.counterRange then
		if canSkill(4) and not STATE.defense.countering then
			if castSkill(4) then
				STATE.defense.countering = true
				STATE.stats.counters = STATE.stats.counters + 1
				task.delay(0.68, function() STATE.defense.countering = false end)
			end
		end
	end
end

local function handlePunish()
	if not STATE.combat.punishReady then return end
	if STATE.combat.lock then return end
	STATE.combat.punishReady = false
	STATE.combat.lock = true
	task.spawn(function()
		task.wait(0.02)
		doM1()
		STATE.stats.punishes = STATE.stats.punishes + 1
		local d = STATE.perf.m1Delay
		task.wait(d * 0.85)
		doM1()
		task.wait(0.06)
		if STATE.defense.perfectBlock and canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		elseif canSkill(1) then
			castSkill(1)
		end
		STATE.defense.perfectBlock = false
		task.wait(0.12)
		STATE.combat.lock = false
	end)
end

local function handleRagdollRecovery()
	local my = getRoot()
	local hum = getHum()
	if not my or not hum then return end
	if isRagdoll(my, hum) then
		STATE.player.isRagdoll = true
		local now = tick()
		if (now - STATE.move.lastRagdollEscape) < CFG.ragdoll.escapeCD then return true end
		STATE.move.lastRagdollEscape = now
		releaseAll()
		STATE.stats.ragdollEsc = STATE.stats.ragdollEsc + 1

		local doJump = math.random() < CFG.ragdoll.jumpChance
		local doDiagonal = math.random() < CFG.ragdoll.diagonalChance
		local sideKey = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
		local forwardKey = math.random() > 0.45 and Enum.KeyCode.W or Enum.KeyCode.S

		task.spawn(function()
			if doJump then
				sendKey(true, Enum.KeyCode.Space)
				task.delay(0.09, function() sendKey(false, Enum.KeyCode.Space) end)
			end

			if doDiagonal then
				sendKey(true, sideKey)
				sendKey(true, forwardKey)
				sendKey(true, Enum.KeyCode.Q)
				task.wait(0.055)
				sendKey(false, Enum.KeyCode.Q)
				task.wait(0.04)
				sendKey(false, sideKey)
				sendKey(false, forwardKey)
			else
				sendKey(true, sideKey)
				sendKey(true, Enum.KeyCode.Q)
				task.wait(0.05)
				sendKey(false, Enum.KeyCode.Q)
				sendKey(false, sideKey)
			end

			if math.random() < CFG.ragdoll.doubleDashChance then
				task.wait(0.12)
				local side2 = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
				sendKey(true, side2)
				sendKey(true, Enum.KeyCode.Q)
				task.wait(0.045)
				sendKey(false, Enum.KeyCode.Q)
				sendKey(false, side2)
			end
		end)
		return true
	end
	STATE.player.isRagdoll = false
	return false
end

local function microWS(dt)
	STATE.move.microClock = STATE.move.microClock + dt
	if STATE.move.microClock >= CFG.movement.microWSInterval then
		STATE.move.microClock = 0
		if STATE.move.mode == "pressure" or STATE.move.mode == "optimal" then
			if math.random() > 0.42 then
				press(Enum.KeyCode.W, "W")
				task.delay(0.048, function() release(Enum.KeyCode.W, "W") end)
			else
				press(Enum.KeyCode.S, "S")
				task.delay(0.042, function() release(Enum.KeyCode.S, "S") end)
			end
		end
	end
end

local function updateMovement(dt)
	local my = getRoot()
	if not my or not STATE.target.root then return end
	local dist = STATE.target.dist
	local hp = STATE.player.hp

	if hp <= CFG.defense.escapeHP and dist < 8.5 then
		STATE.move.mode = "escape"
		emergencyEscape()
		return
	end

	if hp <= CFG.defense.lowHPThreshold then
		STATE.move.mode = "survive"
		if dist < 7.2 then
			press(Enum.KeyCode.S, "S")
			if not STATE.defense.blocking and not STATE.defense.holdingBlock then
				press(Enum.KeyCode.F, "F")
				task.delay(0.25, function() release(Enum.KeyCode.F, "F") end)
			end
			if dist < 4.8 then
				sideDash(math.random() > 0.5 and "left" or "right")
			end
		else
			release(Enum.KeyCode.S, "S")
			press(Enum.KeyCode.W, "W")
		end
		return
	end

	if dist > 15.5 then
		STATE.move.mode = "approach"
		press(Enum.KeyCode.W, "W")
		release(Enum.KeyCode.S, "S")
		if obstacleFront(my) then
			sendKey(true, Enum.KeyCode.Space)
			task.delay(CFG.movement.jumpDelay, function() sendKey(false, Enum.KeyCode.Space) end)
			local side = math.random() > 0.5 and "A" or "D"
			if side == "A" then press(Enum.KeyCode.A, "A") else press(Enum.KeyCode.D, "D") end
			task.delay(0.16, function()
				release(Enum.KeyCode.A, "A")
				release(Enum.KeyCode.D, "D")
			end)
		end
		if dist > 19 and (tick() - STATE.move.lastDash) > CFG.movement.dashCD then
			if math.random() < CFG.movement.diagonalChance then
				if math.random() > 0.5 then
					press(Enum.KeyCode.A, "A")
					doDash()
					task.delay(0.095, function() release(Enum.KeyCode.A, "A") end)
				else
					press(Enum.KeyCode.D, "D")
					doDash()
					task.delay(0.095, function() release(Enum.KeyCode.D, "D") end)
				end
			else
				doDash()
			end
		end
	elseif dist > CFG.combat.optimalMax then
		STATE.move.mode = "pressure"
		press(Enum.KeyCode.W, "W")
		release(Enum.KeyCode.S, "S")
		microWS(dt)
		if math.random() < 0.15 then
			sideDash(math.random() > 0.5 and "left" or "right")
		end
	elseif dist >= CFG.combat.optimalMin and dist <= CFG.combat.optimalMax then
		STATE.move.mode = "optimal"
		microWS(dt)
		if math.random() < 0.18 then
			dashBait()
		elseif math.random() < 0.12 then
			sideDash(math.random() > 0.5 and "left" or "right")
		end
	elseif dist < CFG.combat.minRange then
		STATE.move.mode = "reset"
		release(Enum.KeyCode.W, "W")
		press(Enum.KeyCode.S, "S")
		if math.random() > 0.34 then
			sideDash(math.random() > 0.5 and "left" or "right")
		end
	else
		STATE.move.mode = "neutral"
		microWS(dt)
	end
end

local function updateCamera()
	local my = getRoot()
	if not my or not STATE.target.root then return end
	local pred = predictPos(STATE.target.root)
	STATE.target.predicted = pred
	local look = Vector3.new(pred.X, my.Position.Y, pred.Z)
	my.CFrame = my.CFrame:Lerp(CFrame.lookAt(my.Position, look), CFG.movement.rotationSpeed)
	local camTarget = pred + Vector3.new(0, 1.25, 0)
	Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, camTarget), CFG.movement.lerpSpeed)
end

local function updateTargetState()
	if not STATE.target.hum or not STATE.target.root then return end
	STATE.target.isStunned = isStunned(STATE.target.hum, STATE.target.root)
	STATE.target.isBlocking = isBlocking(STATE.target.hum)
	STATE.target.isAttacking = isAttacking(STATE.target.hum)
	STATE.target.isSkill = isSkill(STATE.target.hum)
	STATE.target.vel = STATE.target.root.AssemblyLinearVelocity or Vector3.zero
	if STATE.target.hum.Health < STATE.target.lastHP then
		STATE.target.threatLevel = math.min(STATE.target.threatLevel + 1, 10)
	end
	STATE.target.lastHP = STATE.target.hum.Health
end

local function updatePlayerState()
	local r = getRoot()
	local h = getHum()
	if r then
		STATE.player.root = r
		STATE.player.pos = r.Position
		STATE.player.vel = r.AssemblyLinearVelocity or Vector3.zero
	end
	if h then
		STATE.player.hum = h
		STATE.player.hp = h.Health
		STATE.player.maxhp = h.MaxHealth
	end
end

local function combatDecision()
	if STATE.combat.lock or STATE.combat.bfActive or STATE.combat.comboActive or STATE.combat.sideDashAttacking then
		blackFlashRetimer()
		return
	end
	if not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then return end
	local dist = STATE.target.dist
	local nearby = countNearby(11.5)
	STATE.cache.nearby = nearby

	if STATE.player.hp <= CFG.defense.escapeHP and dist < 8 then
		emergencyEscape()
		return
	end

	if STATE.target.isBlocking and dist < CFG.defense.blockBreakRange then
		if smartBlockBreak() then return end
	end

	if nearby == 0 and dist <= 7.8 and dist >= 2.0 and canSkill(1) then
		if math.random() < 0.55 then
			blackFlashCombo()
			return
		end
	end

	if dist >= 7.5 and dist <= CFG.combat.sideDashAttackRange then
		if sideDashAttack() then return end
	end

	if dist >= CFG.combat.minRange and dist <= CFG.combat.attackRange then
		if not STATE.perf.safeMode then
			if math.random() < 0.16 and canR() then
				if ghostStrike() then return end
			end
			if math.random() < 0.19 and canR() then
				if infinitePressure() then return end
			end
		end
		if STATE.target.isStunned then
			interruptedM1()
		else
			executeCombo()
		end
	elseif dist > CFG.combat.attackRange and dist < 21 then
		if canSkill(1) and nearby == 0 then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		elseif canSkill(3) then
			castSkill(3)
		end
	end
end

local function mainLoop(dt)
	if not STATE.active then return end
	STATE.perf.dt = dt
	STATE.perf.fps = math.floor(1 / math.max(dt, 0.001))
	updatePingAdaptive()
	updatePlayerState()
	local my = STATE.player.root
	local hum = STATE.player.hum
	if not my or not hum or hum.Health <= 0 then return end

	if handleRagdollRecovery() then return end

	local now = tick()
	if (now - STATE.cache.lastScan) >= CFG.targeting.updateRate then
		scanTargets()
		STATE.cache.lastScan = now
	end

	if not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then
		scanTargets()
		if not STATE.target.root then
			releaseAll()
			return
		end
	end

	STATE.target.dist = (my.Position - STATE.target.root.Position).Magnitude
	updateTargetState()
	updateCamera()
	handleBlock()
	handleCounter()
	handlePunish()
	updateMovement(dt)
	combatDecision()
end

local function getUIParent()
	local ok, core = pcall(function() return game:GetService("CoreGui") end)
	if ok and core then
		local t = pcall(function() return core.Name end)
		if t then return core end
	end
	return LP:WaitForChild("PlayerGui")
end

local UIParent = getUIParent()
if UIParent:FindFirstChild("YUJI_PRO_BOT") then
	UIParent:FindFirstChild("YUJI_PRO_BOT"):Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name = "YUJI_PRO_BOT"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = UIParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 330, 0, 200)
Main.Position = UDim2.new(0, 50, 0, 50)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = Main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 90, 90)
stroke.Thickness = 1.5
stroke.Transparency = 0.22
stroke.Parent = Main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
topBar.BorderSizePixel = 0
topBar.Parent = Main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -42, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "YUJI PRO BOT"
title.TextColor3 = Color3.fromRGB(255, 210, 80)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 24
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 38)
toggleBtn.Position = UDim2.new(0, 10, 0, 46)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = Main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local stats1 = Instance.new("TextLabel")
stats1.Size = UDim2.new(1, -20, 0, 38)
stats1.Position = UDim2.new(0, 10, 0, 94)
stats1.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
stats1.TextColor3 = Color3.fromRGB(190, 190, 200)
stats1.Text = "M1: 0  |  Skills: 0\nBF: 0  |  R: 0  |  SideAtk: 0"
stats1.TextSize = 12
stats1.Font = Enum.Font.Code
stats1.BorderSizePixel = 0
stats1.Parent = Main

local stats1Corner = Instance.new("UICorner")
stats1Corner.CornerRadius = UDim.new(0, 6)
stats1Corner.Parent = stats1

local stats2 = Instance.new("TextLabel")
stats2.Size = UDim2.new(1, -20, 0, 42)
stats2.Position = UDim2.new(0, 10, 0, 138)
stats2.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
stats2.TextColor3 = Color3.fromRGB(255, 120, 120)
stats2.Text = "Ghost:0 Pressure:0 Break:0\nPunish:0 Escape:0 Ragdoll:0"
stats2.TextSize = 12
stats2.Font = Enum.Font.Code
stats2.BorderSizePixel = 0
stats2.Parent = Main

local stats2Corner = Instance.new("UICorner")
stats2Corner.CornerRadius = UDim.new(0, 6)
stats2Corner.Parent = stats2

local function refreshStats()
	stats1.Text = string.format("M1: %d  |  Skills: %d\nBF: %d  |  R: %d  |  SideAtk: %d",
		STATE.stats.m1, STATE.stats.skills, STATE.stats.bfCombos, STATE.stats.rCancel, STATE.stats.sideDashAtk)
	stats2.Text = string.format("Ghost:%d Pressure:%d Break:%d\nPunish:%d Escape:%d Ragdoll:%d",
		STATE.stats.ghost, STATE.stats.pressure, STATE.stats.breaks,
		STATE.stats.punishes, STATE.stats.escapes, STATE.stats.ragdollEsc)
end

toggleBtn.MouseButton1Click:Connect(function()
	STATE.active = not STATE.active
	if STATE.active then
		releaseAll()
		STATE.stats.startTime = tick()
		toggleBtn.Text = "STOP"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
	else
		releaseAll()
		toggleBtn.Text = "START"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	STATE.active = false
	releaseAll()
	SG:Destroy()
end)

UIS.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.RightAlt then
		toggleBtn.MouseButton1Click:Fire()
	end
end)

task.spawn(function()
	while true do
		if STATE.active then
			refreshStats()
		end
		task.wait(0.25)
	end
end)

task.spawn(function()
	while true do
		local t0 = tick()
		RunService.Heartbeat:Wait()
		local dt = tick() - t0
		STATE.perf.ping = clamp(dt * 1000, 12, 420)
		task.wait(0.38)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	pcall(function()
		mainLoop(dt)
	end)
end)

LP.CharacterAdded:Connect(function()
	task.wait(0.48)
	releaseAll()
	STATE.player.char = LP.Character
end)
