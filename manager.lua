-- TEMP MOCK CODE --
local turtle = require 'turtle-mock'
local os = require 'os-mock'
local peripheral = require 'peripheral-mock'
local mineConfigFile = 'mineConfig.lua'
-- END TEMP MOCK CODE --
local mineConfigFile = 'disk/mineConfig.lua'
local TURTLE_ID = 'computercraft:turtle_expanded'
local ADVANCED_TURTLE_ID = 'computercraft:turtle_advanced'

local tArgs = { ... }
local computerCoordinatesModule = 'computerCoordinates'
local computerCoordinatesFileName = 'computerCoordinates.lua'
local computerCoordinates = nil
local dropCoordinatesFileName = 'dropCoordinates.lua'
local dropCoordinatesModule = 'dropCoordinates'
local dropCoordinates = nil

local function setCoordinates(x,y,z)
    coordinatesFile = io.open(computerCoordinatesFileName,'w+')
    io.output(coordinatesFile)
    io.write('COMPUTER_X_POS, COMPUTER_Y_POS, COMPUTER_Z_POS = '..x..', '..y..', '..z)
    io.close(coordinatesFile)
end

local function isInteger(value)
    local number = tonumber(value)
    return number ~= nil and 'number' == type(number) and number == math.floor(number)
end

local function isCoordinatesFileValid(coordinatesFile, coordinatesModule)
    if coordinatesFile ~= nil then
        if coordinatesModule == computerCoordinatesModule then
            computerCoordinates = require(coordinatesModule)
            return COMPUTER_X_POS ~= nil and COMPUTER_Y_POS ~= nil and COMPUTER_Z_POS ~= nil and
                    isInteger(COMPUTER_X_POS) and isInteger(COMPUTER_Y_POS) and isInteger(COMPUTER_Z_POS)
        elseif coordinatesModule == dropCoordinatesModule then
            dropCoordinates = require(coordinatesModule)
            return DROP_X_POS ~= nil and DROP_Y_POS ~= nil and DROP_Z_POS ~= nil and
                    isInteger(DROP_X_POS) and isInteger(DROP_Y_POS) and isInteger(DROP_Z_POS)
        end
    end

    return false
end

local function getTurtleCount()
    local turtleCount = 0

    for itemSlot=1,16 do
        local item = turtle.getItemDetail(itemSlot)
        if item ~= nil and (item.name == TURTLE_ID or item.name == ADVANCED_TURTLE_ID) then
            turtleCount = turtleCount + 1
        end
    end

    return turtleCount
end

local function setDropCoordinates(x,y,z)
    dropCoordinatesFile = io.open(dropCoordinatesFileName,'w+')
    io.output(dropCoordinatesFile)
    io.write('DROP_X_POS, DROP_Y_POS, DROP_Z_POS = '..x..', '..y..', '..z)
    io.close(dropCoordinatesFile)
end

local function isSetCoordinatesCommand(tArgs)
    return #tArgs == 4 and (tArgs[1] == '-sc' or tArgs[1] == '--set-coordinates')
end

local function isGetCoordinatesCommand(tArgs)
    return #tArgs == 1 and (tArgs[1] == '-gc' or tArgs[1] == '--get-coordinates')
end

