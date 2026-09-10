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
		maxDist = 380,
		retargetDist = 36,
		teamCheck = true,
		targetNPCs = true,
		priorityHealth = true,
		updateRate = 0.11,
		predictive = true,
		predictionTime = 0.36,
	},
	combat = {
		attackRange = 7.7,
		minRange = 2.0,
		optimalMin = 5.5,
		optimalMax = 7.5,
		m1Delay = 0.162,
		m1BreakDelay = 0.148,
		behindOffset = 1.52,
		blackFlashRepeat = 3,
		blackFlashGap = 0.30,
		ghostStrikeChance = 0.38,
		infinitePressureChance = 0.42,
		retimerChance = 0.55,
	},
	movement = {
		dashCD = 0.66,
		sideDashCD = 0.70,
		baitCD = 1.10,
		microWSInterval = 0.10,
		diagonalChance = 0.64,
		obstacleCheck = 9.2,
		jumpDelay = 0.12,
		rotationSpeed = 0.44,
		lerpSpeed = 0.34,
	},
	defense = {
		blockRange = 18.5,
		blockMin = 0.16,
		blockMax = 0.46,
		blockCD = 0.36,
		counterRange = 17.0,
		lowHPThreshold = 36,
		escapeHP = 27,
	},
	skills = {
		globalCD = 0.72,
		rCD = 2.05,
		[1] = {name = "DivergentFist", cd = 1.90, last = 0, key = Enum.KeyCode.One},
		[2] = {name = "CrushingBlow", cd = 2.30, last = 0, key = Enum.KeyCode.Two},
		[3] = {name = "BlackFlash", cd = 1.70, last = 0, key = Enum.KeyCode.Three},
		[4] = {name = "ManjiKick", cd = 3.35, last = 0, key = Enum.KeyCode.Four},
	},
}

