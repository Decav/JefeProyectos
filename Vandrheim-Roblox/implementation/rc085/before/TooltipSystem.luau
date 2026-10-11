-- rc084 / EST-44. Client-only tooltip renderer and shared input lifecycle.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local TextService=game:GetService("TextService")
local GuiService=game:GetService("GuiService")
local Config=require(ReplicatedStorage.Config:WaitForChild("TooltipConfig"))
local Data=require(ReplicatedStorage.Shared:WaitForChild("TooltipData"))
local player=Players.LocalPlayer
assert(player,"TooltipSystem is client-only")
local playerGui=player:WaitForChild("PlayerGui")
local System={}
local bindings={}
local current, touch=nil,nil
local screen,card,body,pointer,stroke
local renderQueued=false
local lastDevice=UserInputService:GetLastInputType()

local function visible(origin)
 if not origin or not origin:IsDescendantOf(playerGui) then return false end
 local p,z=origin.AbsolutePosition,origin.AbsoluteSize
 local node=origin
 while node and node~=playerGui do
  if node:IsA("GuiObject") then
   if not node.Visible then return false end
   if node.ClipsDescendants and node~=origin then
    local a,b=node.AbsolutePosition,node.AbsoluteSize
    if p.X+z.X<=a.X or p.X>=a.X+b.X or p.Y+z.Y<=a.Y or p.Y>=a.Y+b.Y then return false end
   end
  end
  if node:IsA("ScreenGui") and not node.Enabled then return false end
  node=node.Parent
 end
 return origin.AbsoluteSize.X>0 and origin.AbsoluteSize.Y>0
end

local function create(class,name,parent,props)
 local object=Instance.new(class)
 object.Name=name
 for key,value in pairs(props or {}) do object[key]=value end
 object.Parent=parent
 return object
end
local function corner(object)
 create("UICorner","Corner",object,{CornerRadius=UDim.new(Config.CornerFraction,0)})
end
local function ensureUI()
 if screen then return end
 screen=create("ScreenGui","TooltipUI",playerGui,{
  ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=Config.DisplayOrder,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
 })
 screen:SetAttribute("TooltipVersion",Config.Version)
 pointer=create("Frame","OriginPointer",screen,{BackgroundColor3=Config.Colors.Background,BorderSizePixel=0,
  AnchorPoint=Vector2.new(0.5,0.5),Rotation=45,ZIndex=1,Visible=false,Active=false})
 create("UIAspectRatioConstraint","Square",pointer,{AspectRatio=1})
 create("UIStroke","Border",pointer,{Thickness=1,Color=Config.Colors.Purple})
 if Config.PanelImage~="" and Config.SliceCenter then
  card=create("ImageLabel","Card",screen,{Image=Config.PanelImage,ScaleType=Enum.ScaleType.Slice,
   SliceCenter=Config.SliceCenter,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,Visible=false,Active=false})
 else
  card=create("Frame","Card",screen,{BackgroundColor3=Config.Colors.Background,BorderSizePixel=0,ZIndex=2,Visible=false,Active=false})
  corner(card)
 end
 stroke=create("UIStroke","Border",card,{Thickness=1,Color=Config.Colors.Purple})
 body=create("ScrollingFrame","Content",card,{BackgroundTransparency=1,BorderSizePixel=0,
  Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0,0),CanvasSize=UDim2.fromScale(0,0),
  ScrollBarThickness=3,ScrollBarImageColor3=Config.Colors.Gold,ScrollingDirection=Enum.ScrollingDirection.Y,
  ElasticBehavior=Enum.ElasticBehavior.Never,Active=false,ZIndex=3})
end

function System.Hide(origin)
 if origin and current and current.origin~=origin then return end
 current=nil
 if card then card.Visible=false; pointer.Visible=false end
end

