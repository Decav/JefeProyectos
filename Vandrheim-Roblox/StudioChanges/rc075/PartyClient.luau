--[[
 PartyClient R9a: presentación de party según HU-ESTETICA-22.
 Las acciones son intenciones; PartyService valida todo en servidor.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AllyTargetState = require(ReplicatedStorage.Shared:WaitForChild("AllyTargetState"))
local ClassConfig = require(ReplicatedStorage.Config:WaitForChild("ClassConfig"))
local UITheme = require(ReplicatedStorage.Config:WaitForChild("UITheme"))
local RoomConfig = require(ReplicatedStorage.Config:WaitForChild("RoomConfig"))
local C = UITheme.Colors
local partyUpdate = Remotes:WaitForChild("PartyStateUpdate")
local state = { members = {}, count = 0 }
local selectedUserId = nil
local liveConnections = {}
local windowConnections = {}
local inviteNonce = 0

local gui = Instance.new("ScreenGui")
gui.Name = "PartyUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 6
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
gui.Parent = playerGui

local function decorate(object, color, width)
 local corner = Instance.new("UICorner")
 corner.CornerRadius = UDim.new(0.07, 0)
 corner.Parent = object
 if color then
  local stroke = Instance.new("UIStroke")
  stroke.Color = color
  stroke.Thickness = width or 1
  stroke.Parent = object
 end
end
local function frame(parent, name, x, y, w, h, color, border)
 local f = Instance.new("Frame")
 f.Name = name
 f.Position = UDim2.fromScale(x,y)
 f.Size = UDim2.fromScale(w,h)
 f.BackgroundColor3 = color
 f.BorderSizePixel = 0
 f.Parent = parent
 if border then decorate(f,border) end
 return f
end
local function label(parent,name,content,x,y,w,h,color,font)
 local t=Instance.new("TextLabel")
 t.Name=name
 t.BackgroundTransparency=1
 t.Position=UDim2.fromScale(x,y)
 t.Size=UDim2.fromScale(w,h)
 t.Text=content
 t.TextColor3=color or C.Parchment
 t.Font=font or UITheme.Fonts.Body
 t.TextScaled=true
 t.TextXAlignment=Enum.TextXAlignment.Left
 t.Parent=parent
 return t
end
local function button(parent,name,content,x,y,w,h,color)
 local b=Instance.new("TextButton")
 b.Name=name
 b.Position=UDim2.fromScale(x,y)
 b.Size=UDim2.fromScale(w,h)
 b.Text=content
 b.TextScaled=true
 b.Font=UITheme.Fonts.Mono
 b.TextColor3=C.Parchment
 b.BackgroundColor3=color or C.SurfaceRaised
 b.BorderSizePixel=0
 decorate(b,C.BrassDark)
 b.Parent=parent
 local base=b.BackgroundColor3
 b.MouseEnter:Connect(function()
  TweenService:Create(b,UITheme.HoverTween,{BackgroundColor3=C.BrassDark}):Play()
 end)
 b.MouseLeave:Connect(function()
  TweenService:Create(b,UITheme.HoverTween,{BackgroundColor3=base}):Play()
 end)
 return b
end
local function progress(parent,name,x,y,w,h,value,maxValue,color)
 local track=frame(parent,name.."Track",x,y,w,h,C.BarBackground)
 decorate(track,C.CombatStroke)
 local fill=frame(track,name.."Fill",0,0,
  math.clamp((tonumber(value) or 0)/math.max(1,tonumber(maxValue) or 1),0,1),1,color)
 return track,fill
end

local openButton=button(gui,"PartyOpen","PARTY",0.025,0.19,0.075,0.037,C.Surface)
openButton.Visible=false -- Se habilita cuando exista un personaje activo.
local hud=frame(gui,"PartyHUD",0.025,0.235,0.225,0.37,C.Canvas)
hud.BackgroundTransparency=1
local hudHeader=label(hud,"Title","PARTY",0,0,1,0.08,C.Brass,UITheme.Fonts.Mono)
local window=frame(gui,"PartyWindow",0.5,0.5,0.35,0.44,C.Surface,C.Brass)
window.AnchorPoint=Vector2.new(0.5,0.5)
window.Visible=false
window.ZIndex=10
local aspect=Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio=430/350
aspect.DominantAxis=Enum.DominantAxis.Width
aspect.AspectType=Enum.AspectType.FitWithinMaxSize
aspect.Parent=window
local windowTitle=label(window,"Title","PARTY · PUEBLO",0.045,0.045,0.6,0.08,C.Parchment,UITheme.Fonts.Title)
windowTitle.ZIndex=11
local countLabel=label(window,"Count","0 / 4",0.78,0.05,0.17,0.05,C.Brass,UITheme.Fonts.Mono)
countLabel.ZIndex=11
local closeButton=button(window,"Close","×",0.91,0.035,0.06,0.07,C.SurfaceRaised)
closeButton.ZIndex=12
local memberArea=frame(window,"Members",0.04,0.17,0.92,0.48,C.Surface)
memberArea.BackgroundTransparency=1
memberArea.ZIndex=11
local createButton=button(window,"Create","CREAR PARTY",0.04,0.73,0.38,0.09,C.BrassDark)
local inviteButton=button(window,"Invite","INVITAR AMIGO",0.04,0.73,0.38,0.09,C.BrassDark)
local leaveButton=button(window,"Leave","SALIR",0.49,0.73,0.21,0.09,C.SurfaceRaised)
local kickButton=button(window,"Kick","EXPULSAR",0.73,0.73,0.23,0.09,C.SurfaceRaised)
local statusLabel=label(window,"Status","",0.04,0.86,0.92,0.07,C.Muted,UITheme.Fonts.Body)
for _,b in ipairs({createButton,inviteButton,leaveButton,kickButton}) do b.ZIndex=11 end

local friendPanel=frame(window,"FriendPicker",0.04,0.16,0.92,0.51,C.SurfaceRaised,C.BrassDark)
friendPanel.ZIndex=14
friendPanel.Visible=false
local friendTitle=label(friendPanel,"Title","JUGADORES EN ESTE PUEBLO",0.04,0.03,0.8,0.1,C.Brass,UITheme.Fonts.Mono)
friendTitle.ZIndex=15
local friendClose=button(friendPanel,"Close","×",0.90,0.03,0.07,0.1,C.Surface)
friendClose.ZIndex=15
local friendList=Instance.new("ScrollingFrame")
friendList.Name="List"
friendList.Position=UDim2.fromScale(0.04,0.18)
friendList.Size=UDim2.fromScale(0.92,0.78)
friendList.BackgroundColor3=C.Surface
friendList.BackgroundTransparency=1
friendList.BorderSizePixel=0
friendList.ScrollBarThickness=6
friendList.ScrollingDirection=Enum.ScrollingDirection.Y
friendList.AutomaticCanvasSize=Enum.AutomaticSize.Y
friendList.CanvasSize=UDim2.new(0,0,0,0)
friendList.ZIndex=15
friendList.Parent=friendPanel
local friendListLayout=Instance.new("UIListLayout")
friendListLayout.Name="ItemsLayout"
friendListLayout.FillDirection=Enum.FillDirection.Vertical
friendListLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
friendListLayout.SortOrder=Enum.SortOrder.LayoutOrder
friendListLayout.Padding=UDim.new(0.02,0)
friendListLayout.Parent=friendList

local confirm=frame(window,"Confirm",0.14,0.25,0.72,0.42,C.SurfaceRaised,C.Brass)
confirm.Visible=false
confirm.ZIndex=20
local confirmText=label(confirm,"Message","",0.07,0.13,0.86,0.25,C.Parchment)
confirmText.ZIndex=21
local confirmYes=button(confirm,"Yes","CONFIRMAR",0.08,0.58,0.4,0.22,C.Crimson)
local confirmNo=button(confirm,"No","CANCELAR",0.53,0.58,0.4,0.22,C.Surface)
confirmYes.ZIndex=21
confirmNo.ZIndex=21
local confirmAction=nil

local popup=frame(gui,"InvitePopup",0.5,0.47,0.36,0.25,C.Surface,C.ArcaneBlue)
popup.AnchorPoint=Vector2.new(0.5,0.5)
popup.Visible=false
popup.ZIndex=30
local popupAspect=Instance.new("UIAspectRatioConstraint")
popupAspect.AspectRatio=430/200
popupAspect.DominantAxis=Enum.DominantAxis.Width
popupAspect.AspectType=Enum.AspectType.FitWithinMaxSize
popupAspect.Parent=popup
local popupTitle=label(popup,"Title","INVITACIÓN A PARTY",0.05,0.08,0.75,0.12,C.Parchment,UITheme.Fonts.Title)
popupTitle.ZIndex=31
local popupBody=label(popup,"Body","",0.05,0.28,0.85,0.24,C.Parchment)
popupBody.ZIndex=31
local acceptButton=button(popup,"Accept","ACEPTAR",0.05,0.69,0.31,0.16,C.Brass)
local rejectButton=button(popup,"Reject","RECHAZAR",0.40,0.69,0.31,0.16,C.SurfaceRaised)
acceptButton.ZIndex=31
rejectButton.ZIndex=31
local inviteScrim=frame(gui,"InviteScrim",0,0,1,1,C.Shadow)
inviteScrim.BackgroundTransparency=0.35
inviteScrim.ZIndex=29
inviteScrim.Visible=false
inviteScrim.Active=true
local roomInviteCard=frame(popup,"DungeonRoom",0.05,0.4,0.9,0.3,C.Shadow,C.BrassDark)
roomInviteCard.ZIndex=31
roomInviteCard.Visible=false
local roomInviteName=label(roomInviteCard,"RoomName","",0.04,0.07,0.74,0.22,C.Parchment,UITheme.Fonts.Title)
local roomInviteCount=label(roomInviteCard,"Occupancy","",0.81,0.07,0.15,0.2,C.Brass,UITheme.Fonts.Mono)
local roomInviteRoster=frame(roomInviteCard,"Roster",0.04,0.43,0.92,0.45,C.Shadow)
for _,obj in ipairs({roomInviteName,roomInviteCount,roomInviteRoster}) do obj.ZIndex=32 end
popup:GetPropertyChangedSignal("Visible"):Connect(function()
 if not popup.Visible then inviteScrim.Visible=false end
end)
local activeInvite=nil

local function clearChildren(container)
 for _,child in ipairs(container:GetChildren()) do
  if child:IsA("GuiObject") then child:Destroy() end
 end
end
local function clearLiveConnections()
 for _,c in ipairs(liveConnections) do c:Disconnect() end
 table.clear(liveConnections)
end
local function clearWindowConnections()
 for _,c in ipairs(windowConnections) do c:Disconnect() end
 table.clear(windowConnections)
end
local function setStatus(message)
 statusLabel.Text=message or ""
end
local function formatMemberClassSpec(member)
 local classId=type(member.classId)=="string" and member.classId or ""
 if classId=="" then return "?" end
 local classData=ClassConfig[classId]
 local specId=type(member.specId)=="string" and member.specId or ""
 if specId=="" then return classId end
 local className=classData and classData.DisplayName
 if type(className)~="string" or className=="" then className=classId end
 for _,specData in pairs(classData and classData.Specs or {}) do
  local specName=type(specData)=="table" and specData.Name
  if type(specName)=="string" and specId==classId.."_"..specName then
   return className.." - "..specName
  end
 end
 return className
end
local function showConfirm(message, action)
 confirmText.Text=message
 confirmAction=action
 confirm.Visible=true
end
confirmYes.MouseButton1Click:Connect(function()
 confirm.Visible=false
 if confirmAction then confirmAction() end
 confirmAction=nil
end)
confirmNo.MouseButton1Click:Connect(function() confirm.Visible=false; confirmAction=nil end)

local function hasActiveCharacter()
 if player:GetAttribute("CharacterSelectionMode") == true then return false end
 local characterName=player:GetAttribute("CharacterName")
 if type(characterName)~="string" or characterName=="" then return false end
 for _,guiName in ipairs({"CharacterSelect","CharacterCreate"}) do
  local selectionGui=playerGui:FindFirstChild(guiName)
  if selectionGui and selectionGui.Enabled then return false end
 end
 return true
end

local function refreshPartyAvailability()
 local active=hasActiveCharacter()
 openButton.Visible=active and not state.inDungeon
 if not active then
  window.Visible=false
  clearWindowConnections()
  friendPanel.Visible=false
  confirm.Visible=false
  confirmAction=nil
 end
end

local function bindSelectionGui(screenGui)
 if not screenGui:IsA("ScreenGui")
  or (screenGui.Name~="CharacterSelect" and screenGui.Name~="CharacterCreate") then
  return
 end
 screenGui:GetPropertyChangedSignal("Enabled"):Connect(refreshPartyAvailability)
end
for _,child in ipairs(playerGui:GetChildren()) do bindSelectionGui(child) end
playerGui.ChildAdded:Connect(function(child)
 bindSelectionGui(child)
 refreshPartyAvailability()
end)
playerGui.ChildRemoved:Connect(refreshPartyAvailability)
player:GetAttributeChangedSignal("CharacterName"):Connect(refreshPartyAvailability)
player:GetAttributeChangedSignal("CharacterSelectionMode"):Connect(refreshPartyAvailability)

local function adapt()
 local camera=workspace.CurrentCamera
 local size=camera and camera.ViewportSize or Vector2.new(1280,720)
 local mobile=UserInputService.TouchEnabled or size.X<900
 for _,b in ipairs({createButton,inviteButton,leaveButton,kickButton,closeButton,acceptButton,rejectButton}) do
  local limit=b:FindFirstChildOfClass("UITextSizeConstraint") or Instance.new("UITextSizeConstraint")
  limit.MinTextSize=10; limit.MaxTextSize=18; limit.Parent=b
 end
 if mobile then
  openButton.Position=UDim2.fromScale(0.015,0.20)
  openButton.Size=UDim2.fromScale(0.16,0.055)
  if player:GetAttribute("UILayoutPartyFrameManaged") ~= true then
   hud.Position=UDim2.fromScale(0.015,0.27)
  end
  hud.Size=UDim2.fromScale(0.27,0.42)
  window.Size=UDim2.fromScale(0.90,0.90)
  popup.Size=roomInviteCard.Visible and UDim2.fromScale(0.86,0.86) or UDim2.fromScale(0.75,0.58)
 else
  openButton.Position=UDim2.fromScale(0.025,0.19)
  openButton.Size=UDim2.fromScale(0.075,0.037)
  if player:GetAttribute("UILayoutPartyFrameManaged") ~= true then
   hud.Position=UDim2.fromScale(0.025,0.235)
  end
  hud.Size=UDim2.fromScale(0.225,0.37)
  window.Size=UDim2.fromScale(0.35,0.44)
  popup.Size=roomInviteCard.Visible and UDim2.fromScale(0.58,0.78) or UDim2.fromScale(0.36,0.44)
 end
 local windowSize=window.AbsoluteSize
 if windowSize.X>0 and windowSize.Y>0 then
  local closeWidth=math.max(0.06,(UserInputService.TouchEnabled and 44 or 30)/windowSize.X)
  closeButton.Size=UDim2.fromScale(closeWidth,math.max(0.07,(UserInputService.TouchEnabled and 44 or 30)/windowSize.Y))
  closeButton.Position=UDim2.fromScale(0.97-closeWidth,0.035)
  countLabel.Position=UDim2.fromScale(0.67,0.05)
  countLabel.Size=UDim2.fromScale(0.15,0.06)
  for _,b in ipairs({createButton,inviteButton,leaveButton,kickButton}) do
   b.Size=UDim2.fromScale(b.Size.X.Scale,UserInputService.TouchEnabled and 0.15 or 0.09)
  end
  statusLabel.Position=UDim2.fromScale(0.04,UserInputService.TouchEnabled and 0.90 or 0.86)
 end
end
local viewportConnection
local function bindViewport()
 if viewportConnection then viewportConnection:Disconnect() end
 local camera=workspace.CurrentCamera
 if camera then viewportConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt) end
 adapt()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
bindViewport()

local function redrawHUD()
 clearLiveConnections()
 for _,child in ipairs(hud:GetChildren()) do
  if child:IsA("Frame") then child:Destroy() end
 end
 local members=state.members or {}
 hud.Visible=#members>0
 refreshPartyAvailability()
 if state.inDungeon then
  window.Visible=false
  clearWindowConnections()
 end
 hudHeader.Text=state.inDungeon and "DUNGEON · PARTY "..#members.."/4" or "PARTY "..#members.."/4"
 local mobile=UserInputService.TouchEnabled
 for i,member in ipairs(members) do
  local isAllyTarget = member.userId == AllyTargetState.GetUserId()
  local rowBackground = isAllyTarget and C.BrassDark
   or (member.alive and C.CombatPanel or C.SurfaceAlt)
  local rowBorder = isAllyTarget and C.Brass
   or (member.userId==state.leaderUserId and C.Brass or C.CombatStroke)
  local row=frame(hud,"Member"..i,0,0.10+(i-1)*0.225,1,0.205,
   rowBackground, rowBorder)
  local rowStroke = row:FindFirstChildOfClass("UIStroke")
  if rowStroke and isAllyTarget then rowStroke.Thickness = 2 end
  local leader=member.userId==state.leaderUserId and "♛ " or ""
  local selfTag=member.userId==player.UserId and "  TÚ" or ""
  local memberName=(type(member.name)=="string" and member.name~="" and member.name)
   or (type(member.username)=="string" and member.username~="" and member.username) or "?"
  local classSpecText=formatMemberClassSpec(member)
  local memberLevel=tonumber(member.level) or 1
  local targetPlayer=Players:GetPlayerByUserId(member.userId)
  label(row,"Name",leader..memberName..selfTag,
   0.07,0.07,0.66,0.27,C.Parchment,UITheme.Fonts.BodyBold)
  local classLevelLabel=label(row,"Class",classSpecText.." · LV "..tostring(memberLevel),
   0.07,0.34,0.78,0.20,C.Muted,UITheme.Fonts.Mono)
  if targetPlayer then
   local function updateMemberLevel()
    local currentLevel=tonumber(targetPlayer:GetAttribute("CharacterLevel")) or memberLevel
    classLevelLabel.Text=classSpecText.." · LV "..tostring(currentLevel)
   end
   updateMemberLevel()
   table.insert(liveConnections,targetPlayer:GetAttributeChangedSignal("CharacterLevel"):Connect(updateMemberLevel))
  end
  if isAllyTarget then
   local targetMarker=label(row,"AllyTargetMarker","OBJ",0.77,0.07,0.18,0.24,C.Brass,UITheme.Fonts.Mono)
   targetMarker.TextXAlignment=Enum.TextXAlignment.Right
   targetMarker.ZIndex=2
  end
  local hpTrack,hpFill=progress(row,"HP",0.07,0.59,0.67,0.13,member.hp,member.maxHp,C.LifeGreen)
  local mpFill=nil
  if not mobile then
   local _,fill=progress(row,"MP",0.07,0.78,0.67,0.09,member.mp,member.maxMp,C.ArcaneBlue)
   mpFill=fill
  end
  local status=label(row,"Status",member.alive and (member.userId==state.leaderUserId and "LÍDER" or "") or "CAÍDO",
   0.76,0.59,0.20,0.22,member.alive and C.Brass or C.CrimsonBright,UITheme.Fonts.Mono)
  if targetPlayer then
   local function bindCharacter(character)
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if humanoid then
     local function updateHealth(health)
      hpFill.Size=UDim2.fromScale(math.clamp(health/math.max(1,humanoid.MaxHealth),0,1),1)
      status.Text=health<=0 and "CAÍDO" or (member.userId==state.leaderUserId and "LÍDER" or "")
      status.TextColor3=health<=0 and C.CrimsonBright or C.Brass
      if isAllyTarget then
       row.BackgroundColor3=C.BrassDark
      else
       row.BackgroundColor3=health<=0 and C.SurfaceAlt or C.CombatPanel
      end
     end
     updateHealth(humanoid.Health)
     table.insert(liveConnections,humanoid.HealthChanged:Connect(updateHealth))
     table.insert(liveConnections,humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
      updateHealth(humanoid.Health)
     end))
    end
    if mpFill then
     local function updateMana()
      mpFill.Size=UDim2.fromScale(math.clamp((tonumber(character:GetAttribute("MP")) or 0)/math.max(1,tonumber(character:GetAttribute("MaxMP")) or 1),0,1),1)
     end
     updateMana()
     table.insert(liveConnections,character:GetAttributeChangedSignal("MP"):Connect(updateMana))
     table.insert(liveConnections,character:GetAttributeChangedSignal("MaxMP"):Connect(updateMana))
    end
   end
   if targetPlayer.Character then bindCharacter(targetPlayer.Character) end
   table.insert(liveConnections,targetPlayer.CharacterAdded:Connect(bindCharacter))
  end
  -- ImageButton avoids UIReskinClient's opaque TextButton styling on this hitbox.
  local selectButton = Instance.new("ImageButton")
  selectButton.Name = "AllyTargetButton"
  selectButton.Position = UDim2.fromScale(0, 0)
  selectButton.Size = UDim2.fromScale(1, 1)
  selectButton.BackgroundTransparency = 1
  selectButton.BorderSizePixel = 0
  selectButton.Image = ""
  selectButton.ImageTransparency = 1
  selectButton.AutoButtonColor = false
  selectButton.ZIndex = 5
  selectButton.Parent = row
  selectButton.Activated:Connect(function()
   AllyTargetState.ToggleUserId(member.userId)
  end)
 end
