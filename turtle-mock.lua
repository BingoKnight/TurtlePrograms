local turtle = {}
local fuelLevel = 100

function turtle.up()
    print('Turtle moving up')
    return true
end

function turtle.down()
    print('Turtle moving down')
    return true
end

function turtle.forward()
    print('Turtle moving forward')
    return true
end

function turtle.back()
    print('Turtle moving back')
    return true
end

function turtle.turnLeft()
    print('Turtle turning left')
    return true
end

function turtle.turnRight()
    print('Turtle turning right')
    return true
end

function turtle.select(slotNum)
    print('Turtle select item',slotNum)
    return true
end

function turtle.dig(toolSide)
    print('Turtle dig forward with tool array:')
    if toolSide == nil or #toolSide == 0 then
        print('No tool array')
        return true
    end

    for i,v in ipairs(toolSide) do
        print(v)
    end
    return true
end

function turtle.digUp(toolSide)
    print('Turtle dig up with tool array:')
    if toolSide == nil or #toolSide == 0 then
        print('No tool array')
        return true
    end

    for i,v in ipairs(toolSide) do
        print(v)
    end
    return true
end

function turtle.digDown(toolSide)
    print('Turtle dig down tool array:')
    if toolSide == nil or #toolSide == 0 then
        print('No tool array')
        return true
    end
    for i,v in ipairs(toolSide) do
        print(v)
    end
    return true
end

function turtle.detect()
    print('Turtle detecting obstacle in front')
    return false
end

function turtle.detectUp()
    print('Turtle detecting obstacle above')
    return false
end

function turtle.detectDown()
    print('Turtle detecting obstacle below')
    return false
end

function turtle.getFuelLevel()
    print('Getting fuel level...')
    print('Fuel Level:',fuelLevel)
    return fuelLevel
end

function turtle.getFuelLimit()
    print('Getting fuel limit: 20000')
    return 20000
end

function turtle.getItemCount()
    print('Getting item count')
    return 64
end

function turtle.refuel(refuelAmount)
    print('Refueling...')
    return number
end

function turtle.drop(count)
    print('Dropping...')
end

function turtle.getItemDetail(index)
    local itemArray = {}

    for i=1,16 do
        itemArray[i] = nil
    end
    
    itemArray[3] = { name = 'minecraft:cobblestone' }
    itemArray[7] = { name = 'computercraft:turtle_expanded' }
    itemArray[15] = { name = 'computercraft:turtle_advanced' }
    itemArray[16] = { name = 'computercraft:turtle_expanded' }

    return itemArray[index]
end

function turtle.place(signText)
    if signText == nil then
        print('Object was placed in front')
    else
        print('Object was place with text "'..signText..'"')
    end

    return true
end

return turtle
