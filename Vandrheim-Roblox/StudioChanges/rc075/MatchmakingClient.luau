-- rc074 / EST-37: five views translated from Pencil Nkt7w/NcFgD.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local Config=ReplicatedStorage:WaitForChild("Config")
local DungeonConfig=require(Config:WaitForChild("DungeonConfig"))
if not DungeonConfig.IsHubPlace() then return end
local RoomConfig=require(Config:WaitForChild("RoomConfig"))
local UITheme=require(Config:WaitForChild("UITheme"))
local ClassConfig=require(Config:WaitForChild("ClassConfig"))
local EnemyConfig=require(Config:WaitForChild("EnemyConfig"))
local BossConfig=require(Config:WaitForChild("BossConfig"))
local LootTables=require(Config:WaitForChild("LootTables"))
local ItemConfig=require(Config:WaitForChild("ItemConfig"))
local Remotes=ReplicatedStorage:WaitForChild("Remotes")
local events={}
for _,name in ipairs({"RequestCreateRoom","RequestRoomList","RequestRoomState","RequestJoinRoom",
 "RequestLeaveRoom","RequestSetReady","RoomStateUpdate","RoomListUpdate","RequestEnterDungeon"}) do
 events[name]=Remotes:WaitForChild(name)
end
local C=UITheme.Colors
local R=RoomConfig.Colors
local playerGui=player:WaitForChild("PlayerGui")
local gui=Instance.new("ScreenGui")
gui.Name="MatchmakingUI"; gui.ResetOnSpawn=false; gui.DisplayOrder=5
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
local room
local roomRevision=-1
local listRevision=-1
local rooms={}
local currentPage="Choice"
local isPublic=true
local portrait=false

local function Rect(parent,x,y,w,h)
 -- Scale inside a ScrollingFrame is relative to its canvas.
 local extent=parent:IsA("ScrollingFrame") and math.max(1,parent.CanvasSize.Y.Scale) or 1
 return UDim2.fromScale(x,y/extent),UDim2.fromScale(w,h/extent)
end
local function Frame(parent,name,x,y,w,h,color,border)
 local f=Instance.new("Frame")
 f.Name=name; f.Position,f.Size=Rect(parent,x,y,w,h)
 f.BackgroundColor3=color or C.SurfaceAlt; f.BorderSizePixel=0
 if border then
  local stroke=Instance.new("UIStroke"); stroke.Color=border; stroke.Thickness=1; stroke.Parent=f
 end
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0.018,0); corner.Parent=f
 f.Parent=parent
 return f
end
local function Text(parent,name,value,x,y,w,h,color,font)
 local t=Instance.new("TextLabel")
 t.Name=name; t.Text=value; t.Position,t.Size=Rect(parent,x,y,w,h)
 t.BackgroundTransparency=1; t.TextColor3=color or C.Parchment
 t.Font=font or UITheme.Fonts.Body; t.TextScaled=true; t.TextWrapped=true
 t.TextXAlignment=Enum.TextXAlignment.Left
 t:SetAttribute("HearthboundCustomTextStyle",true)
 local limit=Instance.new("UITextSizeConstraint"); limit.MaxTextSize=24; limit.Parent=t
 t.Parent=parent
 return t
end
local function Button(parent,name,value,x,y,w,h,callback,primary)
 local b=Instance.new("TextButton")
 b.Name=name; b.Text=value; b.Position,b.Size=Rect(parent,x,y,w,h)
 b.BackgroundColor3=primary and C.Brass or R.Wood
 b.TextColor3=primary and C.Canvas or C.Parchment
 b.Font=UITheme.Fonts.Mono; b.TextScaled=true; b.TextWrapped=true
 b.AutoButtonColor=false; b.BorderSizePixel=0
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0.08,0); corner.Parent=b
 local stroke=Instance.new("UIStroke"); stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
 stroke.Color=R.Wood; stroke.Parent=b
 local limit=Instance.new("UITextSizeConstraint"); limit.MaxTextSize=17; limit.Parent=b
 b.MouseEnter:Connect(function() stroke.Color=C.Brass end)
 b.MouseLeave:Connect(function() stroke.Color=R.Wood end)
 b.Activated:Connect(function() if b.Active then callback() end end)
 b.Parent=parent
 return b