local function position()
 if not current or not card then return end
 local origin=current.origin
 if not visible(origin) then System.Hide(); return end
 local view=screen.AbsoluteSize
 if view.X<1 or view.Y<1 then return end
 local ok,topLeft,bottomRight=pcall(function() return GuiService:GetGuiInset() end)
 topLeft=ok and topLeft or Vector2.zero
 bottomRight=ok and bottomRight or Vector2.zero
 local margin=math.max(8,math.min(view.X,view.Y)*Config.SafeFraction)
 local minX,minY=margin+topLeft.X,margin+topLeft.Y
 local maxX,maxY=view.X-margin-bottomRight.X,view.Y-margin-bottomRight.Y
 local size=current.size
 local sourceCenter=origin.AbsolutePosition+origin.AbsoluteSize*0.5
 local anchor=current.isTouch and sourceCenter or current.point or UserInputService:GetMouseLocation()
 local x,y,side
 if anchor.X+Config.Gap+size.X<=maxX then x=anchor.X+Config.Gap; side="left"
 elseif anchor.X-Config.Gap-size.X>=minX then x=anchor.X-Config.Gap-size.X;side="right"
 else
  x=math.clamp(sourceCenter.X-size.X*0.5,minX,math.max(minX,maxX-size.X))
  local above=origin.AbsolutePosition.Y-Config.Gap-size.Y
  if above>=minY then y=above;side="bottom"
  else y=origin.AbsolutePosition.Y+origin.AbsoluteSize.Y+Config.Gap;side="top" end
 end
 y=y or anchor.Y-size.Y*0.22
 x=math.clamp(x,minX,math.max(minX,maxX-size.X))
 y=math.clamp(y,minY,math.max(minY,maxY-size.Y))
 card.Position=UDim2.fromScale(x/view.X,y/view.Y)
 local px,py
 local edge=math.min(20,math.min(size.X,size.Y)*0.25)
 if side=="left" or side=="right" then
  px=side=="left" and x or x+size.X
  py=math.clamp(sourceCenter.Y,y+edge,y+size.Y-edge)
 else
  px=math.clamp(sourceCenter.X,x+edge,x+size.X-edge)
  py=side=="top" and y or y+size.Y
 end
 pointer.Position=UDim2.fromScale(px/view.X,py/view.Y)
 pointer.Size=UDim2.fromScale(Config.PointerSize/view.X,Config.PointerSize/view.Y)
 pointer.Visible=true
end

local function render()
 if not current then return end
 if not visible(current.origin) then System.Hide();return end
 ensureUI()
 local view=screen.AbsoluteSize
 if view.X<1 or view.Y<1 then return end
 local data=current.data
 local usableWidth=math.max(1,view.X-2*math.max(8,math.min(view.X,view.Y)*Config.SafeFraction))
 local width=math.min(usableWidth,math.clamp(view.X*Config.WidthFraction,Config.MinWidth,Config.MaxWidth))
 local padding=math.min(Config.Padding,width*0.07)
 local contentWidth=width-2*padding
 local rows={}
 local y=padding
 for _,spec in ipairs(data.rows or {}) do
  y+=spec.gap or 0
  local height
  if spec.progress then height=6
  else
   local font=spec.bold and Config.FontName or Config.FontBody
   local bounds=TextService:GetTextSize(spec.text or "",spec.size or Config.DetailSize,font,Vector2.new(contentWidth,100000))
   height=math.max(spec.size or Config.DetailSize,math.ceil(bounds.Y))+3
  end
  table.insert(rows,{spec=spec,y=y,height=height})
  y+=height+Config.RowGap
 end
 local total=math.max(45,y-Config.RowGap+padding)
 local insetTop,insetBottom=GuiService:GetGuiInset()
 local maxHeight=math.max(40,view.Y-insetTop.Y-insetBottom.Y-70)
 local height=math.min(total,maxHeight)
 current.size=Vector2.new(width,height)
 card.Size=UDim2.fromScale(width/view.X,height/view.Y)
 stroke.Color=data.border or Config.Colors.Purple
 pointer.Border.Color=stroke.Color
 for _,child in ipairs(body:GetChildren()) do child:Destroy() end
 for i,entry in ipairs(rows) do
  local spec=entry.spec
  if spec.progress then
   local track=create("Frame","SetProgress",body,{BackgroundColor3=Config.Colors.Track,BorderSizePixel=0,
    Position=UDim2.fromScale(padding/width,entry.y/total),Size=UDim2.fromScale(contentWidth/width,entry.height/total),ZIndex=4})
   corner(track)
   local fill=create("Frame","Fill",track,{BackgroundColor3=Config.Colors.Gold,BorderSizePixel=0,
    Size=UDim2.fromScale(math.clamp(spec.progress,0,1),1),ZIndex=5})
   corner(fill)
  else
   create("TextLabel","Line"..i,body,{BackgroundTransparency=1,
    Position=UDim2.fromScale(padding/width,entry.y/total),Size=UDim2.fromScale(contentWidth/width,entry.height/total),
    Font=spec.bold and Config.FontName or Config.FontBody,TextSize=spec.size or Config.DetailSize,
    Text=spec.text or "",TextColor3=spec.color or Config.Colors.Parchment,
    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
    TextWrapped=true,TextScaled=false,RichText=false,ZIndex=4})
  end
 end
 body.CanvasSize=UDim2.fromScale(0,total/height)
 body.CanvasPosition=Vector2.zero
 body.ScrollingEnabled=total>height
 body.Active=total>height
 card.Visible=true
 position()
end

function System.Show(entityType,data,origin,point,isTouch)
 if not data or not visible(origin) then System.Hide(origin);return end
 if entityType~="item_equipable" and entityType~="item_consumible" and entityType~="skill" then return end
 current={entityType=entityType,data=data,origin=origin,point=point,isTouch=isTouch==true}
 render()
