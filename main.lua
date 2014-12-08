require "global" --comment this to remove global variable checking and improve (a little) performance.
class = require "hump.class"
view = require "view"
settings = require "settings"
game = require "game"
debug = require "debug"

function getKeysOfActionName( actionName, settings, lastKey )
    assert( actionName ~= nil )
    if type(settings) == 'table' then
        local keys = {}
        for key, value in pairs(settings) do
            local keysForValue = getKeysOfActionName( actionName, value, key )
            for k, _ in pairs(keysForValue) do
                keys[k] = true
            end
        end
        return keys
    elseif settings == actionName then
        return { [lastKey] = true }
    end
    return {}
end

function moveKeysString( granularity, settings )
    local up_keys = getKeysOfActionName( granularity..'.up', settings )
    local left_keys = getKeysOfActionName( granularity..'.left', settings )
    local down_keys = getKeysOfActionName( granularity..'.down', settings )
    local right_keys = getKeysOfActionName( granularity..'.right', settings )
    local up_key = next(up_keys)
    local left_key = next(left_keys)
    local down_key = next(down_keys)
    local right_key = next(right_keys)
    
    return "`"..up_key.."', `"..left_key.."', `"..down_key.."' and `"..right_key.."'"
end

function setHelpMessage()
    local coarseMoves = moveKeysString( 'coarse', settings.control )
    local fineMoves = moveKeysString( 'fine', settings.control )
    local message = string.format([[
Welcome to sokoban.sokoban !

"Use %s to move the human character.
"Use %s to move the pixel-bot character.



The pixel-bot is the tiny orange box on the bottom left of the human.
Move all tiny brown boxes to their tiny purple target, and move all regular boxes to their target.

Move a character or press any key to dismiss this hint.]],
    coarseMoves,
    fineMoves)
    viewport:setMessage( message )
end

function love.load()
    print("initializing...")
    
    love.keyboard.setKeyRepeat( true )
    
    world = game.Game( class.clone(settings) )
    viewport = view.GameView( class.clone(settings) )
    
    setHelpMessage()
end

function love.update( time_span )
    world:update( time_span )
end

function love.draw()
    viewport:draw( world )
end

function love.mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
end

function love.keypressed( key )
    viewport:cleanMessage()
    local status, errorMessage = world:keypressed( key )
    if not status and errorMessage then
        viewport:setErrorMessage( errorMessage )
    end
end

function love.keyreleased( key )
    world:keyreleased( key )
end

function love.focus()
    --pause the game
end

--function love.quit()
--end