end

AllyTargetState.Changed(function()
 redrawHUD()
end)

local function redrawWindow()
 countLabel.Text=tostring(state.count or 0).." / 4"
 clearWindowConnections()
 clearChildren(memberArea)
 selectedUserId=nil
 for i,member in ipairs(state.members or {}) do
  local classSpecText=formatMemberClassSpec(member)
  local memberName=(type(member.name)=="string" and member.name~="" and member.name)
   or (type(member.username)=="string" and member.username~="" and member.username) or "?"
  local leaderPrefix=member.userId==state.leaderUserId and "♛  " or ""
  local memberLevel=tonumber(member.level) or 1
  local row=button(memberArea,"Member"..i,"",
   0,0.02+(i-1)*0.22,1,0.18,C.CombatPanel)
  local targetPlayer=Players:GetPlayerByUserId(member.userId)
  local function updateRosterRow()
   local currentLevel=targetPlayer and tonumber(targetPlayer:GetAttribute("CharacterLevel")) or memberLevel
   row.Text=leaderPrefix..memberName.." · "..classSpecText.." · LV "..tostring(currentLevel)
  end
  updateRosterRow()
  if targetPlayer and window.Visible then
   table.insert(windowConnections,targetPlayer:GetAttributeChangedSignal("CharacterLevel"):Connect(updateRosterRow))
  end
  row.TextXAlignment=Enum.TextXAlignment.Left
  row.ZIndex=12
  row.MouseButton1Click:Connect(function()
   selectedUserId=member.userId
   for _,other in ipairs(memberArea:GetChildren()) do
    if other:IsA("TextButton") then other.BackgroundColor3=C.CombatPanel end
   end
   row.BackgroundColor3=C.BrassDark
  end)
 end
 local hasParty=state.partyId~=nil
 local leader=hasParty and state.leaderUserId==player.UserId
 createButton.Visible=not hasParty
 inviteButton.Visible=leader and (state.count or 0)<4 and not state.inDungeon
 leaveButton.Visible=hasParty and not state.inDungeon
 kickButton.Visible=leader and not state.inDungeon
 windowTitle.Text=state.inDungeon and "PARTY · DUNGEON" or "PARTY · PUEBLO"
