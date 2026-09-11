local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = {
	targeting = {
		maxDist = 300,
		lockDist = 48,
		preferIsolated = true,
		isolatedRadius = 26,
		switchThreatDist = 13,
		behindThreatDist = 11,
		updateRate = 0.11,
	},
	combat = {
		minRange = 2.2,
		optimalMin = 3.6,
		optimalMax = 7.1,
		attackRange = 7.5,
		m1Delay = 0.152,
		m1Break = 0.138,
		whiffBackoff = 0.65,
		behindOffset = 1.50,
		bfDelay = 0.30,
		bfBehindTimeout = 0.50,
		rCancelOnBlock = true,
	},
	movement = {
		dashCD = 0.70,
		sideDashCD = 0.74,
		backDashCD = 0.80,
		microInterval = 0.10,
		rotationSpeed = 0.55,
	},
	defense = {
		blockRange = 16.0,
		blockHoldExtra = 0.20,
		counterRange = 14.5,
		counterWindow = 0.60,
		counterCD = 1.25,
		lowHP = 36,
		escapeHP = 22,
		antiComboWindow = 0.80,
	},
	skills = {
		globalCD = 0.78,
		rCD = 2.05,
		[1] = {cd = 1.90, last = 0, key = Enum.KeyCode.One, maxRange = 10.5},
		[2] = {cd = 2.30, last = 0, key = Enum.KeyCode.Two, maxRange = 8.2},
		[3] = {cd = 1.75, last = 0, key = Enum.KeyCode.Three, maxRange = 8.0},
		[4] = {cd = 3.40, last = 0, key = Enum.KeyCode.Four, maxRange = 15.0},
	},
}

local STATE = {
	active = false,
	minimized = false,
	target = {
		root = nil, hum = nil, name = "", dist = 999,
		locked = false, lockTime = 0, lastHitTime = 0,
		isStunned = false, isBlocking = false, isAttacking = false, isSkill = false,
		lastAttackTime = 0, attackClearTime = 0, lastBlockTime = 0,
		vel = Vector3.zero, approaching = false,
	},
	player = {
		root = nil, hum = nil, char = nil,
		hp = 100, maxhp = 100, pos = Vector3.zero,
		isRagdoll = false, lastWhiff = 0, lastDamageTaken = 0,
	},
	input = {W=false,A=false,S=false,D=false,F=false,Space=false,Q=false,R=false},
	combat = {
		lock = false, comboActive = false,
		m1Count = 0, lastM1 = 0, lastHitConfirm = 0,
		bfActive = false, bfStep = 0,
		lastSkill = 0, lastWhiffAction = 0,
		skillWindup = false, currentSkill = 0,
		enemyBlocking = false, punishReady = false,
		lastComboUsed = 0, comboHistory = {0,0,0,0,0},
		historyIndex = 1,
	},
	defense = {
		blocking = false, blockStart = 0, blockEnd = 0,
		holding = false, lastCounter = 0, countering = false,
		counterEnd = 0, lastEscape = 0, escaping = false, antiCombo = false,
	},
	move = {
		mode = "idle", lastDash = 0, lastSide = 0, lastBack = 0,
		microClock = 0, lastRagdoll = 0, faceTarget = true,
	},
	skills = {globalLast = 0, rLast = 0, inProgress = false},
	stats = {
		m1 = 0, skills = 0, bf = 0, blocks = 0, counters = 0,
		kills = 0, escapes = 0, whiffs = 0,
	},
	cache = {lastScan = 0, nearby = 0, behindThreat = nil, lastKillCheck = 0},
	perf = {dt = 0.016, fps = 60, m1Delay = 0.152},
}

local function sendKey(down, key)
	pcall(function() VIM:SendKeyEvent(down, key, false, game) end)
end

local function sendClick(down)
	pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, down, game, 1) end)
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

local function releaseMove()
	release(Enum.KeyCode.W, "W")
	release(Enum.KeyCode.A, "A")
	release(Enum.KeyCode.S, "S")
	release(Enum.KeyCode.D, "D")
end

local function releaseAll()
	releaseMove()
	release(Enum.KeyCode.F, "F")
	release(Enum.KeyCode.Space, "Space")
	release(Enum.KeyCode.Q, "Q")
	release(Enum.KeyCode.R, "R")
	STATE.combat.lock = false
	STATE.combat.comboActive = false
	STATE.combat.bfActive = false
	STATE.combat.bfStep = 0
	STATE.combat.skillWindup = false
	STATE.combat.currentSkill = 0
	STATE.defense.blocking = false
	STATE.defense.holding = false
	STATE.defense.countering = false
	STATE.defense.escaping = false
	STATE.defense.antiCombo = false
	STATE.move.mode = "idle"
	STATE.move.faceTarget = true
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

