-- TEMP MOCK CODE --
local turtle = require 'turtle-mock'
local os = require 'os-mock'
-- END TEMP MOCK CODE --

local tArgs = { ... }

if #tArgs ~= 2 then
    print('Usage: mine <diameter> <height>')
    return
end

local mineDiameter, mineHeight = tonumber(tArgs[1]), tonumber(tArgs[2])
if mineDiameter < 1 or mineHeight < 1 then
    print('Diameter and Height must be positive integers')
    return
end

local xPos, zPos, yPos = 0, 0, 0
local xDir, zDir = 0, 1

local collected = 0
local unloaded = 0

function refuel(amount)
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == 'unlimited' then
        return true
    end

    -- fuelNeeded either equals specified amount of the position from the start location
    -- I think the 2 at the end signifies the turtle turning twice to turn around
    local fuelNeeded = amount or (xPos + zPos + yPos + 2)
    if turtle.getFuelLevel() < fuelNeeded then
        local isFueled = false
        for itemSlot=1,16 do
            if turtle.getItemCount(itemSlot) > 0 then
                turtle.select(itemSlot)
                if turtle.refuel(1) then

                    -- refuel turtle until needed amount or until no fuel remains
                    while turtle.getItemCount(itemSlot) > 0 and turtle.getFuelLevel() < fuelNeeded do
                        turtle.refuel(1)
                    end
                    if turtle.getFuelLevel() >= fuelNeeded then
                        turtle.select(1)
                        return true
                    end
                end
            end
        end
        turtle.select(1)
        return false
    end

    return true
end

local function unload(keepOneFuelStack)
    print('Unloading items...')
    for itemSlot=1,16 do
        local slotItemCount = turtle.getItemCount(itemSlot)
        if slotItemCount > 0 then
            turtle.select(itemSlot)
            local shouldDropStack = true
            if keepOneFuelStack and turtle.refuel(0) then
                shouldDropStack = false
                keepOneFuelStack = false
            end
            if shouldDropStack then
                turtle.drop()
                unloaded = unloaded + slotItemCount
            end
        end
    end
    collected = 0
    turtle.select(1)
end

local function collect()
    local isFull = true
    local totalItems = 0
    for itemSlot=1,16 do
        local itemCount = turtle.getItemCount(itemSlot)
        if itemCount == 0 then
            isFull = false
        end
        totalItems = totalItems + itemCount
    end

    if totalItems > collected then
        collected = totalItems
        if math.fmod(collected + unloaded, 50) == 0 then
            print('Mined '..(collected + unloaded)..' items.')
        end
    end

    if isFull then
        print('No empty slots available')
        return false
    end
    return true
end

local function turnLeft()
    turtle.turnLeft()
    xDir, zDir = -zDir, xDir
end

local function turnRight()
    turtle.turnRight()
    xDir, zDir = zDir, -xDir
end

-- Could be refactored
local function goTo(x, y, z, xd, zd)
    while yPos < y do
        print('yPos:', yPos)
        if turtle.up() then
            yPos = yPos + 1
        elseif turtle.digUp() or turtle.attackUp() then
            collect()
        else
            sleep(0.5)
        end
    end
    
    if xPos > x then
        while xDir ~= -1 do
            turnLeft()
        end
        while xPos > x do
            if turtle.forward() then
                xPos = xPos - 1
            elseif turtle.dig() or turtle.attack() then
                collect()
            else
                sleep(0.5)
            end
        end
    elseif xPos < x then
        while xDir ~= 1 do
            turnLeft()
        end
        while xPos < x do
            if turtle.forward() then
                xPos = xPos + 1
            elseif turtle.dig() or turtle.attack() then
                collect()
            else
                sleep(0.5)
            end
        end
    end

	if zPos > z then
		while zDir ~= -1 do
			turnLeft()
		end
		while zPos > z do
			if turtle.forward() then
				zPos = zPos - 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	elseif zPos < z then
		while zDir ~= 1 do
			turnLeft()
		end
		while zPos < z do
			if turtle.forward() then
				zPos = zPos + 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end	
	end

    while yPos > y do
		if turtle.down() then
			yPos = yPos - 1
		elseif turtle.digDown() or turtle.attackDown() then
			collect()
		else
			sleep( 0.5 )
		end
	end

    while zDir ~= zd or xDir ~= xd do
		turnLeft()
	end