end

local function showLobbyPlayers()
 friendPanel.Visible=true
 clearChildren(friendList)
 friendList.CanvasPosition=Vector2.new(0,0)
 local index=0
 for _,other in ipairs(Players:GetPlayers()) do
  local characterName=other:GetAttribute("CharacterName")
  local hasActiveCharacter=type(characterName)=="string" and characterName~=""
  local isInParty=other:GetAttribute("InParty")==true
  if other~=player and hasActiveCharacter and not isInParty then
   index+=1
   local rowText=characterName
   local className=other:GetAttribute("CharacterClass")
   local characterLevel=other:GetAttribute("CharacterLevel")
   if type(className)=="string" and className~="" then
    rowText..=" · "..className
   end
   if type(characterLevel)=="number" then
    rowText..=" · Nv. "..tostring(characterLevel)
   end
   local lobbyButton=button(friendList,"LobbyPlayer"..index,rowText,
    0,0,0.96,0.19,C.CombatPanel)
   lobbyButton.LayoutOrder=index
   lobbyButton.ZIndex=16
   lobbyButton.TextXAlignment=Enum.TextXAlignment.Left
   lobbyButton.Activated:Connect(function()
    Remotes.RequestInvitePlayer:FireServer({targetUserId=other.UserId})
    friendPanel.Visible=false
   end)
  end
 end
 if index==0 then
  local empty=label(friendList,"Empty","No hay jugadores en el pueblo",0,0,0.96,0.20,C.Muted)
  empty.LayoutOrder=1
  empty.ZIndex=16
  empty.TextXAlignment=Enum.TextXAlignment.Center
  empty.TextWrapped=true
 end