local STATE = {
	active = false,
	target = {root = nil, hum = nil, name = "", dist = 999, lastSeen = 0, vel = Vector3.zero, isStunned = false, isBlocking = false, isAttacking = false, isSkill = false},
	player = {root = nil, hum = nil, char = nil, hp = 100, maxhp = 100, pos = Vector3.zero, vel = Vector3.zero, isRagdoll = false},
	input = {W = false, A = false, S = false, D = false, F = false, Space = false, Q = false, R = false},
	combat = {
		lock = false,
		comboActive = false,
		m1Count = 0,
		lastM1 = 0,
		lastCombo = 0,
		bfCount = 0,
		bfActive = false,
		behindMode = false,
		lastBehind = 0,
		punishReady = false,
		ghostReady = false,
		pressureMode = false,
		lastR = 0,
		skillWindup = false,
		currentSkill = 0,
	},
	defense = {
		blocking = false,
		blockStart = 0,
		blockEnd = 0,
		countering = false,
		lastCounter = 0,
		escaping = false,
		lastEscape = 0,
	},
	move = {
		lastDash = 0,
		lastSide = 0,
		lastBait = 0,
		microClock = 0,
		strafeDir = 1,
		mode = "neutral",
	},
	skills = {globalLast = 0, inProgress = false, rLast = 0},
	stats = {
		m1 = 0, skills = 0, s1 = 0, s2 = 0, s3 = 0, s4 = 0, rCancel = 0,
		blocks = 0, counters = 0, breaks = 0, punishes = 0, bfCombos = 0,
		escapes = 0, baits = 0, ghost = 0, pressure = 0, startTime = 0,
	},
	cache = {lastScan = 0, nearby = 0},
	perf = {dt = 0.016},
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
	STATE.defense.blocking = false
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

local ANIM = {
	attack = {"attack", "swing", "punch", "slash", "m1", "hit", "strike", "combo", "jab", "smash", "uppercut", "kick", "beat"},
	skill = {"skill", "technique", "curse", "domain", "special", "ability", "ultimate", "barrage", "blast", "power"},
	stun = {"stun", "hitstun", "stagger", "downed", "knockback", "launch", "ragdoll", "tumble", "hurt", "flinch", "fall"},
	block = {"block", "guard", "parry", "deflect", "defend", "shield", "brace"},
	ragdoll = {"ragdoll", "stagger", "knockback", "launch", "tumble", "fall", "downed", "hitstun"},
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
		if Vector2.new(v.X, v.Z).Magnitude > 38 then return true end
		if math.abs(v.Y) > 38 then return true end
	end
	return false
end

local function isRagdoll(r, h)
	if not r or not h then return false end
	local v = r.AssemblyLinearVelocity or Vector3.zero
	if Vector2.new(v.X, v.Z).Magnitude > 38 then return true end
	if math.abs(v.Y) > 38 then return true end
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
		p = p + (1 - h.Health / h.MaxHealth) * 55
	end
	if isStunned(h, r) then p = p + 80 end
	if isBlocking(h) then p = p - 35 end
	return p
end

local function scanTargets()
	local my = getRoot()
	if not my then return end
	local now = tick()
	if STATE.target.root and STATE.target.hum and STATE.target.hum.Health > 0 then
		local d = (my.Position - STATE.target.root.Position).Magnitude
		if d < CFG.targeting.retargetDist then
			STATE.target.dist = d
			STATE.target.lastSeen = now
			return
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
	return true
end

local function canR()
	return (tick() - STATE.skills.rLast) >= CFG.skills.rCD
end

local function castR()
	if not canR() then return false end
	sendKey(true, Enum.KeyCode.R)
	task.wait(0.03)
	sendKey(false, Enum.KeyCode.R)
	STATE.skills.rLast = tick()
	STATE.stats.rCancel = STATE.stats.rCancel + 1
	STATE.combat.skillWindup = false
	STATE.combat.currentSkill = 0
	return true
end

local function castSkill(idx, allowCancel)
	if not canSkill(idx) then return false end
	local s = CFG.skills[idx]
	STATE.skills.inProgress = true
	STATE.combat.skillWindup = true
	STATE.combat.currentSkill = idx
	sendKey(true, s.key)
	task.wait(0.08)
	sendKey(false, s.key)
	s.last = tick()
	STATE.skills.globalLast = tick()
	STATE.stats.skills = STATE.stats.skills + 1
	if idx == 1 then STATE.stats.s1 = STATE.stats.s1 + 1
	elseif idx == 2 then STATE.stats.s2 = STATE.stats.s2 + 1
	elseif idx == 3 then STATE.stats.s3 = STATE.stats.s3 + 1
	elseif idx == 4 then STATE.stats.s4 = STATE.stats.s4 + 1 end
	task.delay(0.20, function()
		STATE.skills.inProgress = false
		STATE.combat.skillWindup = false
		STATE.combat.currentSkill = 0
	end)
	return true
end

local function doM1()
	sendClick(true)
	task.wait(0.011)
	sendClick(false)
	STATE.combat.lastM1 = tick()
	STATE.stats.m1 = STATE.stats.m1 + 1
	STATE.combat.m1Count = STATE.combat.m1Count + 1
end

local function doDash()
	local now = tick()
	if (now - STATE.move.lastDash) < CFG.movement.dashCD then return false end
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.052, function() sendKey(false, Enum.KeyCode.Q) end)
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
	task.wait(0.028)
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.055, function()
		sendKey(false, Enum.KeyCode.Q)
		if STATE.target.root and my then
			my.CFrame = CFrame.lookAt(my.Position, STATE.target.root.Position)
		end
	end)
	STATE.move.lastSide = now
	return true
end

local function dashBait()
	local now = tick()
	if (now - STATE.move.lastBait) < CFG.movement.baitCD then return false end
	if STATE.target.dist > 10.5 or STATE.target.dist < 3.8 then return false end
	press(Enum.KeyCode.W, "W")
	task.wait(0.065)
	release(Enum.KeyCode.W, "W")
	press(Enum.KeyCode.S, "S")
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.05, function()
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

local function ghostStrike()
	if STATE.combat.lock or not canR() then return false end
	if math.random() > CFG.combat.ghostStrikeChance then return false end
	if not canSkill(1) and not canSkill(3) then return false end
	STATE.combat.lock = true
	STATE.stats.ghost = STATE.stats.ghost + 1
	task.spawn(function()
		doM1()
		task.wait(0.08)
		doM1()
		task.wait(0.07)
		local sk = canSkill(1) and 1 or 3
		castSkill(sk)
		task.wait(0.09)
		if castR() then
			task.wait(0.12)
			if STATE.target.root and STATE.target.hum and STATE.target.hum.Health > 0 then
				doM1()
				task.wait(0.06)
				doM1()
				task.wait(0.06)
				doM1()
			end
		end
		task.wait(0.15)
		STATE.combat.lock = false
	end)
	return true
end