local ANIM = {
	attack = {"attack","swing","punch","slash","m1","hit","strike","combo","jab","smash","uppercut","kick","beat","pummel","blow"},
	skill  = {"skill","technique","curse","special","ability","divergent","crushing","manji","barrage","blast"},
	stun   = {"stun","hitstun","stagger","downed","knockback","launch","ragdoll","tumble","hurt","flinch","fall","airborne"},
	block  = {"block","guard","parry","deflect","defend","shield","brace"},
	ragdoll= {"ragdoll","stagger","knockback","launch","tumble","fall","downed","hitstun","flung"},
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
		if Vector2.new(v.X, v.Z).Magnitude > 34 then return true end
		if math.abs(v.Y) > 34 then return true end
	end
	return false
end

local function isRagdoll(r, h)
	if not r or not h then return false end
	local v = r.AssemblyLinearVelocity or Vector3.zero
	if Vector2.new(v.X, v.Z).Magnitude > 34 then return true end
	if math.abs(v.Y) > 34 then return true end
	if h.PlatformStand or h.Sit then return true end
	return matchAnim(h, ANIM.ragdoll)
end

local function sameTeam(plr)
	return LP.Team and plr.Team == LP.Team
end

local function countAround(pos, radius, excludeRoot)
	local n = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local r = plr.Character:FindFirstChild("HumanoidRootPart")
			local h = plr.Character:FindFirstChildOfClass("Humanoid")
			if r and h and h.Health > 0 and r ~= excludeRoot then
				if (pos - r.Position).Magnitude <= radius then
					n = n + 1
				end
			end
		end
	end
	return n
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
	return true, h, r, d, p
end

local function scoreTarget(h, r, d, p)
	local score = (CFG.targeting.maxDist - d) / CFG.targeting.maxDist * 80
	score = score + (1 - h.Health / h.MaxHealth) * 40
	if isStunned(h, r) then score = score + 50 end
	if CFG.targeting.preferIsolated then
		local around = countAround(r.Position, CFG.targeting.isolatedRadius, r)
		score = score + math.max(0, 28 - around * 11)
	end
	return score
end

local function scanTargets(force)
	local my = getRoot()
	if not my then return end
	local now = tick()

	if not force and STATE.target.locked and STATE.target.root and STATE.target.hum and STATE.target.hum.Health > 0 then
		local d = (my.Position - STATE.target.root.Position).Magnitude
		STATE.target.dist = d
		if d < CFG.targeting.lockDist then
			local threatNear = false
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP and plr.Character then
					local r = plr.Character:FindFirstChild("HumanoidRootPart")
					local h = plr.Character:FindFirstChildOfClass("Humanoid")
					if r and h and h.Health > 0 and r ~= STATE.target.root then
						local td = (my.Position - r.Position).Magnitude
						if td < CFG.targeting.switchThreatDist and (isAttacking(h) or isSkill(h)) then
							threatNear = true
							break
						end
					end
				end
			end
			if not threatNear then
				STATE.target.lastSeen = now
				return
			end
		end
	end

	local bestScore, best = -1e9, nil
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local ok, h, r, d, p = validTarget(plr.Character, my.Position)
			if ok then
				local sc = scoreTarget(h, r, d, p)
				if sc > bestScore then
					bestScore = sc
					best = {root = r, hum = h, name = plr.Name, dist = d}
				end
			end
		end
	end

	if best and best.root then
		local changed = (not STATE.target.root) or (STATE.target.root ~= best.root)
		STATE.target.root = best.root
		STATE.target.hum = best.hum
		STATE.target.name = best.name
		STATE.target.dist = best.dist
		STATE.target.locked = true
		if changed then STATE.target.lockTime = now end
		STATE.target.lastSeen = now
	else
		STATE.target.root = nil
		STATE.target.hum = nil
		STATE.target.name = ""
		STATE.target.dist = 999
		STATE.target.locked = false
	end
end

local function detectBehindThreat()
	local my = getRoot()
	if not my then return nil end
	local myLook = my.CFrame.LookVector
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local r = plr.Character:FindFirstChild("HumanoidRootPart")
			local h = plr.Character:FindFirstChildOfClass("Humanoid")
			if r and h and h.Health > 0 then
				local to = (r.Position - my.Position)
				local dist = to.Magnitude
				if dist < CFG.targeting.behindThreatDist and dist > 1 then
					local flatTo = Vector3.new(to.X, 0, to.Z).Unit
					local flatLook = Vector3.new(myLook.X, 0, myLook.Z).Unit
					if flatLook:Dot(flatTo) < -0.35 then
						return {root = r, hum = h, dist = dist}
					end
				end
			end
		end
	end
	return nil
end

local function faceTarget(instant)
	local my = getRoot()
	if not my or not STATE.target.root then return end
	if not STATE.move.faceTarget then return end
	local look = Vector3.new(STATE.target.root.Position.X, my.Position.Y, STATE.target.root.Position.Z)
	if instant then
		my.CFrame = CFrame.lookAt(my.Position, look)
	else
		my.CFrame = my.CFrame:Lerp(CFrame.lookAt(my.Position, look), CFG.movement.rotationSpeed)
	end
end

local function facePosition(pos, instant)
	local my = getRoot()
	if not my then return end
	local look = Vector3.new(pos.X, my.Position.Y, pos.Z)
	if instant then
		my.CFrame = CFrame.lookAt(my.Position, look)
	else
		my.CFrame = my.CFrame:Lerp(CFrame.lookAt(my.Position, look), CFG.movement.rotationSpeed)
	end
end

local function canSkill(idx)
	if not idx or idx < 1 or idx > 4 then return false end
	local s = CFG.skills[idx]
	if not s then return false end
	local now = tick()
	if (now - s.last) < s.cd then return false end
	if (now - STATE.skills.globalLast) < CFG.skills.globalCD then return false end
	if STATE.skills.inProgress then return false end
	if STATE.target.dist > s.maxRange then return false end
	return true
end

local function skillReady(idx)
	if not idx or idx < 1 or idx > 4 then return false end
	local s = CFG.skills[idx]
	if not s then return false end
	local now = tick()
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
	task.wait(0.025)
	sendKey(false, Enum.KeyCode.R)
	STATE.skills.rLast = tick()
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
	faceTarget(true)
	sendKey(true, s.key)
	task.wait(0.055)
	sendKey(false, s.key)
	s.last = tick()
	STATE.skills.globalLast = tick()
	STATE.stats.skills = STATE.stats.skills + 1
	task.delay(0.15, function()
		STATE.skills.inProgress = false
		STATE.combat.skillWindup = false
		STATE.combat.currentSkill = 0
	end)
	return true
end

local function doM1()
	faceTarget(true)
	sendClick(true)
	task.wait(0.008)
	sendClick(false)
	STATE.combat.lastM1 = tick()
	STATE.stats.m1 = STATE.stats.m1 + 1
	STATE.combat.m1Count = STATE.combat.m1Count + 1
end

local function doDash()
	local now = tick()
	if (now - STATE.move.lastDash) < CFG.movement.dashCD then return false end
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.042, function() sendKey(false, Enum.KeyCode.Q) end)
	STATE.move.lastDash = now
	return true