end

local function returnSupplies()
    local x, y, z, xd, zd = xPos, yPos, zPos, xDir, zDir
    print('Returning to start...')
    goTo(0, 0, 0, 0, -1)

    local fuelNeeded = 2 * (x + y + z) + 1
    if not refuel(fuelNeeded) then
        unload(true)
        print('Waiting for fuel...')
        while not refuel(fuelNeeded) do
            os.pullEvent('turtle_inventory')
        end
    else
        unload('true')
    end

    print('Resuming mining...')
    goTo(x, y, z, xd, zd)
end

if not refuel() then
    print('Out of fuel')
    return
end 

local function tryUp()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies()
	end
	
	while not turtle.up() do
		if turtle.detectUp() then
			if turtle.digUp() then
				if not collect() then
					returnSupplies()
				end
			else
				return false
			end
		elseif turtle.attackUp() then
			if not collect() then
				returnSupplies()
			end
		else
			sleep( 0.5 )
		end
	end
	
	yPos = yPos + 1

	return true
end

local function tryDown()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies()
	end
	
	while not turtle.down() do
		if turtle.detectDown() then
			if turtle.digDown() then
				if not collect() then
					returnSupplies()
				end
			else
				return false
			end
		elseif turtle.attackDown() then
			if not collect() then
				returnSupplies()
			end
		else
			sleep( 0.5 )
		end
	end
	
	yPos = yPos - 1
	return true
end

local function tryForwards()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies()
	end
	
	while not turtle.forward() do
		if turtle.detect() then
			if turtle.dig() then
				if not collect() then
					returnSupplies()
				end
			else
				return false
			end
		elseif turtle.attack() then
			if not collect() then
				returnSupplies()
			end
		else
			sleep( 0.5 )
		end
	end
	
	xPos = xPos + xDir
	zPos = zPos + zDir
	return true
end

local function mineVertically(mineDirectionUp)
    for k=1,mineHeight-1 do
        if mineDirectionUp then
            if not tryUp() then
                return true
            end
        else
            if not tryDown() then
                return true
            end
        end
    end

    return false
end

local function main()
    print('Mining...')
    
    turtle.select(1)
    
    local alternate = false
    local done = false
    local mineDirectionUp = true
    for i=1,mineDiameter do
    
        for j=1,mineDiameter-1 do
            done = mineVertically(mineDirectionUp)    
            mineDirectionUp = not mineDirectionUp
   
             if not tryForwards() then
                done = true
                break
            end
               

            if done then
                break
            end
        end

        done = mineVertically(mineDirectionUp)    
        mineDirectionUp = not mineDirectionUp
     
        -- if done or at the end of mining trip quit
        -- quit at i == mineDiameter or turtle will turn into next row despite being done
        if done or i == mineDiameter then
            break
        end
    
        if alternate then
             turnLeft()
    
            if not tryForwards() then
                done = true
                break
            end
    
            turnLeft()
        else
            turnRight()
    
            if not tryForwards() then
                done = true
                break
            end
    
            turnRight()
        end
    
        alternate = not alternate
    
        -- done = mineVertically(mineDirectionUp)
        -- mineDirectionUp = not mineDirectionUp

        if done then
            break
        end
    end
    
    print('Going home...')
    
    goTo(0, 0, 0, 0, -1)
    unload(false)
    goTo(0, 0, 0, 0, 1)
    
    print( "Mined "..(collected + unloaded).." items total." )
end

main()