local function infinitePressure()
	if STATE.combat.lock or not canR() then return false end
	if math.random() > CFG.combat.infinitePressureChance then return false end
	STATE.combat.lock = true
	STATE.combat.pressureMode = true
	STATE.stats.pressure = STATE.stats.pressure + 1
	task.spawn(function()
		doM1()
		task.wait(CFG.combat.m1Delay)
		doM1()
		task.wait(CFG.combat.m1Delay)
		doM1()
		task.wait(0.07)
		local sk = 2
		if canSkill(1) then sk = 1
		elseif canSkill(3) then sk = 3
		elseif canSkill(2) then sk = 2 end
		if castSkill(sk) then
			task.wait(0.08)
			castR()
			task.wait(0.11)
			doM1()
			task.wait(CFG.combat.m1Delay)
			doM1()
			task.wait(CFG.combat.m1Delay)
			doM1()
		end
		task.wait(0.18)
		STATE.combat.lock = false
		STATE.combat.pressureMode = false
	end)
	return true
end

local function blackFlashRetimer()
	if not STATE.combat.skillWindup then return false end
	if STATE.combat.currentSkill ~= 1 and STATE.combat.currentSkill ~= 3 then return false end
	if not canR() then return false end
	if math.random() > CFG.combat.retimerChance then return false end
	if castR() then
		task.wait(0.06)
		if canSkill(1) then
			castSkill(1)
			task.wait(0.28)
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
	if countNearby(13) > 0 then return end
	if not canSkill(1) then return end
	STATE.combat.bfActive = true
	STATE.combat.lock = true
	STATE.combat.bfCount = 0
	task.spawn(function()
		for i = 1, CFG.combat.blackFlashRepeat do
			if not STATE.active or not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then break end
			if countNearby(12) > 0 then break end
			doM1()
			task.wait(0.085)
			doM1()
			task.wait(0.085)
			doM1()
			task.wait(0.06)
			goBehind()
			task.wait(0.035)
			if castSkill(1) then
				task.wait(CFG.combat.blackFlashGap)
				if canSkill(1) then
					castSkill(1)
				elseif canR() then
					castR()
					task.wait(0.05)
					if canSkill(1) then castSkill(1) end
				end
				STATE.combat.bfCount = STATE.combat.bfCount + 1
			end
			task.wait(0.16)
		end
		if STATE.combat.bfCount >= 3 then
			STATE.stats.bfCombos = STATE.stats.bfCombos + 1
		end
		STATE.combat.bfActive = false
		STATE.combat.lock = false
		STATE.combat.behindMode = false
	end)
end

local function interruptedM1()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	task.spawn(function()
		doM1()
		task.wait(CFG.combat.m1Delay)
		doM1()
		task.wait(CFG.combat.m1BreakDelay)
		doM1()
		task.wait(0.11)
		if countNearby(11) == 0 and canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		elseif canSkill(3) then
			castSkill(3)
		end
		task.wait(0.25)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
	end)
end

local function normalCombo()
	if STATE.combat.lock or STATE.combat.comboActive then return end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	task.spawn(function()
		for i = 1, 3 do
			if not STATE.active then break end
			doM1()
			if i < 3 then task.wait(CFG.combat.m1Delay) end
		end
		task.wait(0.10)
		if countNearby(11) == 0 then
			if canSkill(1) then castSkill(1)
			elseif canSkill(2) then castSkill(2)
			elseif canSkill(3) then castSkill(3) end
		else
			if canSkill(2) then castSkill(2)
			elseif canSkill(3) then castSkill(3)
			elseif canSkill(1) then castSkill(1) end
		end
		task.wait(0.24)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
	end)
end

local function emergencyEscape()
	local now = tick()
	if (now - STATE.defense.lastEscape) < 1.05 then return false end
	if STATE.defense.escaping then return false end
	STATE.defense.escaping = true
	STATE.defense.lastEscape = now
	STATE.stats.escapes = STATE.stats.escapes + 1
	releaseAll()
	local side = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
	sendKey(true, side)
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.065, function()
		sendKey(false, Enum.KeyCode.Q)
		sendKey(false, side)
		if STATE.player.hp < CFG.defense.escapeHP then
			press(Enum.KeyCode.F, "F")
			task.delay(0.32, function() release(Enum.KeyCode.F, "F") end)
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
	if st or sk then
		if STATE.defense.blocking then
			release(Enum.KeyCode.F, "F")
			STATE.defense.blocking = false
			STATE.defense.blockEnd = now
		end
		return
	end
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

local function handleCounter()
	if not STATE.target.hum then return end
	local dist = STATE.target.dist
	if (isAttacking(STATE.target.hum) or isSkill(STATE.target.hum)) and dist < CFG.defense.counterRange then
		if canSkill(4) and not STATE.defense.countering then
			if castSkill(4) then
				STATE.defense.countering = true
				STATE.stats.counters = STATE.stats.counters + 1
				task.delay(0.72, function() STATE.defense.countering = false end)
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
		task.wait(0.028)
		doM1()
		STATE.stats.punishes = STATE.stats.punishes + 1
		task.wait(0.13)
		STATE.combat.lock = false
	end)