end

local function sideDash(dir)
	local now = tick()
	if (now - STATE.move.lastSide) < CFG.movement.sideDashCD then return false end
	local my = getRoot()
	if not my or not STATE.target.root then return false end
	if not dir then
		dir = math.random() > 0.5 and "left" or "right"
	end
	local to = (STATE.target.root.Position - my.Position)
	if to.Magnitude < 0.1 then return false end
	to = to.Unit
	local right = Vector3.new(-to.Z, 0, to.X)
	local side = (dir == "right") and right or -right
	STATE.move.faceTarget = false
	my.CFrame = CFrame.lookAt(my.Position, my.Position + side)
	task.wait(0.018)
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.042, function()
		sendKey(false, Enum.KeyCode.Q)
		STATE.move.faceTarget = true
		if STATE.target.root then faceTarget(true) end
	end)
	STATE.move.lastSide = now
	return true
end

local function backDash()
	local now = tick()
	if (now - STATE.move.lastBack) < CFG.movement.backDashCD then return false end
	local my = getRoot()
	if not my or not STATE.target.root then return false end
	STATE.move.faceTarget = true
	faceTarget(true)
	press(Enum.KeyCode.S, "S")
	task.wait(0.03)
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.045, function()
		sendKey(false, Enum.KeyCode.Q)
		release(Enum.KeyCode.S, "S")
	end)
	STATE.move.lastBack = now
	return true
end

local function goBehind()
	local my = getRoot()
	if not my or not STATE.target.root then return false end
	local cf = STATE.target.root.CFrame * CFrame.new(0, 0, CFG.combat.behindOffset)
	my.CFrame = CFrame.lookAt(cf.Position, STATE.target.root.Position)
	my.AssemblyLinearVelocity = Vector3.zero
	return true
end

local function isBehindTarget()
	local my = getRoot()
	if not my or not STATE.target.root then return false end
	local toMe = (my.Position - STATE.target.root.Position)
	if toMe.Magnitude < 0.5 then return false end
	local look = STATE.target.root.CFrame.LookVector
	local flatToMe = Vector3.new(toMe.X, 0, toMe.Z).Unit
	local flatLook = Vector3.new(look.X, 0, look.Z).Unit
	return flatLook:Dot(flatToMe) > 0.42
end

local function recordCombo(id)
	STATE.combat.comboHistory[STATE.combat.historyIndex] = id
	STATE.combat.historyIndex = STATE.combat.historyIndex % 5 + 1
	STATE.combat.lastComboUsed = id
end

local function recentComboCount(id)
	local c = 0
	for i = 1, 5 do
		if STATE.combat.comboHistory[i] == id then c = c + 1 end
	end
	return c
end

