surface.CreateFont( "CFC_CALIBRI_20PX_DEFAULT", {
    font = "Calibri",
    extended = false,
    size = 40,
    weight = 500
})

CFCRestartDisplay = {
    finalTime = 0,
    keyFrame = 0,
    isOpen = false,
    flashState = false,
    CFCRestart = {},
    urgencyTime = 30,
    defaultDrawColor = Color( 255, 255, 89 ),
    flashDrawColor = Color( 36, 54, 72 ),
    restartSound = "ambient/alarms/warningbell1.wav"
}

local rd = CFCRestartDisplay

function rd:TimeLeft()
    return self.finalTime - SysTime()
end

function rd:GetBannerText()
    local timeLeft = math.Clamp( math.ceil( self:TimeLeft() ), 0, 600 )
    local formattedTimeLeft = string.FormattedTime( timeLeft, "%i:%02i" )

    return "WARNING: Server Restarting in " .. formattedTimeLeft
end

function rd:RestartUI( delay )
    timer.Create( "CFC_RESTART_FLASHTIMER", 1, 0, function()
        self.flashState = not self.flashState
    end )

    self.isOpen = true

    local curTime = SysTime()
    self.finalTime = curTime + delay

    hook.Add( "HUDPaint", "CFCDrawRestartAlert", function()

        if seisOpen then
            self.keyFrame = math.Clamp( self.keyFrame + 5, 0, ScrW() )
        else
            self.keyFrame = math.Clamp( self.keyFrame - 10, 0, ScrW() )

            if self.keyFrame <= 0 then
                hook.Remove( "HUDPaint", "CFCDrawRestartAlert" )
            end
        end

        surface.SetDrawColor( self.flashDrawColor )
        surface.PlaySound( self.restartSound )
        surface.DrawRect( 0, 5, self.keyFrame, 50 )

        local drawColor = self.defaultDrawColor
        if timeLeft() <= self.urgencyTime then
            if not self.flashState then drawColor = Color( 255, 0, 0 ) end
        end
        
        surface.SetDrawColor( drawColor:Unpack() )
        surface.DrawRect( 0, 4, self.keyFrame, 5 )
        surface.DrawRect( 0, 50, self.keyFrame, 5 )
        surface.SetFont( "CFC_CALIBRI_20PX_DEFAULT" )
        surface.SetTextColor( Color( 255, 255, 255 ) )
        surface.SetTextPos( self.keyFrame / 2 - 250, 10 )
        surface.DrawText( self:GetBannerText() )
    end )
end

function rd:ClearUI()
    self.isOpen = false
end

net.Receive( "CFC_RESTART_START", function()
    local timeLeft = net.ReadInt( 16 )
    rd:RestartUI( timeLeft )
end )
net.Receive( "CFC_RESTART_STOP", function()
    rd:ClearUI()
end )