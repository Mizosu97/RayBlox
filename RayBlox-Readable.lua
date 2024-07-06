local Camera = game.Workspace.CurrentCamera
local Window = script.Parent.Window
local RenderLabel = script.Parent.RenderLabel
local ResolutionX = Window.AbsoluteSize.X
local ResolutionY = Window.AbsoluteSize.Y


local SCALE = 8
local BOUNCES = 3
local RAYSPERPIXEL = 50


local function MulCol3(color1, color2)
	local cR = color1.R * color2.R
	local cG = color1.G * color2.G
	local cB = color1.B * color2.B
	return Color3.new(cR, cG, cB)
end
local function AvgCol3(colors)
	local colorCount = #colors
	local cR = 0
	local cG = 0
	local cB = 0
	for _,color in pairs(colors) do
		cR += color.R
		cG += color.G
		cB += color.B
	end
	cR /= colorCount
	cG /= colorCount
	cB /= colorCount
	return Color3.new(cR, cG, cB)
end



local function Setup()
	print("Setting up shader.")
	for incrementY = 0, ResolutionY, SCALE do
		for incrementX = 0, ResolutionX, SCALE do
			local newPixel = Instance.new("Frame")
			newPixel.Visible = false
			newPixel.Size = UDim2.new(0,SCALE,0,SCALE)
			newPixel.BackgroundColor3 = Color3.new(1,1,1)
			newPixel.Name = tostring(incrementX/SCALE) .. "," .. tostring(incrementY/SCALE)
			newPixel.BorderSizePixel = 0
			newPixel.Parent = Window
			newPixel.Position = UDim2.new(0,incrementX,0,incrementY)
			newPixel.Visible = true
		end
	end
	print("Setup complete.")
end


local function GetPixelCoordinates(Pixel)
	local coords = string.split(Pixel.Name, ",")
	return Vector2.new(coords[1], coords[2])
end


--[=[
local function RayTrace(Pixel)
	local FinalColor = Color3.new(1,1,1)
	local rayOrigin = game.Workspace.CurrentCamera:ScreenPointToRay(Pixel.AbsolutePosition.X, Pixel.AbsolutePosition.Y)
	local rayDirection = rayOrigin.Direction * 1000
	local ray = Ray.new(rayOrigin.Origin, rayDirection)
	local part, position, normal = workspace:FindPartOnRay(ray, game.Players.LocalPlayer.Character, false, true)
	if part then
		FinalColor = part.Color
		if part.Reflectance ~= 0 then
			local incidentDirection = (position - ray.Origin).unit
			local reflectedDirection = incidentDirection - 2 * normal:Dot(incidentDirection) * normal
			local reflectedRay = Ray.new(position, reflectedDirection * 1000)
			local partR, positionR, normalR = workspace:FindPartOnRay(reflectedRay, game.Players.LocalPlayer.Character, false, true)
			if partR then
				print("ray reflected and found a part " .. partR.Name)
				Pixel.BackgroundColor3 = part.Color:lerp(partR.Color, part.Reflectance)
			else
				Pixel.BackgroundColor3 = part.Color:lerp(Color3.new(0.270588, 0.643137, 0.890196), part.Reflectance)
			end
		end
	else
		Pixel.BackgroundColor3 = Color3.new(0.270588, 0.643137, 0.890196)
	end
end
]=]--

local function ShootRay(origin, direction)
	local ray = Ray.new(origin, direction)
	local part, position, normal = workspace:FindPartOnRay(ray, game.Players.LocalPlayer.Character, false, true)
	return {
		["ray"] = ray,
		["part"] = part,
		["position"] = position,
		["normal"] = normal
	}
end

local function ReflectRay(rayInfo, reflectance)
	local perfectReflectance = 1.0
	local randomReflectance = 0.0
	local incidentDirection = (rayInfo.position - rayInfo.ray.Origin).unit
	local reflectedDirection

	if reflectance == 1.0 then
		reflectedDirection = incidentDirection - 2 * rayInfo.normal:Dot(incidentDirection) * rayInfo.normal
	elseif reflectance == 0.0 then
		reflectedDirection = Vector3.new(math.random(), math.random(), math.random()).Unit
	else
		local randomDirection = Vector3.new(math.random(), math.random(), math.random()).Unit
		local perfectReflectionDirection = incidentDirection - 2 * rayInfo.normal:Dot(incidentDirection) * rayInfo.normal
		local dotProduct = reflectedDirection:Dot(rayInfo.normal)
		if dotProduct < 0 then
			reflectedDirection = -reflectedDirection
		end

		reflectedDirection = (1 - reflectance) * randomDirection + reflectance * perfectReflectionDirection
	end
	
	local reflectedRay = Ray.new(rayInfo.position, reflectedDirection * 1000)
	local partR, positionR, normalR = workspace:FindPartOnRay(reflectedRay, game.Players.LocalPlayer.Character, false, true)

	return {
		["ray"] = reflectedRay,
		["part"] = partR,
		["position"] = positionR,
		["normal"] = normalR
	}
end

local function RayTrace(Pixel)
	local FinalColor = Color3.new(1,1,1)
	
	local rayOrigin = game.Workspace.CurrentCamera:ScreenPointToRay(Pixel.AbsolutePosition.X, Pixel.AbsolutePosition.Y)
	local rayDirection = rayOrigin.Direction * 1000
	local initialRay = ShootRay(rayOrigin.Origin, rayDirection)
	
	if initialRay.part ~= nil then
		if initialRay.part.Material == Enum.Material.Neon then
			FinalColor = initialRay.part.Color
		else
			local PartsColors = {}
			table.insert(PartsColors, initialRay.part.Color)

			local lightsourcefound = false
			local lightColor = Color3.new(0, 0, 0)
			local internalbouncecount = 0
			local previousRay = initialRay

			while internalbouncecount ~= BOUNCES and not lightsourcefound do
				local newRay = ReflectRay(previousRay, previousRay.part.Reflectance)

				if newRay.part == nil then
					lightsourcefound = true
					lightColor = Color3.new(0.713725, 0.772549, 0.890196)
				elseif newRay.part.Material == Enum.Material.Neon then
					lightsourcefound = true
					lightColor = newRay.part.Color
				else
					table.insert(PartsColors, newRay.part.Color)
				end

				internalbouncecount += 1
			end
			if lightsourcefound then
				FinalColor = MulCol3(MulCol3(FinalColor, lightColor), AvgCol3(PartsColors))
			else
				FinalColor = Color3.new(0,0,0)
			end

		end
	else
		FinalColor = Color3.new(0.270588, 0.643137, 0.890196)
	end
	
	return FinalColor
end



local ShaderPasses = {
	function(Pixel)
		local colors = {}
		for i = 0, RAYSPERPIXEL, 1 do
			table.insert(colors, RayTrace(Pixel))
		end
		Pixel.BackgroundColor3 = AvgCol3(colors)
	end,
}


local function IteratePixels()
	print("Starting main pixel iteration.")
	for _,Pixel in pairs(Window:GetChildren()) do
		--coroutine.wrap(function()
			for _,Pass in ipairs(ShaderPasses) do
				print("Passing pixel.")
				Pass(Pixel)
			end
		--end)
	end
end


Setup()

local uis = game:GetService("UserInputService")
local active = false
uis.InputBegan:Connect(function(inp, ga)
	if inp.KeyCode == Enum.KeyCode.Equals then
		if active == false then
			RenderLabel.Visible = true
			wait(1)
			Window.Visible = true
			IteratePixels()
			active = true
		else
			RenderLabel.Visible = false
			Window.Visible = false
			active = false
		end
	end
end)