local function blackFlashProper()
	if STATE.combat.bfActive or STATE.combat.lock then return false end
	if not canSkill(3) then return false end
	if STATE.target.dist > 9.2 then return false end
	STATE.combat.bfActive = true
	STATE.combat.lock = true
	STATE.combat.bfStep = 0
	recordCombo(1)
	task.spawn(function()
		local start = tick()
		while tick() - start < CFG.combat.bfBehindTimeout do
			if not STATE.active or not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then break end
			goBehind()
			if isBehindTarget() or STATE.target.dist <= 3.0 then break end
			task.wait(0.028)
		end
		if not STATE.active or not STATE.target.root then
			STATE.combat.bfActive = false
			STATE.combat.lock = false
			return
		end
		faceTarget(true)
		if castSkill(3) then
			STATE.combat.bfStep = 1
			task.wait(CFG.combat.bfDelay)
			if STATE.active and STATE.target.root and STATE.target.hum and STATE.target.hum.Health > 0 then
				sendKey(true, CFG.skills[3].key)
				task.wait(0.045)
				sendKey(false, CFG.skills[3].key)
				CFG.skills[3].last = tick()
				STATE.stats.skills = STATE.stats.skills + 1
				STATE.stats.bf = STATE.stats.bf + 1
			end
		end
		task.wait(0.11)
		STATE.combat.bfActive = false
		STATE.combat.lock = false
		STATE.combat.bfStep = 0
	end)
	return true
end

local function tryRCancel()
	if not STATE.combat.skillWindup then return false end
	if not canR() then return false end
	if STATE.target.isBlocking or STATE.combat.enemyBlocking then
		if CFG.combat.rCancelOnBlock then
			if castR() then
				task.wait(0.05)
				backDash()
				return true
			end
		end
	end
	return false
end

local function registerWhiff()
	STATE.player.lastWhiff = tick()
	STATE.stats.whiffs = STATE.stats.whiffs + 1
	STATE.combat.lastWhiffAction = tick()
end

local function shouldBackoff()
	return (tick() - STATE.player.lastWhiff) < CFG.combat.whiffBackoff
end

local function comboM1IntoSkill(skillIdx)
	if STATE.combat.lock or STATE.combat.comboActive then return false end
	if shouldBackoff() then return false end
	if STATE.target.dist < CFG.combat.minRange or STATE.target.dist > CFG.combat.attackRange then return false end
	if STATE.target.isBlocking or STATE.combat.enemyBlocking then return false end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	recordCombo(skillIdx + 1)
	task.spawn(function()
		local d = STATE.perf.m1Delay
		faceTarget(true)
		doM1()
		task.wait(d)
		if STATE.target.isBlocking or STATE.target.dist > CFG.combat.attackRange + 1.2 then
			registerWhiff()
			backDash()
			STATE.combat.lock = false
			STATE.combat.comboActive = false
			return
		end
		doM1()
		task.wait(d)
		if STATE.target.isBlocking or STATE.target.dist > CFG.combat.attackRange + 1.2 then
			registerWhiff()
			backDash()
			STATE.combat.lock = false
			STATE.combat.comboActive = false
			return
		end
		doM1()
		task.wait(0.08)
		if skillIdx == 3 and canSkill(3) then
			blackFlashProper()
		elseif canSkill(skillIdx) then
			castSkill(skillIdx)
			task.delay(0.12, function() tryRCancel() end)
		elseif canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		end
		task.wait(0.17)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
	end)
	return true
end

local function comboInterrupted()
	if STATE.combat.lock or STATE.combat.comboActive then return false end
	if shouldBackoff() then return false end
	if STATE.target.dist < CFG.combat.minRange or STATE.target.dist > CFG.combat.attackRange then return false end
	if STATE.target.isBlocking then return false end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	recordCombo(3)
	task.spawn(function()
		local d = STATE.perf.m1Delay
		faceTarget(true)
		doM1()
		task.wait(d)
		doM1()
		task.wait(CFG.combat.m1Break)
		doM1()
		task.wait(0.08)
		if canSkill(3) then
			blackFlashProper()
		elseif canSkill(1) then
			castSkill(1)
		elseif canSkill(2) then
			castSkill(2)
		end
		task.wait(0.16)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
	end)
	return true
end

local function comboSideIntoM1()
	if STATE.combat.lock or STATE.combat.comboActive then return false end
	if shouldBackoff() then return false end
	if STATE.target.dist < 4 or STATE.target.dist > 12 then return false end
	STATE.combat.lock = true
	STATE.combat.comboActive = true
	recordCombo(4)
	task.spawn(function()
		sideDash(math.random() > 0.5 and "left" or "right")
		task.wait(0.14)
		if not STATE.target.root or STATE.target.dist > CFG.combat.attackRange + 2 then
			STATE.combat.lock = false
			STATE.combat.comboActive = false
			return
		end
		faceTarget(true)
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
		task.wait(0.15)
		STATE.combat.lock = false
		STATE.combat.comboActive = false
	end)
	return true
end

