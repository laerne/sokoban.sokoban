class = require "hump.class"
mob = require "mob"

tile = {}

Tile = class {
    init = function( self, settings )
        settings = settings or {}
        settings.env = settings.env or 'ground'
        self.env = tile.build( settings.env )
        if settings.mob  then
            self.mob = mob.build( { kind = settings.mob, position = settings.position })
        end
        if settings.trigger then
            if type(settings.trigger) == 'string' then
                settings.trigger = { auto_behavior = settings.trigger, label = settings.trigger }
            elseif type(settings.trigger) == 'function' then
                settings.trigger = { callback = settings.trigger }
            end
            self.trigger = tile.Trigger( settings.trigger )
        end
    end,
}

function Tile:__tostring()
    if self.mob then
        if self.trigger then
            return 'tile('..tostring(self.env.kind)..'+'..tostring(self.mob.kind)..'+'..tostring(self.trigger)..')'
        else
            return 'tile('..tostring(self.env.kind)..'+'..tostring(self.mob.kind)..')'
        end
    else
        if self.trigger then
            return 'tile('..tostring(self.env.kind)..'+'..tostring(self.trigger.kind)..')'
        else
            return 'tile('..tostring(self.env.kind)..')'
        end
    end
end

tile.Tile = Tile

Ground = class {
    init = function( self, settings )
        assert( settings and settings.kind )
        
        self.kind = settings.kind
        self.canMoveOn = true
    end,
}

tile.Ground = Ground

Wall = class {
    init = function( self, settings )
        assert( settings and settings.kind )
        
        self.kind = settings.kind
        self.canMoveOn = false
    end,
}

tile.Wall = Wall

tileEnvironmentFactory = {
    ground = { builder = tile.Ground },
    wall = { builder = tile.Wall },
}

autotriggers = {
    target = function( tile, layer ) if world:isVictorious() then viewport:setMessage("You finished it !") end end,
}

Trigger = class {
    init = function( self, settings )
        assert( settings )
        self.label = settings.label or 'trigger'
        if settings.callback then
            self.callback = callback
        elseif settings.auto_behavior  then
            self.callback = function( tile, layer ) return autotriggers[settings.auto_behavior]( tile, layer ) end
        else
            error "A trigger must have callback function"
        end
    end,
}

tile.Trigger = Trigger


function build( settings )
    if type(settings) == "string" then
        settings = { kind = settings }
    end
        
    local tileEnv = tileEnvironmentFactory[settings.kind].builder( settings )
    return tileEnv
end
tile.build = build

return tile
