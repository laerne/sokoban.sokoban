class = require "hump.class"

mob = {}

function mob.xystr( x, y )
    return tostring(x)..":"..tostring(y)
end


Crate = class {
    init = function( self, settings )
        self.kind = 'crate'
        self.facing = 'down'
        self.action = 'idle'
        self.pos = settings.position
        self.startTime = love.timer.getTime()
    end,
}

function Crate:__tostring()
    return 'crate'
end

--TODO :
function Crate:positionTo( target )
    local oldPos = self.pos
    self.pos = target

    if self.crateTable then
        local oldxystr = mob.xystr( oldPos.x, oldPos.y )
        local targetxystr = mob.xystr( target.x, target.y )
        
        self.crateTable[oldxystr] = nil
        self.crateTable[targetxystr] = self
    end

    if self.subLayer then
        local coarseShift = target - oldPos
        local n = #self.subLayer
        local fineShift = coarseShift * n
        for i, subRow in ipairs( self.subLayer ) do
            for j, subTile in ipairs( subRow ) do
                if subTile.mob then
                    --print( '!!!', subTile.mob.pos, subTile.mob.kind )
                    subTile.mob:positionTo( subTile.mob.pos + fineShift )
                    --print( '--->', subTile.mob.pos )
                end
            end
        end
    end
end

mob.Crate = Crate

Character = class {
    init = function( self, settings )
        self.kind = 'character'
        self.pos = settings.position
        self.facing = 'down'
        self.action = 'idle'
        self.startTime = love.timer.getTime()
    end,
}

function Character:__tostring()
    return 'character at ('..self.pos.x..','..self.pos.y..')'
end

function Character:positionTo( target )
    self.pos = target
end

mob.Character = Character


mobFactory = {
    crate = { builder = mob.Crate },
    character = { builder = mob.Character },
}

function build( settings )
    if type(settings) == "string" then
        settings = { kind = settings }
    end
    
    return mobFactory[settings.kind].builder( settings )
end
mob.build = build

return mob