local function decideBestCombo()
	local dist = STATE.target.dist
	local stunned = STATE.target.isStunned
	local blocking = STATE.target.isBlocking or STATE.combat.enemyBlocking
	local nearby = countAround(STATE.player.pos, 13, STATE.target.root)

	if blocking then
		if skillReady(3) and dist <= 9 then
			if goBehind() then
				task.wait(0.04)
				return blackFlashProper()
			end
		end
		if skillReady(1) and dist <= CFG.skills[1].maxRange then
			return castSkill(1)
		end
		return backDash()
	end

	if stunned then
		if skillReady(3) and dist <= 9 then
			return blackFlashProper()
		end
		if skillReady(1) and dist <= CFG.skills[1].maxRange then
			return comboM1IntoSkill(1)
		end
		if skillReady(2) and dist <= CFG.skills[2].maxRange then
			return comboM1IntoSkill(2)
		end
		return comboInterrupted()
	end

	if dist >= CFG.combat.minRange and dist <= CFG.combat.attackRange then
		if skillReady(3) and nearby <= 1 then
			return blackFlashProper()
		end
		if skillReady(1) and recentComboCount(2) < 4 then
			return comboM1IntoSkill(1)
		end
		if skillReady(2) and recentComboCount(3) < 3 then
			return comboM1IntoSkill(2)
		end
		if recentComboCount(4) < 3 and dist >= 4.5 then
			return comboSideIntoM1()
		end
		return comboInterrupted()
	end

	if dist > CFG.combat.attackRange and dist <= 13 then
		if skillReady(1) and dist <= CFG.skills[1].maxRange then
			return castSkill(1)
		end
	end

	return false
end

local function handleBlock()
	if not STATE.target.hum then return end
	local now = tick()
	local dist = STATE.target.dist
	local atk = isAttacking(STATE.target.hum)
	local sk = isSkill(STATE.target.hum)
	local st = STATE.target.isStunned

	if atk or sk then
		STATE.target.lastAttackTime = now
		STATE.target.attackClearTime = 0
	else
		if STATE.target.lastAttackTime > 0 and STATE.target.attackClearTime == 0 then
			STATE.target.attackClearTime = now
		end
	end

	if st then
		if STATE.defense.blocking or STATE.defense.holding then
			release(Enum.KeyCode.F, "F")
			STATE.defense.blocking = false
			STATE.defense.holding = false
			STATE.defense.blockEnd = now
		end
		return
	end

	local shouldBlock = false
	if (atk or sk) and dist <= CFG.defense.blockRange then
		shouldBlock = true
	elseif STATE.target.approaching and dist < 10.5 and dist > 4 then
		shouldBlock = true
	end

	if shouldBlock then
		faceTarget(true)
		if not STATE.defense.blocking and not STATE.defense.holding then
			if (now - STATE.defense.blockEnd) > 0.20 then
				press(Enum.KeyCode.F, "F")
				STATE.defense.blocking = true
				STATE.defense.holding = true
				STATE.defense.blockStart = now
				STATE.stats.blocks = STATE.stats.blocks + 1
			end
		else
			faceTarget(true)
		end
	else
		if STATE.defense.holding then
			if STATE.target.attackClearTime > 0 and (now - STATE.target.attackClearTime) >= CFG.defense.blockHoldExtra then
				release(Enum.KeyCode.F, "F")
				STATE.defense.blocking = false
				STATE.defense.holding = false
				STATE.defense.blockEnd = now
				STATE.combat.punishReady = true
			end
		end
	end
end

local function handleCounter()
	if not STATE.target.hum then return end
	if STATE.defense.countering then return end
	local dist = STATE.target.dist
	local now = tick()
	if (now - STATE.defense.lastCounter) < CFG.defense.counterCD then return end
	if dist > CFG.defense.counterRange then return end

	local enemyAboutToHit = isAttacking(STATE.target.hum) or isSkill(STATE.target.hum) or STATE.target.approaching
	if not enemyAboutToHit then return end

	if canSkill(4) then
		faceTarget(true)
		if castSkill(4) then
			STATE.defense.countering = true
			STATE.defense.lastCounter = now
			STATE.defense.counterEnd = now + CFG.defense.counterWindow
			STATE.stats.counters = STATE.stats.counters + 1
			task.delay(CFG.defense.counterWindow + 0.1, function()
				STATE.defense.countering = false
			end)
		end
	end
end

local function handleAntiCombo()
	local now = tick()
	if STATE.player.lastDamageTaken > 0 and (now - STATE.player.lastDamageTaken) < CFG.defense.antiComboWindow then
		if not STATE.defense.antiCombo then
			STATE.defense.antiCombo = true
			sideDash(math.random() > 0.5 and "left" or "right")
			task.delay(0.10, function()
				if canSkill(4) then
					faceTarget(true)
					castSkill(4)
				else
					press(Enum.KeyCode.F, "F")
					task.delay(0.28, function() release(Enum.KeyCode.F, "F") end)
				end
				STATE.defense.antiCombo = false
			end)
		end
	end
