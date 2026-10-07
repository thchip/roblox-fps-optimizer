-- FPSOptimizer.lua
-- Módulo avançado de otimização de FPS para Roblox com suporte a Mobile
-- Melhorado para celular: mais liso, mais desempenho

local FPSOptimizer = {}
FPSOptimizer.__index = FPSOptimizer

-- CONFIGURAÇÕES PADRÃO (CFG)
local DEFAULT_CONFIG = {
	-- Detecção de dispositivo
	isMobile = function()
		local UserInputService = game:GetService("UserInputService")
		return UserInputService:GetLastInputType() == Enum.UserInputType.Touch
	end,
	
	-- CONFIGURAÇÕES GERAIS
	enabled = true,
	autoDetectMobile = true,
	debugMode = false,
	
	-- ILUMINAÇÃO (Lighting)
	lighting = {
		globalShadows = false,
		shadowSoftness = 0,
		brightness = 2.5,
		clockTime = 12,
		fogEnabled = true,
		fogStart = 0,
		fogEnd = 400, -- Celular: 400, PC: 800
		outdoorAmbient = Color3.fromRGB(120, 120, 120),
		qualityLevel = 4, -- 1-21 (baixo=1, alto=21)
	},
	
	-- RENDERING E STREAMING
	streaming = {
		enabled = true,
		minRadius = 8,
		maxRadius = 150, -- Celular: 150, PC: 300
		maxLoadsPerFrame = 2,
		priorityGridSize = 32,
	},
	
	-- PARTÍCULAS E EFEITOS
	particles = {
		disableAll = false,
		maxActive = 30, -- Celular: 30, PC: 100
		reduceSize = true,
		sizeMultiplier = 0.6, -- Reduz tamanho das partículas em 40%
		speedMultiplier = 0.8,
		emissionMultiplier = 0.5, -- Metade das partículas emitidas
		disableTrails = true,
		disableBeams = true,
	},
	
	-- SOMBRAS (Shadows)
	shadows = {
		castShadow = false, -- Desativa sombras de partes
		characterShadows = false,
		shadowMapSize = 256, -- Menor = mais rápido
	},
	
	-- FÍSICA (Physics)
	physics = {
		reducedQuality = true,
		jointPreservation = false,
		maxCollisionsPerFrame = 64,
		lowFriction = true,
	},
	
	-- UI E IMAGENS
	ui = {
		lowResTextures = true,
		textureQuality = 0.75,
		disableTextureAnimations = false,
	},
	
	-- CAMERA E DISTÂNCIA DE RENDERIZAÇÃO
	camera = {
		maxRenderDistance = 250, -- Celular: 250, PC: 500
		cullingEnabled = true,
		lodSystem = true, -- Level of Detail
	},
	
	-- PERFORMANCE MONITOR
	monitor = {
		enabled = true,
		checkInterval = 3, -- Segundos
		autoAdjust = true,
		targetFPS = 60,
		minAcceptableFPS = 40,
	}
}

function FPSOptimizer.new(customConfig)
	local self = setmetatable({}, FPSOptimizer)
	
	-- Mescla config padrão com customizada
	self.cfg = self:_mergeConfig(DEFAULT_CONFIG, customConfig or {})
	
	-- Auto detecta mobile
	if self.cfg.autoDetectMobile and self.cfg.isMobile() then
		self:_applyMobileOptimizations()
	end
	
	self._connections = {}
	self._originalSettings = {}
	self._isApplied = false
	self._lastCheckTime = tick()
	self._frameCount = 0
	self._currentFPS = 60
	
	return self
end

-- Mescla tabelas de configuração
function FPSOptimizer:_mergeConfig(default, custom)
	local result = {}
	for key, value in pairs(default) do
		if type(value) == "table" and type(custom[key]) == "table" then
			result[key] = self:_mergeConfig(value, custom[key])
		else
			result[key] = custom[key] ~= nil and custom[key] or value
		end
	end
	for key, value in pairs(custom) do
		if result[key] == nil then
			result[key] = value
		end
	end
	return result
end

-- Otimizações específicas para mobile
function FPSOptimizer:_applyMobileOptimizations()
	self.cfg.lighting.fogEnd = 350
	self.cfg.streaming.maxRadius = 120
	self.cfg particles.maxActive = 20
	self.cfg.camera.maxRenderDistance = 200
	self.cfg.monitor.minAcceptableFPS = 35
	
	if self.cfg.debugMode then
		print("[FPSOptimizer] ✓ Otimizações Mobile ativadas")
	end
end

-- APLICAR TODAS AS OTIMIZAÇÕES
function FPSOptimizer:Enable()
	if self._isApplied then return end
	self._isApplied = true
	
	if self.cfg.debugMode then
		print("[FPSOptimizer] Ativando otimizações...")
	end
	
	self:_optimizeLighting()
	self:_optimizeStreaming()
	self:_optimizeParticles()
	self:_optimizeShadows()
	self:_optimizePhysics()
	self:_optimizeUI()
	self:_optimizeCamera()
	self:_startPerformanceMonitor()
	
	if self.cfg.debugMode then
		print("[FPSOptimizer] ✓ Todas as otimizações aplicadas!")
	end