end
local function SetEnabled(button,enabled)
 button.Active=enabled; button.Selectable=enabled
 button.TextTransparency=enabled and 0 or 0.5
 button.BackgroundTransparency=enabled and 0 or 0.5
end
local function Icon(parent,role,x,y,w,h)
 local icon=Instance.new("ImageLabel")
 icon.Name="RoleGlyph"; icon.BackgroundTransparency=1
 icon.Position=UDim2.fromScale(x,y); icon.Size=UDim2.fromScale(w,h)
 icon.Image=RoomConfig.RoleIcons[role] or ""; icon.ScaleType=Enum.ScaleType.Fit
 local aspect=Instance.new("UIAspectRatioConstraint"); aspect.AspectRatio=1
 aspect.AspectType=Enum.AspectType.FitWithinMaxSize; aspect.Parent=icon
 icon.Parent=parent
 return icon
end
local function CoverageIcon(parent,role,isCovered,x,y,w,h)
 local icon=Instance.new("ImageLabel")
 icon.Name=role.."CoverageGlyph"; icon.BackgroundTransparency=1
 icon.Position=UDim2.fromScale(x,y); icon.Size=UDim2.fromScale(w,h)
 local icons=isCovered and RoomConfig.RoleIcons or RoomConfig.RoleIconsUncovered
 icon.Image=(icons and icons[role]) or RoomConfig.RoleIcons[role] or ""
 icon.ScaleType=Enum.ScaleType.Fit
 icon:SetAttribute("Role",role); icon:SetAttribute("Covered",isCovered)
 local aspect=Instance.new("UIAspectRatioConstraint"); aspect.AspectRatio=1
 aspect.AspectType=Enum.AspectType.FitWithinMaxSize; aspect.Parent=icon
 icon.Parent=parent
 return icon