end

local function microWS(dt)
	STATE.move.microClock = STATE.move.microClock + dt
	if STATE.move.microClock >= CFG.movement.microWSInterval then
		STATE.move.microClock = 0
		if STATE.move.mode == "pressure" then
			if math.random() > 0.44 then
				press(Enum.KeyCode.W, "W")
				task.delay(0.055, function() release(Enum.KeyCode.W, "W") end)
			else
				press(Enum.KeyCode.S, "S")
				task.delay(0.048, function() release(Enum.KeyCode.S, "S") end)
			end
		end
	end
end

local function updateMovement(dt)
	local my = getRoot()
	if not my or not STATE.target.root then return end
	local dist = STATE.target.dist
	local hp = STATE.player.hp

	if hp <= CFG.defense.escapeHP and dist < 9.5 then
		STATE.move.mode = "escape"
		emergencyEscape()
		return
	end

	if hp <= CFG.defense.lowHPThreshold then
		STATE.move.mode = "survive"
		if dist < 7.8 then
			press(Enum.KeyCode.S, "S")
			if not STATE.defense.blocking then
				press(Enum.KeyCode.F, "F")
				task.delay(0.28, function() release(Enum.KeyCode.F, "F") end)
			end
			if dist < 5.2 then
				sideDash(math.random() > 0.5 and "left" or "right")
			end
		else
			release(Enum.KeyCode.S, "S")
			press(Enum.KeyCode.W, "W")
		end
		return
	end

	if dist > 17.5 then
		STATE.move.mode = "approach"
		press(Enum.KeyCode.W, "W")
		release(Enum.KeyCode.S, "S")
		if obstacleFront(my) then
			sendKey(true, Enum.KeyCode.Space)
			task.delay(CFG.movement.jumpDelay, function() sendKey(false, Enum.KeyCode.Space) end)
			local side = math.random() > 0.5 and "A" or "D"
			if side == "A" then press(Enum.KeyCode.A, "A") else press(Enum.KeyCode.D, "D") end
			task.delay(0.18, function()
				release(Enum.KeyCode.A, "A")
				release(Enum.KeyCode.D, "D")
			end)
		end
		if dist > 21 and (tick() - STATE.move.lastDash) > CFG.movement.dashCD then
			if math.random() < CFG.movement.diagonalChance then
				if math.random() > 0.5 then
					press(Enum.KeyCode.A, "A")
					doDash()
					task.delay(0.11, function() release(Enum.KeyCode.A, "A") end)
				else
					press(Enum.KeyCode.D, "D")
					doDash()
					task.delay(0.11, function() release(Enum.KeyCode.D, "D") end)
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
		if math.random() < 0.17 and (tick() - STATE.move.lastSide) > CFG.movement.sideDashCD then
			sideDash(math.random() > 0.5 and "left" or "right")
		end
	elseif dist >= CFG.combat.optimalMin and dist <= CFG.combat.optimalMax then
		STATE.move.mode = "pressure"
		microWS(dt)
		if math.random() < 0.20 then
			dashBait()
		elseif math.random() < 0.14 then
			sideDash(math.random() > 0.5 and "left" or "right")
		end
	elseif dist < CFG.combat.minRange then
		STATE.move.mode = "reset"
		release(Enum.KeyCode.W, "W")
		press(Enum.KeyCode.S, "S")
		if math.random() > 0.38 then
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
	local look = Vector3.new(pred.X, my.Position.Y, pred.Z)
	my.CFrame = my.CFrame:Lerp(CFrame.lookAt(my.Position, look), CFG.movement.rotationSpeed)
	local camTarget = pred + Vector3.new(0, 1.35, 0)
	Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, camTarget), CFG.movement.lerpSpeed)
end

