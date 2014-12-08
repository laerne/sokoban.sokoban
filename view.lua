class = require "hump.class"
camera = require "hump.camera"
vector = require "hump.vector"
game = require "game"

view = {}

function autoload_images( table )
    for k, v in pairs(table) do
        if type(v) == "table" then
            autoload_images( v )
        elseif v == 0 then
            table[k] = 0
        elseif type(v) == "string" then
            table[k] = love.graphics.newImage( table[k] )
        else
            print( "invalid image path type for "..k.." : "..type(v) )
        end
    end
end

LayerView = class {
    init = function( self, settings )
        --self.camera = camera( -love.graphics.getHeight(), -love.graphics.getWidth() )
        --self.camera = camera( 0, 0 )
        
        self.tile_width = settings.tile_width
        
        if type(settings) ~= 'table' then
            settings = {}
        end
        
        if settings.background and settings.background.image then
            self.background_image = love.graphics.newImage( settings.background.image )
            self.background_x = settings.background.x or 0 -- -self.background_image:getWidth() / 2
            self.background_y = settings.background.y or 0 -- -self.background_image:getHeight() / 2
            --self.background.camera = camera( 0, 0 )
        end
        
        autoload_images( settings.sprite )
        self.sprite = settings.sprite
    end,
}

function deep_access( table, ... )
    local next_table = nil
    if type(table) == 'table' and tostring(table) ~= 'Image' then
        next_table = table[select(1,...)]
        if next_table == nil then
            next_table = table.default
        end
    end
    
    if next_table then
        return deep_access( next_table, select(2,...) )
    else
        return table
    end
end

function getTileImage( tile, sprite )
    local trigger_label = tile.trigger and tile.trigger.label or 'no_trigger'
    return deep_access( sprite, tile.env.kind, trigger_label )
end

function getMobImage( tile, sprite )
    if tile.mob then
        local trigger_label = tile.trigger and tile.trigger.label or 'no_trigger'
        if tile.mob.animationDuration then
            local now = love.timer.getTime()
            local ratio = 1 - ( now - tile.mob.startTime ) / tile.mob.animationDuration
            return deep_access( sprite, tile.mob.kind, tile.mob.action, tile.mob.facing, tile.kind, trigger_label ), game.directionalShift[ tile.mob.facing ] * -32 * ratio
        else
            return deep_access( sprite, tile.mob.kind, tile.mob.action, tile.mob.facing, tile.kind, trigger_label ), vector(0,0)
        end
    end
    return nil
end

function LayerView:draw( layer )
    --self.camera:attach()
    
    if self.background_image then
        love.graphics.draw( self.background_image, self.background_x, self.background_y )
    end
    
    local mobImgs = {}
    
    for i,row in ipairs(layer.map) do
        for j,actual_tile in ipairs(layer.map[i]) do
            local tile = layer:getTile(vector(i,j))
            local x,y = (i-1)*self.tile_width, (j-1)*self.tile_width
            
            local image = getTileImage( tile, self.sprite.tile )
            if image and image ~= 0 then love.graphics.draw( image, x, y ) end
            
            local image, pixelShift = getMobImage( tile, self.sprite.mob )
            if image and image ~= 0 then table.insert( mobImgs, { image = image, position = vector(x,y) + pixelShift } ) end
        end
    end
    for _, mobImg in pairs(mobImgs) do
        love.graphics.draw( mobImg.image, mobImg.position.x, mobImg.position.y )
    end
    
    --self.camera:detach()
end

view.LayerView = LayerView


GameView = class {
    init = function( self, settings )
        love.graphics.setBackgroundColor( 32, 0, 32 )
        love.graphics.setNewFont( "data/FreeMonoBold.ttf", 24 )
        self.coarse = view.LayerView( settings.coarse.graphics )
        self.fine = view.LayerView( settings.fine.graphics )
        self.fine_opacity = settings.opacity or 255
        -- code snippet? : for i, layerSettings in ipairs(settings.layers) do
    end
}

function GameView:draw( world )
    love.graphics.clear()
    self.coarse:draw( world.coarse )
    love.graphics.setColor( 255, 255, 255, self.fine_opacity )
    self.fine:draw( world.fine )
    love.graphics.setColor( 255, 255, 255, 255 )
    
    if self.message then
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local oldRed,oldGreen,oldBlue,oldAlpha = love.graphics.getColor()
        love.graphics.setColor( self.message.r, self.message.g, self.message.b, self.message.a )
        love.graphics.setColor( oldRed, oldGreen, oldBlue, oldAlpha )
        love.graphics.printf( self.message.text, 0, 0, w, 'center' )
    end
end

function GameView:cleanMessage()
    self.message = nil
end

function GameView:setMessage( text, r, g, b, a )
    self.message = self.message or {}
    self.message.text = text
    self.message.r = r or 255
    self.message.g = g or 255
    self.message.b = b or 255
    self.message.a = a or 255
end

function GameView:setErrorMessage( text )
    self:setMessage( text, 255, 51, 0, 255 )
end

view.GameView = GameView

return view