end
local function Clear(parent)
 for _,child in ipairs(parent:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
end
local function Scroll(parent,name,x,y,w,h)
 local s=Instance.new("ScrollingFrame")
 s.Name=name; s.Position=UDim2.fromScale(x,y); s.Size=UDim2.fromScale(w,h)
 s.BackgroundTransparency=1; s.BorderSizePixel=0; s.ScrollBarThickness=5
 s.ScrollBarImageColor3=C.Brass; s.ScrollingDirection=Enum.ScrollingDirection.Y
 s.CanvasSize=UDim2.fromScale(0,0); s.Parent=parent
 return s
end

local openButton
local main=Frame(gui,"PortalWindow",0.5,0.5,0.87,0.88,C.Canvas,C.Brass)
main.AnchorPoint=Vector2.new(0.5,0.5); main.Visible=false; main.Active=true
local aspect=Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio=1.65; aspect.AspectType=Enum.AspectType.FitWithinMaxSize; aspect.Parent=main
Text(main,"Eyebrow","PREDUNGEON  /  HELADA",0.035,0.025,0.75,0.028,C.Brass,UITheme.Fonts.Mono)
Text(main,"Heading","El portal de la Helada",0.035,0.064,0.8,0.07,C.Parchment,UITheme.Fonts.Title)
Text(main,"Subtitle","Forma tu grupo, revisa la ruta y cruza el umbral cuando estéis listos.",
 0.035,0.145,0.87,0.035,C.Muted)
Button(main,"Close","X",0.92,0.04,0.05,0.06,function() main.Visible=false end)
local nav=Frame(main,"Navigation",0.035,0.205,0.93,0.066,C.Canvas)
local content=Frame(main,"Views",0.035,0.295,0.93,0.61,C.SurfaceAlt,R.Wood)
local feedback=Text(main,"Feedback","",0.035,0.925,0.93,0.047,R.Cold)
local pages={}
for _,name in ipairs({"Choice","Create","List","Room","Guide"}) do
 pages[name]=Frame(content,name,0,0,1,1,C.SurfaceAlt)
 pages[name].Visible=false
end
local renderRoom,renderList,renderGuide
local function ShowPage(name)
 currentPage=name
 for key,page in pairs(pages) do page.Visible=key==name end
 for _,b in ipairs(nav:GetChildren()) do
  if b:IsA("TextButton") then b.BackgroundColor3=b.Name==name and C.BrassDark or C.SurfaceRaised end
 end
 if name=="List" then events.RequestRoomList:FireServer(); renderList() end
 if name=="Room" then events.RequestRoomState:FireServer(); renderRoom() end
 if name=="Guide" then renderGuide() end
end
local function Open()
 main.Visible=true
 feedback.Text=""
 events.RequestRoomState:FireServer()
 ShowPage(room and "Room" or "Choice")
end
openButton=Button(gui,"DungeonMenu","DUNGEON",0.025,0.145,0.1,0.035,Open)
local function UpdateAvailability()
 local active=type(player:GetAttribute("CharacterName"))=="string"
 if not active then main.Visible=false end
 openButton.Visible=active and not main.Visible
end
player:GetAttributeChangedSignal("CharacterName"):Connect(UpdateAvailability)
main:GetPropertyChangedSignal("Visible"):Connect(UpdateAvailability)
UpdateAvailability()

local confirmation=Frame(main,"SoloConfirmation",0.15,0.3,0.7,0.4,C.Canvas,C.Brass)
confirmation.ZIndex=20; confirmation.Visible=false
main:GetPropertyChangedSignal("Visible"):Connect(function()
 if not main.Visible then confirmation.Visible=false end
end)
Text(confirmation,"Message","¿Salir de tu party y entrar en Solo?",0.06,0.1,0.88,0.35)
Button(confirmation,"Confirm","SALIR Y ENTRAR",0.06,0.62,0.55,0.22,function()
 confirmation.Visible=false
 events.RequestEnterDungeon:FireServer({mode="solo",confirmLeave=true})
 feedback.Text="Preparando travesía individual..."
end,true)
Button(confirmation,"Cancel","CANCELAR",0.65,0.62,0.29,0.22,function() confirmation.Visible=false end)
local function Solo()
 if player:GetAttribute("InParty") or room then confirmation.Visible=true
 else events.RequestEnterDungeon:FireServer({mode="solo"}); feedback.Text="Preparando travesía individual..." end
end
local function Group()
 if player:GetAttribute("InParty") then
  events.RequestCreateRoom:FireServer({})
  ShowPage("Room")
 else ShowPage("Create") end
end

for i,entry in ipairs({{"Choice","SOLO / GRUPO"},{"Create","CREAR SALA"},{"List","SALAS ABIERTAS"},{"Room","TU SALA"},{"Guide","GUÍA"}}) do
 Button(nav,entry[1],entry[2],(i-1)*0.203,0,0.188,1,function()
  if entry[1]=="Create" and player:GetAttribute("InParty") then Group()
  else ShowPage(entry[1]) end
 end)
end
local choice=pages.Choice
Text(choice,"Eyebrow","ELEGIR CAMINO",0.03,0.04,0.9,0.06,C.Brass,UITheme.Fonts.Mono)
Text(choice,"Title","¿Cómo cruzarás la Helada?",0.03,0.13,0.92,0.11,C.Parchment,UITheme.Fonts.Title)
Text(choice,"Hint","Elige una travesía individual o reúne una compañía.",0.03,0.26,0.92,0.07,C.Muted)
local soloCard=Frame(choice,"SoloCard",0.03,0.4,0.45,0.35,C.Shadow,R.Wood)
Text(soloCard,"Title","EN SOLITARIO",0.06,0.09,0.88,0.15,C.Brass,UITheme.Fonts.Mono)
Text(soloCard,"Description","Tu camino, tu ritmo.",0.06,0.3,0.88,0.2,C.Muted)
Button(soloCard,"Solo","ENTRAR SOLO",0.06,0.64,0.88,0.25,Solo)
local groupCard=Frame(choice,"GroupCard",0.52,0.4,0.45,0.35,C.Surface,C.Brass)
Text(groupCard,"Title","EN COMPAÑÍA",0.06,0.09,0.88,0.15,C.Brass,UITheme.Fonts.Mono)
Text(groupCard,"Description","Reúne tu grupo de 2 a 4.",0.06,0.3,0.88,0.2,C.Muted)
Button(groupCard,"Group","FORMAR GRUPO",0.06,0.64,0.88,0.25,Group,true)
Button(choice,"Guide","ABRIR GUÍA DE LA HELADA",0.03,0.83,0.94,0.11,function() ShowPage("Guide") end)

local create=pages.Create
Text(create,"Title","Prepara tu compañía",0.035,0.045,0.93,0.13,C.Parchment,UITheme.Fonts.Title)
Text(create,"NameLabel","NOMBRE DE SALA · OPCIONAL",0.035,0.23,0.93,0.055,C.Muted,UITheme.Fonts.Mono)
local nameInput=Instance.new("TextBox")
nameInput.Name="RoomName"; nameInput.Position=UDim2.fromScale(0.035,0.32)
nameInput.Size=UDim2.fromScale(0.93,0.12); nameInput.BackgroundColor3=C.Shadow
nameInput.TextColor3=C.Parchment; nameInput.PlaceholderColor3=C.Muted
nameInput.Font=UITheme.Fonts.Body; nameInput.TextScaled=true
nameInput.Text=""; nameInput.PlaceholderText=RoomConfig.DefaultRoomName
nameInput.ClearTextOnFocus=false; nameInput.MultiLine=false; nameInput.Parent=create
local publicButton,privateButton
local function Visibility(value)
 isPublic=value
 publicButton.BackgroundColor3=value and C.BrassDark or C.SurfaceRaised
 privateButton.BackgroundColor3=value and C.SurfaceRaised or C.BrassDark
end
publicButton=Button(create,"Public","PÚBLICA",0.035,0.5,0.45,0.12,function() Visibility(true) end)
privateButton=Button(create,"Private","PRIVADA",0.515,0.5,0.45,0.12,function() Visibility(false) end)
Visibility(true)
Text(create,"VisibilityHelp","Pública — cualquiera del pueblo puede unirse\nPrivada — solo invitados · no aparece en la lista",
 0.035,0.65,0.93,0.12,C.Muted)
Button(create,"CreateRoom","CREAR SALA",0.035,0.83,0.93,0.12,function()
 events.RequestCreateRoom:FireServer({roomName=nameInput.Text,isPublic=isPublic})
 feedback.Text="Preparando sala..."
end,true)

local list=pages.List
Text(list,"Title","Compañías que buscan aventureros",0.035,0.04,0.72,0.13,C.Parchment,UITheme.Fonts.Title)
Button(list,"Refresh","ACTUALIZAR",0.79,0.055,0.175,0.11,function() events.RequestRoomList:FireServer() end)
local listScroll=Scroll(list,"Rooms",0.035,0.23,0.93,0.71)
renderList=function()
 Clear(listScroll)
 listScroll.CanvasSize=UDim2.fromScale(0,math.max(1,#rooms*0.26))
 if #rooms==0 then
  Text(listScroll,"Empty","No hay salas abiertas — crea una",0,0.08,1,0.18,C.Muted)
 end
 for i,entry in ipairs(rooms) do
  local row=Frame(listScroll,"Room"..i,0,(i-1)*0.26,1,0.23,C.Shadow,R.Wood)
  Text(row,"Name",entry.roomName or RoomConfig.DefaultRoomName,0.025,0.12,0.51,0.29)
  local counts={Tank=0,Heal=0,DPS=0}
  for _,role in pairs(entry.roles or {}) do if counts[role] then counts[role]+=1 end end
  Text(row,"Details",(entry.leaderName or "").." · "..tostring(entry.count).."/4",
   0.025,0.55,0.4,0.23,C.Muted,UITheme.Fonts.Mono)
  Text(row,"Roles",string.format("T %d · H %d · DPS %d",counts.Tank,counts.Heal,counts.DPS),
   0.44,0.55,0.33,0.23,R.Cold,UITheme.Fonts.Mono)
  CoverageIcon(row,"Tank",counts.Tank>=1,0.56,0.14,0.055,0.42)
  CoverageIcon(row,"Heal",counts.Heal>=1,0.63,0.14,0.055,0.42)
  CoverageIcon(row,"DPS",counts.DPS>=2,0.70,0.14,0.055,0.42)
  local full=(entry.count or 4)>=RoomConfig.MaxMembers
  local join=Button(row,"Join",full and "LLENA" or "UNIRSE",0.81,0.2,0.17,0.6,function()
   events.RequestJoinRoom:FireServer({partyId=entry.partyId})
   feedback.Text="Solicitando ingreso..."
  end)
  SetEnabled(join,not full and not player:GetAttribute("InParty"))
 end
end

local roomPage=pages.Room
renderRoom=function()
 Clear(roomPage)
 if not room then
  Text(roomPage,"Empty","Aún no tienes sala. Forma tu compañía o busca una sala abierta.",0.06,0.18,0.88,0.25,C.Muted)
  Button(roomPage,"OpenGroup","FORMAR GRUPO",0.2,0.58,0.6,0.15,Group,true)
  return
 end
 local busy=room.status~="lobby" or room.recovery
 Text(roomPage,"Name",room.roomName or RoomConfig.DefaultRoomName,0.03,0.04,0.68,0.11,C.Parchment,UITheme.Fonts.Title)
 Text(roomPage,"Privacy",(room.isPublic and "PÚBLICA" or "PRIVADA").." · "..#room.members.."/4",
  0.73,0.06,0.24,0.07,R.Cold,UITheme.Fonts.Mono)
 local counts={Tank=0,Heal=0,DPS=0}
 local memberScroll=Scroll(roomPage,"Members",0.03,0.2,0.94,0.42)
 local compact=main.AbsoluteSize.X<820
 memberScroll.CanvasSize=UDim2.fromScale(0,portrait and 2.5 or (compact and 2.04 or 0))
 for i=1,4 do
  local member=room.members[i]
  local x=portrait and 0 or (compact and ((i-1)%2)*0.505 or (i-1)*0.253)
  local y=portrait and (i-1)*0.62 or (compact and math.floor((i-1)/2)*1.02 or 0)
  local card=Frame(memberScroll,"Member"..i,x,y,portrait and 0.99 or (compact and 0.485 or 0.24),portrait and 0.57 or 0.98,C.Shadow,
   member and member.userId==room.leaderUserId and C.Brass or C.CombatStroke)
  if member then
   local role=room.roles[tostring(member.userId)] or "DPS"
   counts[role]=(counts[role] or 0)+1
   local ready=room.ready[tostring(member.userId)]==true
   Icon(card,role,0.06,0.08,0.2,0.23)
   Text(card,"Role",role,0.32,0.09,0.62,0.17,R.Cold,UITheme.Fonts.Mono)
   Text(card,"Name",member.name or member.username or "Aventurero",0.06,0.36,0.88,0.17)
   local class=ClassConfig[member.classId]
   Text(card,"Class",(class and class.DisplayName or member.classId or "").." · Nv. "..tostring(member.level),
    0.06,0.58,0.88,0.14,C.Muted)
   Text(card,"Ready",(member.userId==room.leaderUserId and "LÍDER · " or "")..(ready and "LISTO" or "NO LISTO"),
    0.06,0.79,0.88,0.14,ready and R.Ready or C.Muted,UITheme.Fonts.Mono)
  else Text(card,"Empty","VACANTE",0.1,0.38,0.8,0.2,C.Muted,UITheme.Fonts.Mono) end
 end
 local info
 if #room.members==1 then info="Tu sala está abierta: invita, espera compañeros o entra en Solo."
 elseif room.origin=="preformed" then info="Party existente · inicio cuando todos los presentes estén listos."
 else
  local missing={}
  for _,goal in ipairs({{"Tank",1},{"Heal",1},{"DPS",2}}) do
   local n=math.max(0,goal[2]-counts[goal[1]])
   if n>0 then table.insert(missing,tostring(n).." "..goal[1]) end
  end
  info=#missing==0 and "Objetivo 1/1/2 alcanzado · informativo"
   or "Objetivo 1/1/2 · faltan "..table.concat(missing,", ").." (informativo)"
 end
 if busy then info=room.recovery and "Traslado pendiente de confirmación." or "Cruzando el umbral..." end
 local strip=Frame(roomPage,"Composition",0.03,0.66,0.94,0.1,R.Info,R.Cold)
 CoverageIcon(strip,"Tank",counts.Tank>=1,0.015,0.15,0.07,0.7)
 CoverageIcon(strip,"Heal",counts.Heal>=1,0.09,0.15,0.07,0.7)
 CoverageIcon(strip,"DPS",counts.DPS>=2,0.165,0.15,0.07,0.7)
 Text(strip,"Info",info,0.26,0.13,0.72,0.74)
 local leader=room.leaderUserId==player.UserId
 local invite=Button(roomPage,"Invite","INVITAR",0.03,0.83,0.2,0.12,function()
  local partyGui=playerGui:FindFirstChild("PartyUI")
  local picker=partyGui and partyGui:FindFirstChild("OpenInvitePicker")
  if picker then picker:Fire() else feedback.Text="El selector de invitados aún no está disponible." end
 end)
 SetEnabled(invite,leader and not busy and #room.members<RoomConfig.MaxMembers)
 local leave=Button(roomPage,"Leave","SALIR DE SALA",0.25,0.83,0.22,0.12,function()
  events.RequestLeaveRoom:FireServer()
 end)
 SetEnabled(leave,not busy)
 local ownReady=room.ready[tostring(player.UserId)]==true
 local ready=Button(roomPage,"Ready",ownReady and "NO ESTOY LISTO" or "LISTO",0.49,0.83,0.22,0.12,function()
  events.RequestSetReady:FireServer({ready=not ownReady})
 end)
 SetEnabled(ready,not busy and #room.members>=2)
 local start=Button(roomPage,"Start",#room.members==1 and "ENTRAR SOLO" or "EMPEZAR RUN",0.73,0.83,0.24,0.12,function()
  if #room.members==1 then Solo() else events.RequestSetReady:FireServer({ready=true}) end
 end,true)
 start.Visible=leader
 SetEnabled(start,not busy and (#room.members==1 or not ownReady))
end

local function ItemName(id)
 local item=ItemConfig[id]
 if not item and type(ItemConfig.GetTemplate)=="function" then item=ItemConfig.GetTemplate(id) end
 return item and (item.name or item.Name or item.displayName) or "Próximamente"
end
local function Percent(value)
 return type(value)=="number" and string.format("%.0f%%",value*100) or "Próximamente"
end
renderGuide=function()
 local page=pages.Guide; Clear(page)
 Text(page,"Title","Guía de la Helada",0.03,0.035,0.94,0.12,C.Parchment,UITheme.Fonts.Title)
 local scroll=Scroll(page,"GuideContent",0.03,0.21,0.94,0.74)
 scroll.CanvasSize=UDim2.fromScale(0,3.1)
 local floorKeys={}
 for index in pairs(EnemyConfig.FLOOR_TEMPLATES or {}) do table.insert(floorKeys,index) end
 table.sort(floorKeys)
 Text(scroll,"Summary",RoomConfig.DungeonName.." · "..#floorKeys.." pisos · run individual o de sala",
  0,0,1,0.1,R.Cold,UITheme.Fonts.Mono)
 for i,index in ipairs(floorKeys) do
  local names={}; local levels={}
  for _,id in ipairs(EnemyConfig.FLOOR_TEMPLATES[index]) do
   local enemy=EnemyConfig.GetTemplate(id)
   if enemy then table.insert(names,enemy.name or "Próximamente"); if enemy.level then table.insert(levels,enemy.level) end end
  end
  table.sort(levels)
  local minibossId=EnemyConfig.GetMiniboss(index)
  local miniboss=minibossId and EnemyConfig.GetTemplate(minibossId)
  if miniboss then table.insert(names,miniboss.name) end
  local row=Frame(scroll,"Floor"..index,0,0.15+(i-1)*0.23,1,0.2,C.Shadow,R.Wood)
  Text(row,"Floor","PISO "..index.."\nNv. "..tostring(levels[1] or "Próximamente"),0.02,0.12,0.18,0.75,R.Cold,UITheme.Fonts.Mono)
  Text(row,"Enemies",#names>0 and table.concat(names," · ") or "Próximamente",0.23,0.12,0.74,0.75)
 end
 local miniId=EnemyConfig.GetMiniboss(4)
 local mini=miniId and EnemyConfig.GetTemplate(miniId)
 local final
 for _,boss in pairs(BossConfig) do if type(boss)=="table" and boss.floorIndex==5 then final=boss; break end end
 local miniLoot=mini and LootTables.GetTable(mini.lootTable)
 local bossLoot=final and LootTables.GetTable(final.lootTable)
 local uniques={}
 for _,id in ipairs(miniLoot and miniLoot.uniquePool or {}) do table.insert(uniques,ItemName(id)) end
 local y=0.15+#floorKeys*0.23
 Text(scroll,"LootHeading","LOOT · ÚLTIMOS DOS JEFES",0,y,1,0.12,C.Brass,UITheme.Fonts.Mono)
 Text(scroll,"Miniboss",(mini and mini.name or "Próximamente").."\nÚnico: "..Percent(miniLoot and miniLoot.uniqueChance)
  .."\n"..(#uniques>0 and table.concat(uniques," · ") or "Próximamente"),0,y+0.17,1,0.5)
 local weights=bossLoot and bossLoot.bossRewardWeights or {}
 local types=bossLoot and bossLoot.epicReward and bossLoot.epicReward.typeWeights or {}
 local gold=bossLoot and bossLoot.GoldRange
 Text(scroll,"Boss",(final and final.name or "Próximamente").." · COFRE\n"
  ..Percent(weights.frost).." épica de clase · "..Percent(weights.blue).." pieza azul · "..Percent(weights.gold).." oro"
  .."\nDentro de la rama épica: "..Percent(types.weapon).." arma / "..Percent(types.armor).." armadura"
  .."\nOro: "..(gold and tostring(gold.min).."–"..tostring(gold.max) or "Próximamente"),
  0,y+0.77,1,0.63)
end

events.RoomStateUpdate.OnClientEvent:Connect(function(payload)
 if type(payload)~="table" then return end
 if payload.kind=="open" then Open(); return end
 if payload.kind=="error" then
  feedback.Text=payload.message or "No se pudo completar la acción."
  main.Visible=true
  return
 end
 local nextRevision=tonumber(payload.revision) or 0
 if nextRevision<roomRevision then return end
 roomRevision=nextRevision
 if payload.kind=="state" then
  local previous=room and room.partyId
  room=payload; renderRoom()
  if previous~=room.partyId then
   main.Visible=true; feedback.Text=""; ShowPage("Room")
  end
 elseif payload.kind=="cleared" then
  room=nil; renderRoom()
  if currentPage=="Room" then ShowPage("Choice") end
 end
end)
events.RoomListUpdate.OnClientEvent:Connect(function(payload)
 if type(payload)~="table" or type(payload.rooms)~="table" then return end
 local nextRevision=tonumber(payload.revision) or 0
 if nextRevision<listRevision then return end
 listRevision=nextRevision; rooms=payload.rooms; renderList()
end)
Remotes.PartyStateUpdate.OnClientEvent:Connect(function(payload)
 if type(payload)=="table" and (payload.kind=="error" or payload.kind=="notice") and main.Visible then
  feedback.Text=payload.message or ""
 end
end)

local cameraConnection
local function Responsive()
 local camera=workspace.CurrentCamera
 local size=camera and camera.ViewportSize or Vector2.new(1280,720)
 portrait=size.Y>size.X
 aspect.AspectRatio=portrait and 0.7 or 1.65
 main.Size=UDim2.fromScale(UserInputService.TouchEnabled and 0.94 or 0.87,0.9)
 local close=main:FindFirstChild("Close")
 if close and main.AbsoluteSize.X>0 and main.AbsoluteSize.Y>0 then
  local width=math.max(0.05,36/main.AbsoluteSize.X)
  close.Size=UDim2.fromScale(width,math.max(0.06,36/main.AbsoluteSize.Y))
  close.Position=UDim2.fromScale(0.97-width,0.03)
 end
 renderRoom()
end
local function BindCamera()
 if cameraConnection then cameraConnection:Disconnect() end
 local camera=workspace.CurrentCamera
 if camera then cameraConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(Responsive) end
 Responsive()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(BindCamera)
gui.Parent=playerGui
ShowPage("Choice"); BindCamera()
events.RequestRoomState:FireServer()