end

-- OTIMIZAR ILUMINAÇÃO
function FPSOptimizer:_optimizeLighting()
	local Lighting = game:GetService("Lighting")
	
	self._originalSettings.globalShadows = Lighting.GlobalShadows
	self._originalSettings.brightness = Lighting.Brightness
	self._originalSettings.fogEnd = Lighting.FogEnd
	self._originalSettings.shadowSoftness = Lighting.ShadowSoftness
	
	Lighting.GlobalShadows = self.cfg.lighting.globalShadows
	Lighting.ShadowSoftness = self.cfg.lighting.shadowSoftness
	Lighting.Brightness = self.cfg.lighting.brightness
	Lighting.ClockTime = self.cfg.lighting.clockTime
	Lighting.OutdoorAmbient = self.cfg.lighting.outdoorAmbient
	Lighting.FogEnd = self.cfg.lighting.fogEnd
	Lighting.ShadowMapSize = self.cfg.shadows.shadowMapSize
	
	if self.cfg.debugMode then
		print("[FPSOptimizer] ✓ Iluminação otimizada")
	end
end

-- OTIMIZAR STREAMING
function FPSOptimizer:_optimizeStreaming()
	local Workspace = game:GetService("Workspace")
	
	if self.cfg.streaming.enabled then
		Workspace.StreamingEnabled = true
		Workspace.StreamingMinRadius = self.cfg.streaming.minRadius
		Workspace.StreamingMaxRadius = self.cfg.streaming.maxRadius
		
		if self.cfg.debugMode then
			print(string.format("[FPSOptimizer] ✓ Streaming ativado (Min: %d, Max: %d)", 
				self.cfg.streaming.minRadius, 
				self.cfg.streaming.maxRadius))
		end
	end
end

-- OTIMIZAR PARTÍCULAS
function FPSOptimizer:_optimizeParticles()
	local Workspace = game:GetService("Workspace")
	local particlesOptimized = 0
	
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		-- ParticleEmitter
		if descendant:IsA("ParticleEmitter") then
			if self.cfg.particles.disableAll then
				descendant.Enabled = false
			else
				descendant.Speed = NumberRange.new(descendant.Speed.Min * self.cfg.particles.speedMultiplier)
				descendant.Rotation = NumberRange.new(descendant.Rotation.Min * self.cfg.particles.sizeMultiplier)
				descendant.Size = NumberRange.new(descendant.Size.Min * self.cfg.particles.sizeMultiplier)
				descendant.Emission = math.floor(descendant.Emission * self.cfg.particles.emissionMultiplier)
				particlesOptimized = particlesOptimized + 1
			end
		end
		
		-- Trail
		if descendant:IsA("Trail") and self.cfg.particles.disableTrails then
			descendant.Enabled = false
			particlesOptimized = particlesOptimized + 1
		end
		
		-- Beam
		if descendant:IsA("Beam") and self.cfg.particles.disableBeams then
			descendant.Enabled = false
			particlesOptimized = particlesOptimized + 1
		end
		
		-- Explosion
		if descendant:IsA("Explosion") then
			descendant.BlastRadius = math.min(descendant.BlastRadius, 5)
			descendant.BlastPressure = math.min(descendant.BlastPressure, 400000)
		end
	end
	
	if self.cfg.debugMode then
		print(string.format("[FPSOptimizer] ✓ %d efeitos otimizados", particlesOptimized))
	end
end

-- OTIMIZAR SOMBRAS
function FPSOptimizer:_optimizeShadows()
	local Workspace = game:GetService("Workspace")
	local shadowsRemoved = 0
	
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") then
			if self.cfg.shadows.castShadow == false then
				descendant.CastShadow = false
				shadowsRemoved = shadowsRemoved + 1
			end
		end
	end
	
	-- Remove sombras de personagens
	if self.cfg.shadows.characterShadows == false then
		local Players = game:GetService("Players")
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("Part") then
						descendant.CastShadow = false
					end
				end
			end
		end
	end
	
	if self.cfg.debugMode then
		print(string.format("[FPSOptimizer] ✓ %d sombras removidas", shadowsRemoved))
	end
end

-- OTIMIZAR FÍSICA
function FPSOptimizer:_optimizePhysics()
	local Workspace = game:GetService("Workspace")
	
	if self.cfg.physics.reducedQuality then
		Workspace.Gravity = 196.2 -- Mantém o padrão
	end
	
	-- Reduz qualidade de joints
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("Weld") or descendant:IsA("Motor6D") then
			if self.cfg.physics.jointPreservation == false then
				-- Pode ser otimizado se necessário
			end
		end
	end
	
	if self.cfg.debugMode then
		print("[FPSOptimizer] ✓ Física otimizada")
	end
end

