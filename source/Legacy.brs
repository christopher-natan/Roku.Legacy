 '*
 '* These are my complete Roku BrightScript codes written for legacy players.
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Function DevString()
m.basePoint        = "http://client.findstep.com/roku/"
m.imgXPoint        = "http://image.findstep.com/"

'-----------------------------------------------------------------------------------------------------------------------------------
'   BrightScript Developer / Developed By: Christopher M. Natan
'   New version 3.1 
'-----------------------------------------------------------------------------------------------------------------------------------       

m.isPatternLink    = "(ec2-54-183-253-90|findstep.com)"
'-----------------------------------------------------------------------------------------------------------------------------------
'   0. Fix Section
'-----------------------------------------------------------------------------------------------------------------------------------       
    m.SettingsGeneral  = Function()
    End Function
            
    m.GridScreen       = Function()
    End Function
    
    m.Bootstrap        = Function()
    m.Bootstrap        = {}      
    End Function

 '-----------------------------------------------------------------------------------------------------------------------------------
 '   1. Utility Section
 '-----------------------------------------------------------------------------------------------------------------------------------
     m.Transfer          = invalid
     m.Http              = Function(url as String) as Object
        this             = {}
        this.url         = StrTrim(url)
        this.m           = m
        
        DSCONFIG                   = Function() as Object
            config                 = {}
            config.EnableEncodings = true 
            config.Header          = "application/x-www-form-urlencoded"
            config.Certificate     = "common:/certs/ca-bundle.crt"
            config.Retry           = 20
            config.TimeOut         = 2000
            config.Method          = "GET"
            
            return config
        End Function 
        
        DSTRANSFER                 = Function(this) as Object
           this.transfer           = CreateObject("roUrlTransfer")
           this.port               = CreateObject("roMessagePort")
           this.transfer.SetUrl(this.url)
           this.transfer.SetPort(this.port)
           this.transfer.AddHeader("Content-Type", this.config.Header)
           this.transfer.SetCertificatesFile(this.config.Certificate)
           this.transfer.InitClientCertificates() 
           this.transfer.EnableEncodings(this.config.EnableEncodings)
           this.transfer.SetRequest(this.config.Method)
           this.dsHeaders(this)
           this.m.Transfer = this.transfer
           
           Print "-connecting to url: ";this.url
           return this
        End Function
        
        DSHEADERS                    = Function(this)
            viewerId                 = "0"
            if this.m.Registry().Read("HashedViewerId") <> invalid then viewerId = this.m.Registry().Read("HashedViewerId")

            this.transfer.AddHeader("CN-08201979", this.m.device.serial)
            this.transfer.AddHeader("CN-02082015", this.m.manifest.access_key)
            this.transfer.AddHeader("CN-11082013", viewerId)
            this.transfer.AddHeader("CN-06282012", this.m.Registry().Read("HashedModified"))
        End Function
        
        DSCONNECT                    = Function(this) as Object
            results                  = invalid
            retry                    = this.config.Retry
            timeout                  = this.config.TimeOut
            while true
                this                 = this.dsTransfer(this)
                if (this.transfer.AsyncGetToString())
                    event            = wait(timeout, this.transfer.GetPort()) 
                    if type(event)   = "roUrlEvent"    
                        results      = event.GetString()
                        if ValidStr(results) <> "" then exit while
                    else if event    = invalid
                         this.transfer.AsyncCancel()
                         timeout     = 2 * timeout
                    end if
                endif
                
                retry    = retry - 1
                if retry = 0 then  exit while
                print "-retry : "; retry  
           end while
           if ValidStr(results) = "" then results = invalid
           
           return results
       End Function
       
       this.config      =  dsConfig()
       this.dsHeaders   =  dsHeaders
       this.dsTransfer  =  dsTransfer
       results          =  dsConnect(this)
       
       roRegEx          = CreateObject("roRegex", this.m.isPatternLink,"")
       isMatch          = roRegEx.Match(this.url)
       
       if isMatch[0]    <> invalid then
            if results  = invalid then Dialog(this.m.message["InvalidConnection"].title, this.m.message["InvalidConnection"].text)
       end if
       
       return results 
   End Function       
   
   m.EndGate            = Function()
        return invalid
   End Function
      
   m.TimeLong             = Function() as Object
        this              = {}
        this.dateTime     = CreateObject("roDateTime")
        this.dateTime.ToLocalTime()
        current           = {}
        current.month     = this.dateTime.GetMonth().toStr()
        current.day       = this.dateTime.GetDayOfMonth().toStr()
        current.year      = this.dateTime.GetYear().toStr()
        current.hours     = ToLeadingZero(this.dateTime.GetHours().toStr())
        current.minutes   = ToLeadingZero(this.dateTime.GetMinutes().toStr())
        current.seconds   = ToLeadingZero(this.dateTime.GetSeconds().toStr())
        current.formatLong= current.month + current.day + current.hours + current.minutes + current.seconds
        
        return current
   End Function
   
   m.Registry         = Function() as Object
   
       DSREAD         = Function(key, section = invalid) as String
           if key     = invalid then return ""
           if section = invalid then section  = "DevString"
          
           registrationSection = CreateObject("roRegistrySection", section)
           if registrationSection.Exists(key) then 
              return registrationSection.Read(key)
           else
              return "" 
           end if
       End Function
       
       DSWRITE = Function(key, value, section = invalid)
           if key     = invalid then return ""
           if value   = invalid then return ""
           if value   = ""      then return ""
           if section = invalid then section = "DevString"
           
           registrationSection = CreateObject("roRegistrySection", section)
           registrationSection.Write(key, value)
           registrationSection.Flush()
       End Function
       
       return {Read:dsRead, Write:dsWrite}
    End Function
    
    m.ValidValue             = Function(value, default)
        if value             = invalid OR type(value) = "roInvalid" then 
            return default
        end if
        
        return value
    End Function
   
 '-----------------------------------------------------------------------------------------------------------------------------------
 '   2. App Section
 '-----------------------------------------------------------------------------------------------------------------------------------
     
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
       this["InvalidPinEntry"]    = { Title: "Invalid Pin Entry",       Text: "Sorry, the PIN that you've entered is invalid. Please try again."}                                                                              
       this["ChannelDown"]        = { Title: "Channel Is Down",         Text: "Either this channel is currently down or not existing. Please try again in a few seconds."}                                                                              
      
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
        
    m.GLOBALVIEWERPARAMETER         = Function() as Object
        this                        = {}
        if m.settings               = invalid then return {}
        if m.settings.viewer        = invalid then return {}
         
        this.viewerId               = "/"  + m.settings.viewer.HashedId
        this.viewers                = this.viewerId
        
        'if viewer's hashed id is not on the registry yet then write it
        if m.Registry().Read("HashedViewerId") = "" then
            m.Registry().Write("HashedViewerId", m.settings.viewer.HashedId)
        end if    
        return this
    End Function
    
    m.GLOBALSETTINGS    = Function() as Object
        this            = {}
        response        = m.Http(m.url.settings)
        if response     = invalid then return m.EndGate()
        results         = ParseJSON(response)
        print results
        if results.error <> invalid then
            Dialog(m.message["ChannelDown"].Title, m.message["ChannelDown"].Text) 
            return false
        end if
        'if channel's modified field value is not equal on the registry 
        'copy then then write it
        if m.Registry().Read("HashedModified") <> results.settings.properties.Modified then
            m.Registry().Write("HashedModified", results.settings.properties.Modified)
        end if
        results.settings.channel        = {}
        results.settings.channel.EnableMarathon = false
        
        'results.settings.viewer.IsRegistered = 0
        'results.settings.viewer.IsActivated  = 1
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
        base                   = StrTrim(m.basePoint)
        imgx                   = StrTrim(m.imgXPoint)
        folder                 = "service"
        this.base              = base 
        this.category          = base + folder + "/categories/"         + m.hash(rnd(1).tostr()) + rest + "?screenType={SCREEN_TYPE}"
        this.settings          = base + folder + "/settings/"           + m.hash(rnd(1).tostr()) + rest
        this.viewed            = base + folder + "/views/{PARAM}"       + rest
        this.register          = base + folder + "/register/{PARAM}"    + rest
        this.online            = base + folder + "/online/{PARAM1}"     + rest
        this.guide             = imgx + "Guide.jpg"
        this.ad                = imgx + "StartUpAd.jpg"
        this.loader            = imgx + "Loader.jpg"
        this.spinner           = [imgx + "Spinner1.jpg", imgx + "Spinner2.jpg", imgx + "Spinner3.jpg"]
        this.nomedia           = imgx  + "NoMedia.png"
        
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
   
   m.GLOBALTHEMES           = Function() as Boolean
       if m.settings.theme  = invalid then return false
       if m.settings.screen.ScreenType = m.isNoneScreen then return false
       if m.settings.screen.ScreenType = m.isScheduledScreen then return false
       meta                 = {}
       for each item in m.settings.theme
            value          = ValidStr(m.settings.theme[item])
            name           = ValidStr(item)
            meta[name]     = value
            
            if Instr(1, StrTrim(value), "http") >=1 then
                url       = StrTrim(value)
                Print "-theme image: "; name + " : " + url    
                file      = "tmp:/" + name
                m.Transfer.SetUrl(url)
                m.Transfer.GetToFile(file)                
                meta[name]= file
            endif
        next  
    
       appManager           = CreateObject("roAppManager")
       appManager.SetTheme(meta)
              
       return true    
   End Function
   m.GlobalConstant()
   m.GlobalThemes()
  'write the breadcrumb default previous item - OnLoad
   m.Registry().Write("BreadCrumbPrevious", "Home")
   
 '-----------------------------------------------------------------------------------------------------------------------------------
 '   3. Feeds Section
 '-----------------------------------------------------------------------------------------------------------------------------------   
   
   m.FeedsCategory     = Function(endUrl as String) as Object
       this             = {}
       this.m           = m
       this.endUrl      = endUrl
       response         = this.m.CacheGet(this)
       if response     <> invalid then return response
       
       response         = m.Http(endUrl)
       if response      = invalid then return m.EndGate()
       results          = ParseJSON(response)
       if results       = invalid then return invalid
       
       results.attributes = results.categories         
       results.titles     = []
       
       'if response element is a <category> then
       if results.categories <> invalid then  
           for each items in results.categories
               results.titles.push(items.Title)
           next
       else
          results.attributes = results.items
          results.titles     = []
       end if
       
       this.m.CacheSet(this, results)
       return results
    End Function
    
    m.FeedsItem         = Function(endUrl, this = invalid) as Object
       if endUrl        = invalid then return invalid
       
       this.endUrl      = endUrl
       response         = this.m.CacheGet(this)
       if response     <> invalid then return response
       
       response         = this.m.Http(endUrl)
       if response      = invalid then return m.EndGate()
       results          = ParseJSON(response)
       items            = []
       
       if results.items <> invalid then
         for each item in results.items
             items.push(item)
         next 
       end if
              
       this.m.CacheSet(this, items) 
       return items
   End Function
   
   m.FeedsYoutube   = Function(this, start) as Object
        content     = this.content
        content[start].ContentId = content[start].ContentId
        details     = Http("Connect").ToSite("http://www.youtube.com/get_video_info?video_id=" + content[start].contentId)
        if details  = invalid then return invalid
        
        formats      = this.m.YoutubeFormats(details)
        if formats   = invalid then return invalid
        
        bitrates    = []
        urls        = []
        qualities   = []
        'if format   = invalid then return invalid
        
        for each format in formats
            bitrates.Push(format["bitrate"])
            urls.Push(format["url"])
            qualities.Push(format["quality"])
        next 
           
        media = {}
        media["StreamBitrates"]   = bitrates
        media["StreamUrls"]       = urls
        media["StreamQualities"]  = qualities
        media["StreamFormat"]     = "mp4"
        media["Title"]            = content[start].Title
        media.ContentId        = content[start].ContentId
        return media
   End Function 
   
   m.FeedsVimeo       = Function(this, start)
       content        = this.content
       item           = content[start]
       playStreamUrl  = StrTrim(StrReplace( this.m.settings.vimeo.PlayStream, "{VIDEOID}", item.MetaData))
       response       = this.m.Http(playStreamUrl)
       
       if response    = invalid then return invalid
       if response    = "" then return invalid
       
       result         = ParseJson(response)
       
       if result.request        = invalid then return invalid
       if result.request.files  = invalid then return invalid
       
       if result.request.files.h264 <> invalid then
           if result.request.files.h264.hd <> invalid then
               if result.request.files.h264.hd.url <> invalid then
                    item["StreamUrls"]      = [StrTrim(result.request.files.h264.hd.url)]
                    item["StreamBitrates"]  = [result.request.files.h264.hd.bitrate]        
                    
                    return item
               end if 
           end if 
            
           if result.request.files.h264.sd <> invalid then
               if result.request.files.h264.sd.url <> invalid then
                    item["StreamUrls"]      = [StrTrim(result.request.files.h264.sd.url)]
                    item["StreamBitrates"]  = [result.request.files.h264.sd.bitrate]        
                    
                    return item
               end if 
           end if
        else
           if result.request.files.progressive[1] <> invalid then
                item["StreamUrls"]      = [StrTrim(result.request.files.progressive[1].url)]
                item["StreamBitrates"]  = [0]  
                return item 
           end if 
           if result.request.files.progressive[0] <> invalid then
                item["StreamUrls"]      = [StrTrim(result.request.files.progressive[0].url)]
                item["StreamBitrates"]  = [0]  
                return item 
           end if 
           if result.request.files.hls.url <> invalid then
                item["StreamUrls"]      = [StrTrim(result.request.files.hls.url)]
                item["StreamBitrates"]  = [0]
                return item 
           end if 
   
        end if 

      return invalid
   End Function
   
   m.SetOnline           = Function(this) as Object        
        seconds          = invalid
        if  this.imOnlineNow   = false then
            this.imOnlineTimer = CreateObject("roTimespan")
            this.imOnlineTimer.Mark()
            seconds            = this.imOnline * 2
        end if
        
        if  this.imOnlineTimer  = invalid then
            this.imOnlineTimer = CreateObject("roTimespan")
            this.imOnlineTimer.Mark()
        else
            if seconds  = invalid then     
                seconds = this.imOnlineTimer.totalSeconds()
            end if
            if seconds >= this.imOnline then
                Print "--reset"
                
                this.imOnlineNow   = true
                this.imOnlineTimer = invalid                
                hashed             = StrReplace(this.url.online, "{PARAM1}", this.settings.manifest.HashedId)
                            
                response         = this.Http(hashed)
                if response <> invalid then
                    results      = ParseJSON(response)
                end if 
            end if 
        end if    
   End Function 
   
   m.SetViewed          = Function(this, content) as Object
        if content.HashedId = invalid then return invalid
        viewedUrl       = StrReplace(this.m.url.viewed, "{PARAM}", content.HashedId)
        response        = this.m.Http(viewedUrl)
        if response <> invalid then
            results         = ParseJSON(response)
        end if    
   End Function 
   
   m.CacheGet         = Function(this) as Object
      code            = this.m.CacheCode(this) 
      if this.m[code] <> invalid then  return this.m[code]
      
      return invalid
   End Function
   
   m.CacheCode        = Function(this)
      code            = this.m.GlobalHash(this.EndUrl)
      return code
   End Function
   
   m.CacheSet         = Function(this, results) as Boolean
      code            = this.m.CacheCode(this)  
      this.m[code]    = results
      
      return true
   End Function
     
 '-----------------------------------------------------------------------------------------------------------------------------------
 '   4. Screen Section
 '-----------------------------------------------------------------------------------------------------------------------------------  
   
    m.ScreenGRID        = Function(categories) as Integer
        this            = {}
        this.port       = CreateObject("roMessagePort")
        this.screen     = CreateObject("roGridScreen")
        this.categories = categories
        this.wait       = 600
        this.index      = 0
        this.load       = 2
        this.content    = []
        this.loaded     = []
        this.m          = m
        this.loader     = m.ScreenLoader(this)
        
        this.feedsItem      = m.FeedsItem
        this.screenSelector = m.ScreenSelector
        
        DSBEHAVIOR      = Function(this) as Object
            if m.settings.screen.BehaviorAtTopRow = "exit" then
                '@todo this should be happens if not startup screen
                this.screen.SetUpBehaviorAtTopRow("exit")
            end if
        End Function

        DSPROPERTIES    = Function(this) as Object
            this.screen.SetMessagePort(this.port)
            this.screen.SetDisplayMode(m.settings.screen.DisplayModeGrid) 
            this.screen.SetGridStyle(m.settings.screen.ListStyleGrid)
            this.screen.SetupLists(this.categories.attributes.count())
            this.screen.SetListNames(this.categories.titles)
            this.screen.SetBreadcrumbEnabled(StrToBool(m.settings.screen.SetBreadcrumbEnabledGrid))
        End Function
        
        DSPRELOADCONTENT = Function(this) as Object 
            overall      = this.categories.attributes.count()
            for index    = 0 to overall - 1
               isVisible = true 
               items     = []
               for each dummy in [0,1,2,3,4,5] 
                   items[dummy] =  {title:"Loading...", sdposterurl:"", hdposterurl:"", description:""}
               next
               this.screen.SetContentList(index, items)
               if index >= this.load then isVisible = false
               this.screen.SetListVisible(index,isVisible)
            next index
        End Function
        
        DSLOADCONTENT     = Function(this, start = 0) as Object 
             total        = this.categories.attributes.count()
             if total > this.load then total = this.load
             if start > 0 then total = start + 1
                          
             for index    = start to (total - 1)
                 this.screen.SetListVisible(index,true)
                 items    = this.feedsItem(this.categories.attributes[index].EndPoint, this)
                 
                 if items = invalid    then items = this.dsNoContent(this)
                 if items.count() <= 0 then items = this.dsNoContent(this)
                 this.screen.SetContentList(index, items)
                 this.loaded[index] = true
                 this.content[index]= items
             next index
             
             return this
        End Function
        
        DSNOCONTENT        = Function(this) as Object 
            current        = []
            hdposterUrl    =  this.m.url.nomedia
            sdposterUrl    =  this.m.url.nomedia 
            current[0]     = {title:"No Media Items", sdposterurl:hdposterUrl, hdposterurl:sdposterUrl, description:"Media items are not available."}    
            return current                
        End Function
        
        DSSHOW            = Function(this) as Object
            this.screen.show()
            'this.screen.ShowMessage("Loading...")
            this.screen.SetFocusedListItem(1,3)
        End Function
        
        DSSETBREADCRUMB   = Function(this) as Object
            previous      = this.m.Registry().Read("BreadCrumbPrevious")
            this.screen.SetBreadcrumbText(previous, this.m.breadCrumb.current)
        End Function
        
        DSEVENTS          = Function(this) as Boolean
            total         = this.categories.attributes.count()
            if total > this.load then
                is          = this.loadContent(this, 2)
                this.loaded = is.loaded
            end if           
            while true
                event          = wait(this.wait,  this.screen.GetMessagePort())
                if type(event) = "roGridScreenEvent"   then
                    if event.isListItemFocused()       then
                        row     = event.GetIndex()
                        nextRow = row + 1
                        if nextRow < total  then this.screen.SetListVisible(nextRow, true)
                        if this.loaded[nextRow]  = invalid AND nextRow < total then
                            Print "inside:"
                            local = this.loadContent(this, nextRow)  
                            this.loaded[nextRow] = true
                        end if
                    else if event.isListItemSelected() then
                        column           = event.GetData()
                        row              = event.GetIndex()
                       'set breadcrumb and previous
                        this.m.breadCrumb.current = this.content[row][column].Title
                        
                        'this.screen.ShowMessage("Loading...")
                        this.loader.Show()
                        item             = {}
                        item             = this.content[row]
                        'call another screen
                        currentColumn    = m.ScreenAnalyzer(item, column)
                        'this.screen.ClearMessage()
                        this.loader.Close()
                        this.loader      = this.m.ScreenLoader(this)
                        
                        'set focus if springboard only
                        if item[column] <> invalid then
                            if item[column].ScreenType = this.m.isSpringboardScreen then
                                this.screen.SetFocusedListItem(row, currentColumn - 1)
                            end if    
                        end if    
                    else if event.isScreenClosed() then
                        exit while
                    end if
                end if
            end while
            this.screen.close()
            
            return true  
        End Function
        
        this.dsNoContent = dsNoContent
        dsBehavior(this)
        dsProperties(this)
        dsSetBreadCrumb(this)
        dsPreLoadContent(this)
        
        is               = dsLoadContent(this, 0)
        if this.content.count() <=0 then
             this.screen.ShowMessage("No Media Items")
        end if
        this.loaded      = is.loaded
        
        dsShow(this)
        
        this.loadContent = dsLoadContent
        dsEvents(this)
        
        return m.isReturn
    End Function
    
    
    
    m.ScreenPOSTER      = Function(categories, this = {}) as Integer
        this.port       = CreateObject("roMessagePort")
        this.screen     = CreateObject("roPosterScreen")
        this.categories = categories
        this.wait       = 600
        this.m          = m
        this.loader     = m.ScreenLoader(this)
        
        this.feedsItem      = m.FeedsItem
        this.screenSelector = m.ScreenSelector
        
        DSBEHAVIOR      = Function(this) as Object
        End Function

        DSPROPERTIES    = Function(this) as Object
            this.screen.SetMessagePort(this.port)
            displayMode = m.settings.screen.DisplayModePoster
            listStyle   = m.settings.screen.ListStylePoster
            
            ' possible a poster screen
            if this.ListStyleSimple <> invalid then 
                listStyle     = this.ListStyleSimple 
                displayMode   = this.DisplayModeSimple
                this.categories.titles = invalid
            end if
            
            this.screen.SetListDisplayMode(displayMode) 
            this.screen.SetListStyle(listStyle)

            if this.categories.titles <> invalid then
                this.screen.SetListNames(this.categories.titles)
            end if
            
            enableBreadCrumb = StrToBool(m.settings.screen.SetPosterBreadCrumbEnabled)
            if this.BreadCrumbEnable <>invalid then 
                enableBreadCrumb = true
            end if
            this.screen.SetBreadcrumbEnabled(enableBreadCrumb)
        End Function
        
        DSDUMMIES        = Function(this) as Object  
        End Function
        
        DSLOADCONTENT     = Function(this, start = 0) as Object        
             this.screen.SetContentList([])
             if this.categories.titles <> invalid then
                this.content = this.feedsItem(this.categories.attributes[start].EndPoint, this)
             else
                'simple screen
                this.content = this.categories.attributes  
             endif    
             if this.content.count() >=1 then 
                this.screen.SetContentList(this.content)
                focused   = this.content.Count() / 2
                this.screen.SetFocusedListItem(focused)
             else 
                this.screen.ShowMessage("No Media Items")
             endif
             this.loaded  = true
             return this
        End Function
        
        DSSHOW            = Function(this) as Object
            this.screen.show()
            this.screen.ShowMessage("Loading...")
        End Function
        
        DSSETBREADCRUMB   = Function(this) as Object
            previous      = this.m.Registry().Read("BreadCrumbPrevious")
            this.screen.SetBreadcrumbText(previous, this.m.breadCrumb.current)
        End Function
        
        DSEVENTS                  = Function(this) as Boolean         
            while true
                event             = wait(this.wait,  this.screen.GetMessagePort())
                if type(event)    = "roPosterScreenEvent"   then
                    if event.isListFocused()       then
                        row              = event.GetIndex()
                        this             = this.dsLoadContent(this, row)  
                    else if event.isListItemSelected() then 
                        'this.screen.ShowMessage("Loading...")
                        this.loader.Show()
                        column           = event.GetIndex()
                        item             = this.content
                        
                       'set breadcrumb previous
                        this.m.breadCrumb.current = item[column].Title
                        
                        'call another screen 
                        currentColumn    = m.ScreenAnalyzer(item, column)
                        if item[column].ScreenType = this.m.isSpringboardScreen then
                            this.screen.SetFocusedListItem(currentColumn - 1)
                        endif
                        
                        this.loader.Close()
                        this.loader     = m.ScreenLoader(this)
                    else if event.isScreenClosed()     then
                        exit while
                    end if
                end if
            end while
            this.screen.close()
            return true  
        End Function
        
        dsBehavior(this)
        dsProperties(this)
        dsSetBreadCrumb(this)
        dsShow(this)
        
        is                 = dsLoadContent(this, 0)
        this.dsLoadContent = dsLoadContent
        dsEvents(this)
        
        return m.isReturn
    End Function
    
    
    
    m.ScreenLIST        = Function(items) as Integer
        this            = {}
        this.port       = CreateObject("roMessagePort")
        this.screen     = CreateObject("roListScreen")
        this.wait       = 600
        this.items      = items.attributes
        this.settings   = m.settings
        this.loader     = m.ScreenLoader(this)
        this.m          = m
        
        DSBEHAVIOR      = Function(this) as Object
            if m.settings.screen.BehaviorAtTopRow = "exit" then
                '@todo this should be happens if not startup screen
                this.screen.SetUpBehaviorAtTopRow("exit")
            end if
        End Function
        
        DSPROPERTIES    = Function(this) as Object
            this.screen.SetMessagePort(this.port)
            if this.items <> invalid AND this.items.count() >= 0 then
               channel  = this.settings.screen
               for i = 0 to this.items.Count() - 1
                    this.items[i]       = this.dsOptionsDisplayTitle(this, i)
                    this.items[i]       = this.dsOptionsAssignImages(this, i)
               end for
            end if  
        End Function
        
        DSOPTIONS_DISPLAYTITLE = Function(this, i)
             screen   =  this.settings.screen
             if screen.DisplayListTitle <> invalid AND screen.DisplayListTitle.toInt() =  this.m.isNo then
                    this.items[i]["ShortDescriptionLine1"]  = ""
                    this.items[i]["ShortDescriptionLine2"]  = ""  
             end if
             return this.items[i]
        End Function
        this.dsOptionsDisplayTitle = dsOptions_DisplayTitle
        
        DSOPTIONS_ASSIGNIMAGES = Function(this, i)
             screen            =  this.settings.screen
             
             'assign default values
             if screen.DisplayBackgroundImage.toInt() = this.m.isYes then
                image                                 = this.items[i]["HDBackgroundImageUrl"]
             else
                image                                 = this.items[i]["HDPosterUrl"]
             end if
             this.items[i]["HDBackgroundImageUrl"] = invalid
             this.items[i]["SDBackgroundImageUrl"] = invalid
             this.items[i]["SDPosterUrl"]          = invalid
             this.items[i]["HDPosterUrl"]          = invalid
             
             if this.items[i] <> invalid AND screen.DisplayBackgroundImage <> invalid then 
                 'transfer  = CreateObject("roUrlTransfer")
                 'fileHD    = "tmp:/" + "HD" + this.items[i].Id
                 'transfer.SetUrl(image)                     
                 'transfer.GetToFile(fileHD)
                 fileHD   =  image
                 if screen.DisplayBackgroundImage.toInt() = this.m.isYes then
                    this.items[i]["HDBackgroundImageUrl"]  = fileHD
                    this.items[i]["SDBackgroundImageUrl"]  = fileHD
                 else
                    this.items[i]["SDPosterUrl"]           = fileHD
                    this.items[i]["HDPosterUrl"]           = fileHD
                 endif
             endif
             return this.items[i]
        End Function
        this.dsOptionsAssignImages = dsOptions_AssignImages
          
        DSLOADCONTENT     = Function(this, start = 0) as Object
             this.screen.SetContent(this.items) 
             this.loaded  = true
             return this
        End Function
        
        DSSHOW            = Function(this) as Object
            this.screen.show()
        End Function
        
        DSSETBREADCRUMB   = Function(this) as Object
            previous      = this.m.Registry().Read("BreadCrumbPrevious")
            this.screen.SetBreadcrumbText(previous, this.m.breadCrumb.current)
        End Function
        
        DSEVENTS                  = Function(this) as Boolean         
            while true
                event             = wait(this.wait,  this.screen.GetMessagePort())
                if type(event)    = "roListScreenEvent"   then
                    if event.isListItemFocused()          then
                        row       = event.GetIndex()
                    else if event.isListItemSelected()    then
                        column    = event.GetIndex()
                        item      = this.items
                        this.loader.Show() 
                        'set for breadcrumb 
                        this.m.breadCrumb.current = item[column].Title
                        
                        'restore to HD/SD PosterUrl
                        if this.settings.screen.DisplayBackgroundImage.toInt() = this.m.isYes then
                            HDBackground                        = item[column]["HDBackgroundImageUrl"]
                            SDBackground                        = item[column]["SDBackgroundImageUrl"]
                            item[column]["SDPosterUrl"]         = HDBackground
                            item[column]["HDPosterUrl"]         = SDBackground
                        end if
                        
                        'call another screen 
                        current   = m.ScreenAnalyzer(item, column)
                        if current <> m.isReturn current = column
                        this.loader.Close()
                        this.loader = m.ScreenLoader(this)
                        this.screen.SetFocusedListItem(column)
                    else if event.isScreenClosed()        then
                        exit while
                    end if
                end if
            end while
            this.screen.close()
            return true  
        End Function
        
        dsBehavior(this)
        dsProperties(this)
        dsSetBreadCrumb(this)        
        this.screenSelector = m.ScreenSelector
        is                  = dsLoadContent(this, 0)
        
        dsShow(this)
        dsEvents(this)
        
        return 1
    End Function


    
    m.ScreenSPRINGBOARD         = Function(content) as Integer
        this                    = {}
        this.port               = CreateObject("roMessagePort")
        this.screen             = CreateObject("roSpringboardScreen")
        this.wait               = 600
        this.content            = content
        this.column             = content[0].column ' current column is always on index 0
        this.m                  = m
        
        DSBEHAVIOR      = Function(this) as Object    
        End Function
        
        DSPROPERTIES    = Function(this) as Object
            displayMode      = this.m.ValidValue(m.settings.screen.DisplayModeSpringboard, "scale-to-fit")
            posterStyle      = this.m.ValidValue(m.settings.screen.SetPosterStyle, "Rounded-Rect-16x9-Generic")
            descriptionStyle = this.m.ValidValue(m.settings.screen.DescriptionStyle, "Video")
            breadCrumbEnabled= this.m.ValidValue(StrToBool(m.settings.screen.SetBreadcrumbEnabledSpringboard), true)
            
            this.screen.SetMessagePort(this.port)
            this.screen.SetDescriptionStyle(descriptionStyle) 
            this.screen.SetDisplayMode(displayMode)
            this.screen.SetPosterStyle(posterStyle)
            this.screen.AllowUpdates(true)
            this.screen.SetBreadcrumbEnabled(breadCrumbEnabled)
            
            '--------- for implementation -------------
            this.screen.SetStaticRatingEnabled(false)
        End Function
        
        DSLOADCONTENT     = Function(this, start = 0) as Object
             content      = this.content[start]   
             this.loaded  = true
             this.screen.SetContent(content)
             return this
        End Function
        
        DSSHOW            = Function(this) as Object
            this.screen.show()
        End Function
        
        DSSETBREADCRUMB   = Function(this) as Object
            previous      = this.m.Registry().Read("BreadCrumbPrevious")
            this.screen.SetBreadcrumbText(previous, this.m.breadCrumb.current)
        End Function
        
        DSBUTTONS         = Function(this) as Object
            content       = this.content[this.column]
            this.screen.ClearButtons()
            
            if content.ItemId <> invalid then 
                itemId = content.ItemId
                if this.m.Registry().Read(itemId) <> invalid AND this.m.Registry().Read(itemId).toint() >= 1 then
                    this.screen.AddButton(this.m.isResumed,       "Resume playing")    
                    this.screen.AddButton(this.m.isPlayBeginning, "Play from beginning")
                else
                    this.screen.AddButton(this.m.isPlay,          "Play")    
                end if    
            else      
                if ValidStr(content.Alias) = "categories" then
                    this.screen.AddButton(this.m.isViewContent,   "View Content")
                else
                    this.screen.AddButton(this.m.isPlay,          "Play")
                end if
            end if
            
            if this.content.count() >=2 then
                this.screen.Addbutton(this.m.isRightKey, ">> Next")
                this.screen.AddButton(this.m.isLeftKey,  "<< Previous")  
            end if
            this.screen.AddButton(this.m.isBack,            "Go Back")
        End Function
        
        DSEVENTS                  = Function(this) as Integer         
            select                = 0                
            while true
                event             = wait(this.wait,  this.screen.GetMessagePort())
                if type(event)    = "roSpringboardScreenEvent"   then
                    if event.isButtonPressed()   then
                         return event.GetIndex() 
                    else if event.isRemoteKeyPressed()
                        select    = event.GetIndex()
                        exit while    
                    else if event.isScreenClosed()    then
                        select = 0
                        exit while
                    end if
                end if
            end while
            return select  
        End Function
        
        DSLOOP                  = Function(this) as Object
            total               = this.content.count() - 1
            current             = this.content
            select              = invalid
            while select       <> this.m.isBack AND select    <>  this.m.isClose
                select          = this.dsEvents(this)
                if select       = this.m.isLeftKey OR select   = this.m.isPrevious then      ' PREVIOUS 
                     if this.column - 1 < 0 then this.column   = total + 1
                     this.column = this.column - 1
                    'set breadcrumb and previous
                     this.m.breadCrumb.current = this.content[this.column].Title
                     this.dsBreadCrumb(this) 
                else if select   = this.m.isPlay OR select = this.m.isPlayBeginning          ' PLAY
                     itemId      = this.content[this.column].ItemId
                     this.m.Registry().Write(itemId, "0")
                     this.content[0].column = this.column
                     m.ScreenSelector(this.m.isVideoScreen, this.content)              
                else if select   = this.m.isResumed 
                     itemId      = this.content[this.column].ItemId                          ' RESUME                    
                     if this.m.Registry().Read(itemId) <> invalid AND this.m.Registry().Read(itemId).toint() >= 1 then
                        this.content[0].column            = this.column
                        this.content[0].isResumed         = true
                        m.ScreenSelector(this.m.isVideoScreen, this.content)
                     end if
                else  if select = m.isViewContent then                                      ' VIEW CONTENT
                      categorUrl= this.content[this.column].EndPoint
                      m.ScreenSelector(this.content[this.column].screenType, m.FeedsCategory(categorUrl))        
                else                                                                        ' NEXT
                    if this.column + 1 > total then this.column = -1
                    this.column = this.column + 1
                    'set breadcrumb
                    this.m.breadCrumb.current = this.content[this.column].Title
                    this.dsBreadCrumb(this)
                end if
                
                is  = this.dsLoadContent(this, this.column)
                this.dsButtons(this)
            end while
            this.screen.close()
            return false
        End Function
        
        dsBehavior(this)
        dsProperties(this)
        dsSetBreadCrumb(this)
        dsShow(this)
        dsButtons(this)
         
        is                      = dsLoadContent(this, this.column)
        this.dsBreadCrumb       = dsSetBreadCrumb
        this.dsEvents           = dsEvents
        this.dsLoadContent      = dsLoadContent
        this.dsButtons          = dsButtons
        dsLoop(this) 
        
        'return the current column
        if this.column <= -1 then this.column  = this.column + 1
        return this.column    
    End Function
    
    
    'note param (content) become BYREF because already inside the caller function 
    m.ScreenVIDEO       = Function(content) as Integer
        this            = { isYoutube      : m.isYouTube, isVimeo: m.isVimeo }
        this.get        = { FeedsYoutube   : m.FeedsYoutube, FeedsVimeo   : m.FeedsVimeo }
        this.content    = content
        this.column     = content[0].column
        this.wait       = 600
        this.pnp        = 10 'position notification period
        this.port       = CreateObject("roMessagePort")
        this.render     = "screen" 'player or screen'
        this.message    = m.message
        this.noRemote   = false
        this.forever    = true
        this.isResumed  = false
        this.randomSeek = false
        this.timeStop   = 0
        this.m          = m
        
        if content[0].IsResumed <> invalid then  this.isResumed         = content[0].IsResumed 
        if content[0].Forever <> invalid then  this.forever             = content[0].Forever   
        if content[0].Render <> invalid then this.render                = content[0].Render
        if content[0].NoRemote <> invalid then this.noRemote            = content[0].NoRemote
        if content[0].TimeStop <> invalid then this.timeStop            = content[0].TimeStop
        if content[0].RandomSeek <> invalid then this.randomSeek        = StrToBool(content[0].RandomSeek)
        
        if this.randomSeek = true then
            firstItem =  this.content[0]
            seconds   =  Rnd(8) * 1000
            this.m.Registry().Write(firstItem.ItemId, seconds.toStr())
        end if

        DSVIDEO         = Function(this) as Object
            select      = {screen: CreateObject("roVideoScreen"), player: CreateObject("roVideoPlayer")}
            return select[this.render]
        End Function
        this.screen     = dsVideo(this)
   
        DSCLOSEDCAPTION = Function(this, content) as String 
           contentId    = content.Id
           if content.Subtitle <> "" then
                results = this.m.Http(content.SubtitleUrl)
                result  = ParseJSON(results)
                file    = "tmp:/" + contentId + ".srt"
                WriteAsciiFile(file, result.subtitle)
                
                return "file://" + file
           end if
           
           return ""
        End Function
        
        DSPROPERTIES           = Function(this) as Object
            this.screen.SetMessagePort(this.port)
            this.screen.SetPositionNotificationPeriod(this.pnp)
            if this.render     = "player" then 
                this.screen.SetMessagePort(this.dsCanvas.GetMessagePort())
                this.screen.SetDestinationRect(this.dsCanvas.GetCanvasRect())
            else
                this.screen.EnableTrickPlay(true)    
            end if    
        End Function
       
        DSLOADER                    = Function()
             canvas                 = CreateObject("roImageCanvas")
             canvas.SetMessagePort(CreateObject("roMessagePort"))
             canvas.SetLayer(1, {color: "#000000"})
             canvas.SetLayer(2, {text: ""})
             canvas.AllowUpdates(true)
             canvas.SetMessagePort(canvas.GetMessagePort())
             return canvas
        End Function
        this.dsCanvas                = dsLoader()
        
        DSSELECTPROVIDERSCREEN       = Function(this, start, media) as Object 
            if this.m.IsYoutubeURL(media.StreamUrls[0]) = true then
                    media            = this.get.FeedsYoutube(this, start)
                    if media         = invalid then return invalid
             end if
             
             if this.content[start].TypeId = this.isVimeo then
                    media            = this.get.FeedsVimeo(this, start)
                    if media         = invalid then return invalid
             end if
             
             return media
        End Function
        
         DSSELECTPROVIDERPLAYER     = Function(this, start, media) as Object
         
            if media[0].stream.url <> invalid then 
               streamUrl = media[0].stream.url 
            else
               streamUrl = media.StreamUrls[0]
            end if

            if this.m.IsYoutubeURL(streamUrl) = true then
                    media = this.get.FeedsYoutube(this, start)
                    if media <> invalid then
                        media = [{ Stream: { url     : media.StreamUrls } 
                                   StreamFormat      : media.StreamFormat 
                                   SwitchingStrategy : "full-adaptation"}]          
                    else
                        return invalid
                    end if            
             end if
             if this.content[start].TypeId = this.isVimeo then
                    media = this.get.FeedsVimeo(this, start)
                    if media <> invalid then
                        media = [{ Stream: { url     : media.StreamUrls } 
                                   StreamFormat      : media.StreamFormat 
                                   SwitchingStrategy : "full-adaptation"}]          
                    else
                        return invalid
                    end if            
             end if
             if this.content[start].TypeId = this.m.isAds then
                    media = [this.content[start]]   
             end if
             
             return media
        End Function
        
        DSLOADCONTENTSCREEN          = Function(this, start = 0) as Object 
             content                 = this.content[start]
             ' streaming content into array 
             media                   = {}
             media["StreamUrls"]     = [content.StreamUrls]
             media["StreamBitrates"] = [content.StreamBitrates]
             media["StreamQualities"]= [content.StreamQualities]
             media["StreamFormat"]   = content.StreamFormat
             media["Title"]          = content.Title
             media                   = this.dsSelectProviderScreen(this, start, media)
             'Print "-media:";media
             if media                = invalid then return invalid
             
             subtitleUrl             = this.dsClosedCaption(this, content)
             if subtitleUrl <> "" then
                media.SubtitleUrl    = subtitleUrl
             end if
             this.content[start].Id  = content.Id
             this.screen.SetContent(media)
             this.dsSeek(this, content)
             
             return this.content
        End Function
        this.dsLoadContentScreen     = dsLoadContentScreen
        
        DSLOADCONTENTPLAYER          = Function(this, start = 0) as Object 
             content                 = this.content[start]
             ' streaming content into array 
             media  = [{ Stream: { url     : content.StreamUrls } 
                         StreamFormat      : content.StreamFormat 
                         SwitchingStrategy : "full-adaptation"
                      }]
             media = this.dsSelectProviderPlayer(this, start, media)
             if media                     = invalid then return invalid
             
             this.content[start].Id       = content.Id
             this.dsSeek(this, content)
             this.screen.SetContentList(media)
             this.screen.play()
             
             return this.content
        End Function
        this.dsLoadContentPlayer    = dsLoadContentPlayer
        
        DSSEEK                      = Function(this, content) as Boolean
            if content.ItemId       = invalid then return false    
            itemId                  = content.ItemId    
            if this.m.Registry().Read(itemId) <> invalid AND this.m.Registry().Read(itemId).toint() >= 1 then
                 miliseconds = this.m.Registry().Read(itemId).toint() * 1000
                 this.screen.Seek(miliseconds)
            end if
            if this.IsResumed = false then this.screen.Seek(0)
            if this.IsResumed = true then this.IsResumed = false 'restored to default
            if content.IsAd  <> invalid then this.screen.Seek(0)
        End Function
        
        DSLOADCONTENT               = Function(this, current = 0) as Object
             'increment viewed
             this.m.SetViewed(this, this.content[current])
        
             select                 = {screen: this.dsLoadContentScreen, player: this.dsLoadContentPlayer}
             return select[this.render](this, current)
        End Function     
        
        DSSHOW                      = Function(this) as Object
            if this.render = "screen" then this.screen.show()
        End Function
        
        DSREINITIALIZE            = Function(this) as Object
            this.port             = CreateObject("roMessagePort")
            select                = {screen: CreateObject("roVideoScreen"), player: CreateObject("roVideoPlayer")}
            this.screen           = select[this.render]
            this.dsProperties(this)
            if this.render = "screen" then this.screen.show()
        End Function

        DSEVENTS                  = Function(this) as Integer         
            events                = invalid
            name                  = {screen : "roVideoScreenEvent", player: "roVideoPlayerEvent"}
            isLoaded              = false
            counter               = 0
            while true
                event             = wait(0,  this.screen.GetMessagePort())
                if type(event)    = name[this.render]      then
                    if event.isPlaybackPosition()          then
                         
                         'set online
                         this.m.SetOnline(this.m)
                    
                         'write the position to registry for resume later
                         index    = event.GetIndex()
                         itemId   = this.content[this.column].ItemId
                         this.m.Registry().Write(itemId, index.toStr())
                         
                         'if there is a video time stop then
                         if this.timeStop >= 1 then
                             current      = this.m.TimeLong()
                             if current.formatLong.toInt() > this.timeStop then 
                                this.dsCanvas.close()
                                return 0
                             end if   
                         end if
                         
                         'check if there is tracking event
                         this.m.AdVastTrackingEvent(this.content[this.column], event)
                         
                    else if event.isStatusMessage() then
                        Print "--" + event.GetMessage() + "--"
                        counter                   =  counter + 1
                        if event.GetMessage()     = "startup progress" AND isLoaded = false then 
                            print name.screen
                            if name.screen = "roVideoPlayerEvent" OR this.m.screenType = "None" then
                                this.dsCanvas.ClearLayer(2)
                                this.dsCanvas.SetLayer(1, {Color: "#00000000", CompositionMode: "Source"})
                                this.dsCanvas.Show()
                            end if
                            isLoaded = true
                            
                        else if event.GetMessage() =  "Unspecified or invalid track path/url." or event.GetMessage() = "HTTP status 404" then
                           
                            if this.noRemote = false then 
                                Dialog(this.message["VideoUnavailable"].Title, this.message["VideoUnavailable"].Text)  
                                this.dsCanvas.close()
                                return 0
                            else
                                return 3 ' request failed 
                            end if
                            
                        else if event.GetMessage()       = "start of play" 
                            this.dsCanvas.ClearLayer(2)
                        else
                            remainder = counter mod 2
                            if remainder = 1 then spinner  = this.m.url.spinner[0]
                            if remainder = 0 then spinner  = this.m.url.spinner[1]
                            if counter  >= 3 then 
                                counter  = 0
                                spinner  = this.m.url.spinner[2]
                            end if
                            this.dsCanvas.SetLayer(2, {url: spinner, TargetRect:{x:550, y:290}, CompositionMode:"Source"}) 
                            
                        end if
                        events = 6
                    else if event.isStreamStarted()        then   
                    else if event.isPartialResult()        then
                        events = 1
                        exit while
                    else if event.isRequestFailed()        then
                        events = 3 
                        exit while
                    else if event.isFullResult()           then
                        events = 2
                        exit while     
                    else if event.isScreenClosed()         then
                        events = 0
                        exit while
                    end if
                else if type(event) = "roImageCanvasEvent"
                    if event.isRemoteKeyPressed() and this.noRemote = false then
                        index    = event.GetIndex() + 100
                        if index =  this.m.isUpKey  + 100 then
                        
                            'check if there is tracking event
                            this.m.AdVastTrackingEvent(this.content[this.column], event)
                            this.dsCanvas.close()
                            return 0
                        end if    
                    end if 
                end if
            end while
            
            return events  
        End Function
        
        DSDEBUG                 = Function(content)
            print "*"
            print content.StreamUrls[0]
            print content.StreamBitrates[0]
            print content.StreamFormat
            print "*"
        End Function
        
        DSLOOP                  = Function(this) as Boolean
            total               = this.content.count() - 1
            events              = invalid
            current             = this.column
            loader              = this.dsLoader()
            while events       <> m.isBack AND events <>  m.isClose
                    returned        = this.m.isYes
                    if this.forever = true then 
                         if current > total then current = 0
                    end if
                    
                    'set the current column played index to global
                    this.m.playedIndex  = current + 1
                    
                    'execute before the video play
                    if this.content[0].NoCallBeforeEachVideo = invalid then 
                        returned     = m.ScreenBeforeEachVideo(this.content[current])
                        if returned  = this.m.isAds then
                            this.dsReinitialize(this)
                            returned = this.m.isYes
                        end if 
                        if returned  = this.m.isNo then exit while   
                    end if
                    
                    'if not free forever
                    if this.forever = false then 
                         if current > total then exit while    
                    end if
                    if returned    = this.m.isNo  then content = invalid
                    
                    'if not an item 
                    if this.content[current].HashedId = invalid then 
                        content  = invalid
                        returned = invalid
                        events   = m.isRequestFailed
                    end if
                     
                    'if audio screen
                    if this.content[current].TypeId = 4 then 
                        loader.show()                         
                        events    = this.m.ScreenSelector("Audio", this.content[current])
                        if events = this.m.isScreenClosed then
                            exit while
                        end if
                        returned  = events
                        content   = invalid
                    end if
                    
                    'if all returned is Yes then let us load the content
                    if returned    = this.m.isYes then content = this.dsLoadContent(this, current)     
                    if content     = invalid then 
                        events     = m.isRequestFailed
                    else
                        events     = this.dsEvents(this)
                    end if    
                    loader.show()
                    
                    if events      = m.isScreenClosed     then
                        exit while
                    else if events = m.isPartialResult    then
                        ' continue to another video
                        ' current  = current + 1
                        ' this.dsReinitialize(this)
                        exit while
                    else if events = m.isRequestFailed    then
                       ' continue to another video
                        current    = current + 1
                        this.dsReinitialize(this)
                    else if events = m.isFullResult       then
                       ' if not auto play 
                        if StrToBool(this.m.settings.screen.AutoPlayNextVideo) = false then exit while
                        
                       ' continue to another video 
                        current    = current + 1
                        this.dsReinitialize(this)
                    else if events = m.isButtonPressed    then
                        current    = current + 1 
                        this.dsReinitialize(this)
                        ' continue to another video 
                    else
                        exit while       
                    end if
            end while
            loader.close() 
            if this.render = "screen"  then this.screen.close()
            if this.render = "player"  then this.screen.stop()
            return false
        End Function
        
        dsProperties(this)
        dsShow(this)
        
        this.dsSelectProviderScreen   = dsSelectProviderScreen
        this.dsSelectProviderPlayer   = dsSelectProviderPlayer
        
        this.dsClosedCaption    = dsClosedCaption
        this.dsLoadContent      = dsLoadContent
        this.dsEvents           = dsEvents
        this.dsDebug            = dsDebug
        this.dsProperties       = dsProperties
        this.dsReinitialize     = dsReinitialize
        this.dsLoader           = dsLoader
        this.dsSeek             = dsSeek
        dsLoop(this)
        
        return 1
    End Function
    
       
    
    m.ScreenSIMPLE              = Function(item) as Integer
        this                    = {}
        this.ListStyleSimple    = m.settings.screen.ListStyleSimple
        this.DisplayModeSimple  = m.settings.screen.DisplayModeSimple
        this.BreadCrumbEnable   = true

        return m.ScreenPoster(item, this)
    End Function
    
    

    m.ScreenNONE                = Function(content) as Integer
        this                    = {}
        render                  = "player"
        
        if StrToBool(m.settings.screen.EnableProgressBar) = true then
            render              = "screen"    
        end if
        
        item                    = content.items
        item[0].Column          = 0
        item[0].Render          = render 
        item[0].NoRemote        = true
        item[0].RandomSeek      = m.settings.screen.RandomPlayStart
        
        if StrToBool(m.settings.screen.IsLoop) = true then
            while true
                m.ScreenVideo(item)
            end while
            return m.isBack
        end if
        
        return m.ScreenVideo(item)
    End Function
    
    
    
    m.ScreenSCHEDULED           = Function(content) as Integer
        this                    = {}
        this.timezone           = CreateObject ("roDeviceInfo").GetTimeZone()   
        this.canvas             = CreateObject("roImageCanvas")
        this.port               = CreateObject("roMessagePort")
        this.content            = content
        this.wait               = 1000
        this.m                  = m
        this.sizes              = this.canvas .GetCanvasRect()
        
        DSCANVASSTATUS      = Function(text as String) as Object
            canvasStatus    = [{
                                 TargetRect: {x:0,y:0,h:70},
                                 Color:"#222222", CompositionMode:"Source_Over",
                               },
                               {
                                    TargetRect: {x:15,y:0, h:70},
                                    TextAttrs:{Color:"#FFCCCCCC", Font:"Small",
                                    HAlign:"Left",Direction:"LeftToRight"},
                                    Text:text
                               }] 
             return canvasStatus                  
        End Function
            
        DSPROPERTIES        = Function(this) as Object
           width            = this.canvas.GetCanvasRect().w / 2
           height           = this.canvas.GetCanvasRect().h / 2
           targetRect       = {x:width, y:height, w:117, h:26}
           canvasItems      = [
                {  
                    url: this.m.settings.screen.DisplayImageHD
                    TargetRect:{x:0,y:0,w: this.sizes.w, h: this.sizes.h}
                },
                { 
                    Text:""
                    TextAttrs:{Color:"#FFCCCCCC", Font:"Medium",
                    HAlign:"HCenter", VAlign:"VCenter",
                    Direction:"LeftToRight"}
                    TargetRect:{x:390,y:357,w:500,h:60}
                }]
           this.canvas.SetMessagePort(this.port)
           this.canvas.SetLayer(0, {Color:"#FF000000", CompositionMode:"Source"})
           this.canvas.SetRequireAllImagesToDraw(true)
           this.canvas.SetLayer(1, canvasItems)
           this.canvas.SetLayer(2, this.dsCanvasStatus("Checking schedules..."))
           this.canvas.show()
           
           return this.canvas 
        End Function
        
        DSNEXTSHOW          = Function(this, selectedItems, current)
            if selectedItems[0] <> invalid then
               msg          = ""
               time         = selectedItems[0].Title
               runtime      = selectedItems[0].ScheduleStartLong.toInt() - current.formatLong.toInt()
               minutes      = int(runtime / 100) ' converted to minutes
               tick         = minutes.toStr()
               if tick      = "0" then msg = " and few seconds.."
               this.canvas.SetLayer(2, this.dsCanvasStatus("The show will starts in about " + tick + " minute(s)" + msg))
            else
               this.canvas.SetLayer(2, this.dsCanvasStatus("There are no scheduled shows"))     
            end if
        End Function
         
        DSEVENTS            = Function(this) as Integer
            while(true)
              contentItems  = this.content.items
               msg          = wait(this.wait, this.canvas.GetMessagePort())
               if type(msg) = "roImageCanvasEvent" then
                   if (msg.isRemoteKeyPressed()) then
                   
                   else if (msg.isScreenClosed()) then
                      exit while
                   end if
               end if
               current           = this.m.TimeLong()
               if contentItems <> invalid then
                   selectedItems = []
                   index         = 0
                   for each items in contentItems
                        item          = []
                        item[0]       = items
                        if items.ScheduleStartLong.toInt() <= current.formatLong.toInt() and items.ScheduleEndLong.toInt() >= current.formatLong.toInt() and items.Played = invalid then
                               item[0].Column                 = 0
                               item[0].Render                 = "player" 
                               item[0].NoRemote               = true
                               item[0].ScreenBeforeEachVideo  = true 
                               item[0].Forever                = false
                               item[0].NoCallBeforeEachVideo  = true
                               item[0].TimeStop               = items.ScheduleEndLong.toInt()
                              
                               'check if the access was on time or not
                               runtime          = current.formatLong.toInt() - item[0].ScheduleStartLong.toInt()
                               if runtime      >= 10 then
                                    duration    = item[0].ScheduleDuration
                                    toSeconds   = duration * 60 ' converted to seconds
                                    inSeconds   = runtime / 100 ' converted to seconds
                                    withSeconds = toSeconds - inSeconds
                                    itemId      = item[0].ItemId
                                    this.m.Registry().Write(itemId, str(withSeconds))
                                    item[0].IsResumed = true
                               end if                        
                               
                               returned                       = this.m.ScreenVideo(item)
                               items.Played                   = true
                        end if
                       if current.formatLong.toInt() > items.ScheduleEndLong.toInt()  then
                             items.Played        = true
                       end if
                       
                       if items.Played           = invalid  then
                            selectedItems[index] = items
                            index                = index + 1
                       end if 
                   next
                   contentItems = selectedItems
               end if
               'set the next show
               this.dsNextShow(this, selectedItems, current)  
           end while
           
           this.canvas.Close() 
        End Function
        
        this.dsCanvasStatus = dsCanvasStatus
        this.dsNextShow     = dsNextShow
        dsProperties(this)
        dsEvents(this)
                
        return 0
    End Function
       
       
          
    m.ScreenREGISTRATION     = Function(item, options) as Integer
        this                 = {}
        this.m               = m
        this.port            = CreateObject("roMessagePort")
        this.screen          = CreateObject("roCodeRegistrationScreen")
        this.wait            = 100
        this.sleep           = 3000
        this.loader          = m.ScreenLoader(this)
        this.retryInterval   = 8
        this.retryDuration   = 200
        this.isExit          = false
        this.code            = ""
        this.options         = options
                
        DSPROPERTIES    = Function(this) as Object
            intro       = this.options.intro + "  Go to"
            goUrl       = this.options.url
           
            this.screen.SetTitle(this.options.title)
            this.screen.AddFocalText(" ",     "spacing-dense")
            this.screen.AddFocalText(intro,   "spacing-dense")
            this.screen.AddFocalText(" ",     "spacing-dense")
            this.screen.AddFocalText(goUrl,   "spacing-dense")
            this.screen.AddFocalText(" ",     "spacing-dense")
            this.screen.AddFocalText("on your computer or mobile device.",   "spacing-dense")
            this.screen.AddFocalText("When prompted, enter the Activation Code below:", "spacing-dense")
            this.screen.AddFocalText(" ",     "spacing-dense")
            this.screen.AddFocalText(" ",     "spacing-dense")
            this.screen.SetRegistrationCode("retrieving code...")
            this.screen.AddFocalText(" ",     "spacing-dense")
            this.screen.AddFocalText(" ",     "spacing-dense")
            this.screen.AddFocalText("This screen will automatically close and you can start using " + this.m.settings.manifest.Name + " channel.", "spacing-dense")
            this.screen.AddFocalText(" ",     "spacing-dense")
        End Function
        
        DSBUTTON        = Function(this) as Object  
            this.screen.AddButton(this.m.isGetNewCode, "Get a new code")
            this.screen.AddButton(this.m.isBack,       "Back")
        End Function
                
        DSSHOW            = Function(this) as Object
            this.screen.SetMessagePort(this.port)
            this.screen.show()
        End Function
        
        DSSTATUS              = Function(this) as Boolean     
            statusUrl         = StrReplace(this.m.url.register, "{PARAM}", this.code + "/")
            results           = this.m.Http(statusUrl)
            results           = ParseJSON(results)
            Print results
            if results.status = 0  then return false
            if results.status = 1  then
                return true
            end if
            
            return false
        End Function
                     
        DSEVENTS                    = Function(this) as Integer         
            events                  = 0
            while true
                event               = wait(this.retryInterval * this.wait,  this.screen.GetMessagePort())
                this.duration       = this.duration + this.retryInterval            
                if event            = invalid exit while
                
                if type(event)      = "roCodeRegistrationScreenEvent"   then
                    if event.isScreenClosed()
                        events      = this.m.isScreenClosed 
                        exit while
                    else if event.isButtonPressed()
                        if event.GetIndex()   = this.m.isGetNewCode
                            this.screen.SetRegistrationCode("Retrieving Code...")
                            events            = this.m.isGetNewCode
                            exit while 
                        endif
                        if event.GetIndex()   = this.m.isBack 
                            events            = this.m.isBack
                            exit while 
                        end if 
                    endif
                end if
            end while

           return events  
        End Function
        
        DSLOOP                   =  Function(this) as Integer 
            maxTries             = 3
            tries                = 0
            while true
                this.duration    = 0
                codeUrl          = StrReplace(this.m.url.register, "{PARAM}", "getcode/")
                results          = this.m.Http(codeUrl)
                results          = ParseJSON(results)
                this.code        = results.code
                this.screen.SetRegistrationCode(results.code)         
                while true
                    sleep(this.sleep)   
                    status        = this.dsStatus(this)
                    if status     = false then
                        events    = this.dsEvents(this)
                    else
                        this.screen.Close()
                        return this.m.isYes 
                    end if
                    if events        = this.m.isBack then 
                         this.isExit = true   
                         exit while
                    end if
                    if events        = this.m.isGetNewCode then exit while
                    if this.duration > this.retryDuration  exit while
                end while 
                tries               = tries + 1
                if tries > maxTries then
                    Dialog(this.m.message["RegistrationExpired"].Title, this.m.message["RegistrationExpired"].Text)
                    this.isExit     = true
                end if
                if this.isExit      = true then exit while
            end while
            
            'this.screen.Close()
            return this.m.isNo 
        End Function
        
        dsProperties(this)
        dsButton(this)
        dsShow(this)
        this.dsStatus    = dsStatus
        this.dsEvents    = dsEvents
        
        events           = dsLoop(this)
        return events
    End Function
    
    
    
    m.ScreenPINENTRY    = Function(item) as Integer
        this            = {}
        this.port       = CreateObject("roMessagePort")
        this.screen     = CreateObject("roPinEntryDialog")
        this.wait       = 600
        this.m          = m
        this.item       = item
        DSPROPERTIES    = Function(this) as Object
            this.screen.SetTitle("Enter PIN to unlock this item.")
            this.screen.SetMessagePort(this.port)
            this.screen.AddButton(this.m.isYes, "Unlock")
            this.screen.AddButton(this.m.isNo, "Cancel")
            this.screen.EnableBackButton(true)
            this.screen.SetNumPinEntryFields(this.item.PinTotal.toInt())
        End Function
                
        DSSHOW                = Function(this) as Object
            this.screen.show()
        End Function
        
        DSEVENTS               = Function(this) as Integer         
           returned            = this.m.isYes
           while true
                event          = wait(this.wait, this.screen.GetMessagePort())    
                if type(event) = "roPinEntryDialogEvent" then
                     if event.isButtonPressed() then
                        index    = event.GetIndex()
                        if index = this.m.isYes then
                            pin  =  this.screen.Pin()
                            if len(pin) >= this.item.PinTotal.toInt() then
                                if StrTrim(pin) = StrTrim(this.item.Pin) then
                                    returned    =  this.m.isYes
                                    exit while
                                else
                                    Dialog(this.m.message["InvalidPinEntry"].Title, this.m.message["InvalidPinEntry"].Text)    
                                end if
                            end if
                        else
                          returned =  this.m.isNo
                          exit while      
                        end if
                     else if event.isScreenClosed() then 
                          returned =  this.m.isNo
                          exit while 
                     end if
                end if
            end while
            
           this.screen.Close()
           return returned
        End Function
        
        dsProperties(this)
        dsShow(this)
        returned = dsEvents(this)
        
        return returned
    End Function
    
    
    m.ScreenAUDIO       = Function(item) as Integer
        this            = {}
        this.screen     = CreateObject("roAudioPlayer")
        this.cover      = CreateObject("roSlideShow")
        this.port       = CreateObject("roMessagePort")
        this.wait       = 100
        this.m          = m
        this.item       = item
        this.events     = m.isBack
        
        DSCOVER         = Function(this) as Object
            show        = []
            this.cover.SetMessagePort(this.port)
            ' shrink pictures by 5% to show a little bit of border (no overscan)
            this.cover.SetUnderscan(1.0)      
            this.cover.SetBorderColor("#555555")
            this.cover.SetMaxUpscale(5.0)
            this.cover.SetDisplayMode("photo-fit")
            this.cover.SetPeriod(6)
            this.cover.Show()
            
            show[0]  = {url:this.item.CoverHD}
            this.cover.SetContentList(show)
        End Function
        
        DSPROPERTIES    = Function(this) as Object
            isLoop      = StrToBool(this.item.IsLoop)
            item        = {Url:this.item.StreamUrls, StreamFormat:this.item.StreamFormat}
            this.screen.SetMessagePort(this.port)
            this.screen.AddContent(item)
            this.screen.SetLoop(isLoop)
            this.screen.Play()
        End Function
                
        DSEVENTS             = Function(this) as Integer         
            while true 
                event        = wait(this.wait, this.cover.GetMessagePort()) 
                if type(event) = "roSlideShowEvent"  then  
                    if event.isRemoteKeyPressed() then
                        message    = event.getIndex()
                        if message = this.m.isUpKey then
                            this.events = this.m.isScreenClosed
                            exit while
                        end if
                    else if event.isPaused() then
                        this.screen.Pause()
                    else if event.isResumed() then
                        this.screen.Resume()
                    else if event.isScreenClosed() then
                       exit while
                    else    
                       message = event.getMessage()
                    end if  
                 else if type(event) = "roAudioPlayerEvent"
                    if event.isStatusMessage() then
                        if event.getMessage() = "end of playlist" 
                             exit while
                        end if
                     else if event.isScreenClosed() then
                         exit while    
                    endif
                end if
            end while
        End Function
        
        dsCover(this)
        dsProperties(this)
        dsEvents(this)
        
        this.screen.Stop()
        this.cover.Close()
        return this.events
    End Function
    
    
    
    m.ScreenBeforeVIDEOSCREEN = Function(item) as Integer
        this                  = {}
        this.m                = m
        events                = this.m.isYes
        
        DSURL                 = Function(this)
            url               = this.m.settings.screen.RegistrationDefault
            if StrToBool(this.m.settings.screen.RegistrationEmbed)  then
                url     = this.m.settings.screen.RegistrationUrl
            end if
            return url
        End Function
        
        DSSCREENREGISTRATION  = Function(this)
            returned          = this.m.isYes
            if m.settings.screen.RegistrationEnable = true AND m.settings.screen.RegistrationType = this.m.isBeforeVideoPlayed then
               'if viewers is already registered then return true
                if this.m.settings.viewer.IsRegistered = this.m.isYes then return this.m.isYes
                
                options       = {url:this.dsUrl(this), intro: "To activate " + this.m.settings.manifest.Name + " channel on this device.", title: "Device Registration"}
                returned      = m.ScreenRegistration(this, options)
            end if
            return returned
        End Function
        
        this.dsUrl            = dsUrl
        if this.m.settings.properties.IsPartnershipEnabled = false then
            events            = dsScreenRegistration(this)
        end if
        return events
    End Function
    
    
    
    m.ScreenBeforeEACHVIDEO   = Function(item) as Integer
        this                  = {}
        this.m                = m
        this.item             = item
        this.default          = m.isYes
 
        DSPINENTRY            = Function(this) as Object
            returned          = this.m.isYes
            if StrTrim(this.item.Pin) <> "" then
                returned      = m.ScreenPinEntry(this.item)
            end if   
            return returned                 
        End Function
        
        DSADVADS              = Function(this) as Integer
            return this.m.AdVads(this)
        End Function
        
        DSADVASTS             = Function(this)
            return this.m.AdVast(this)
        End Function
        
        if dsPinEntry(this)                 = this.m.isNo then return this.m.isNo
        if this.m.settings.vads.Count()     >= 1 then return dsAdVads(this)
        if this.m.settings.vasts.Count()    >= 1 then return dsAdVasts(this)
        
        return  this.default 
    End Function
    
    
    
    m.ScreenBeforeCategoryContent  = Function(item) as Integer
        this                    = {}
        this.m                  = m
        this.item               = item
        this.default            = m.isYes
 
        DSPINENTRY              = Function(this) as Object
            returned            = this.m.isYes
            if StrTrim(this.item.Pin) <> "" then
                returned        = this.m.ScreenPinEntry(this.item)
            end if   
            return returned                 
        End Function
                
        if dsPinEntry(this)     = this.m.isNo then return this.m.isNo        
        return  this.default 
    End Function
    
    
    
    m.ScreenBEFOREMAIN        = Function(item) as Integer
        this                  = {}
        this.m                = m
        
        DSURL                 = Function(this)
            url               = this.m.settings.screen.RegistrationDefault
            if StrToBool(this.m.settings.screen.RegistrationEmbed)  then
                url           = this.m.settings.screen.RegistrationUrl
            end if
            return url
        End Function
        this.dsUrl            = dsUrl
        
        DSSCREENREGISTRATION  = Function(this)
            returned          = this.m.isYes
            if this.m.settings.screen.RegistrationEnable = true AND this.m.settings.screen.RegistrationType = this.m.isBeforeMainScreen then
                'if viewers is already registered return true
                if this.m.settings.viewer.IsRegistered = this.m.isYes then return this.m.isYes
                
                options       = {url:this.dsUrl(this), intro: "To activate " + this.m.settings.manifest.Name + " channel on this device.", title: "Device Registration"}
                returned      = this.m.ScreenRegistration(this, options)
            end if
                        
            return returned
        End Function
       
        DSSCREENACTIVATION    = Function(this)
            returned          = this.m.isYes
            options           = {url:this.m.settings.properties.PartnershipLoginUrl, intro: "To activate " + this.m.settings.manifest.Name + " channel on this device.", title: "Device Activation"}
            returned          = this.m.ScreenRegistration(this, options)
            return returned
        End Function
      
        if this.m.settings.properties.IsPartnershipEnabled = false then
            events = dsScreenRegistration(this)
        end if

        if this.m.settings.properties.IsPartnershipEnabled = true then 
           'if viewers is already activated return true
            if this.m.settings.viewer.IsActivated = this.m.isYes then return this.m.isYes
            events = dsScreenActivation(this)
        end if
        
        return events
    End Function
    
  
  
    m.ScreenLOADER      = Function(this)
       canvas           = CreateObject("roImageCanvas")
       port             = CreateObject("roMessagePort")
       w                = canvas.GetCanvasRect().w / 2
       h                = canvas.GetCanvasRect().h / 2           
       canvasItems      = [
            {  
                url:   m.url.loader
                TargetRect:{x:550, y:290},
                CompositionMode:"Source_Over"
            }]
       canvas.SetLayer(0, {Color:"#FF000000", CompositionMode:"Source"})
       canvas.SetRequireAllImagesToDraw(true)
       canvas.SetLayer(1, canvasItems)
       
       return canvas 
    End Function
    
    
    
    m.ScreenAnalyzer         = Function(item, column) as Integer
        returned             = 0
        ' we need to trap that sometimes some items have invalid item[column]
        if item[column].Id   = invalid then return 0
        if item[column]      = invalid then return 0
        
        ' we need to check if type is category by checking the ParenId
        if item[column].ParentId <> invalid then
             returned    = m.ScreenBeforeCategoryContent(item[column])
             if returned = m.isNo then return 0   
        end if        
        
        ' write the breadcrumb previous item
        m.Registry().Write("BreadCrumbPrevious", item[column].BreadCrumb)
                
        ' springboard
        if item[column].screenType  = m.isSpringboardScreen then
            item[0].column          = column 'always pass to item[0] for the current column
            returned = m.ScreenSelector(m.isSpringboardScreen, item) 
        ' category
        else         
           EndPoint              = item[column].EndPoint
           ' if EndPoint is blank or invalid then return false
           if EndPoint           = invalid then return 0
           if ValidStr(EndPoint) = ""      then return 0
           returned = m.ScreenSelector(item[column].screenType, m.FeedsCategory(EndPoint))   
        end if
        return returned    
    End Function
        
      
    ' note: [item] either categories or feeds
    m.ScreenSelector   = Function(screenType, item) as Integer
         option                   = {}
         option.returnPlayedIndex = false
         
         ' set online
         m.SetOnline(m)
          
         if screenType = m.isGridScreen             then returned = m.ScreenGrid(item)
         if screenType = m.isPosterScreen           then returned = m.ScreenPoster(item)
         if screenType = m.isListScreen             then returned = m.ScreenList(item)
         if screenType = m.isScheduledScreen        then returned = m.ScreenScheduled(item)
         if screenType = m.isSimpleScreen           then returned = m.ScreenSimple(item)
         if screenType = m.isNoneScreen             then returned = m.ScreenNone(item)
         if screenType = m.isRegistrationScreen     then returned = m.ScreenRegistration(item)
         if screenType = m.isAudioScreen            then returned = m.ScreenAudio(item)
         
         if screenType = m.isSpringboardScreen      then 
                if StrToBool(m.settings.screen.EnableSpringboard) = true then 
                    returned = m.ScreenSpringboard(item)
                else 
                   screenType               = m.isVideoScreen
                   option.returnPlayedIndex = true
                end if
         end if
         
         if screenType = m.isVideoScreen            then 
               if m.ScreenBeforeVideoScreen(item)  = m.isNo then return m.isNo
               returned = m.ScreenVideo(item)
               
               if option.returnPlayedIndex         = true return m.playedIndex
         end if
         
         return returned
    End Function  
    
    
    m.ScreenFREE         = Function() as Boolean
        this             = {}
        this.m           = m
        this.canvas      = CreateObject("roImageCanvas")
        this.port        = CreateObject("roMessagePort")
        this.wait        = 2000
 
        if this.m.settings.properties.IsExpired = 0 then return true
       
        DSGETCONTENT     = Function(this, counter)
           properties    = this.canvas.GetCanvasRect()
           layer   = [   
                        {
                            Url: this.m.url.ad,
                            TargetRect: {x:0,y:0}
                        }, 
                        {
                            TargetRect: {x:0,y:0,h:70},
                            Color:"#222222", CompositionMode:"Source_Over",
                        },
                        {
                            TargetRect: {x:15,y:0, h:70},
                            TextAttrs:{Color:"#FFCCCCCC", Font:"Small",
                            HAlign:"Left",Direction:"LeftToRight"},
                            Text:"This Ad will close in " + counter.toStr()
                        },
                       
                     ]  
            return layer
        End Function
       
        DSPROPERTIES    = Function(this) as Object
           properties   = this.canvas.GetCanvasRect()
           this.canvas.SetMessagePort(this.port)
           this.canvas.SetRequireAllImagesToDraw(true)
           
           layer        = { Color:"#FF000000", CompositionMode:"Source"}                       
           this.canvas.SetLayer(0, layer)
           this.canvas.AllowUpdates(true)
           this.canvas.Show()
        End Function
                
       DSEVENTS             = Function(this) as Integer 
          counter           = 14
          
          while(true)
               msg          = wait(this.wait, this.canvas.GetMessagePort())
               if type(msg) = "roImageCanvasEvent" then
                   if (msg.isRemoteKeyPressed()) then
                   else if (msg.isScreenClosed()) then
                       exit while
                   end if
               end if
               layer      = this.dsGetContent(this, counter)  
               this.canvas.SetLayer(1, layer)
               if counter <0 then
                    exit while
               end if
               counter     = counter - 1
           end while
           
           this.canvas.Close()
       End Function 
      
      this.dsGetContent = dsGetContent
      dsProperties(this)
      dsEvents(this) 
      
      return true
   End Function
    
 '-----------------------------------------------------------------------------------------------------------------------------------
 '   5. Ads Section
 '-----------------------------------------------------------------------------------------------------------------------------------    
   
   m.AdVads                         = Function(this) as Integer
     item                           = this.m.settings.vads
     if item[0]                     = invalid then return this.m.isYes
     item[0].Column                 = 0
     item[0].Render                 = "player" 
     item[0].NoRemote               = true
     item[0].ScreenBeforeEachVideo  = true 
     item[0].Forever                = false
     item[0].NoCallBeforeEachVideo  = true
     this.m.ScreenVideo(item)
    
     return this.m.isAds
   End Function
   
   m.AdVast                        = Function(this)
      this.nwmVast                 = nwm_vast()
      this.nwmUtilities            = nwm_utilities()
      this.items                   = this.m.settings.vasts
      this.m                       = m
               
      DSRESOLVEDURL                = Function(vastTagUrl) as String
         'vastTagUrl                = "s3-us-west-1.amazonaws.com/rokutestchannel1/xml/vast.xml" 
         return vastTagUrl
      End Function
      
      DSSETUP                     = Function(this) as Integer
         if this.items[0]         = invalid then return this.m.isYes                  
         index                    = 0
         vast                     = []
         for each item in this.items
            url       = this.dsResolvedUrl(item.Url)
            raw       = this.nwmUtilities.GetStringFromURL(url)
            ? raw
            this.nwmVast.Parse(raw, false, true)
            
            if this.nwmVast.video <> invalid
                vast[index]                   = this.nwmVast.video
                vast[index].MinBandwidth      = 250
                vast[index].TypeId            = this.m.isAds
                vast[index].ItemId            = index.tostr()
                vast[index].HashedId          = "Hashed" + index.tostr()
                index = index + 1
            end if
         next
        
         if vast[0] = invalid then return this.m.isYes
         vast[0].Column                 = 0
         vast[0].Render                 = "player" 
         vast[0].NoRemote               = true
         vast[0].ScreenBeforeEachVideo  = true 
         vast[0].Forever                = false
         vast[0].NoCallBeforeEachVideo  = true
          
         this.m.ScreenVideo(vast)
      End Function
      
      this.dsResolvedUrl            = dsResolvedUrl
      dsSetup(this)
      
      return this.m.isAds
   End Function  
   
   
   m.AdVastTrackingEvent        = Function(content, events)
      if content.trackingEvents = invalid then return invalid
      trackingEvents            = content.trackingEvents
      
      Print "-tracking"
      for each trackingEvent in trackingEvents
          if trackingEvent.time = events.GetIndex()
              result        = true
              timeout       = 3000
              timer         = CreateObject("roTimespan")
              timer.Mark()
              port          = CreateObject("roMessagePort")
              xfer          = CreateObject("roURLTransfer")
              xfer.SetPort(port)
              xfer.SetURL(trackingEvent.url)
              if xfer.AsyncGetToString()
                event       = wait(timeout, port)
                if event    = invalid
                  xfer.AsyncCancel()
                  result    = false
                end if
              end if
          end if    
      next
      
      return result   
   End Function



  m.RoTubeURLDecode = Function(str As String) As String
      m.RotubeStrReplace(str,"+"," ") ' backward compatibility
      if not m.DoesExist("encodeProxyUrl") then m.encodeProxyUrl = CreateObject("roUrlTransfer")
      
      return m.encodeProxyUrl.Unescape(str)
  End function

  m.RotubeStrReplace = Function(baseStr As String, oldSub As String, newSub As String) As String
      newstr = ""
      i = 1
      while i <= Len(basestr)
          x = Instr(i, basestr, oldsub)
          if x = 0 then
              newstr = newstr + Mid(basestr, i)
              exit while
          endif
          if x > i then
              newStr = newstr + Mid(basestr, i, x-i)
              i = x
          endif

          newStr = newStr + newsub
          i = i + Len(oldsub)
      end while
      return newStr
  End Function


  ' YoutubeFormat - Credits to toasterdesigns.net (Thanks man!)
  m.YoutubeFormats = Function(results As String) As Object
      print "Okay, this is a YouTube format"
      roRegex             = CreateObject("roRegex", "(?:|&"+CHR(34)+")url_encoded_fmt_stream_map=([^(&|\$)]+)", "")
      videoFormatsMatches = roRegex.Match(results)
      if videoFormatsMatches[0]<>invalid then
          videoFormats = videoFormatsMatches[1]
      else
          return invalid
      end if

      sep1 = CreateObject("roRegex", "%2C", "")
      sep2 = CreateObject("roRegex", "%26", "")
      sep3 = CreateObject("roRegex", "%3D", "")

      videoURL          = CreateObject("roAssociativeArray")
      videoFormatsGroup = sep1.Split(videoFormats)
      for each videoFormat in videoFormatsGroup
          videoFormatsElem = sep2.Split(videoFormat)
          videoFormatsPair = CreateObject("roAssociativeArray")
          for each elem in videoFormatsElem
              pair = sep3.Split(elem)
              if pair.Count() = 2 then
                  videoFormatsPair[pair[0]] = pair[1]
              end if
          end for

          if videoFormatsPair["url"]<>invalid then 
              r1  = CreateObject("roRegex", "\\\/", ""):r2=CreateObject("roRegex", "\\u0026", "")
              url = m.RoTubeURLDecode(m.RoTubeURLDecode(videoFormatsPair["url"]))
              r1.ReplaceAll(url, "/"):r2.ReplaceAll(url, "&")
          end if
          if videoFormatsPair["itag"]<>invalid then
              itag = videoFormatsPair["itag"]
          end if
          if videoFormatsPair["sig"]<>invalid then 
              sig = videoFormatsPair["sig"]
              url = url + "&signature=" + sig
          end if

          if Instr(0, LCase(url), "http") = 1 then 
              videoURL[itag] = url
          end if
      end for

      qualityOrder    = ["18","22","37"]
      bitrates        = [1768,5250,7750]
      isHD            = [false,true,true]
      streamQualities = []
      for i = 0 to qualityOrder.Count()-1
          qn = qualityOrder[i]
         
          if videoURL[qn]<>invalid then
              streamQualities.Push({url: videoURL[qn], bitrate: bitrates[i], quality: isHD[i], contentid: qn})
          end if
      end for
      
      return streamQualities
  End Function

  m.IsYoutubeURL = Function(youtubeUrl) as Boolean
    roRegex = CreateObject("roRegex", "^(http(s)??\:\/\/)?(www\.)?((youtube.com)|(youtu.be))", "")
    isMatch = roRegex.IsMatch(youtubeUrl)
    print youtubeUrl
    print "Is this url is youtube? :"; isMatch
    return isMatch
  End Function

 '-----------------------------------------------------------------------------------------------------------------------------------
 '   6. Main Section
 '-----------------------------------------------------------------------------------------------------------------------------------    
  
   ' -- startup: we need to use another event so that it would not exit after the events -- 
   startup = m.ScreenLoader(this)
   startup.Show()
  
  ' set online
   m.SetOnline(m)
   while true
        m.ScreenFREE()
        
        wait(10,  CreateObject("roMessagePort"))
        if m.ScreenBeforeMain(this) = m.isNo then return m.isNo
                
        categorUrl = StrTrim(StrReplace( m.url.category, "{SCREEN_TYPE}", m.settings.screen.ScreenType))
        m.ScreenSelector(m.screenType, m.FeedsCategory(categorUrl))  
        exit while
   end while
   startup.Close()
       
End Function'Remove