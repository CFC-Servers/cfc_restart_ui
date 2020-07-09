local finalTime
local keyFrame = 0
local isOpen = false
local flashState = false
local CFCRestart = {}
surface.CreateFont( "CFC_CALIBRI_20PX_DEFAULT", {
    font = "Calibri",
    extended = false,
    size = 40,
    weight = 500
})

local function timeLeft()
    return finalTime - SysTime()
end

local function restartUI()
    timer.Create( "CFC_RESTART_FLASHTIMER", 1, 0, function()
        flashState = not flashState
    end )

    isOpen = true
    hook.Remove( "HUDPaint", "CFCDrawRestartAlert" )
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
    
        CFCRestart.urgencyTime = 30 -- extracting that 30 out from here, should probably be named something better
        CFCRestart.defaultDrawColor = Color( 255, 255, 89 )

        local drawColor = self.defaultDrawColor

        if timeLeft() <= self.urgencyTime then
            if not flashState then
            drawColor = Color( 255, 0, 0 )
        end
end

-- From the wiki: "Providing a Color structure is slower than providing four numbers. You may use Color:Unpack for this."
surface.SetDrawColor( drawColor:Unpack() )

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
