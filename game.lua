class = require "hump.class"
vector = require "hump.vector"
timer = require "hump.timer"
tile = require "tile"
mob = require "mob"
level_loader = require "level_loader"

game = {}

Layer = class{
    init = function( self, settings )
        self.character = mob.Character( settings.level.character )
        self.map = level_loader.tilemap_from_image( settings.level.image )
        self.map[self.character.pos.x][self.character.pos.y].mob = self.character
        self.crates = {}
        
        for i, row in ipairs(self.map) do
            for j, tile in ipairs(row) do
                if tile.mob and tile.mob.kind == 'crate' then
                    tile.mob.crateTable = self.crates
                    tile.mob:positionTo( tile.mob.pos ) -- tile.mob will register itself to self.crates with this call
                end
            end
        end
    end,
}

directionalShift = {
    up = vector(0,-1),
    left = vector(-1,0),
    down = vector(0,1),
    right = vector(1,0),
}

game.directionalShift = directionalShift

function Layer:getTile( p )
    if p.x <= 0 or p.x > #self.map or p.y <= 0 or p.y > #self.map[p.x] then
        return tile.Tile { env = 'wall' }
    end
    if self.layerMask then
        local coarsePositionStr = mob.xystr( math.ceil( p.x / self.layerMaskTileWidth ), math.ceil( p.y / self.layerMaskTileWidth ) )
        local tw = self.layerMaskTileWidth
        local coarsePosition = vector( math.ceil( p.x / tw ), math.ceil( p.y / tw ) )
        
        if self.layerMask[coarsePositionStr] then
            local shift = p + vector( tw, tw ) - ( coarsePosition * tw )
            return self.layerMask[coarsePositionStr].subLayer[shift.x][shift.y]
        end
    end
    
    return self.map[p.x][p.y]
end

function Layer:callTrigger( tile )
    if tile.trigger then
        return tile.trigger.callback( tile, self )
    end
end

function Layer:move( character, shift )
    local originTile = self:getTile( character.pos )
    local target = character.pos + shift
    local targetTile = self:getTile( target )
    
    local characterTile = self:getTile( character.pos )
    if characterTile.mob ~= character then --character is hidden
        return nil, "Cannot move character when hidden by an object."
    end
    
    if targetTile.env.canMoveOn then
        if targetTile.mob then
            if targetTile.mob.kind == 'crate' then
                local beyondTargetPos = target + shift
                local beyondTargetTile = self:getTile( beyondTargetPos )
                if beyondTargetTile.env.canMoveOn and not beyondTargetTile.mob then
                    beyondTargetTile.mob = targetTile.mob
                    targetTile.mob = character
                    originTile.mob = nil
                    
                    beyondTargetTile.mob:positionTo( beyondTargetPos )
                    character:positionTo( target )
                    
                    self:callTrigger(targetTile)
                    self:callTrigger(beyondTargetTile)
                    
                    return { [character] = true, [beyondTargetTile.mob] = true }
                end
            end
        else
            targetTile.mob = character
            originTile.mob = nil
            character:positionTo( target )
            
            self:callTrigger(targetTile)
            
            return { [character] = true }
        end
    end
    return nil
    
    --self.character.pos = self.character.pos + shift
end

function moveMob( mob, direction )
    local shift = directionalShift[direction]
    local k = mob.animationDuration and 0 or 1
    
    mob.facing = direction
    --mob.action = 'moving'
    --mob.startTime = love.timer.getTime()
    --mob.animationDuration = 0.3
    --mob.startPosition = mob.pos - shift
    --
    return 0 --instead of k
end

function Layer:animatedMove( character, direction )
    local mobsThatMoved, errorMsg = self:move( character, game.directionalShift[direction] )
    character.facing = direction
    if mobsThatMoved then
        for mob, _ in pairs( mobsThatMoved ) do
            moveMob( mob, direction )
        end
    else
        --The move couldn't be done.  Maybe some error message is to be displayed ?
    end
    return ( not not mobsThatMoved ), errorMsg
end

function Layer:isVictorious()
    for _, crate in pairs( self.crates ) do
        local crateTile = self:getTile( crate.pos )
        if not crateTile.trigger or crateTile.trigger.label ~= 'target' then
            return false
        end
    end
    return true
end

--never called so far
function checkMobAnimation( mob )
    local now = love.timer.getTime()
    if mob.animationDuration and now > mob.startTime + mob.animationDuration then
        mob.startTime = now
        mob.animationDuration = nil
        mob.action = 'idle'
        mob.startPosition = nil
        --return -1
    end
    return 0
end

function Layer:update( time_span )
    --checking the board
    --for i, row in ipairs(self.map) do
    --    for j, tile in ipairs(row) do
    --        if tile.mob then
    --            local k = checkMobAnimation( tile.mob )
    --            self.nbOfMovingMobs = self.nbOfMovingMobs + k
    --        end
    --    end
    --end
end

game.Layer = Layer

Game = class {
    init = function( self, settings )
        self.coarse = game.Layer( settings.coarse )
        self.fine = game.Layer( settings.fine )
        self:initCrates( settings.crates )
    
        self.control = settings.control
        
        self.actions = {
            -- todo keep the self.coarse.character references ?
            ['coarse.up']    = function() return self.coarse:animatedMove( self.coarse.character, 'up'    ) end,
            ['coarse.left']  = function() return self.coarse:animatedMove( self.coarse.character, 'left'  ) end,
            ['coarse.down']  = function() return self.coarse:animatedMove( self.coarse.character, 'down'  ) end,
            ['coarse.right'] = function() return self.coarse:animatedMove( self.coarse.character, 'right' ) end,
            ['fine.up']    = function() return self.fine:animatedMove( self.fine.character, 'up'    ) end,
            ['fine.left']  = function() return self.fine:animatedMove( self.fine.character, 'left'  ) end,
            ['fine.down']  = function() return self.fine:animatedMove( self.fine.character, 'down'  ) end,
            ['fine.right'] = function() return self.fine:animatedMove( self.fine.character, 'right' ) end,
        }
    end
}

function Game:initCrates( cratesSettings )
    local n = 16 -- self.coarse.tile_width/self.fine.tile_width
    for _, crate in pairs(self.coarse.crates) do
        local x,y = (crate.pos.x-1)*n, (crate.pos.y-1)*n
        crate.subLayer = level_loader.tilemap_from_image( cratesSettings.level.image, x, y, n, n )
    end
    self.fine.layerMask = self.coarse.crates
    self.fine.layerMaskTileWidth = n
end

function Game:isVictorious()
    return self.coarse:isVictorious() and self.fine:isVictorious()
end

function Game:update( time_span )
    self.coarse:update( time_span )
    self.fine:update( time_span )
end

function Game:keypressed( key )
    local action = self.control.key[key]
    if action then
        return self.actions[action]()
    end
end

function Game:keyreleased( key )
end

game.Game = Game

return game
