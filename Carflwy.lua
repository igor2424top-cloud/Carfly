local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local vehicle = nil
local flying = false
local flyThread = nil

-- Функция поиска машины, в которой сидит игрок
local function findPlayerVehicle()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant == humanoid then
            local veh = v.Parent
            while veh and not veh:IsA("Model") do veh = veh.Parent end
            if veh then return veh end
        end
    end
    return nil
end

-- Функция CarFly
local function startCarFly()
    vehicle = findPlayerVehicle()
    if not vehicle then
        print("[CarFly] Ты не в транспорте! Сядь в машину.")
        return false
    end
    
    local primary = vehicle:FindFirstChild("PrimaryPart") or vehicle:FindFirstChildWhichIsA("BasePart")
    if not primary then
        print("[CarFly] У транспорта нет PrimaryPart")
        return false
    end
    
    flying = true
    print("[CarFly] Активирован")
    
    if flyThread then task.cancel(flyThread) end
    flyThread = task.spawn(function()
        while flying and vehicle and vehicle.Parent and primary and primary.Parent do
            -- Удерживаем транспорт рядом с игроком и поднимаем
            local targetCF = root.CFrame * CFrame.new(0, -1.5, -4) -- чуть сзади и ниже
            vehicle:SetPrimaryPartCFrame(targetCF)
            
            -- Подъёмная сила
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, 20, 0) -- скорость подъёма
            bv.Parent = primary
            task.wait(0.1)
            bv:Destroy()
            
            -- Стабилизация от опрокидывания
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.CFrame = root.CFrame
            bg.Parent = primary
            task.wait(0.1)
            bg:Destroy()
            
            task.wait()
        end
    end)
    return true
end

local function stopCarFly()
    flying = false
    if flyThread then task.cancel(flyThread); flyThread = nil end
    if vehicle then
        for _, obj in pairs(vehicle:GetDescendants()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then obj:Destroy() end
        end
    end
    print("[CarFly] Деактивирован")
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.Parent = player:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 200, 0, 100)
f.Position = UDim2.new(0.5, -100, 0.5, -50)
f.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
f.BackgroundTransparency = 0.2
f.BorderSizePixel = 0
f.Active = true
f.Draggable = true
local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 8)
uc.Parent = f
f.Parent = sg

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.8, 0, 0, 40)
btn.Position = UDim2.new(0.1, 0, 0.3, 0)
btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
btn.Text = "CARFLY (Вкл)"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextScaled = true
btn.Parent = f
local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 6)
bc.Parent = btn

btn.MouseButton1Click:Connect(function()
    if not flying then
        local ok = startCarFly()
        if ok then
            btn.Text = "CARFLY (Выкл)"
            btn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        else
            btn.Text = "Нет машины!"
            task.wait(1)
            btn.Text = "CARFLY (Вкл)"
        end
    else
        stopCarFly()
        btn.Text = "CARFLY (Вкл)"
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end
end)

print("[ROCKET] Trident Carfly исправлен и готов")
