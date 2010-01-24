'Copyright 2010 Dirk Elmendorf


Function Main() as Integer
  app = CreateObject("roAssociativeArray")


  app.port = CreateObject("roMessagePort")
  app.screen = CreateObject("roSpringboardScreen")
  app.screen.SetMessagePort(app.port)
  app.player = CreateObject("roAudioPlayer")
  app.player.SetMessagePort(app.port)
  

  app.screen_options = CreateObject("roAssociativeArray")
  app.screen_options.ContentType = "episode"
  app.screen_options.Title = "KEXP"
  app.screen_options.SDPosterURL = "pkg:/images/episode_icon_sd.png"
  app.screen_options.HDPosterURL = "pkg:/images/episode_icon_sd.png"
  app.screen.SetStaticRatingEnabled(false)


  app.song = CreateObject("roAssociativeArray")
  app.song.Url = "http://kexp-mp3-2.cac.washington.edu:8000/"
  app.song.StreamFormat = "mp3"
  app.status = CreateObject("roString")
  app.status = ""

  Play(app)

  while true
    msg = wait(0, app.port)
    if type(msg) = "roAudioPlayerEvent"
      if msg.isStatusMessage() then
        print "Audio Player Event:"; msg.getmessage()
        if msg.GetMessage() = "start of play" then
          PlayingNow(app)
        endif
      endif
    else if msg.isButtonPressed()  then
        if msg.GetIndex() = 1 then 
          Pause(app)
        else if msg.GetIndex() = 2 then 
          Play(app)
        else if msg.GetIndex() = 3 then 
          return ExitApp(app)
        endif
    else if msg.isScreenClosed() then
      return ExitApp(app)
    endif
  end while
end Function
Function ExitApp(app) as Integer
  print "Goodbye World!"
  app.player.stop()
  return 0
end Function
Sub DrawScreen(app,description) 
  app.screen_options.Description = description
  app.screen.SetContent(app.screen_options)
  app.screen.Show()
end Sub
Sub PlayingNow(app)
  app.screen.ClearButtons()
  app.screen.AddButton(1, "Pause Stream")
  app.screen.AddButton(3, "Exit")
  DrawScreen(app,"Live MP3 Stream from KEXP.org")
end Sub
Sub Play(app)
  if app.status = "" then
    app.player.AddContent(app.song)
    app.player.SetLoop(true)
    app.player.play()
    app.status = "playing"
  else if app.status = "paused" 
    app.player.resume()
    app.status = "playing"
  endif

  app.screen.ClearButtons()
  app.screen.AddButton(3, "Exit")

  DrawScreen(app, "Buffering....")
end Sub
Sub Pause(app)
  if app.status = "playing" then
    app.player.pause()
    app.status = "paused"
  endif
  
  app.screen.ClearButtons()
  app.screen.AddButton(2, "Resume Stream")
  app.screen.AddButton(3, "Exit")

  DrawScreen(app, "Stream Paused")

end Sub