local function isDeployCommand(tArgs)
    return (#tArgs == 11 or #tArgs == 5 or #tArgs == 7 or #tArgs == 9) and
        (tArgs[1] == '-d' or tArgs[1] == '--deploy')
end

local function isDeployRelativeCommand(tArgs)
    return #tArgs == 4 and (tArgs[1] == '-dr' or tArgs[1] == '--deploy-relative')
end

local function isTurtleCountCommand(tArgs)
    return #tArgs == 1 and tArgs[1] == '-tc'
end

local function isSetDropCoordinatesCommand(tArgs)
    return #tArgs == 4 and (tArgs[1] == '-sd' or tArgs[1] == '-set-drop')
end

local function isGetDropCoordinatesCommand(tArgs)
    return #tArgs == 1 and (tArgs[1] == '-gd' or tArgs[1] == '-get-drop')
end

local function getDeployParams(tArgs)
    local function isValidParam(index)
        return tArgs[index] ~= nil and isInteger(tArgs[index])
    end

    local params =  {
        location = nil,
        count = 1,
        size = {
            x = 100,
            y = 5,
            z = 100
        }
    }

    for i=2,#tArgs do
        if tArgs[i] == '-l' then
            local isValidLocationParam = true
            for j=i+1,i+3 do
                if not isValidParam(j) then
                   isValidLocationParam = false
                   break
                end
            end

            if isValidLocationParam then
                params.location = {
                    x = tonumber(tArgs[i+1]),
                    y = tonumber(tArgs[i+2]),
                    z = tonumber(tArgs[i+3])
                }

                i = i + 3
            else
                break
            end
        elseif tArgs[i] == '-c' then
            if isValidParam(i+1) then
               params.count = tonumber(tArgs[i+1])
               i = i + 1
            else
                params.count = nil
                break
            end
        elseif tArgs[i] == '-s' then
            local isValidSizeParam = true
            for j=i+1,i+3 do
                if not isValidParam(j) then
                   isValidSizeParam = false
                   break
                end
            end

            if isValidSizeParam then
                params.size = {
                    x = tonumber(tArgs[i+1]),
                    y = tonumber(tArgs[i+2]),
                    z = tonumber(tArgs[i+3])
                }

                i = i + 3
            else
                params.size = nil
                break
            end
        end
    end

    return params
end

function refuel(amount)
    if fuelLevel == 'unlimited' then
        return true
    end

    if turtle.getFuelLevel() == 0 then
        local isFueled = false
        for itemSlot=1,16 do
            if turtle.getItemCount(itemSlot) > 0 then
                turtle.select(itemSlot)
                if turtle.refuel(1) then

                    -- refuel turtle until needed amount or until no fuel remains
                    while turtle.getItemCount(itemSlot) > 0 do
                        turtle.refuel(1)
                    end
                end
            end
        end
        turtle.select(1)
    end

    return turtle.getFuelLevel() > 0
end

local function tryUp()
    if not refuel() then
        print( "Not enough Fuel" )
    end

    return turtle.up()
end

local function tryDown()
    if not refuel() then
        print( "Not enough Fuel" )
    end

    return turtle.down()
end

local function getTurtlePositions(turtleCount, relativeLocation, mineSize)
    if turtleCount == 1 then
        return {
            {
                xLoc = relativeLocation.x,
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z,
                mineRight = mineSize.x,
                mineHeight = mineSize.y,
                mineForward = mineSize.z,
                xDir = 0,
                zDir = 1
            }
        }
    elseif turtleCount == 2 then
        return {
            {
                xLoc = relativeLocation.x,
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2) + 1,
                mineRight = mineSize.x,
                mineHeight = mineSize.y,
                mineForward = math.floor(mineSize.z / 2) - 1,
                xDir = 0,
                zDir = 1
            },
            {
                xLoc = relativeLocation.x + mineSize.x,
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2),
                mineRight = mineSize.x,
                mineHeight = mineSize.y,
                mineForward = math.floor(mineSize.z / 2),
                xDir = 0,
                zDir = -1
            }
        }
    --    TODO: fix turtle count 3, 3rd mines back, 2nd mines right, 1st mines forward
    elseif turtleCount == 3 then
        return {
            {
                xLoc = relativeLocation.x,
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2) + 1,
                mineRight = mineSize.x,
                mineHeight = mineSize.y,
                mineForward = math.floor(mineSize.z / 2) - 1,
                xDir = 0,
                zDir = 1
            },
            {
                xLoc = relativeLocation.x + math.floor(mineSize.x / 2),
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2),
                mineForward = math.floor(mineSize.x / 2) - 1,
                mineHeight = mineSize.y,
                mineRight = math.floor(mineSize.z / 2),
                xDir = 1,
                zDir = 0
            },
            {
                xLoc = relativeLocation.x + math.floor(mineSize.x / 2) + 1,
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2),
                mineRight = math.floor(mineSize.x / 2),
                mineHeight = mineSize.y,
                mineForward = math.floor(mineSize.z / 2),
                xDir = 0,
                zDir = -1
            }
        }
    elseif turtleCount == 4 then
        return {
            {
                xLoc = relativeLocation.x + math.floor(mineSize.x / 2),
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2) + 1,
                mineForward = math.floor(mineSize.x / 2),
                mineHeight = mineSize.y,
                mineRight = math.floor(mineSize.z / 2) - 1,
                xDir = -1,
                zDir = 0
            },
            {
                xLoc = relativeLocation.x + math.floor(mineSize.x / 2) + 1,
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2) + 1,
                mineRight = math.floor(mineSize.x / 2) - 1,
                mineHeight = mineSize.y,
                mineForward = math.floor(mineSize.z / 2) - 1,
                xDir = 0,
                zDir = 1
            },
            {
                xLoc = relativeLocation.x + math.floor(mineSize.x / 2),
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2),
                mineRight = math.floor(mineSize.x / 2),
                mineHeight = mineSize.y,
                mineForward = math.floor(mineSize.z / 2),
                xDir = 0,
                zDir = -1
            },
            {
                xLoc = relativeLocation.x + math.floor(mineSize.x / 2) + 1,
                yLoc = relativeLocation.y,
                zLoc = relativeLocation.z + math.floor(mineSize.z / 2),
                mineForward = math.floor(mineSize.x / 2) - 1,
                mineHeight = mineSize.y,
                mineRight = math.floor(mineSize.z / 2),
                xDir = 1,
                zDir = 0
            }
        }
    end

    return nil