end

local function handlePunish()
	if not STATE.combat.punishReady then return end
	if STATE.combat.lock then return end
	STATE.combat.punishReady = false
	STATE.combat.lock = true
	task.spawn(function()
		faceTarget(true)
		task.wait(0.025)
		doM1()
		task.wait(STATE.perf.m1Delay * 0.85)
		if STATE.target.dist <= 8 and canSkill(3) then
			blackFlashProper()
		elseif canSkill(1) then
			castSkill(1)
		end
		task.wait(0.14)
		STATE.combat.lock = false
	end)
end

local function handleRagdoll()
	local my = getRoot()
	local hum = getHum()
	if not my or not hum then return false end
	if isRagdoll(my, hum) then
		STATE.player.isRagdoll = true
		local now = tick()
		if (now - STATE.move.lastRagdoll) < 0.35 then return true end
		STATE.move.lastRagdoll = now
		releaseAll()
		local sideKey = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
		local fwdKey = math.random() > 0.5 and Enum.KeyCode.W or Enum.KeyCode.S
		task.spawn(function()
			if math.random() < 0.45 then
				sendKey(true, Enum.KeyCode.Space)
				task.delay(0.08, function() sendKey(false, Enum.KeyCode.Space) end)
			end
			sendKey(true, sideKey)
			sendKey(true, fwdKey)
			sendKey(true, Enum.KeyCode.Q)
			task.wait(0.048)
			sendKey(false, Enum.KeyCode.Q)
			task.wait(0.03)
			sendKey(false, sideKey)
			sendKey(false, fwdKey)
		end)
		return true
	end
	STATE.player.isRagdoll = false
	return false
end

local function emergencyEscape()
	local now = tick()
	if (now - STATE.defense.lastEscape) < 1.0 then return false end
	if STATE.defense.escaping then return false end
	STATE.defense.escaping = true
	STATE.defense.lastEscape = now
	STATE.stats.escapes = STATE.stats.escapes + 1
	releaseAll()
	local sideKey = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
	sendKey(true, sideKey)
	sendKey(true, Enum.KeyCode.Q)
	task.delay(0.05, function()
		sendKey(false, Enum.KeyCode.Q)
		sendKey(false, sideKey)
		STATE.defense.escaping = false
	end)
	return true
end

local function updateMovement(dt)
	local my = getRoot()
	if not my or not STATE.target.root then
		releaseMove()
		STATE.move.mode = "idle"
		return
	end
	local dist = STATE.target.dist
	local hp = STATE.player.hp

	local vel = STATE.target.root.AssemblyLinearVelocity or Vector3.zero
	local toMe = (my.Position - STATE.target.root.Position)
	if toMe.Magnitude > 0.1 and vel.Magnitude > 1 then
		local approachDot = vel.Unit:Dot((-toMe).Unit)
		STATE.target.approaching = approachDot > 0.35 and vel.Magnitude > 6
	else
		STATE.target.approaching = false
	end

	if shouldBackoff() then
		STATE.move.mode = "backoff"
		STATE.move.faceTarget = true
		faceTarget(false)
		release(Enum.KeyCode.W, "W")
		press(Enum.KeyCode.S, "S")
		if (tick() - STATE.move.lastBack) > CFG.movement.backDashCD then
			backDash()
		elseif (tick() - STATE.move.lastSide) > CFG.movement.sideDashCD then
			sideDash(math.random() > 0.5 and "left" or "right")
		end
		return
	end

	if hp <= CFG.defense.escapeHP and dist < 8 then
		STATE.move.mode = "escape"
		if dist < 5.5 then
			faceTarget(true)
			if canSkill(4) then
				castSkill(4)
			else
				press(Enum.KeyCode.F, "F")
				task.delay(0.3, function() release(Enum.KeyCode.F, "F") end)
			end
		else
			emergencyEscape()
		end
		return
	end

	if hp <= CFG.defense.lowHP then
		STATE.move.mode = "survive"
		if dist < 6.5 then
			faceTarget(true)
			if canSkill(4) then
				castSkill(4)
			else
				press(Enum.KeyCode.F, "F")
				task.delay(0.28, function() release(Enum.KeyCode.F, "F") end)
			end
		elseif dist < 10 then
			release(Enum.KeyCode.W, "W")
			press(Enum.KeyCode.S, "S")
			if (tick() - STATE.move.lastBack) > CFG.movement.backDashCD then
				backDash()
			elseif (tick() - STATE.move.lastSide) > CFG.movement.sideDashCD then
				sideDash(math.random() > 0.5 and "left" or "right")
			end
			faceTarget(false)
		else
			release(Enum.KeyCode.S, "S")
			press(Enum.KeyCode.W, "W")
			faceTarget(false)
		end
		return
	end

	STATE.move.faceTarget = true

	if dist > 15.5 then
		STATE.move.mode = "approach"
		press(Enum.KeyCode.W, "W")
		release(Enum.KeyCode.S, "S")
		faceTarget(false)
		if dist > 21 and (tick() - STATE.move.lastDash) > CFG.movement.dashCD then
			if math.random() < 0.55 then
				local sideKey = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
				local flag = sideKey == Enum.KeyCode.A and "A" or "D"
				press(sideKey, flag)
				doDash()
				task.delay(0.09, function()
					release(Enum.KeyCode.A, "A")
					release(Enum.KeyCode.D, "D")
				end)
			else
				doDash()
			end
		end
	elseif dist > CFG.combat.optimalMax then
		STATE.move.mode = "close"
		press(Enum.KeyCode.W, "W")
		release(Enum.KeyCode.S, "S")
		faceTarget(false)
		STATE.move.microClock = STATE.move.microClock + dt
		if STATE.move.microClock > CFG.movement.microInterval then
			STATE.move.microClock = 0
			if (tick() - STATE.move.lastSide) > CFG.movement.sideDashCD and math.random() < 0.4 then
				sideDash(math.random() > 0.5 and "left" or "right")
			end
		end
	elseif dist >= CFG.combat.optimalMin and dist <= CFG.combat.optimalMax then
		STATE.move.mode = "optimal"
		releaseMove()
		faceTarget(true)
		STATE.move.microClock = STATE.move.microClock + dt
		if STATE.move.microClock > CFG.movement.microInterval then
			STATE.move.microClock = 0
			local r = math.random()
			if r < 0.35 then
				press(Enum.KeyCode.W, "W")
				task.delay(0.045, function() release(Enum.KeyCode.W, "W") end)
			elseif r < 0.55 then
				press(Enum.KeyCode.S, "S")
				task.delay(0.04, function() release(Enum.KeyCode.S, "S") end)
			elseif r < 0.75 and (tick() - STATE.move.lastSide) > CFG.movement.sideDashCD then
				sideDash(math.random() > 0.5 and "left" or "right")
			end
		end
	elseif dist < CFG.combat.minRange then
		STATE.move.mode = "reset"
		release(Enum.KeyCode.W, "W")
		press(Enum.KeyCode.S, "S")
		faceTarget(true)
		if (tick() - STATE.move.lastBack) > CFG.movement.backDashCD then
			backDash()
		elseif (tick() - STATE.move.lastSide) > CFG.movement.sideDashCD then
			sideDash(math.random() > 0.5 and "left" or "right")
		end
	else
		STATE.move.mode = "neutral"
		faceTarget(true)
	end