local function updateTargetState()
	if not STATE.target.hum or not STATE.target.root then return end
	STATE.target.isStunned = isStunned(STATE.target.hum, STATE.target.root)
	STATE.target.isBlocking = isBlocking(STATE.target.hum)
	STATE.target.isAttacking = isAttacking(STATE.target.hum)
	STATE.target.isSkill = isSkill(STATE.target.hum)
	STATE.target.vel = STATE.target.root.AssemblyLinearVelocity or Vector3.zero
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
	if STATE.combat.lock or STATE.combat.bfActive or STATE.combat.comboActive then
		blackFlashRetimer()
		return
	end
	if not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then return end
	local dist = STATE.target.dist
	local nearby = countNearby(12.5)
	STATE.cache.nearby = nearby

	if STATE.player.hp <= CFG.defense.escapeHP and dist < 9 then
		emergencyEscape()
		return
	end

	if STATE.target.isBlocking and dist < 14.5 then
		if canSkill(1) then
			castSkill(1)
			STATE.stats.breaks = STATE.stats.breaks + 1
			return
		elseif canSkill(2) then
			castSkill(2)
			STATE.stats.breaks = STATE.stats.breaks + 1
			return
		end
	end

	if nearby == 0 and dist <= 8.3 and dist >= 2.2 then
		if canSkill(1) then
			blackFlashCombo()
			return
		end
	end

	if dist >= CFG.combat.minRange and dist <= CFG.combat.attackRange then
		if math.random() < 0.22 and canR() then
			if ghostStrike() then return end
		end
		if math.random() < 0.25 and canR() then
			if infinitePressure() then return end
		end
		if STATE.target.isStunned then
			interruptedM1()
		elseif dist <= CFG.combat.optimalMax then
			if math.random() < 0.52 then
				interruptedM1()
			else
				normalCombo()
			end
		end
	elseif dist > CFG.combat.attackRange and dist < 23 then
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
	updatePlayerState()
	local my = STATE.player.root
	local hum = STATE.player.hum
	if not my or not hum or hum.Health <= 0 then return end

	if isRagdoll(my, hum) then
		STATE.player.isRagdoll = true
		if (tick() - STATE.move.lastDash) > 0.33 then
			local side = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
			sendKey(true, side)
			sendKey(true, Enum.KeyCode.Q)
			task.delay(0.055, function()
				sendKey(false, Enum.KeyCode.Q)
				sendKey(false, side)
			end)
			STATE.move.lastDash = tick()
		end
		return
	else
		STATE.player.isRagdoll = false
	end

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
if UIParent:FindFirstChild("YUJI_PRO_AI") then
	UIParent:FindFirstChild("YUJI_PRO_AI"):Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name = "YUJI_PRO_AI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = UIParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 180)
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
stroke.Thickness = 1.4
stroke.Transparency = 0.25
stroke.Parent = Main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
topBar.BorderSizePixel = 0
topBar.Parent = Main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "YUJI PRO AI"
title.TextColor3 = Color3.fromRGB(255, 210, 80)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 36)
toggleBtn.Position = UDim2.new(0, 10, 0, 44)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 15
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = Main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local stats1 = Instance.new("TextLabel")
stats1.Size = UDim2.new(1, -20, 0, 34)
stats1.Position = UDim2.new(0, 10, 0, 90)
stats1.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
stats1.TextColor3 = Color3.fromRGB(190, 190, 200)
stats1.Text = "M1: 0  |  Skills: 0\nBF Combo: 0  |  R Cancel: 0"
stats1.TextSize = 12
stats1.Font = Enum.Font.Code
stats1.BorderSizePixel = 0
stats1.Parent = Main

local stats1Corner = Instance.new("UICorner")
stats1Corner.CornerRadius = UDim.new(0, 6)
stats1Corner.Parent = stats1

local stats2 = Instance.new("TextLabel")
stats2.Size = UDim2.new(1, -20, 0, 34)
stats2.Position = UDim2.new(0, 10, 0, 130)
stats2.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
stats2.TextColor3 = Color3.fromRGB(255, 120, 120)
stats2.Text = "Ghost:0 Pressure:0\nPunish:0 Escape:0 Bait:0"
stats2.TextSize = 12
stats2.Font = Enum.Font.Code
stats2.BorderSizePixel = 0
stats2.Parent = Main

local stats2Corner = Instance.new("UICorner")
stats2Corner.CornerRadius = UDim.new(0, 6)
stats2Corner.Parent = stats2

local function refreshStats()
	stats1.Text = string.format("M1: %d  |  Skills: %d\nBF Combo: %d  |  R Cancel: %d",
		STATE.stats.m1, STATE.stats.skills, STATE.stats.bfCombos, STATE.stats.rCancel)
	stats2.Text = string.format("Ghost:%d Pressure:%d\nPunish:%d Escape:%d Bait:%d",
		STATE.stats.ghost, STATE.stats.pressure,
		STATE.stats.punishes, STATE.stats.escapes, STATE.stats.baits)
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
		task.wait(0.27)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	pcall(function()
		mainLoop(dt)
	end)
end)

LP.CharacterAdded:Connect(function()
	task.wait(0.55)
	releaseAll()
	STATE.player.char = LP.Character
end)
