 '*
 '* These are my complete Roku BrightScript codes written for legacy players.
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function DSScreen()
      
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
            this.screen.SetBreadcrumbEnabled(StrToBool(m.settings.screen.SetGridBreadCrumbEnabled))
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
                 
                 if items = invalid    then items = this.dsNoContent()
                 if items.count() <= 0 then items = this.dsNoContent()
                 this.screen.SetContentList(index, items)
                 this.loaded[index] = true
                 this.content[index]= items
             next index
             
             return this
        End Function
        
        DSNOCONTENT        = Function() as Object 
            current        = []
            current[0]     = {title:"No Media Items", sdposterurl:"", hdposterurl:"", description:"This category has no media items."}    
            return current                
        End Function
        
        DSSHOW            = Function(this) as Object
            this.screen.show()
            this.screen.ShowMessage("Loading...")
            this.screen.SetFocusedListItem(1,3)
        End Function
        
        DSSETBREADCRUMB   = Function(this) as Object
            previous      = RegistryRead("BreadCrumbPrevious")
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
                    else if event.isScreenClosed()     then
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
        dsShow(this)
        dsPreLoadContent(this)
        
        is               = dsLoadContent(this, 0)
        if this.content.count() <=0 then
             this.screen.ShowMessage("No Media Items")
        end if
        this.loaded      = is.loaded
        
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
                displayMode = this.ListStyleSimple 
                listStyle   = this.DisplayModeSimple
                this.categories.titles = invalid
            end if
            
            this.screen.SetListDisplayMode(displayMode) 
            this.screen.SetListStyle(listStyle)

            if this.categories.titles <> invalid then
                this.screen.SetListNames(this.categories.titles)
            end if    
            this.screen.SetBreadcrumbEnabled(StrToBool(m.settings.screen.SetPosterBreadCrumbEnabled))
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
            previous      = RegistryRead("BreadCrumbPrevious")
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
            previous      = RegistryRead("BreadCrumbPrevious")
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
        dsShow(this)
        
        this.screenSelector = m.ScreenSelector
        is                  = dsLoadContent(this, 0)
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
        
            this.screen.SetMessagePort(this.port)
            this.screen.SetDescriptionStyle(m.settings.screen.DescriptionStyle) 
            this.screen.SetDisplayMode(m.settings.screen.DisplayModeSpringboard)
            this.screen.SetPosterStyle(m.settings.screen.SetPosterStyle)
            this.screen.AllowUpdates(true)
            this.screen.SetBreadcrumbEnabled(true)
            
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
            previous      = RegistryRead("BreadCrumbPrevious")
            this.screen.SetBreadcrumbText(previous, this.m.breadCrumb.current)
        End Function
        
        DSBUTTONS         = Function(this) as Object
            content       = this.content[this.column]
            this.screen.ClearButtons()
            
            if content.ItemId <> invalid then 
                itemId = content.ItemId
                if RegistryRead(itemId) <> invalid AND RegistryRead(itemId).toint() >= 1 then
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
                     RegistryWrite(itemId, "0")
                     this.content[0].column = this.column
                     m.ScreenSelector(this.m.isVideoScreen, this.content)              
                else if select   = this.m.isResumed 
                     itemId      = this.content[this.column].ItemId                          ' RESUME                    
                     if RegistryRead(itemId) <> invalid AND RegistryRead(itemId).toint() >= 1 then
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
        this.noremote   = false
        this.forever    = true
        this.isResumed  = false
        this.randomSeek = false
        this.timeStop   = 0
        this.m          = m
        
        if content[0].IsResumed <> invalid then  this.isResumed         = content[0].IsResumed 
        if content[0].Forever <> invalid then  this.forever             = content[0].Forever   
        if content[0].Render <> invalid then this.render                = content[0].Render
        if content[0].NoRemote <> invalid then this.noremote            = content[0].NoRemote
        if content[0].TimeStop <> invalid then this.timeStop            = content[0].TimeStop
        if content[0].RandomSeek <> invalid then this.randomSeek        = StrToBool(content[0].RandomSeek)
        
        if this.randomSeek = true then
            firstItem =  this.content[0]
            seconds   =  Rnd(8) * 1000
            RegistryWrite(firstItem.ItemId, seconds.toStr())
        end if

        DSVIDEO         = Function(this) as Object
            select      = {screen: CreateObject("roVideoScreen"), player: CreateObject("roVideoPlayer")}
            return select[this.render]
        End Function
        this.screen     = dsVideo(this)
   
        DSCLOSEDCAPTION = Function(this, content) as Object 
           contentId    = content.Id
           file         = "tmp:/" + contentId + ".srt"
           if content.Subtitle <> invalid then
                WriteAsciiFile(file, content.Subtitle)
           end if
           return "file://" + file
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
             if this.content[start].TypeId = this.isYouTube then
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
            if this.content[start].TypeId = this.isYouTube then
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
             
             return media
        End Function
        
        DSLOADCONTENTSCREEN          = Function(this, start = 0) as Object 
             content                               = this.content[start]
             ' streaming content into array 
             media                   = {}
             media.StreamUrls        = [content.StreamUrls]
             media.StreamBitrates    = [content.StreamBitrates]
             media.StreamQualities   = [content.StreamQualities]
             media.StreamFormat      = content.StreamFormat
             media.Title             = content.Title
             media                   = this.dsSelectProviderScreen(this, start, media)
             
             media.SubtitleUrl       = this.dsCloseCaption(this, content)
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
            if RegistryRead(itemId) <> invalid AND RegistryRead(itemId).toint() >= 1 then
                 miliseconds = RegistryRead(itemId).toint() * 1000
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
                         
                         ' set online
                         this.m.SetOnline(this.m)
                    
                         'write the position to registry for resume later
                         index    = event.GetIndex()
                         itemId   = this.content[this.column].ItemId
                         RegistryWrite(itemId, index.toStr())
                         
                         'if there is a video time stop then
                         if this.timeStop >= 1 then
                             current      = this.m.TimeLong()
                             if current.formatLong.toInt() > this.timeStop then 
                                this.dsCanvas.close()
                                return 0
                             end if   
                         end if
                    else if event.isStatusMessage()           then
                        Print "--" + event.GetMessage() + "--"
                        counter                   =  counter + 1
                        if event.GetMessage()     = "startup progress" AND isLoaded = false then 
                            
                            this.dsCanvas.ClearLayer(2)
                            this.dsCanvas.SetLayer(1, {Color: "#00000000", CompositionMode: "Source"})
                            this.dsCanvas.Show()
                            isLoaded = true
                            
                        else if event.GetMessage() =  "Unspecified or invalid track path/url." or event.GetMessage() = "HTTP status 404" then
                           
                            if this.noremote = false then 
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
                            this.dsCanvas.SetLayer(2, {url: spinner, TargetRect:{x:550, y:290}}) 
                            
                        end if
                        events    = 6
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
                    if event.isRemoteKeyPressed() and this.noremote = false then
                        index    = event.GetIndex() + 100
                        if index =  this.m.isUpKey  + 100 then
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
                        
                        if returned = this.m.isNo then exit while   
                    end if
                    
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
        
        this.dsCloseCaption     = dsClosedCaption
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
        this.wait               = 5000
        this.m                  = m
        this.sizes              = this.canvas .GetCanvasRect()
                       
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
           this.canvas.show()
           
           return this.canvas 
        End Function
         
        DSEVENTS              = Function(this) as Integer
            while(true)
               msg = wait(this.wait, this.canvas.GetMessagePort())
               if type(msg) = "roImageCanvasEvent" then
                   if (msg.isRemoteKeyPressed()) then
                   
                   else if (msg.isScreenClosed()) then
                      exit while
                   end if
               end if
               current            = this.m.TimeLong()
               for each items in this.content.items
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
                                RegistryWrite(itemId, str(withSeconds))
                                item[0].IsResumed = true
                           end if                        
                           
                           returned                       = this.m.ScreenVideo(item)
                           items.Played                   = true
                    end if
                next
           end while
           
           this.canvas.Close() 
        End Function
        
        dsProperties(this)
        dsEvents(this)
                
        return 0
    End Function
       
       
          
    m.ScreenREGISTRATION     = Function(item) as Integer
        this                 = {}
        this.m               = m
        this.port            = CreateObject("roMessagePort")
        this.screen          = CreateObject("roCodeRegistrationScreen")
        this.wait            = 100
        this.sleep           = 2000
        this.loader          = m.ScreenLoader(this)
        this.retryInterval   = 8
        this.retryDuration   = 200
        this.isExit          = false
        
        DSPROPERTIES    = Function(this) as Object
            intro       = "Please link your Roku Device by visiting"
            from        = "From your computer,"
            url         = this.m.settings.screen.RegistrationDefault
            
            if StrToBool(this.m.settings.screen.RegistrationEmbed)  then
                url     = this.m.settings.screen.RegistrationUrl
            end if
    
            this.screen.SetTitle("")
            this.screen.AddParagraph(intro)
            this.screen.AddFocalText(" ", "spacing-dense")
            this.screen.AddFocalText(from, "spacing-dense")
            this.screen.AddFocalText(url, "spacing-dense")
            this.screen.AddFocalText("and enter this code to activate:", "spacing-dense")
            this.screen.SetRegistrationCode("retrieving code...")
            this.screen.AddParagraph("This screen will automatically update as soon as your activation completes")
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
            statusUrl         = StrReplace(this.m.url.register, "{PARAM}", "getstatus/")
            results           = this.m.Http(statusUrl)
            results           = ParseJSON(results)
            if results.status = 0  then return false
            if results.status = 1 then
                'viewerId      = results.viewerId
                'RegistryWrite(m.manifest.access_key, viewerId)
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
            this.screen.SetTitle("Enter PIN to unlock this media item")
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
        
        DSSCREENREGISTRATION  = Function(this)
            returned          = this.m.isYes
            if m.settings.screen.RegistrationEnable = true AND m.settings.screen.RegistrationType = this.m.isBeforeVideoPlayed then
                returned      = m.ScreenRegistration(this)
            end if
            return returned
        End Function
        
        events                = dsScreenRegistration(this)
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
    
    
    
    m.ScreenBEFOREMAIN        = Function(item) as Integer
        this                  = {}
        this.m                = m
        
        DSSCREENREGISTRATION  = Function(this)
            returned          = this.m.isYes
            if this.m.settings.screen.RegistrationEnable = true AND this.m.settings.screen.RegistrationType = this.m.isBeforeMainScreen then
                returned      = this.m.ScreenRegistration(this)
            end if
            return returned
        End Function
      
        events = dsScreenRegistration(this)
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
                TargetRect:{x:550, y:290}
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
        
        'write the breadcrumb previous item
         RegistryWrite("BreadCrumbPrevious", item[column].BreadCrumb)
                
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
     
End Function'Remove