end

local function main()
    if isSetCoordinatesCommand(tArgs) then
        x = tArgs[2]
        y = tArgs[3]
        z = tArgs[4]

        setCoordinates(x,y,z)

    elseif isGetCoordinatesCommand(tArgs) then
        local coordinatesFile = io.open(computerCoordinatesFileName, 'r')

        if isCoordinatesFileValid(coordinatesFile, computerCoordinatesModule, {
            x = COMPUTER_X_POS, y = COMPUTER_Y_POS, z = COMPUTER_Z_POS
        }) then
            computerCoordinates = require(computerCoordinatesModule)
            print('x = '..COMPUTER_X_POS)
            print('y = '..COMPUTER_Y_POS)
            print('z = '..COMPUTER_Z_POS)
        else
            print('Computer coordinates file not set. Run deploy -sc <x> <y> <z> to set computer coordinates file.')
        end
    elseif isDeployCommand(tArgs) then
        local params = getDeployParams(tArgs)

        if params.location == nil or params.count == nil or params.size == nil then
            print('Invalid command. Deploy command must be in one of the following formats:')
            print('manager -d -l <x> <y> <z> -c <count> -s <x> <y> <z>')
            print('manager -d -l <x> <y> <z> -c <count>')
            print('manager -d -l <x> <y> <z> -s <x> <y> <z>')
            print('manager -d -l <x> <y> <z>')
            return
        end

        local computerCoordinatesFile = io.open(computerCoordinatesFileName, 'r')
        local dropCoordinatesFile = io.open(dropCoordinatesFileName, 'r')

        if isCoordinatesFileValid(computerCoordinatesFile, computerCoordinatesModule, {
            x = COMPUTER_X_POS, y = COMPUTER_Y_POS, z = COMPUTER_Z_POS
        }) then
            computerCoordinates = require(computerCoordinatesModule)
        else
            print('Computer coordinates file not set. Run deploy -sc <x> <y> <z> to set computer coordinates file.')
            return
        end

        if isCoordinatesFileValid(dropCoordinatesFile, dropCoordinatesModule, {
            x = DROP_X_POS, y = DROP_Y_POS, z = DROP_Z_POS
        }) then
            dropCoordinates = require(dropCoordinatesModule)
        else
            print('Drop coordinates file not set. Run deploy -sd <x> <y> <z> to set drop coordinates file.')
            return
        end

        local turtleCount = getTurtleCount()

        if params.count > 4 then
            print('Too many turtles, the max is 4 per mining trip')
            return
        elseif params.count > turtleCount and turtleCount > 0 then
            print('Not enough turtles to perform this action, would you like to use the '..turtleCount..' available? [y/n]')
            local useAvailable = io.read()

            if useAvailable:lower() == 'y' then
                params.count = turtleCount
                print('Using available '..turtleCount..' turtles...')
            else
                return
            end
        elseif turtleCount == 0 then
            print('No turtles to deploy')
            return
        end

        mineSize = params.size
        count = params.count
        relativeLocation = {
            x = params.location.x - COMPUTER_X_POS,
            y = params.location.y - COMPUTER_Y_POS,
            z = params.location.z - COMPUTER_Z_POS
        }

        local turtlePositions = getTurtlePositions(count, relativeLocation, mineSize)

        for i=1,count do
            local diskDrive = peripheral.wrap('front')
            if diskDrive == nil then
                if not tryDown() then
                    tryUp()
                end

                diskDrive = peripheral.wrap('front')
            end

            if diskDrive == nil then
                print('ERROR: could not find disk drive')
                return
            end

            local mineConfig = io.open(mineConfigFile, 'w+')
            io.output(mineConfig)
            io.write('LOCATION_X_POS, LOCATION_Y_POS, LOCATION_Z_POS = '..turtlePositions[i].xLoc..', '..turtlePositions[i].yLoc..', '..turtlePositions[i].zLoc..'\n')
            io.write('DROP_X_POS, DROP_Y_POS, DROP_Z_POS = '..(DROP_X_POS - COMPUTER_X_POS)..', '..(DROP_Y_POS - COMPUTER_Y_POS)..', '..(DROP_Z_POS - COMPUTER_Z_POS - 1)..'\n')
            io.write('MINE_FORWARD, MINE_HEIGHT, MINE_RIGHT = '..turtlePositions[i].mineForward..', '..turtlePositions[i].mineHeight..', '..turtlePositions[i].mineRight..'\n')
            io.write('X_DIRECTION, Z_DIRECTION = '..turtlePositions[i].xDir..', '..turtlePositions[i].zDir)
            io.close(mineConfig)

            if not tryUp() then
                print('ERROR: obstable blocking ability to move up to place turtle')
                return
            end

            if turtle.detect() then
                print('ERROR: obstacle blocking turtle placement')
                return
            end

            for itemSlot=1,16 do
                local item = turtle.getItemDetail(itemSlot)
                if item ~= nil and (item.name == TURTLE_ID or item.name == ADVANCED_TURTLE_ID) then
                    turtle.select(itemSlot)
                    if turtle.place() then
                        break
                    else
                        print('ERROR: could not place turtle')
                        return
                    end
                end
            end

            while turtle.detect() do
                sleep(0.5)
            end
        end

        turtle.select(1)
    elseif isDeployRelativeCommand(tArgs) then
        print('Deploying relative to current position...')
    elseif isTurtleCountCommand(tArgs) then
        print('Turtle Count: '..getTurtleCount())
    elseif isSetDropCoordinatesCommand(tArgs) then
        local coordinatesFile = io.open(computerCoordinatesFileName, 'r')

        if not isCoordinatesFileValid(coordinatesFile, computerCoordinatesModule, {
            x = COMPUTER_X_POS, y = COMPUTER_Y_POS, z = COMPUTER_Z_POS
        }) then
            print('Computer\'s coordinates must be set before drop coordinates')
            return
        end

        x = tArgs[2]
        y = tArgs[3]
        z = tArgs[4]

        setDropCoordinates(x,y,z)
    elseif isGetDropCoordinatesCommand(tArgs) then
        local coordinatesFile = io.open(dropCoordinatesFileName, 'r')

        if isCoordinatesFileValid(coordinatesFile, dropCoordinatesModule, {
            x = DROP_X_POS, y = DROP_Y_POS, z = DROP_Z_POS
        }) then
            dropCoordinates = require(dropCoordinatesModule)
            print('x = '..DROP_X_POS)
            print('y = '..DROP_Y_POS)
            print('z = '..DROP_Z_POS)
        else
            print('Drop coordinates file not set. Run deploy -sd <x> <y> <z> to set drop coordinates file.')
        end
    else
        print('Invalid command. Type manager -h for help.')
    end
end

main()