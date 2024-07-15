local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local KnitClient = debug.getupvalue(require(LocalPlayer.PlayerScripts.TS.knit).setup, 6)
bedwars = {
	["ClientHandlerStore"] = require(LocalPlayer.PlayerScripts.TS.ui.store).ClientStore, ["SwordController"] = KnitClient.Controllers.SwordController,
	["CombatConstant"] = require(game:GetService("ReplicatedStorage").TS.combat["combat-constant"]).CombatConstant,
	["KnockbackTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1),
	["SprintController"] = KnitClient.Controllers.SprintController,
	["DamageIndicator"] = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator
}
	function GetMatchState()
		return bedwars["ClientHandlerStore"]:getState().Game.matchState
	end
	function IsAlive(plr)
		plr = plr or LocalPlayer
			if not plr.Character then return false end        
			if not plr.Character:FindFirstChild("Head") then return false end
			if not plr.Character:FindFirstChild("Humanoid") then return false end
			if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
		return true
	end
    function GetQueueType()
        local state = bedwars["ClientHandlerStore"]:getState()
        return state.Game.queueType or "bedwars_test"
    end
	function getserverpos(Position)
		local x = math.round(Position.X/3)
		local y = math.round(Position.Y/3)
		local z = math.round(Position.Z/3)
		return Vector3.new(x,y,z)
	end
	local function GetInventory(plr)
		if not plr then 
			return {items = {}, armor = {}}
		end
	
		local suc, ret = pcall(function() 
			return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
		end)
	
		if not suc then 
			return {items = {}, armor = {}}
		end
		if plr.Character and plr.Character:FindFirstChild("InventoryFolder") then 
			local invFolder = plr.Character:FindFirstChild("InventoryFolder").Value
			if not invFolder then return ret end
			for i,v in next, ret do 
				for i2, v2 in next, v do 
					if typeof(v2) == 'table' and v2.itemType then
						v2.instance = invFolder:FindFirstChild(v2.itemType)
					end
				end
				if typeof(v) == 'table' and v.itemType then
					v.instance = invFolder:FindFirstChild(v.itemType)
				end
			end
		end
	
		return ret
	end
	local BedwarsSwords = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"]).BedwarsMelees
	function hashFunc(vec)
		return {value = vec}
	end
	function getBeds()
		local beds = {}
		for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
			if string.lower(v.Name) == "bed" and v:FindFirstChild("Covers") ~= nil and v:FindFirstChild("Covers").Color ~= LocalPlayer.Team.TeamColor then
				table.insert(beds,v)
			end
		end
		return beds
	end
	
	local function getSword()
		local highest, returning = -9e9, nil
		for i,v in next, GetInventory(LocalPlayer).items do 
			local swords = table.find(BedwarsSwords, v.itemType)
			if not swords then continue end
			if swords > highest then 
				returning = v
				highest = swords
			end
		end
		return returning
	end
	local SwordAnimations = {
		["Slow"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(220), math.rad(100), math.rad(100)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.25}
		}
	}
	local origC0 = game:GetService("ReplicatedStorage").Assets.Viewmodel.RightHand.RightWrist.C0
	spawn(function ()
	EnabledKillaura = true
					if EnabledKillaura then
						CheckKillaura = true
							repeat task.wait() until GetMatchState() ~= 0
							if not EnabledKillaura then return end
							while task.wait() do
								for i, v in pairs(game:GetService("Players"):GetChildren()) do
									if v.Team ~= LocalPlayer.Team and IsAlive(v) and IsAlive(LocalPlayer) and not v.Character:FindFirstChildOfClass("ForceField") then
										local Magnitude = (v.Character:FindFirstChild("HumanoidRootPart").Position - LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
										if Magnitude < 30 then
											Sword = getSword()
											if Sword ~= nil then
													spawn(function()
														local anim = Instance.new("Animation")
														anim.AnimationId = "rbxassetid://4947108314"
														local loader = LocalPlayer.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
														loader:LoadAnimation(anim):Play()
															if CostumAnimations then
																CostumAnimations = false
																for i,v in pairs(SwordAnimations["Slow"]) do
																	game:GetService("TweenService"):Create(Camera.Viewmodel.RightHand.RightWrist,TweenInfo.new(v.Time),{C0 = origC0 * v.CFrame}):Play()
																	task.wait(v.Time-0.01)
																end
																CostumAnimations = true
														end
														game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.SwordHit:FireServer({
															["chargedAttack"] = {["chargeRatio"] = 0},
															["entityInstance"] = v.Character,
															["validate"] = {
																["targetPosition"] = hashFunc(v.Character:FindFirstChild("HumanoidRootPart").Position),
																["selfPosition"] = hashFunc(LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position + ((LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude > 14 and (CFrame.lookAt(LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position, v.Character:FindFirstChild("HumanoidRootPart").Position).LookVector * 4) or Vector3.new(0, 0, 0))),
															}, 
															["weapon"] = Sword.tool,
														})
														game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.DragonBreath:FireServer({
															["Player"] = game:GetService("Players").LocalPlayer
														})
												end)
											end
										end
									end
								end
				end
			end
		end)
		spawn(function ()
			EnabledNuker = true
			if EnabledNuker then
					repeat
						task.wait(0.1)
						if IsAlive(LocalPlayer) and LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0.1 then
							local beds = getBeds()
							for i,v in pairs(beds) do
								local mag = (v.Position - LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
								if mag < 30 then
										local params = RaycastParams.new()
										params.FilterType = Enum.RaycastFilterType.Exclude
										params.IgnoreWater = true
									local raycastResult = game:GetService("Workspace"):Raycast(v.Position + Vector3.new(0,24,0),Vector3.new(0,-27,0),params)
									if raycastResult then
											local targetBlock = nil
											if raycastResult.Instance then
												targetBlock = raycastResult.Instance
											else
												if not raycastResult.Instance then
													targetBlock = v
												end
											end
											for i, v in pairs(targetBlock:GetChildren()) do
												if v:IsA("Texture") then
													v:Destroy()
												end
											end
											game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@easy-games"):FindFirstChild("block-engine").node_modules:FindFirstChild("@rbxts").net.out._NetManaged.DamageBlock:InvokeServer({
											["blockRef"] = {
												["blockPosition"] = getserverpos(v.Position)
											},
											["hitPosition"] = getserverpos(v.Position),
											["hitNormal"] = getserverpos(v.Position)
										})
										end
									end
								end
							end
					until not EnabledNuker
			end
		end)
        spawn(function ()
            EnabledAutoQueue = true
            spawn(function()
                repeat task.wait(3) until GetMatchState() == 2 or not EnabledAutoQueue
                if not EnabledAutoQueue then return end
                game:GetService("ReplicatedStorage"):FindFirstChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events").joinQueue:FireServer({["queueType"] = GetQueueType()})
            end)
        end)
		spawn(function ()
			
			local Player = game.Players.LocalPlayer
			local Character = Player.Character or Player.CharacterAdded:Wait()
			local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
			local Humanoid = Character:WaitForChild("Humanoid")
			
			local TweenService = game:GetService("TweenService")
			local RunService = game:GetService("RunService")
			
			local AutoWinBoolean = false
			local ChaseSpeedValue = 15
			
			
			function GetRemote(Tab)
				for i, v in pairs(Tab) do
					if v == "Client" then
						return Tab[i + 1]
					end
				end
				return ""
			end
			
			local Bedwars = {
				["ClientHandlerStore"] = require(Player.PlayerScripts.TS.ui.store).ClientStore
			}
			
			
			local IsNetworkOwner = isnetworkowner or (gethiddenproperty and function(part)
				if gethiddenproperty(part, "NetworkOwnershipRule") == Enum.NetworkOwnership.Manual then 
					return false
				end
				return true
			end) or function() return true end
			
			function GetMatchState()
				return Bedwars["ClientHandlerStore"]:getState().Game.matchState
			end
			
			function ChatMakeSystemMessage(Message)
				game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
					Text = Message,
					Font = Enum.Font.FredokaOne,
					TextSize = 20,
					Color = Color3.new(0, 1, 0)
				})
			end
			
			
			function KillHumanoid(Time)
				task.wait(Time)
				if Player.leaderstats.Bed.Value == "✅" then
					Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
					Player.Character.Humanoid.Health = 0
					game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ResetCharacter:FireServer()
				end
			end
			
			function FindNearestPlayer()
				local NearestPlayer
				local NearestDistance = math.huge
				for i, v in pairs(game.Players:GetChildren()) do
					if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v ~= Player and v.Team ~= Player.Team and v.Character.Humanoid.Health > 0 then
						local Distance = (v.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
						if Distance < NearestDistance then
							NearestPlayer = v
							NearestDistance = Distance
						end
					end
				end
				return NearestPlayer, NearestDistance
			end
			
			function FindNearestBed()
				local NearestBed = nil
				local MinDistance = math.huge
				for _,v in pairs(game.Workspace:GetDescendants()) do
					if v.Name:lower() == "bed" and v:FindFirstChild("Covers") and v:FindFirstChild("Covers").BrickColor ~= Player.Team.TeamColor then
						local Distance = (v.Position - Player.Character.HumanoidRootPart.Position).Magnitude
						if Distance < MinDistance then
							NearestBed = v
							MinDistance = Distance
						end
					end
				end
				return NearestBed
			end
			
			function TweenToNearestPlayer(NearestPlayer)
				if NearestPlayer then
					local TweenTime = 0.65
					local TweenInformation = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
					local PlayerTween = TweenService:Create(Player.Character.HumanoidRootPart, TweenInformation, {CFrame = NearestPlayer.Character.HumanoidRootPart.CFrame})
					if NearestPlayer.Character.Humanoid.Health > 0 then
						PlayerTween:Play()
					end
				end
			end
			
			function TweenToNearestPlayerSlow(NearestPlayer)
				if NearestPlayer then
					local TweenTime = (HumanoidRootPart.Position - NearestPlayer.Character.HumanoidRootPart.Position).Magnitude / 23.4 / ChaseSpeedValue
					local TweenInformation = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
					local PlayerTween = TweenService:Create(Player.Character.HumanoidRootPart, TweenInformation, {CFrame = NearestPlayer.Character.HumanoidRootPart.CFrame})
					if NearestPlayer.Character.Humanoid.Health > 0 then
						PlayerTween:Play()
					end
					if not PlayerTween.Completed then
						KillHumanoid(0)
					end
				end
			end
			
			function TweenToNearestBed()
				local NearestBed = FindNearestBed()
				if NearestBed then
					local TweenTime = 0.65
					local TweenInformation = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
					local BedTween = TweenService:Create(Player.Character.HumanoidRootPart, TweenInformation, {CFrame = NearestBed.CFrame + Vector3.new(0, 10, 0)})
					BedTween:Play()
					repeat
						task.wait()
						if not BedTween.Completed then
							KillHumanoid(0)
						end
					until BedTween.Completed or Player.CharacterAdded
				end
			end
			
			function AutoWin()
				Player.CharacterAdded:Connect(function()
					task.wait(0.3)
					local NearestBed = FindNearestBed()
					local TeamOfBedPlayer = nil
					if NearestBed and AutoWinBoolean == true and GetMatchState() == 1 and Player.leaderstats.Bed.Value == "✅" then		
						TweenToNearestBed()			
						local TeamColor = NearestBed:FindFirstChild("Covers").BrickColor
						for i, v in pairs(game.Players:GetChildren()) do
							if v.Team ~= Player.Team and v ~= Player then
								if v.TeamColor == TeamColor then
									TeamOfBedPlayer = v
								end
							end
						end
			
						repeat
							task.wait()
							if not TeamOfBedPlayer then
								task.wait(4)
								KillHumanoid(0)
							end
							if not IsNetworkOwner(Player.Character.HumanoidRootPart) then
								KillHumanoid(0)
							end
							if TeamOfBedPlayer then
								if TeamOfBedPlayer.leaderstats.Bed.Value ~= "✅" then
									KillHumanoid(0)
								end
							end
						until TeamOfBedPlayer.leaderstats.Bed.Value ~= "✅" or Player.Character.Humanoid.Health <= 0
						KillHumanoid(0)
			
					else
						if not FindNearestBed() and AutoWinBoolean == true and GetMatchState() == 1 and Player.leaderstats.Bed.Value == "✅" then
							local NearestPlayer = FindNearestPlayer()
							local KillsValue = Player.leaderstats.Kills.Value
			
							local Number = 0
			
							if NearestPlayer then
								TweenToNearestPlayer(NearestPlayer)
								task.wait(0.7)
							end
			
							if not IsNetworkOwner(Player.Character.HumanoidRootPart) then
								KillHumanoid(0)
							end
			
							repeat
								if NearestPlayer and KillsValue <= Player.leaderstats.Kills.Value and Number < 20 then
									task.wait(1)
									TweenToNearestPlayerSlow(NearestPlayer)
									Number = Number + 1
								else
									if KillsValue < Player.leaderstats.Kills.Value then
										KillHumanoid(0)
									end
								end
								if not IsNetworkOwner(Player.Character.HumanoidRootPart) then
									KillHumanoid(0)
								end
								if not NearestPlayer or Number >= 20 then
									KillHumanoid(0)
								end
							until Player.leaderstats.Kills.Value ~= KillsValue or Player.Character.Humanoid.Health <= 0 or not NearestPlayer
							KillHumanoid(0)
						end
					end
				end)
				RunService.Heartbeat:Connect(function()
					if AutoWinBoolean == true and Character and Humanoid.Health > 0 and FindNearestBed() and GetMatchState() == 1 then
						KillHumanoid(0)
						task.wait(0.7)
						ChatMakeSystemMessage("Death tp started!")
					end
				end)
			end
			
			AutoWinBoolean = true
			AutoWin()
			local AlSploit = Instance.new("ScreenGui")
			local MainFrame = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local AutowinToggle = Instance.new("TextButton")
			local UICorner_2 = Instance.new("UICorner")
			local TweenSpeed = Instance.new("TextLabel")
			local UICorner_3 = Instance.new("UICorner")
			local TweenSpeed_2 = Instance.new("TextLabel")
			local UICorner_4 = Instance.new("UICorner")
			local Lower = Instance.new("TextButton")
			local UICorner_5 = Instance.new("UICorner")
			local Higher = Instance.new("TextButton")
			local UICorner_6 = Instance.new("UICorner")
			local TweenSpeed_3 = Instance.new("TextLabel")
			local UICorner_7 = Instance.new("UICorner")
			
			AlSploit.ResetOnSpawn = false
			
			AlSploit.Name = "AlSploit"
			AlSploit.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
			AlSploit.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			
			MainFrame.Name = "MainFrame"
			MainFrame.Parent = AlSploit
			MainFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			MainFrame.Position = UDim2.new(0.553374052, 0, 0.607833207, 0)
			MainFrame.Size = UDim2.new(0, 340, 0, 130)
			
			UICorner.Parent = MainFrame
			
			AutowinToggle.Name = "AutowinToggle"
			AutowinToggle.Parent = MainFrame
			AutowinToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 0)
			AutowinToggle.BorderSizePixel = 0
			AutowinToggle.Position = UDim2.new(0.270588249, 0, 7.4505806e-09, 0)
			AutowinToggle.Size = UDim2.new(0, 155, 0, 25)
			AutowinToggle.SizeConstraint = Enum.SizeConstraint.RelativeXX
			AutowinToggle.Font = Enum.Font.LuckiestGuy
			AutowinToggle.Text = "Autowin"
			AutowinToggle.TextColor3 = Color3.fromRGB(0, 0, 0)
			AutowinToggle.TextScaled = true
			AutowinToggle.TextSize = 14.000
			AutowinToggle.TextWrapped = true
			
			UICorner_2.Parent = AutowinToggle
			
			TweenSpeed.Name = "TweenSpeed"
			TweenSpeed.Parent = MainFrame
			TweenSpeed.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TweenSpeed.BackgroundTransparency = 1.000
			TweenSpeed.Position = UDim2.new(0.235294119, 0, 0.353846163, 0)
			TweenSpeed.Size = UDim2.new(0, 180, 0, 21)
			TweenSpeed.Font = Enum.Font.LuckiestGuy
			TweenSpeed.Text = "Player Chase Speed"
			TweenSpeed.TextColor3 = Color3.fromRGB(0, 0, 0)
			TweenSpeed.TextScaled = true
			TweenSpeed.TextSize = 14.000
			TweenSpeed.TextWrapped = true
			
			UICorner_3.Parent = TweenSpeed
			
			TweenSpeed_2.Name = "TweenSpeed"
			TweenSpeed_2.Parent = MainFrame
			TweenSpeed_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TweenSpeed_2.BackgroundTransparency = 1.000
			TweenSpeed_2.Position = UDim2.new(0.235294119, 0, 0.838461518, 0)
			TweenSpeed_2.Size = UDim2.new(0, 180, 0, 21)
			TweenSpeed_2.Font = Enum.Font.LuckiestGuy
			TweenSpeed_2.Text = "0"
			TweenSpeed_2.TextColor3 = Color3.fromRGB(0, 0, 0)
			TweenSpeed_2.TextScaled = true
			TweenSpeed_2.TextSize = 14.000
			TweenSpeed_2.TextWrapped = true
			
			UICorner_4.Parent = TweenSpeed_2
			
			Lower.Name = "Lower"
			Lower.Parent = MainFrame
			Lower.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Lower.BackgroundTransparency = 1.000
			Lower.BorderSizePixel = 0
			Lower.Position = UDim2.new(2.98023224e-08, 0, 0.838461518, 0)
			Lower.Size = UDim2.new(0, 155, 0, 25)
			Lower.SizeConstraint = Enum.SizeConstraint.RelativeXX
			Lower.Font = Enum.Font.LuckiestGuy
			Lower.Text = "<<"
			Lower.TextColor3 = Color3.fromRGB(0, 0, 0)
			Lower.TextScaled = true
			Lower.TextSize = 14.000
			Lower.TextWrapped = true
			
			UICorner_5.Parent = Lower
			
			Higher.Name = "Higher"
			Higher.Parent = MainFrame
			Higher.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Higher.BackgroundTransparency = 1.000
			Higher.BorderSizePixel = 0
			Higher.Position = UDim2.new(0.544117689, 0, 0.838461518, 0)
			Higher.Size = UDim2.new(0, 155, 0, 25)
			Higher.SizeConstraint = Enum.SizeConstraint.RelativeXX
			Higher.Font = Enum.Font.LuckiestGuy
			Higher.Text = ">>"
			Higher.TextColor3 = Color3.fromRGB(0, 0, 0)
			Higher.TextScaled = true
			Higher.TextSize = 14.000
			Higher.TextWrapped = true
			
			UICorner_6.Parent = Higher
			
			TweenSpeed_3.Name = "TweenSpeed"
			TweenSpeed_3.Parent = MainFrame
			TweenSpeed_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TweenSpeed_3.BackgroundTransparency = 1.000
			TweenSpeed_3.Position = UDim2.new(0.235294119, 0, 0.676923096, 0)
			TweenSpeed_3.Size = UDim2.new(0, 180, 0, 21)
			TweenSpeed_3.Font = Enum.Font.LuckiestGuy
			TweenSpeed_3.Text = ""
			TweenSpeed_3.TextColor3 = Color3.fromRGB(0, 0, 0)
			TweenSpeed_3.TextScaled = true
			TweenSpeed_3.TextSize = 14.000
			TweenSpeed_3.TextWrapped = true
			UICorner_7.Parent = TweenSpeed_3
			
			Higher.Activated:Connect(function()
				if ChaseSpeedValue <= 14 then
					ChaseSpeedValue = ChaseSpeedValue + 1
				end
			end)
			Lower.Activated:Connect(function()
				if ChaseSpeedValue >= 2 then
					ChaseSpeedValue = ChaseSpeedValue - 1
				end
			end)
			AutowinToggle.Activated:Connect(function()
				AutoWinBoolean = not AutoWinBoolean
				if AutoWinBoolean == true then
					AutowinToggle.BackgroundColor3 = Color3.new(0, 1, 0)
					AutowinToggle.Text = "Autowin(If turned on and off reset character.)"
				end
				if AutoWinBoolean == false then
					AutowinToggle.BackgroundColor3 = Color3.new(1, 0, 0)	
					AutowinToggle.Text = "Autowin"
				end
			end)
			RunService.Heartbeat:Connect(function()
				TweenSpeed_2.Text = ChaseSpeedValue
				if ChaseSpeedValue == 15 then
					TweenSpeed_3.Text = "(Default)"
				end
				if ChaseSpeedValue ~= 15 then
					TweenSpeed_3.Text = ""
			
				end
			end)
		end)
