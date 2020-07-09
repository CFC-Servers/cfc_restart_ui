local finalTime
local keyFrame = 0
local isOpen = false
local flashState = false

surface.CreateFont( "CFC_CALIBRI_20PX_DEFAULT", {
    font = "Calibri",
    extended = false,
    size = 40,
    weight = 500
})

local function timeLeft()
    return finalTime - SysTime()
end

concommand.Add( "clean", function()
    isOpen = false
end )

local function restartUI()
    timer.Create( "CFC_RESTART_FLASHTIMER", 1, 0, function()
        flashState = not flashState
    end )

    isOpen = true
    local delay = net.ReadInt( 16 )
    local curTime = SysTime()
    finalTime = curTime + delay
    hook.Add( "HUDPaint", "CFCDrawRestartAlert", function()

        if isOpen then
            keyFrame = math.Clamp( keyFrame + 5, 0, ScrW() )
        else
            keyFrame = math.Clamp( keyFrame - 10, 0, ScrW() )

            if keyFrame <= 0 then
                hook.Remove( "HUDPaint", "CFCDrawRestartAlert" )
            end
        end

        surface.SetDrawColor( Color( 36, 54, 72 ) )
        surface.PlaySound( "ambient/alarms/warningbell1.wav" )
        surface.DrawRect( 0, 5, keyFrame, 50 )
    
        if flashState and timeLeft() <= 30 then surface.SetDrawColor( Color( 255, 255, 89 ) ) elseif not flashState and timeLeft() <= 30 then surface.SetDrawColor( Color( 255, 0, 0 ) ) elseif timeLeft() > 30 then surface.SetDrawColor( 255, 255, 89 ) end

        surface.DrawRect( 0, 4, keyFrame, 5 )
        surface.DrawRect( 0, 50, keyFrame, 5 )
        surface.SetFont( "CFC_CALIBRI_20PX_DEFAULT" )
        surface.SetTextColor( Color( 255, 255, 255 ) )
        surface.SetTextPos( keyFrame / 2 - 250, 10 )
        surface.DrawText( "WARNING: Server Restarting in " .. string.FormattedTime( math.Clamp( math.ceil( timeLeft() ), 0, 600  ), "%i:%02i" ) )
    end )
end

local function stopRestart()
    isOpen = false
end

net.Receive( "CFC_RESTART_START", restartUI )
net.Receive( "CFC_RESTART_STOP", stopRestart )