end

local function updateTargetState()
	if not STATE.target.hum or not STATE.target.root then return end
	STATE.target.isStunned = isStunned(STATE.target.hum, STATE.target.root)
	STATE.target.isBlocking = isBlocking(STATE.target.hum)
	STATE.target.isAttacking = isAttacking(STATE.target.hum)
	STATE.target.isSkill = isSkill(STATE.target.hum)
	STATE.target.vel = STATE.target.root.AssemblyLinearVelocity or Vector3.zero
	if STATE.target.isBlocking then
		STATE.target.lastBlockTime = tick()
		STATE.combat.enemyBlocking = true
	else
		if (tick() - STATE.target.lastBlockTime) > 0.4 then
			STATE.combat.enemyBlocking = false
		end
	end
end

local function updatePlayerState()
	local r = getRoot()
	local h = getHum()
	if r then
		STATE.player.root = r
		STATE.player.pos = r.Position
	end
	if h then
		local oldHP = STATE.player.hp
		STATE.player.hum = h
		STATE.player.hp = h.Health
		STATE.player.maxhp = h.MaxHealth
		if h.Health < oldHP - 1 then
			STATE.player.lastDamageTaken = tick()
		end
	end
end

local function checkKill()
	local now = tick()
	if now - STATE.cache.lastKillCheck < 0.3 then return end
	STATE.cache.lastKillCheck = now
	if STATE.target.hum and STATE.target.hum.Health <= 0 and STATE.target.locked then
		STATE.stats.kills = STATE.stats.kills + 1
		STATE.target.locked = false
		STATE.target.root = nil
		STATE.target.hum = nil
	end
end

local function combatDecision()
	if STATE.combat.lock or STATE.combat.bfActive or STATE.combat.comboActive then
		tryRCancel()
		return
	end
	if not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then return end
	if shouldBackoff() then return end

	local dist = STATE.target.dist

	local behind = detectBehindThreat()
	if behind then
		STATE.cache.behindThreat = behind
		facePosition(behind.root.Position, true)
		if behind.dist < 9 then
			if canSkill(4) then
				castSkill(4)
				return
			else
				press(Enum.KeyCode.F, "F")
				task.delay(0.3, function() release(Enum.KeyCode.F, "F") end)
				return
			end
		end
	else
		STATE.cache.behindThreat = nil
	end

	if STATE.player.hp <= CFG.defense.escapeHP and dist < 8 then
		if dist < 5.5 and canSkill(4) then
			faceTarget(true)
			castSkill(4)
		else
			emergencyEscape()
		end
		return
	end

	decideBestCombo()