end

openButton.MouseButton1Click:Connect(function()
 if state.inDungeon or not hasActiveCharacter() then return end
 window.Visible=not window.Visible
 if not window.Visible then clearWindowConnections() end
 redrawWindow()
end)
closeButton.MouseButton1Click:Connect(function()
 window.Visible=false
 clearWindowConnections()
end)
createButton.MouseButton1Click:Connect(function() Remotes.RequestCreateParty:FireServer() end)
inviteButton.MouseButton1Click:Connect(showLobbyPlayers)
-- rc074: MatchmakingClient requests the existing invitation picker locally.
local openInvitePicker=Instance.new("BindableEvent")
openInvitePicker.Name="OpenInvitePicker"
openInvitePicker.Parent=gui
openInvitePicker.Event:Connect(function()
 if state.inDungeon or state.leaderUserId~=player.UserId or not hasActiveCharacter() then return end
 window.Visible=true
 redrawWindow()
 showLobbyPlayers()
end)
friendClose.MouseButton1Click:Connect(function() friendPanel.Visible=false end)
leaveButton.MouseButton1Click:Connect(function()
 showConfirm("¿Salir del party?",function() Remotes.RequestLeaveParty:FireServer() end)
end)
kickButton.MouseButton1Click:Connect(function()
 if not selectedUserId or selectedUserId==player.UserId then
  setStatus("Selecciona a otro miembro"); return
 end
 showConfirm("¿Expulsar a este miembro?",function()
  Remotes.RequestKickPlayer:FireServer({targetUserId=selectedUserId})
 end)
end)
acceptButton.MouseButton1Click:Connect(function()
 if activeInvite then
  Remotes.RequestRespondInvite:FireServer({partyId=activeInvite.partyId,accept=true})
 end
 activeInvite=nil
 popup.Visible=false
end)
rejectButton.MouseButton1Click:Connect(function()
 if activeInvite then
  Remotes.RequestRespondInvite:FireServer({partyId=activeInvite.partyId,accept=false})
 end
 activeInvite=nil
 popup.Visible=false
end)

