CATEGORY_NAME = "Utility"

if SERVER then
    util.AddNetworkString( "CFC_RESTART_START" )
    util.AddNetworkString( "CFC_RESTART_STOP" )
end

local function cfcRestartTimerCallback()
    timer.Destroy( "CFC_RESTART_TIMER" )


    print( "would restart here !" )
    http.Post( "" ) -- soon™
    RunConsoleCommand( "changelevel", game.GetMap() )
end

local function cfcUlxRestart( calling_ply, delay )
    net.Start( "CFC_RESTART_START" )
    net.WriteInt( math.Round( delay ),  16 )
    net.Broadcast()


    timer.Create( "CFC_RESTART_TIMER", delay, 1, cfcRestartTimerCallback )
    ulx.fancyLogAdmin( calling_ply, "#A told the server to restart in #i seconds", tostring( delay ) )
end

local function cfcUlxStopRestart( calling_ply, delay )
    timer.Remove( "CFC_RESTART_TIMER" )
    ulx.fancyLogAdmin( calling_ply, "#A told the server to stop restarting" )

    net.Start( "CFC_RESTART_STOP" )
    net.Broadcast()
end


local svrestart = ulx.command( CATEGORY_NAME, "ulx svrestart", cfcUlxRestart, "!svrestart" )
svrestart:addParam{ type = ULib.cmds.NumArg, min = 10, max = 600, hint = "Restart Time", ULib.cmds.optional, ULib.cmds.round, default = 30 }
svrestart:defaultAccess( ULib.ACCESS_SUPERADMIN )
svrestart:help( "Restarts the server after the given time, and alerts all players of a restart." )

local stopsvrestart = ulx.command( CATEGORY_NAME, "ulx svstoprestart", cfcUlxStopRestart, "!svstoprestart" ) 
stopsvrestart:defaultAccess( ULib.ACCESS_SUPERADMIN )
stopsvrestart:help( "Stops the server from restarting." )