end
function System.Refresh()
 if not current or renderQueued then return end
 renderQueued=true
 task.defer(function()
  renderQueued=false
  if not current then return end
  local record=bindings[current.origin]
  if record then current.data=record.provider(); if not current.data then System.Hide();return end end
  render()
 end)
end
function System.CanActivate(origin,input)
 local record=bindings[origin]
 if not record then return true end
 if input and input.UserInputType~=Enum.UserInputType.Touch then return true end
 return not (touch and touch.record==record and (touch.held or touch.cancelled))
  and not (record.suppressed and (not input or record.suppressed==input))
end

local function showRecord(record,point,isTouch)
 local data=record.provider()
 if not data then System.Hide(record.origin);return end
 System.Show(data.entityType,data,record.origin,point,isTouch)
end

function System.Unbind(origin)
 local record=bindings[origin]
 if not record then return end
 bindings[origin]=nil
 if touch and touch.record==record then touch=nil end
 System.Hide(origin)
 for _,connection in ipairs(record.connections) do connection:Disconnect() end
end
function System.Bind(origin,provider,options)
 System.Unbind(origin)
 options=options or {}
 local record={origin=origin,provider=provider,connections={},suppressed=nil}
 bindings[origin]=record
 local function connect(signal,callback)
  table.insert(record.connections,signal:Connect(callback))
 end
 local function invalidate()
  if touch and touch.record==record then
   record.suppressed=touch.input;touch.cancelled=true
  end
  System.Hide(origin)
 end
 connect(origin.MouseEnter,function()
  if lastDevice~=Enum.UserInputType.Touch then showRecord(record,UserInputService:GetMouseLocation(),false) end
 end)
 connect(origin.MouseLeave,function()
  if not current or not current.isTouch then System.Hide(origin) end
 end)
 connect(origin.InputBegan,function(input)
  if input.UserInputType==Enum.UserInputType.Touch and not options.externalTouch then
   record.suppressed=nil
   if not provider() or player:GetAttribute("UILayoutEditMode")==true then return end
   if touch then System.Hide(touch.record.origin) end
   local candidate={record=record,input=input,start=Vector2.new(input.Position.X,input.Position.Y),held=false,cancelled=false}
   touch=candidate
   task.delay(Config.HoldSeconds,function()
    if touch==candidate and not candidate.cancelled and visible(origin) then
     candidate.held=true;record.suppressed=input
     showRecord(record,candidate.start,true)
    end
   end)
  end
 end)
 connect(origin:GetPropertyChangedSignal("AbsolutePosition"),position)
 connect(origin:GetPropertyChangedSignal("AbsoluteSize"),position)
 connect(origin.Destroying,function() System.Unbind(origin) end)
 local node=origin
 while node and node~=playerGui do
  if node:IsA("GuiObject") then connect(node:GetPropertyChangedSignal("Visible"),function() if not visible(origin) then invalidate() end end) end
  if node:IsA("ScreenGui") then connect(node:GetPropertyChangedSignal("Enabled"),function() if not visible(origin) then invalidate() end end) end
  if node:IsA("ScrollingFrame") then connect(node:GetPropertyChangedSignal("CanvasPosition"),invalidate) end
  node=node.Parent
 end
 return function() System.Unbind(origin) end
end

UserInputService.LastInputTypeChanged:Connect(function(kind) lastDevice=kind end)
UserInputService.InputChanged:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseMovement and current and not current.isTouch then
  current.point=Vector2.new(input.Position.X,input.Position.Y)
  position()
 end
 if touch and input==touch.input then
  local point=Vector2.new(input.Position.X,input.Position.Y)
  if (point-touch.start).Magnitude>Config.MoveTolerance then
   touch.cancelled=true;touch.record.suppressed=input;System.Hide(touch.record.origin)
  end
 end
end)
UserInputService.InputEnded:Connect(function(input)
 if touch and input==touch.input then
  local candidate=touch
  if candidate.held or candidate.cancelled then candidate.record.suppressed=input end
  System.Hide(candidate.record.origin)
  touch=nil
 end
end)
player.CharacterAdded:Connect(function()
 touch=nil;Data.Reset();System.Hide()
end)
local cameraConnection
local function bindCamera()
 if cameraConnection then cameraConnection:Disconnect() end
 if workspace.CurrentCamera then cameraConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(System.Refresh) end
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()
-- Presentation updates only; no gameplay requests.
local remotes=ReplicatedStorage:WaitForChild("Remotes")
remotes:WaitForChild("InventoryData").OnClientEvent:Connect(function(value) Data.SetInventory(value);System.Hide() end)
remotes:WaitForChild("SpellbookData").OnClientEvent:Connect(function(value) Data.SetSpellbook(value);System.Hide() end)
return System