partyUpdate.OnClientEvent:Connect(function(payload)
 if type(payload)~="table" then return end
 if payload.kind=="state" then
  state=payload
  local selectedAllyUserId = AllyTargetState.GetUserId()
  if selectedAllyUserId then
   local stillInParty = false
   for _, member in ipairs(state.members or {}) do
    if member.userId == selectedAllyUserId then
     stillInParty = true
     break
    end
   end
   if not stillInParty then
    AllyTargetState.SetUserId(nil)
   end
  end
  redrawHUD()
  redrawWindow()
 elseif payload.kind=="invite" then
  inviteNonce+=1
  local nonce=inviteNonce
  activeInvite=payload
  local isRoom=type(payload.roomName)=="string"
  roomInviteCard.Visible=isRoom
  inviteScrim.Visible=isRoom
  popup.Size=isRoom and UDim2.fromScale(0.58,0.65) or UDim2.fromScale(0.36,0.25)
  popupAspect.AspectRatio=isRoom and 550/424 or 430/200
  popupTitle.Text=isRoom and "¿Te unes a la Helada?" or "INVITACIÓN A PARTY"
  popupBody.Position=isRoom and UDim2.fromScale(0.05,0.25) or UDim2.fromScale(0.05,0.28)
  popupBody.Size=isRoom and UDim2.fromScale(0.9,0.1) or UDim2.fromScale(0.85,0.24)
  acceptButton.Position=isRoom and UDim2.fromScale(0.4,0.82) or UDim2.fromScale(0.05,0.69)
  acceptButton.Size=isRoom and UDim2.fromScale(0.55,0.11) or UDim2.fromScale(0.31,0.16)
  rejectButton.Position=isRoom and UDim2.fromScale(0.05,0.82) or UDim2.fromScale(0.4,0.69)
  rejectButton.Size=isRoom and UDim2.fromScale(0.3,0.11) or UDim2.fromScale(0.31,0.16)
  if isRoom then
   popupBody.Text=tostring(payload.leaderName or "Un aventurero").." te invita a su sala de dungeon."
   roomInviteName.Text=payload.roomName
   local members=payload.roomMembers or {}
   roomInviteCount.Text=tostring(#members).."/4"
   for _,child in ipairs(roomInviteRoster:GetChildren()) do child:Destroy() end
   for i,member in ipairs(members) do
    local role=RoomConfig.GetRole(member)
    local icon=Instance.new("ImageLabel")
    icon.Name="RoleGlyph"; icon.BackgroundTransparency=1; icon.Image=RoomConfig.RoleIcons[role] or ""
    icon.Position=UDim2.fromScale((i-1)*0.25,0.1); icon.Size=UDim2.fromScale(0.06,0.65)
    icon.ScaleType=Enum.ScaleType.Fit; icon.ZIndex=33; icon.Parent=roomInviteRoster
    local caption=label(roomInviteRoster,"Member"..i,member.name or member.username or "?",
     (i-1)*0.25+0.065,0.12,0.17,0.6,C.Muted,UITheme.Fonts.Body)
    caption.ZIndex=33; caption.TextWrapped=true
   end
  else
   popupBody.Text=tostring(payload.leaderName or "Un amigo").." te invitó a su party.\n¿Quieres unirte a la aventura?"
  end
  acceptButton.Visible=true
  rejectButton.Visible=true
  popup.Visible=true
  adapt()
  task.delay(math.max(0,(tonumber(payload.expiresAt) or os.time())-os.time()),function()
   if nonce==inviteNonce and activeInvite then
    roomInviteCard.Visible=false
    popupTitle.Text="INVITACIÓN EXPIRADA"
    popupBody.Text="La invitación ya no está disponible."
    acceptButton.Visible=false
    rejectButton.Visible=false
    activeInvite=nil
    task.delay(3,function() if nonce==inviteNonce then popup.Visible=false end end)
   end
  end)
 elseif payload.kind=="inviteExpired" then
  inviteNonce+=1
  activeInvite=nil
  roomInviteCard.Visible=false
  popupTitle.Text="INVITACIÓN EXPIRADA"
  popupBody.Text="La invitación ya no está disponible."
  acceptButton.Visible=false
  rejectButton.Visible=false
  popup.Visible=true
  local nonce=inviteNonce
  task.delay(3,function() if nonce==inviteNonce then popup.Visible=false end end)
 elseif payload.kind=="notice" or payload.kind=="error" then
  setStatus(payload.message)
 end
end)
redrawHUD()
redrawWindow()
print("[Vandrheim] PartyClient R9a activo")