end

local function mainLoop(dt)
	if not STATE.active then return end
	STATE.perf.dt = dt
	STATE.perf.fps = math.floor(1 / math.max(dt, 0.001))
	updatePlayerState()
	local my = STATE.player.root
	local hum = STATE.player.hum
	if not my or not hum or hum.Health <= 0 then return end

	if handleRagdoll() then return end

	local now = tick()
	if (now - STATE.cache.lastScan) >= CFG.targeting.updateRate then
		scanTargets(false)
		STATE.cache.lastScan = now
	end

	if not STATE.target.root or not STATE.target.hum or STATE.target.hum.Health <= 0 then
		checkKill()
		scanTargets(true)
		if not STATE.target.root then
			releaseAll()
			return
		end
	end

	STATE.target.dist = (my.Position - STATE.target.root.Position).Magnitude
	updateTargetState()
	handleBlock()
	handleCounter()
	handleAntiCombo()
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
Main.Size = UDim2.new(0, 270, 0, 178)
Main.Position = UDim2.new(0, 40, 0, 80)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = SG

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = Main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 70, 70)
mainStroke.Thickness = 1.2
mainStroke.Transparency = 0.35
mainStroke.Parent = Main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
topBar.BorderSizePixel = 0
topBar.Parent = Main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "YUJI PRO BOT"
title.TextColor3 = Color3.fromRGB(255, 220, 90)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 24)
minBtn.Position = UDim2.new(1, -62, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -32)
content.Position = UDim2.new(0, 0, 0, 32)
content.BackgroundTransparency = 1
content.Parent = Main

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 32)
toggleBtn.Position = UDim2.new(0, 10, 0, 6)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = content

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local stats1 = Instance.new("TextLabel")
stats1.Size = UDim2.new(1, -20, 0, 34)
stats1.Position = UDim2.new(0, 10, 0, 44)
stats1.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
stats1.TextColor3 = Color3.fromRGB(200, 200, 210)
stats1.Text = "Kills: 0  |  M1: 0\nBF: 0  |  Skills: 0"
stats1.TextSize = 12
stats1.Font = Enum.Font.Code
stats1.BorderSizePixel = 0
stats1.Parent = content

local stats1Corner = Instance.new("UICorner")
stats1Corner.CornerRadius = UDim.new(0, 6)
stats1Corner.Parent = stats1

local stats2 = Instance.new("TextLabel")
stats2.Size = UDim2.new(1, -20, 0, 34)
stats2.Position = UDim2.new(0, 10, 0, 84)
stats2.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
stats2.TextColor3 = Color3.fromRGB(255, 140, 140)
stats2.Text = "Block: 0  |  Counter: 0\nMode: idle"
stats2.TextSize = 12
stats2.Font = Enum.Font.Code
stats2.BorderSizePixel = 0
stats2.Parent = content

local stats2Corner = Instance.new("UICorner")
stats2Corner.CornerRadius = UDim.new(0, 6)
stats2Corner.Parent = stats2

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -16, 0, 16)
credit.Position = UDim2.new(0, 8, 1, -20)
credit.BackgroundTransparency = 1
credit.Text = "Make By HKTD Roblox"
credit.TextColor3 = Color3.fromRGB(120, 120, 130)
credit.TextSize = 11
credit.Font = Enum.Font.Gotham
credit.TextXAlignment = Enum.TextXAlignment.Center
credit.Parent = content

local fullSize = UDim2.new(0, 270, 0, 178)
local miniSize = UDim2.new(0, 270, 0, 32)

local function refreshStats()
	stats1.Text = string.format("Kills: %d  |  M1: %d\nBF: %d  |  Skills: %d",
		STATE.stats.kills, STATE.stats.m1, STATE.stats.bf, STATE.stats.skills)
	stats2.Text = string.format("Block: %d  |  Counter: %d\nMode: %s",
		STATE.stats.blocks, STATE.stats.counters, STATE.move.mode)
end

toggleBtn.MouseButton1Click:Connect(function()
	STATE.active = not STATE.active
	if STATE.active then
		releaseAll()
		scanTargets(true)
		toggleBtn.Text = "STOP"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 140, 70)
	else
		releaseAll()
		toggleBtn.Text = "START"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	end
end)

minBtn.MouseButton1Click:Connect(function()
	STATE.minimized = not STATE.minimized
	if STATE.minimized then
		Main.Size = miniSize
		content.Visible = false
		minBtn.Text = "+"
	else
		Main.Size = fullSize
		content.Visible = true
		minBtn.Text = "—"
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
		if STATE.active then refreshStats() end
		task.wait(0.28)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	pcall(function() mainLoop(dt) end)
end)

LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	releaseAll()
	STATE.player.char = LP.Character
	STATE.target.locked = false
end)
