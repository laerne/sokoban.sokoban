vector = require "hump.vector"
tile = require "tile"
mob = require "mob"

level_loader = {}

function rgb_to_int( r, g, b )
    return r*65536 + g*256 + b
end

local tile_type = {
    [0x333333] = { env = 'wall', mob = nil },
    [0x999999] = { env = 'ground', mob = nil },
    [0x0000ff] = { env = 'ground', mob = 'crate' },
    [0x00ffff] = { env = 'ground', mob = 'crate', trigger = 'target' },
    [0x00ff00] = { env = 'ground', trigger = 'target' },
    none = { env = 'wall', mob = nil },
}
setmetatable( tile_type, { __index = function( t, k )
    return t.none
end } )


function tilemap_from_image( filename, x, y, w, h )
    local imageData = love.image.newImageData( filename )
    local tilemap = {}
    x = x or 0
    y = y or 0
    w = w or imageData:getWidth()
    h = h or imageData:getHeight()

    
    for i = 0,w-1 do
        tilemap[ i + 1 ] = {}
        for j = 0,h-1 do
            local colorint = rgb_to_int( imageData:getPixel( x+i, y+j ) )
            local tileSettings = tile_type[ colorint ]
            tileSettings.position = vector(x+i+1,y+j+1) --change the tile_type entry, but at this point we don't care
            local t = tile.Tile(tileSettings)
            tilemap[i+1][j+1] = t
        end
    end
    
    --for k,v in pairs(tilemap) do
    --    print( "!!!", k, #v )
    --    for kk,vv in pairs(v) do
    --        print( "!!!", k, kk, vv )
    --    end
    --end
    
    
    return tilemap
end





level_loader.tile_type = tile_type
level_loader.tilemap_from_image = tilemap_from_image

return level_loader
