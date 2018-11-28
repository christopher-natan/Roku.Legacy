 '*
 '* These are my complete Roku BrightScript codes written for legacy players.
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function DSApp()
    DSUtil()
    
    m.GLOBALMESSAGE               = Function() as Object
       this                       = {}
       this["ConnectionError"]    = { Title: "Connection Error",        Text: "Could not connect to server, please try again in a few minutes"}
       this["NoRecordsFound"]     = { Title: "No Records Found",        Text: "There are no records found on this screen"}                                   
       this["InvalidConnection"]  = { Title: "Maintenance Mode",        Text: "Sorry for the inconvenience. We are currently undergoing maintenance to our Roku Channel. We'll be back soon. Thank You." }                   
       this["InvalidXMLFormat"]   = { Title: "Maintenance Mode",        Text: "Sorry for the inconvenience. We are currently undergoing maintenance to our Roku Channel. We'll be back soon. Thank You." }                       
       this["SlowConnection"]     = { Title: "Slow Connection",         Text: "Couldn't connect to server because your internet connection is too slow."}                                                                              
       this["VideoUnavailable"]   = { Title: "Not Available",           Text: "This item (video or audio) is currently not available."}                                                                              
       this["YoutubeUnavailable"] = { Title: "Not Available",           Text: "Sorry, this video is currently not available."}
       this["DeviceNotSupported"] = { Title: "Legacy Device",           Text: "Sorry for the inconvenience, some functions are no longer supported on this platform."}                                                                              
       this["RegistrationExpired"]= { Title: "Session Expired",         Text: "Sorry, device registration session has expired. Please try again."}                                                                              
       this["InvalidPinEntry"]    = { Title: "Invalid Pin Entry",       Text: "Sorry, pin that you've entered is invalid. Please try again."}                                                                              
      
       return this 
    End Function
    
    m.GLOBALDEVICEINFO  = Function() as Object
        info            = CreateObject("roDeviceInfo")
        this            = {}
        this.model      = info.GetModel()
        this.version    = info.GetVersion()
        this.serial     = info.GetDeviceUniqueId()
        
        return this
    End Function
        
     m.GLOBALVIEWERPARAMETER        = Function() as Object
        this                        = {}
        this.viewerId               = "/"  + m.settings.viewer.HashedId
        
        this.viewers                = this.viewerId
        return this
    End Function
    
    m.GLOBALSETTINGS    = Function() as Object
        this            = {}
        response        = m.Http(m.url.settings)
        if response     = invalid then return m.EndGate()
        results         = ParseJSON(response)
        
        return results.settings
    End Function

    m.GLOBALMANIFEST    = Function() as Object
      result  = {}
      raw     = ReadASCIIFile("pkg:/manifest")
      lines   = raw.Tokenize(Chr(10))
      for each line in lines
        bits  = line.Tokenize("=")
        if bits.Count() > 1
            result.AddReplace(StrTrim(bits[0]), StrTrim(bits[1]))
        end if
      next
      return result
    End Function
        
    m.GLOBALURL                = Function() as Object
        rest                   = ".json"
        this                   = {}
        base                   = StrTrim(m.manifest.base_url)
        folder                 = "services"
        this.base              = base 
        this.category          = base + folder + "/categories/"         + m.hash(rnd(1).tostr()) + rest
        this.settings          = base + folder + "/settings/"           + m.hash(rnd(2).tostr()) + rest
        this.viewed            = base + folder + "/viewed/{PARAM}"                + rest
        this.register          = base + folder + "/register/{PARAM}"              + rest
        this.online            = base + folder + "/online/{PARAM1}"     + rest
        this.guide             = base + "img/misc/guide.jpg"
        this.ad                = base + "img/misc/ad.jpg"
        this.loader            = base + "imgx/defaults/loader.jpg"
        this.spinner           = [base + "imgx/defaults/spinner1.jpg", base + "imgx/defaults/spinner2.jpg", base + "imgx/defaults/spinner3.jpg"]
        this.loading           = base + "imgx/defaults/loading.png"
        
        return this
    End Function
    
    m.GLOBALHASH               = Function(text = "" as String) as String
        ts                     = CreateObject("roTimespan")
        ba                     = CreateObject("roByteArray")
        ts.Mark()
        if text = "" then text = ts.TotalMilliseconds().tostr()
        ba.FromAsciiString(text)
        digest                 = CreateObject("roEVPDigest")
        digest.Setup("sha1")
        result                 = digest.Process(ba)
        return result
    End Function
    
    m.GLOBALCONSTANT            = Function()  
       m.hash                   = m.globalHash
       
      ' Holds the current played items column index
       m.playedIndex            = 0
      
      ' Screen variable 
       m.imCounter              = 0
       m.imUninitialized        = "<uninitialized>"
      
      ' Report every [5] minutes that viewer is online
       m.imOnline               = 5 * 60
       m.imOnlineNow            = false
        
      ' Yes No Decision
       m.isNo                   = 0
       m.isYes                  = 1
       
      ' All Out
       m.isReset                = 0
       m.isClose                = 0
       m.isCancel               = 0
       m.isExit                 = 0
       
      ' Stream State      
       m.isScreenClosed         = 0
       m.isPartialResult        = 1
       m.isFullResult           = 2
       m.isRequestFailed        = 3 
       m.isRemoteKeyPressed     = 5
       m.isButtonPressed        = 6
       
      ' Remote Key Button
       m.isLeftKey              = 4 
       m.isRightKey             = 5
       m.isUpKey                = 2 
       m.isDownKey              = 3
       
      ' Past Tense
       m.isAccepted             = 1
       m.isRemoved              = 2
       m.isDisplayed            = 3
       m.isEnabled              = 4
      
      ' Screens
       m.isGridScreen           = "Grid"
       m.isPosterScreen         = "Poster"
       m.isListScreen           = "List"
       m.isScheduledScreen      = "Scheduled"
       m.isSimpleScreen         = "Simple"
       m.isNoneScreen           = "None"
       m.isSpringboardScreen    = "Springboard"
       m.isRegistrationScreen   = "Registration"
       m.isVideoScreen          = "Video"
       m.isAudioScreen          = "Audio"
     
      ' Video Type 
       m.isDefine               = 1
       m.isYouTube              = 2
       m.isVimeo                = 5
       m.isAmazonS3             = 4
             
      ' String Result       
       m.isEmpty                = ""
       m.isNone                 = "None"
       m.isInvalid              = "Invalid"
       
      ' Format Type       
       m.isAudio                = 1
       m.isVideo                = 2 
       
      ' Player And Button Navigation
       m.isPlayBeginning        = 18
       m.isPlay                 = 19
       m.isNext                 = 20
       m.isPrevious             = 21
       m.isBack                 = 22
       m.isPaused               = 23
       m.isResumed              = 24
       m.isStopped              = 25
       m.isAnalyzer             = 26
       m.isViewContent          = 27
       
       m.isReturn               = 88
       m.isGetNewCode           = 99
       m.isGetStatus            = 99
       
      ' Registration
       m.isBeforeMainScreen     = "before-main-screen"
       m.isBeforeVideoPlayed    = "before-video-played"
       
       m.isAds                  = 8
       
      ' Device Info
       m.device                 = m.GlobalDeviceInfo()
       
      ' Message 
       m.message                = m.GlobalMessage()               
        
      ' Manifest 
       m.manifest               = m.GlobalManifest()
             
      ' Url 
       m.url                    = m.GlobalUrl()
       
      ' Channel : [source, world, channel, vasts, viewer, vads, theme, advertisement]
       m.settings               = m.GlobalSettings()
       
      ' Viewer Parameter
       m.parameter              = m.GlobalViewerParameter()
       
      ' Summary
       m.screenType             = m.settings.screen.screenType
       
       m.breadCrumb             = {previous: "", current: "", store: {}}
   End Function
   
   m.GLOBALTHEMES          = Function() as Boolean
       if m.settings.themes = invalid then return false
       meta                = {}
       for each item in m.settings.themes
            value          = ValidStr(m.settings.themes[item])
            name           = ValidStr(item)
            meta[name]     = value
                
            if Instr(1, StrTrim(value), "http") >=1 then
                m.Prints(StrTrim(value))
                url         = StrTrim(value)   
                file        = Http("Connect").ToFile(url, name)
                meta[name]  = file       
            endif
        next  
    
       appManager           = CreateObject("roAppManager")
       appManager.SetTheme(meta)
              
       return true    
   End Function
   m.GlobalConstant()
   m.GlobalThemes()
  'write the breadcrumb previous item
   RegistryWrite("BreadCrumbPrevious", "Home")
   
   
   DSFeeds()
   DSScreen()
   DSAd()
  
   ' -- startup: we need to use another event so that it would not exit after the events -- 
   startup = m.ScreenLoader(this)
   startup.Show()
  
  ' set online
   m.SetOnline(m)
   while true
        wait(10,  CreateObject("roMessagePort"))
        if m.ScreenBeforeMain(this) = m.isNo then return m.isNo
        
        categorUrl                  = m.url.category
        m.ScreenSelector(m.screenType, m.FeedsCategory(categorUrl))  
        exit while
   end while
   startup.Close()
   
End Function'Remove