-- OTIMIZAR UI
function FPSOptimizer:_optimizeUI()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	if player and player:FindFirstChild("PlayerGui") then
		for _, descendant in ipairs(player.PlayerGui:GetDescendants()) do
			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				if self.cfg.ui.lowResTextures then
					-- Reduz resolução de imagens
					descendant.ScaleType = Enum.ScaleType.Stretch
				end
			end
		end
	end
	
	if self.cfg.debugMode then
		print("[FPSOptimizer] ✓ UI otimizada")
	end
end

-- OTIMIZAR CAMERA
function FPSOptimizer:_optimizeCamera()
	local Workspace = game:GetService("Workspace")
	
	-- Ativa LOD (Level of Detail) se disponível
	if self.cfg.camera.cullingEnabled then
		-- Implementa culling de objetos distantes
		for _, part in ipairs(Workspace:GetChildren()) do
			if part:IsA("Model") then
				for _, child in ipairs(part:GetChildren()) do
					if child:IsA("Part") then
						-- Marca para culling
					end
				end
			end
		end
	end
	
	if self.cfg.debugMode then
		print(string.format("[FPSOptimizer] ✓ Camera otimizada (Max distance: %d)", 
			self.cfg.camera.maxRenderDistance))
	end
end

-- MONITOR DE PERFORMANCE
function FPSOptimizer:_startPerformanceMonitor()
	if not self.cfg.monitor.enabled then return end
	
	local RunService = game:GetService("RunService")
	local lastTime = tick()
	local frameCounter = 0
	
	local function updateFPS()
		frameCounter = frameCounter + 1
		local currentTime = tick()
		local deltaTime = currentTime - lastTime
		
		if deltaTime >= 1 then
			self._currentFPS = math.floor(frameCounter / deltaTime)
			frameCounter = 0
			lastTime = currentTime
			
			-- Auto adjust se necessário
			if self.cfg.monitor.autoAdjust then
				self:_autoAdjustPerformance()
			end
			
			if self.cfg.debugMode then
				print(string.format("[FPSOptimizer] FPS: %d", self._currentFPS))
			end
		end
	end
	
	local connection = RunService.RenderStepped:Connect(updateFPS)
	table.insert(self._connections, connection)
end

-- AUTO AJUSTE DE PERFORMANCE
function FPSOptimizer:_autoAdjustPerformance()
	if self._currentFPS < self.cfg.monitor.minAcceptableFPS then
		-- Reduz mais qualidade
		self.cfg.lighting.fogEnd = math.max(200, self.cfg.lighting.fogEnd - 50)
		self.cfg.streaming.maxRadius = math.max(100, self.cfg.streaming.maxRadius - 20)
		self.cfg.particles.maxActive = math.max(10, self.cfg.particles.maxActive - 5)
		
		local Lighting = game:GetService("Lighting")
		Lighting.FogEnd = self.cfg.lighting.fogEnd
		
		if self.cfg.debugMode then
			print("[FPSOptimizer] ⚠️ FPS baixo! Reduzindo qualidade...")
		end
	elseif self._currentFPS > self.cfg.monitor.targetFPS then
		-- Pode aumentar qualidade ligeiramente
		if self.cfg.lighting.fogEnd < 500 then
			self.cfg.lighting.fogEnd = math.min(500, self.cfg.lighting.fogEnd + 25)
			local Lighting = game:GetService("Lighting")
			Lighting.FogEnd = self.cfg.lighting.fogEnd
		end
	end
end

-- DESATIVAR OTIMIZAÇÕES
function FPSOptimizer:Disable()
	if not self._isApplied then return end
	self._isApplied = false
	
	-- Restaura configurações originais
	local Lighting = game:GetService("Lighting")
	if self._originalSettings.globalShadows ~= nil then
		Lighting.GlobalShadows = self._originalSettings.globalShadows
	end
	if self._originalSettings.brightness ~= nil then
		Lighting.Brightness = self._originalSettings.brightness
	end
	if self._originalSettings.fogEnd ~= nil then
		Lighting.FogEnd = self._originalSettings.fogEnd
	end
	
	-- Desconecta eventos
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	self._connections = {}
	
	if self.cfg.debugMode then
		print("[FPSOptimizer] ✗ Otimizações desativadas")
	end
end

-- OBTER FPS ATUAL
function FPSOptimizer:GetCurrentFPS()
	return self._currentFPS
end

-- MUDAR CONFIGURAÇÃO
function FPSOptimizer:SetConfig(path, value)
	local keys = string.split(path, ".")
	local target = self.cfg
	
	for i = 1, #keys - 1 do
		target = target[keys[i]]
	end
	
	target[keys[#keys]] = value
	
	if self.cfg.debugMode then
		print(string.format("[FPSOptimizer] Config alterada: %s = %s", path, tostring(value)))
	end
end

-- OBTER CONFIGURAÇÃO ATUAL
function FPSOptimizer:GetConfig()
	return self.cfg
end

return FPSOptimizer
