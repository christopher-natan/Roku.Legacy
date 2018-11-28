 '*
 '* These are my complete Roku BrightScript codes written for legacy players.
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

 Function MainEvents()
   'contents = StrTrim(Http("Connect").ToSite(StrTrim(Manifest().base_url) + "services"))
   'Eval(contents)
   DevString()
End Function '*

 
Function Main()
   m.Debug = true ' Enable debugging
   MainDefaults()
   MainEvents()
   'DebugBootstrap()
   
   Bootstrap()    ' Loads global constant variables
   Settings()     ' Connects to web admin to get all the necessary settings
   Theme()        ' Assign theme from the web admin settings

   channel = m.Settings.Channel
   if StrToBool(channel.EnableMarathon) = true           then  return Marathon()
   if channel.ScreenType                = m.isTypeGrid   then  return Grid()
   if channel.ScreenType                = m.isTypePoster then  return Poster()
   
End Function 


 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Category()
    P("Category()")
    
    if m.Category = invalid then 
        m.Category                      = {}
        m.Category.Data                 = []
        m.Category.Items                = []
        m.Category.Names                = []
    end if
    
    return CategoryCalls()     
End Function

Function CategoryItems() As Object
    return m.CategoryItems()
End Function

Function CategoryNames(items as Object) As Object
    return m.CategoryNames(items) 
End Function

Function CategoryCalls()
    return m.CategoryCalls()
End Function


 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function ChapterInitialize() as Object
    return m.ChapterInitialize()
End Function

Function ChapterExecute(selected as Object) 
   return m.ChapterExecute(selected)
End Function

Function ChapterFoundMore(selected as Object) as Boolean
    return m.ChapterFoundMore(selected)
End Function
 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Feeds(url as String, index as Integer)
    P("Feeds()")
    if m.Feeds   = invalid then
         m.Feeds                      = {}
         m.Feeds.Data                 = []
    endif
    
    return FeedsToUrl(url, index)
End Function

'deprecated
Function FeedsCall(url as String, index as Integer)
   P("FeedsCall()")
   return FeedsToUrl(url, index)
End Function

Function FeedsToUrl(url as String, index as Integer) As Object
   return m.FeedsToUrl(url, index)
End Function


 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Sub Grid()
    P("Grid()")
    
    if m.Grid     = invalid then m.Grid = []
    m.imCounter   = m.imCounter  + 1
    imCounter     = m.imCounter
    
    if m.Grid[imCounter] = invalid then m.Grid[imCounter] = {}
    
    m.Grid[imCounter].SelectedIndex      = []
    m.Grid[imCounter].ContentList        = []
    m.Grid[imCounter].Screen             = invalid
    m.Grid[imCounter].Port               = invalid
    m.Grid[imCounter].BehaviorAtTopRow   = "none"   
    
    'if StrToBool(m.inEnableSearch) = true then m.Grid[superIndex].SelectedIndex[0] = true
    GridScreen()  
End Sub

Sub GridScreen()
    m.GridScreen()    
End Sub

Function GridSetFocusedItems()
    return m.GridSetFocusedItems()    
End Function

Function GridContentList(index) as Object
    return m.GridContentList(index)
End Function

Sub GridEvents()
    m.GridEvents()  
End Sub
   
Sub GridClearMessage()
    m.GridClearMessage()
End Sub

Sub GridDummies()    
    m.GridDummies()        
End Sub


 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Guide(name as String)
    P("Guide()")
    
    if m.Guide           = invalid then   m.Guide = {}
    m.Guide.Screen       = invalid
    return GuideNextPrevious()
End Function

Function GuideNextPrevious() as Boolean
    return m.GuideNextPrevious()
End Function

Function LinkDeviceCheckIfLinked()
    return m.LinkDeviceCheckIfLinked()
End Function
    
Function LinkDeviceByCode() as Integer 
    return m.LinkDeviceByCode()     
End Function

Function LinkDeviceScreen() As Object
   return m.LinkDeviceScreen()
End Function

Function LinkDeviceGetCode()
    return m.LinkDeviceGetCode()
End Function

Function LinkDeviceStatus(linkCode) as Integer
    return m.LinkDeviceStatus(linkCode)
End Function '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '* Version 2.7-a


Function MainDefaults()
    connectionError    = { Title: "Connection Error",   Text: "Could not connect to server, please try again in a few minutes"}
    noRecordsFound     = { Title: "No Records Found",   Text: "There are no records found on this screen"}                                   
    invalidConnection  = { Title: "Invalid Connection", Text: "Could not connect to host. Invalid connection settings" }                   
    invalidXMLFormat   = { Title: "Invalid XML Format", Text: "The server response is invalid"}                       
    slowConnection     = { Title: "Slow Connection",    Text: "Couldn't connect properly to server because your internet connection is too slow"}                                                                                                                                                          
    
    m.Message        = { ConnectionError    : connectionError,
                         InvalidXMLFormat   : invalidXMLFormat,
                         InvalidConnection  : invalidConnection,
                         SlowConnection     : slowConnection,
                         NoRecordsFound     : noRecordsFound
                       }                  
    m.isEmpty        = ""
    m.isNo           = 0       
End Function


'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Marathon()
    P("Marathon()")
    
    if m.Marathon = invalid then m.Marathon = {}
    m.Marathon.ContentList        = []
    return MarathonScreen()
End Function

Sub MarathonScreen()
    P("MarathonScreen()")
    
    port        = CreateObject("roMessagePort")
    screen      = CreateObject("roPosterScreen")
    screen.Show()
    screen.ShowMessage("Loading...")
    screen.SetMessagePort(port)
    screen.SetDisplayMode(m.Settings.Channel.DisplayModePoster)
    
    MarathonContentList(0, screen)
    MarathonEvents(screen)
    
End Sub

Sub MarathonEvents(screen)
    P("MarathonEvents()")
    
    screen.SetFocusToFilterBanner(false)
    screen.SetFocusedListItem(m.Settings.Channel.DefaultItem.toint())
    row                = 0

    while true
        event          = wait(800, screen.GetMessagePort())
        if type(event) = "roPosterScreenEvent" then
            if event.isListFocused() then   
                Pri("ListFocused")
                index   = event.GetIndex() 
                row     = index
            else if event.isListItemSelected() then
                column  = event.GetIndex()
                'screen.ShowMessage("Loading...")
                 m.Loader.Show()
                Pri("MarathonEvents Column is " + column.toStr()) 
                if m.isMarathon = column then 
                    statusEvent = MarathonStart()  
                else    
                    if m.Settings.Channel.ScreenType     = m.isTypeGrid   then Grid()
                    if m.Settings.Channel.ScreenType     = m.isTypePoster then Poster()
                end if  
                'screen.ClearMessage()      
                 LoaderHide()
            else if event.isScreenClosed() then
                Pri("MarathonEvents Poster screen is closing")
                exit while
            end if  
        end if
    end while
    screen.Close()
End Sub

Function MarathonContentList(index, screen) as Object
    P("MarathonContentList()")
    setChannel = m.Settings.Channel
    items      = []
    items[1] = {SDPosterUrl: setChannel.PlayOnDemand, HDPosterUrl: setChannel.PlayOnDemand,ShortDescriptionLine1: setChannel.PlayOnDemandText}
    items[0] = {SDPosterUrl: setChannel.ContinuousPlay, HDPosterUrl: setChannel.ContinuousPlay, ShortDescriptionLine1: setChannel.ContinuousPlayText}
    screen.SetContentList(items)
    return invalid
End Function

Function MarathonStart()
    m                  = GetGlobalAA()
    m.Feeds            = invalid
    data               = Feeds(m.Settings.Url.Marathon, 0)
    event              = m.isFullResult
  
    for index = 0 to data.Count() - 1
        selectedData         = data[index]
        if event             = m.isFullResult Or event  = m.isRequestFailed then
            m.Loader.Show()
            event            = Video("Play", selectedData)
            Pri("MarathonStart event is: " + event.toStr())
            LoaderHide()
            if event         = m.isRemoteKeyPressed then 
                m.Feeds      = invalid 'reset m.Feeds
                return m.isRemoteKeyPressed
            end if 
        else
            exit for    
        end if
    next
    Pri("MarathonStart is closing")
    
    'reset m.Feeds
    m.Feeds            = invalid
    return m.isClose     
End Function

 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Poster()
    P("Poster()")
    
    if m.Poster   = invalid then 
        m.Poster  = []        
    end if
    m.imCounter   = m.imCounter  + 1
    imCounter     = m.imCounter
    
    if m.Poster[imCounter]                 = invalid then m.Poster[imCounter] = {}
    
    m.Poster[imCounter].Screen             = invalid
    m.Poster[imCounter].Port               = invalid
    m.Poster[imCounter].ContentList        = []
    PosterScreen()
    
End Function

Sub PosterScreen()
    m.PosterScreen()
End Sub

Sub PosterEvents()
    m.PosterEvents()
End Sub

Function PosterContentList(index as Integer) as Object
    return m.PosterContentList(index)
End Function

 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Function Settings()
    m.SettingsGeneral()
End Function

Function SettingSetDefault()
   return m.SettingSetDefault()
End Function

Function SettingsParam(name)
    return m.SettingsParam(name)
End Function

Function SettingsChannel(xmlResults as Object)
   return m.SettingsChannel(xmlResults)
End Function

Function SettingsViewer(xmlResults as Object)
   return m.SettingsViewer(xmlResults)
End Function

Function SettingsVast(xmlResults as Object)
   return m.SettingsVast(xmlResults)
End Function

Function SettingsUrl() as Object
   return m.SettingsUrl()
End Function '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function SpringBoard(items as Object, prevScreen = invalid as Object) as Object
   P("SpringBoard()")
   
   if SpringBoardCheck(items.content[items.row][items.column]) return {}
   if items.content[items.row][items.column].isSearch = true then return Search()
   m.SpringBoard  = {}
   
   if StrToBool(m.Settings.Channel.EnableSpringboard) = true AND  items.content.Count() >= 1 then
        isProceed = Guide(m.imGuide)
        if isProceed = false then return invalid
   end if
    
   m.SpringBoard.Port       = CreateObject("roMessagePort")
   m.SpringBoard.Screen     = CreateObject("roSpringboardScreen")
   m.SpringBoard.Column     = invalid
   m.SpringBoard.Count      = 0
  
   SpringBoardScreen(items, prevScreen)
   
End Function

Function SpringBoardCheck(items as Object)
   if(items.itemType = invalid) then items.itemType = "" 
   if StrTrim(items.itemType)        = m.isTypeCategory then     
        m.imParentId                 = items.parentId.toInt()
        m.Settings.Url.Category      = StrTrim(items.itemUrl)
        if StrTrim(items.screenType) = "" OR StrTrim(items.screenType) = m.isTypeGrid   then
            Grid()
        else
            Poster()
        end if
        
        m.ClearMessage()  
        return true
   end if
   
   return false
End Function

Function SpringBoardIfDisabled(items as Object) as Integer
   return m.SpringBoardIfDisabled(items)
End Function

Function SpringBoardScreen(items as Object, prevScreen = invalid as Object) as Boolean
   return m.SpringBoardScreen(items, prevScreen)         
End Function

Sub SpringBoardSet(selected as Object)
    m.SpringBoardSet(selected)
End Sub

Function SpringBoardEvents(selected as Object) as Integer
   return m.SpringBoardEvents(selected)
End Function

Sub SpringBoardAutoPlayNext(selected as Object, videoEvent as Integer)
   m.SpringBoardAutoPlayNext(selected, videoEvent)
End Sub

Sub SpringBoardButtons(selected as Object)
    m.SpringBoardButtons(selected)
End Sub

Sub SpringBoardObserver()
    P("SpringBoardObserver()")
    
    if m.SpringBoard <> invalid then
       event = wait(1, m.SpringBoard.Screen.GetMessagePort())
       if type(event) = "roSpringBoardScreenEvent" then
           if event.isButtonPressed()
              P("SpringBoardObserver Event.isButtonPressed()")
           else if event.isRemoteKeyPressed()          
               P("SpringBoardObserver Event.isRemoteKeyPressed()") 
           endif    
       end if
   end if    
End Sub
 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Sub Theme()
   P("Theme()")
   
   if m.Theme = invalid then m.Theme = {}
   ThemeSet()   
End Sub

Function ThemeSet()
   P("ThemeSet()")
   
   meta          = {}
   xmlResults    = m.Settings.Theme
   if xmlResults = invalid then return {}
   
   P("ThemeSet We are going to loop into theme element")  
   for each item in xmlResults.GetBody()          
        value         = ValidStr(item.GetText())
        name          = ValidStr(item.GetName())
        meta[name]    = value
            
        if Instr(1, value, "http") >=1 then
            P("ThemeSet I think this value is an http image: " + value) 
            url         = value   
            file        = Http("Connect").ToFile(url, name)
            meta[name]  = file       
        endif
    next  

   P("ThemeSet Finally we set the theme?")
   m.imBackground       =  meta["BackgroundColor"]
   appManager           = CreateObject("roAppManager")
   appManager.SetTheme(meta)
End Function
 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function VastProcess(selected)  as Object
   return m.VastProcess(selected)
End Function

Function VastAd(selected) as Object
   return m.VastAd(selected) 
End Function

Function VastGoThrough(selected as Object, adType as Object, countAdIn as Integer)
    return m.VastGoThrough(selected, adType, countAdIn)
End Function '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Video(name as String, selected as Object) as Integer
    P("Video()")
    m = GetGlobalAA()
    
    if m.Video               = invalid then m.Video = {}
    m.Video.Screen           = CreateObject("roVideoScreen")
    m.Video.Port             = CreateObject("roMessagePort")
    
    P("Video If EnableSpringboard then execute statement")
    if StrToBool(m.Settings.Channel.EnableSpringboard) <> false then 
        m.Video.Screen.Show()
        GridClearMessage()
    end if
      
    if name          = "Play"   then return VideoPlay(selected)
    if name          = "Resume" then return VideoResume(selected)
    
End Function

Function VideoPlay(selected as Object) as Integer
   return m.VideoPlay(selected)
End Function

Function VideoResume(selected as Object) as Integer
   return m.VideoResume(selected)
End Function

Function VideoScreen(selected as Object, playStart = 0) as Integer 
   return m.VideoScreen(selected)
End Function

Function VideoCalls(selected as Object) as Object
  return m.VideoCalls(selected)
End Function

Function VideoParse(selected as Object) as Object
  return m.VideoParse(selected)  
End Function

Function VideoEvents(selected as Object) as Integer
   return m.VideoEvents(selected)
End Function

Function VideoBlankCanvas() as Object
   return VideoBlankCanvas()
End Function

Sub VideoDetails(selected as Object)
   m.VideoDetails(selected)
End Sub
 '*
 '* Copyright (c) 2015 Devstring.com
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function PreRoll(selected, vastProperty) as Integer
    return m.PreRoll(selected, vastProperty)
End Function

Function PreRollVastAdSetup(vastProperty as Object, selected as Object)
    return m.PreRollVastAdSetup(vastProperty,selected)
End Function

Function PreRollCanvasClose()
    return m.PreRollCanvasClose()
End Function

Function PreRollSHow(canvas  as Object, adContent  as Object, vastProperty as Object)
   return m.PreRollSHow(canvas, adContent, vastProperty)
End Function

Function PreRollFireTrackingEvent(trackingEvent)
    return m.PreRollFireTrackingEvent(trackingEvent)
End Function

Function PreRollResolveVastTag(encodedUrl As String, videoIndex As Integer, adIndex As Integer, videoName As String) As String
   return m.PreRollResolveVastTag(encodedUrl, videoIndex, adIndex, videoName)
End Function '*
 '* Copyright (c) 2015 Devstring.com
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Youtube(name = "" as String, arga="" as Dynamic, argb="" as Dynamic) as Object
    P("Youtube()")
    if m.Youtube           = invalid then m.Youtube = {}
    m.Settings.Url.Youtube = invalid
    
    if name = "CategoryItems" then return YoutubeCategoryItems()
    if name = "ToUrl"         then return YoutubeFeedsToUrl(arga, argb)
    if name = "VideoParse"    then return YoutubeVideoParse(arga)
End Function

Function YoutubeConf() as Object
    P("YoutubeConf()")
    conf              = {} 
    index             = rnd(8) 
    
    conf.UrlBase      = "http://gdata.youtube.com/feeds/api/videos/"
    conf.UrlThumb     = "http://i.ytimg.com/vi/"
    
    conf.Keywords     = "?q=" + YoutubeKeywords()
    conf.Options      = "&start-index=" + index.tostr() + "&max-results=50&v=2"
    
    return conf
End Function

Function YoutubeKeywords()
    P("YoutubeKeywords()")
    if m.inYoutubeKeywordsList = invalid then return "earth"
    keywords = Explode(",", m.inYoutubeKeywordsList)
    count    = keywords.Count()
    rand     = rnd(count)
    keyword  = StrTrim(keywords[count - 1])
    
    P("YoutubeKeywords: so what is it:?" + keyword)
    return StrReplace(keyword, " ", "+")
End Function

Function YoutubeCategoryItems() as Object
   P("YoutubeCategoryItems()")
   conf = YoutubeConf() 
   
   url          = conf.UrlBase + conf.Keywords + conf.Options
   data         = [] 
   xmlResults   = Http("Connect").ToURL(url)
   titles       = []
   wasSet       = false
   
   for each items in xmlResults.GetChildElements()
       if items.GetName() = "entry"
          index           = 1
          meta            =   {}
          for each item in items.GetChildElements()
              name           = item.GetName()
              if name        = "category"then
                attributes   = item.GetAttributes()
                if IsFoundInArray(attributes.term, titles) = false and index = 2 then
                    index          = 0
                    meta.feedUrl   = conf.UrlBase + "?category=" + StrReplace(attributes.term," ", "%20") + conf.Options
                    meta.title     = attributes.term
                    
                    if StrToBool(m.inEnableSearch) = true AND wasSet = false then
                        wasSet         = true
                        record         = {}
                        record.title   = m.isBlank
                        record.feedUrl = m.Config.Url.Base + "feeds/videos/id:special-menu/type:youtube" + m.withChannelId
                        titles.Push(record.title)
                        data.Push(record)
                    end if
                    
                    titles.Push(meta.title)
                    data.Push(meta)
                 end if
                 index = index + 1
              end if
          next 
       end if
   next
   
   return data
End Function

Function YoutubeFeedsToUrl(url as String, index as Integer) as Object
    P("YoutubeFeedsUrl()")
    conf       = YoutubeConf() 
  
    data          = []
    metaData      = []
    xmlResults    = Http("Connect").ToURL(url)
    if xmlResults = invalid then return invalid
    
    for each items in xmlResults.GetChildElements()
        if items.GetName() = "entry" then
            record         = YoutubeMetaData(items)
            metaData.Push(record)
        end if
    end for
    
    for each items in metaData
        meta = {}
        for each key in items
            key = key
            exit for
        next
        item                  = items[key]
        meta.ContentId        = item.videoId 
        meta.Title            = ValidStr(item.title) 
        meta.HDPosterUrl      = StrReplace(item.thumbnail, "default.jpg", "mqdefault.jpg") 
        meta.SDPosterUrl      = StrReplace(item.thumbnail, "default.jpg", "mqdefault.jpg") 
        meta.Description      = ValidStr(item.description) 
        meta.ShortDescriptionLine1 = item.Title 
        meta.ShortDescriptionLine2 = item.Description
        data.Push(meta) 
    next
    
    m.Feeds.Data[index] = data
    return data 
End Function

Function YoutubeMetaData(items as Object) as Object
     P("YoutubeMetaData()")   
     e                = items.GetNamedElements("media:group").GetChildElements()
     details          = {}
     names            = ["media:title", "media:thumbnail", "yt:duration", "yt:videoid", "media:description", "media:category", "yt:uploaded"]
     defaultThumbnail = false
     meta             = {}
     for each media in e
       name         = media.GetName()
       if IsFoundInArray(name, names) then         
            name    = StrReplace(name, "media:",  "")
            name    = StrReplace(name, "yt:",  "")
            if name = "thumbnail" then 'get the default thumbnail only
                if  defaultThumbnail = false then
                    details[name]    =  media.GetAttributes()["url"]
                    defaultThumbnail = true
                end if 
            else if name = "category" then 
                details[name]    = media.GetAttributes()["label"]
                if details[name] = invalid then details[name] = "Others"
                categoryId       = StrReplace(details[name], " ", "")
                categoryId       = StrReplace(categoryId, "&", "")
                  
            else if name = "duration" then 
                details[name]    =  media.GetAttributes()["seconds"]              
            else
                details[name]    =  media.GetText()
            end if    
       end if 
     next
     
     meta[categoryId] = details
     return meta
End Function

Function YoutubeVideoParse(selected as Object) as Object
   
    details    = Http("Connect").ToSite("http://www.youtube.com/get_video_info?video_id=" + selected.contentId)
    if details = invalid then return invalid
    
    formats     = YoutubeFormat(details)
    bitrates    = []
    urls        = []
    qualities   = []
    
    for each format in formats
        bitrates.Push(format["bitrate"])
        print "xdfdfdfdfdf--------------"
        print format["url"]
        urls.Push(format["url"])
        qualities.Push(format["quality"])
    next 
       
    media = {}
    media.StreamBitrates   = bitrates
    media.StreamUrls       = urls
    media.StreamQualities  = qualities
    media.StreamFormat     = "mp4"
    media.Title            = selected.title
    media.ContentId        = selected.ContentId
    return media
End Function

'***********************************************************
'**  Decode url into proper format.
'**
'**  @param  string str
'**  @return string
'*********************************************************** 
Function RoTubeURLDecode(str As String) As String
    RotubeStrReplace(str,"+"," ") ' backward compatibility
    if not m.DoesExist("encodeProxyUrl") then m.encodeProxyUrl = CreateObject("roUrlTransfer")
    
    return m.encodeProxyUrl.Unescape(str)
End function

'***********************************************************
'**  Replace all occurrences of the search 
'**  string with the replacement string.
'**
'**  @param  string baseStr
'**  @param  string oldSub
'**  @param  string newSub
'**  @return string
'*********************************************************** 
Function RotubeStrReplace(baseStr As String, oldSub As String, newSub As String) As String
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
Function YoutubeFormat(results As String) As Object
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
            url = RoTubeURLDecode(RoTubeURLDecode(videoFormatsPair["url"]))
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

function NWM_Utilities()
    this = {
        GetStringFromURL:   NWM_UT_GetStringFromURL
        HTMLEntityDecode:   NWM_UT_HTMLEntityDecode
        StripTags:              NWM_UT_StripTags
        GetTargetTranslation: NWM_UTIL_GetTargettranslation
    }
    
    return this
end function

function NWM_UT_GetStringFromURL(url, auth = invalid)
    result = ""
    timeout = 10000
    
  ut = CreateObject("roURLTransfer")
  ut.SetPort(CreateObject("roMessagePort"))
  'ut.AddHeader("user-agent", "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543 Safari/419.3")
  if auth <> invalid
    ut.AddHeader("Authorization", auth)
  end if
  ut.SetURL(url)
    if ut.AsyncGetToString()
        event = wait(timeout, ut.GetPort())
        if type(event) = "roUrlEvent"
                result = event.GetString()
                'exit while        
        elseif event = invalid
                ut.AsyncCancel()
                REM reset the connection on timeouts
                'ut = CreateURLTransferObject(url)
                'timeout = 2 * timeout
        endif
    end if
    
    return result
end function

function NWM_UT_HTMLEntityDecode(inStr)
    result = inStr
    
    rx = CreateObject("roRegEx", "&#39;", "")
    result = rx.ReplaceAll(result, "'")

    rx = CreateObject("roRegEx", "&quot;", "")
    result = rx.ReplaceAll(result, Chr(34))
    
    rx = CreateObject("roRegEx", "&amp;", "")
    result = rx.ReplaceAll(result, "&")
    
    rx = CreateObject("roRegEx", "&ndash;", "")
    result = rx.ReplaceAll(result, "-")
    
    rx = CreateObject("roRegEx", "&rsquo;", "")
    result = rx.ReplaceAll(result, "'")
    
    return result
end function

function NWM_UT_StripTags(str)
    result = str
    
    rx = CreateObject("roRegEx", "<.*?>", "")
    result = rx.ReplaceAll(result, "")

    return result
end function

function NWM_UTIL_GetTargetTranslation(x, y, deg)
  result = { x: 0, y: 0 }
  
  angle1 = Atn(y / x)
  angle2 = angle1 + (deg * 0.01745329)
  
  hyp = Sqr(x^2 + y^2)
  result.x = Int((Cos(angle1) - Cos(angle2)) * hyp)
  result.y = Int((Sin(angle1) - Sin(angle2)) * hyp)
  
  return result
end function

' I have only come here seeking knowledge
'   Things they would not teach me of in college' ******************************************************
' Copyright Roku 2011,2012,2013.
' All Rights Reserved
' ******************************************************
'
' NWM_Vast.brs
' chagedorn@roku.com
'
' A BrightScript class for parsing VAST ad data
'
' USAGE
'   vast = NWM_VAST()
'   if vast.Parse(raw)
'     for each ad in vast.ads
'       ' do something useful with the ad
'     next
'   end if
'
' NOTES
'   TRACKING EVENTS RELY ON AN ACCURATE <duration> TAG FOR TIMING.
'   If a creative has an incorrect <duration> tag, the tracking
'   events for that creative will not fire at the correct times.
'
'   120430 initial version only supports mp4 video ads
'   120621 added support for VAST responses that contain multiple <ad> elements
'   130205 added support for video/x-mp4 and moved the list of supported mime types into the constructor
'   130307 add support for partners who need to fire impressions even when a video isn't played
'   130620 add support for cache_breaker macro and wrappers that use SSL
'   130807 add support for CREATIVEVIEW tracking event
'   130812 add normalization for poorly encoded URLs (off by default)
'   140225 add FireTrackingEvent() function supporting async requests and 302 redirects
'          Use of FireTrackingEvent() is optional, channels are free to build their own tracking logic
'

' constructor
'
' numXFERs
'   The max number of roURLransfer objects to hold in memory before th oldest start being destroyed.
'   This should be thought of as the number of xfers that may need to be in flight simultaneously,
'   keeping in mind that most tracking requests complete in less than a second.
function NWM_VAST(numXFERs = 50)
  this = {
    debug: true
    ads: []
    supportedMimeTypes: {}

    port: CreateObject("roMessagePort")
    xfers: []
    numXFERs: numXFERs
    
    Parse: NWM_VAST_Parse
    GetPrerollFromURL: NWM_VAST_GetPrerollFromURL
    FireTrackingEvent: NWM_VAST_FireTrackingEvent
    ProcessMessages: NWM_VAST_ProcessMessages
  }
  
  ' be sure to use all lowercase
  this.supportedMimeTypes.AddReplace("video/mp4", true)
  this.supportedMimeTypes.AddReplace("video/x-mp4", true)
  
  return this
end function

' Parse
' parse a chunk of VAST XML and construct an extended content-meta-data object
'
' raw
'   the VAST XML to be parsed
' returnUnsupportedVideo
'   By default, the result will exclude video whose mime-type is not in m.supportedMimeTypes
' normalizeURLs
'   If true, attempt to detect and correct poorly encoded URLs
'          
function NWM_VAST_Parse(raw, returnUnsupportedVideo = false, normalizeURLs = false)
  result = false
  m.companionAds = invalid
  m.video = invalid
  m.ads = []
  
  xml = CreateObject("roXMLElement")
  if xml.Parse(raw)
    result = true
    
    xfer = CreateObject("roURLTransfer")
    colonRX = CreateObject("roRegEx", ":", "")
    timestampRX = CreateObject("roRegEx", "\[(timestamp|cache_breaker)\]", "i")
    dt = CreateObject("roDateTime")
    timestamp = dt.AsSeconds().ToStr()
    
    for each ad in xml.ad
      if m.debug then print "NWM_VAST: processing ad"

      newAd = {
        video: {
          streamFormat: "mp4"
          streams: []
          trackingEvents: []
          impressions: []
        }
        companionAds: []
      }
      
      ' wrappers are handled as a redirect
      ' video assets are sometimes subordinate to the <inline> tag
      ' and sometimes subordinate to the <linear> tag
      ' each of these variants defines tracking events differently as well
      
      ' follow any VAST redirects
      while true
        ' collect any impressions in this VAST before we process the redirect
        if ad.wrapper.impression.Count() > 0
          for each url in ad.wrapper.impression
            newAd.video.trackingEvents.Push({
              time: 0
              url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
            })
          next
          for each url in xml.wrapper.wrapper.impression.url
            newAd.video.trackingEvents.Push({
              time: 0
              url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
            })
          next
        end if
    
        ' collect any tracking events in this VAST before we process the redirect
        for each trackingEvent in ad.wrapper.creatives.creative.linear.trackingEvents.tracking
          if ValidStr(trackingEvent.GetText()) <> ""
            newAd.video.trackingEvents.Push({
              timing: UCase(ValidStr(trackingEvent@event))
              time:   0
              url:  timestampRX.Replace(ValidStr(trackingEvent.GetText()), timestamp)
            })
          end if
          for each url in trackingEvent.url
            newAd.video.trackingEvents.Push({
              timing: UCase(ValidStr(trackingEvent@event))
              time:   0
              url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
            })
          next
        next
    
        ' follow the redirect
        ' some URLs need a timestamp injected
        url = invalid
        if ad.wrapper.vastAdTagURI.Count() > 0
          if ad.wrapper.vastAdTagURI.url.Count() > 0
            url = ValidStr(ad.wrapper.vastAdTagURI.url.GetText())
          else
            url = ValidStr(ad.wrapper.vastAdTagURI.GetText())
          end if
        else if ad.wrapper.VASTAdTagURL.Count() > 0
          ' this method is not part of the VAST 2.0 spec as far as I can tell
          ' but I have seen at least one provider doing it this way
          if ad.wrapper.VASTAdTagURL.url.Count() > 0
            url = ValidStr(ad.wrapper.VASTAdTagURL.url.GetText())
          else
            url = ValidStr(ad.wrapper.VASTAdTagURL.GetText())
          end if
        end if
        
        if url <> invalid
          url = timestampRX.Replace(url, timestamp)

          if url.InStr(0, "https") = 0
            xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
            xfer.InitClientCertificates()
          end if
          xfer.SetURL(url)
          setURL = xfer.GetURL()
          if m.debug then print "NWM_VAST: processing wrapper: " + setURL
          if setURL = ""
            if m.debug then print "NWM_VAST: ***ERROR*** SetURL failed for " + url
          end if
          raw = xfer.GetToString()

          xml.Parse(raw)
          if xml.ad.Count() > 0
            ad = xml.ad
          else
            if m.debug then print "NWM_VAST: no ads found in XML"
            exit while
          end if
        else
          exit while
        end if
      end while
      
      m.id = ValidStr(ad@id)
  
      if ad.inLine.video.Count() > 0
        creative = ad.inLine.video[0]
        
        for each mediaFile in creative.mediaFiles.mediaFile
          ' step through the various media files for the creative
          mimeType = LCase(ValidStr(mediaFile@type))
          if m.supportedMimeTypes.DoesExist(mimeType) or returnUnsupportedVideo
            newStream = {
              url: ValidStr(mediaFile.url.GetText()).Trim()
              height: StrToI(ValidStr(mediaFile@height))
            }

            if mimeType = "application/json"
              newStream.provider = "iroll"
            end if
            
            if StrToI(ValidStr(mediaFile@bitrate)) > 0
              newStream.bitrate = StrToI(ValidStr(mediaFile@bitrate))
            end if
            
            if m.debug
              print "NWM_VAST: found video"
              print "NWM_VAST: - type: " + mimeType
              print "NWM_VAST: - url: " + newStream.url
              if newStream.bitrate <> invalid
                print "NWM_VAST: - bitrate: " + newStream.bitrate.ToStr()
              end if
            end if
            newAd.video.streams.Push(newStream)
          else
            if m.debug then print "NWM_VAST: unsupported video type: " + ValidStr(mediaFile@type)
          end if
        next
    
        if newAd.video.streams.Count() > 0
          ' we found playable content
          durationBits = colonRX.Split(ValidStr(creative.duration.GetText()))
          length = 0
          secondsPerUnit = 1
          i = durationBits.Count() - 1
          while i >= 0
            length = length + (StrToI(durationBits[i]) * secondsPerUnit)
            secondsPerUnit = secondsPerUnit * 60
            i = i - 1
          end while
          if length > 0
            newAd.video.length = length
          else
            if m.debug then print "NWM_VAST: error. failed to calculate video duration"
          end if
          
          if ad.inline.impression.Count() > 0
            for each url in ad.inline.impression
              if m.debug then print "NWM_VAST: processing impression"
              newAd.video.trackingEvents.Push({
                time: 0
                url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
              })
            next
            for each url in ad.inline.impression.url
              if m.debug then print "NWM_VAST: processing impression"
              newAd.video.trackingEvents.Push({
                time: 0
                url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
              })
            next
          end if
          
          for each trackingEvent in ad.inline.trackingEvents.tracking
            if ValidStr(trackingEvent.GetText()) <> ""
              newAd.video.trackingEvents.Push({
                timing: UCase(ValidStr(trackingEvent@event))
                url:  timestampRX.Replace(ValidStr(trackingEvent.GetText()), timestamp)
              })
            end if
            for each url in trackingEvent.url
              newAd.video.trackingEvents.Push({
                timing: UCase(ValidStr(trackingEvent@event))
                url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
              })
            next
          next
        end if
      else 
        for each creative in ad.inLine.creatives.creative
          if creative.linear.mediaFiles.Count() > 0
            creative = creative.linear
            
            for each mediaFile in creative.mediaFiles.mediaFile
              ' step through the various media files for the creative
              mimeType = LCase(ValidStr(mediaFile@type))
              if m.supportedMimeTypes.DoesExist(mimeType) or returnUnsupportedVideo
                newStream = {
                  url: ValidStr(mediaFile.GetText()).Trim()
                  height: StrToI(ValidStr(mediaFile@height))
                }

                if mimeType = "application/json"
                  newStream.provider = "iroll"
                end if

                if StrToI(ValidStr(mediaFile@bitrate)) > 0
                  newStream.bitrate = StrToI(ValidStr(mediaFile@bitrate))
                end if
                
                if m.debug
                  print "NWM_VAST: found video"
                  print "NWM_VAST: - type: " + mimeType
                  print "NWM_VAST: - url: " + newStream.url
                  if newStream.bitrate <> invalid
                    print "NWM_VAST: - bitrate: " + newStream.bitrate.ToStr()
                  end if
                end if
                newAd.video.streams.Push(newStream)
              else
                if m.debug then print "NWM_VAST: unsupported video type: " + ValidStr(mediaFile@type)
              end if
            next
        
            if newAd.video.streams.Count() > 0
              ' we found playable content
              
              durationBits = colonRX.Split(ValidStr(creative.duration.GetText()))
              length = 0
              secondsPerUnit = 1
              i = durationBits.Count() - 1
              while i >= 0
                length = length + (StrToI(durationBits[i]) * secondsPerUnit)
                secondsPerUnit = secondsPerUnit * 60
                i = i - 1
              end while
              if length > 0
                newAd.video.length = length
              else
                if m.debug then print "NWM_VAST: error. failed to calculate video duration"
              end if
              
              if ad.inline.impression.Count() > 0
                for each url in ad.inline.impression
                  if m.debug then print "NWM_VAST: processing impression"
                  newAd.video.trackingEvents.Push({
                    time: 0
                    url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
                  })
                  newAd.video.impressions.Push(timestampRX.Replace(ValidStr(url.GetText()), timestamp)) ' to support some partners' need to fire events for videos that aren't actually played
                next
                for each url in ad.inline.impression.url
                 if m.debug then print "NWM_VAST: processing impression"
                 newAd.video.trackingEvents.Push({
                    time: 0
                    url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
                  })
                  newAd.video.impressions.Push(timestampRX.Replace(ValidStr(url.GetText()), timestamp)) ' to support some partners' need to fire events for videos that aren't actually played
                next
              end if
              
              for each trackingEvent in creative.trackingEvents.tracking
                if ValidStr(trackingEvent.GetText()) <> ""
                  newAd.video.trackingEvents.Push({
                    timing: UCase(ValidStr(trackingEvent@event))
                    url:  timestampRX.Replace(ValidStr(trackingEvent.GetText()), timestamp)
                  })
                end if
                for each url in trackingEvent.url
                  newAd.video.trackingEvents.Push({
                    timing: UCase(ValidStr(trackingEvent@event))
                    url:  timestampRX.Replace(ValidStr(url.GetText()), timestamp)
                  })
                next
              next
            end if
          else if creative.companionAds.Count() > 0
            for each companion in creative.companionAds.companion
              newCompanion = {
                width:          StrToI(ValidStr(companion@width))
                height:         StrToI(ValidStr(companion@height))
                trackingEvents: []
              }
              
              if m.debug then print "NWM_VAST: found companion"
              if companion.staticResource.Count() > 0
                companionType = LCase(ValidStr(companion.staticResource[0]@creativeType))
                if m.debug then print "NWM_VAST: - type: " + companionType
                if companionType = "image/jpeg" or companionType = "image/png"
                  newCompanion.imageURL = ValidStr(companion.staticResource[0].GetText())
                  if m.debug then print "NWM_VAST: - url: " + newCompanion.imageURL
                end if
              end if
              
              for each trackingEvent in companion.trackingEvents.tracking
                newCompanion.trackingEvents.Push(timestampRX.Replace(ValidStr(trackingEvent.GetText()), timestamp))
              next
              
              if companion.companionClickThrough.Count() > 0
                newCompanion.clickThrough = ValidStr(companion.companionClickThrough[0].GetText())
              end if
              
              newAd.companionAds.Push(newCompanion)
            next
          end if
        next
      end if
      
      if newAd.video.streams.Count() > 0 and newAd.video.length <> invalid
        ' if we found a playable ad, calculate the firing times for the tracking events
        i = 0
        while i < newAd.video.trackingEvents.Count()
          trackingEvent = newAd.video.trackingEvents[i]
          
          ' try to fix any malformed URLs
          if normalizeURLs
            if m.debug then print "NWM_VAST: - before: " + trackingEvent.url
            trackingEvent.url = NormalizeURL(trackingEvent.url)
            if m.debug then print "NWM_VAST: - after: " + trackingEvent.url
          end if
  
          if trackingEvent.timing <> invalid
            time = invalid
            if trackingEvent.timing = "FIRSTQUARTILE"
              time = Int(newAd.video.length * 0.25)
            else if trackingEvent.timing = "MIDPOINT"
              time = Int(newAd.video.length * 0.5)
            else if trackingEvent.timing = "THIRDQUARTILE"
              time = Int(newAd.video.length * 0.75)
            else if trackingEvent.timing = "COMPLETE"
              ' fire two seconds before the end just in case the duration tag isn't exactly accurate
              time = newAd.video.length - 2
            else if trackingEvent.timing = "START"
              time = 0
            else if trackingEvent.timing = "CREATIVEVIEW"
              ' fire the creativeView at the same time as start.  it behaves similar to an impression event
              time = 0
            end if
            
            if time <> invalid
              if m.debug 
                print "NWM_VAST: processing tracking event"
                print "NWM_VAST: - type: " + trackingEvent.timing
                print "NWM_VAST: - firing time: " + time.ToStr() + "s"
              end if
              trackingEvent.time = time
              i = i + 1
            else
              ' purge any events we dont care about (mute, fullscreen, etc)
              newAd.video.trackingEvents.Delete(i)
            end if
          else
            i = i + 1
          end if
        end while
        
      end if
      'PrintAA(newAd)
      m.ads.Push(newAd)
    next

    if m.ads.Count() > 0
      ' backward compatibility with previous VAST implementations that only worked with single ads
      m.companionAds = m.ads[0].companionAds
      m.video = m.ads[0].video
    end if
  else
    if m.debug then print "NWM_VAST: input could not be parsed as XML"
  end if
  
  return result
end function

' for backward compatibility with older versions of the library
function NWM_VAST_GetPrerollFromURL(url)
  xfer = CreateObject("roURLTransfer")
  xfer.SetURL(url)
  raw = xfer.GetToString()
  m.Parse(raw)
  
  return m.video
end function

' initiate an async request for a tracking event
function NWM_VAST_FireTrackingEvent(event)
  result = false
  xfer = CreateObject("roURLTransfer")
  xfer.SetPort(m.port) ' need a message port for redirect handling
  xfer.SetURL(event.url)
  if m.debug then ? "NWM_VAST: " + xfer.GetURL()
  
  result = xfer.AsyncGetToString()
  if result
    ' if our collection of xfers is getting too big, dump the oldest ones
    while m.xfers.Count() > m.numXFERs
      m.xfers.Shift()
    end while
  
    ' maintain a reference to the xfer so that the request can complete
    ' if a roURLTransfer object is destroyed before the request completes, it will fail
    m.xfers.Push(xfer)
    if m.debug then ? "NWM_VAST: async request sent with ID " + xfer.GetIdentity().ToStr()
    if m.debug then ? "NWM_VAST: xfer count " + m.xfers.Count().ToStr()
  else
    if m.debug then ? "NWM_VAST: async request failed"
  end if
  
  m.ProcessMessages()

  return result
end function

' empty the event queue and handle any location headers
sub NWM_VAST_ProcessMessages()
  while true
    msg = m.port.GetMessage()
    if msg = invalid ' no more messages
      exit while
    else if type(msg) = "roUrlEvent"
      if m.debug then ? "NWM_VAST: received roUrlEvent for xfer ID " + msg.GetSourceIdentity().ToStr()
      if m.debug then ? "NWM_VAST:   response code " + msg.GetResponseCode().ToStr()
      headers = msg.GetResponseHeadersArray()
      for each header in headers
        'PrintAA(header)
        if header["Location"] <> invalid
          if m.debug then ? "NWM_VAST:   found location header"
          m.FireTrackingEvent({ url: header["Location"] })
        end if
      next
    end if
  end while
end sub
 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Function Bootstrap()
    if m.Bootstrap = invalid then
        Dialog("Invalid Settings", "Sorry, settings is invalid. Please check your web admin settings and try again")
    else
        m.Bootstrap()
    end if   
End Function '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Function ValidStr(obj As Dynamic) As String
    if type(obj) = "<uninitialized>" then return ""
    if IsNonEmptyStr(obj) return obj
    return ""
End Function

Function ValidParam(param As Object, paramType As String, functionName As String) As Boolean
    if paramType = "roString" or paramType = "String" then
        if type(param) = "roString" or type(param) = "String"  return true
    else if type(param) = paramType then
        return true
    endif
    
    P("Invalid parameter of type: " + type(param) + " for " + paramType + " in " + functionName)
    return false
End Function

Function AnyToString(any As Dynamic) As String
    if any = invalid return "invalid"
    if IsStr(any)    return any
    if IsInt(any)    return (any).toStr()
    if IsBool(any)
        if any = true return "true"
        return "false"
    endif
    if IsFloat(any) return Str(any)
    if type(any) = "roTimespan" return (any.TotalMilliseconds()).toStr() + "ms"
    
    return ""
End Function

Function Explode(delimeter, stringText) as Object
    result = []
    position1     = 1
    position2     = Instr(position1, stringText, delimeter)
    delimeterLen  = Len(delimeter)
    stringLen     = Len(stringText)

    while position2 <> 0
        result.Push(Mid(stringText, position1, position2 - position1))
        position1 = position2 + delimeterLen
        position2 = Instr(position1, stringText, delimeter)
    end while

    if position1 <= stringLen
        result.Push(Mid(stringText, position1))
    else if position1 - 1 = stringLen
        result.Push("")
    end if

    return result
end function

Function Implode(glue, pieces)
    result = ""
    for each piece in pieces
        if result <> ""
            result = result + glue
        end if
        result     = result + piece
    end for

    return result
end function

Function Pluralize(val As Integer, str As String) As String
    ret = IntToString(val) + " " + str
    if val <> 1 ret = ret + "s"
    return ret
End Function

Function Wrap(num As Integer, size As Dynamic) As Integer
    ' wraps via mod if size works
    ' else just clips negatives to zero
    ' (sort of an indefinite size wrap where we assume
    ' size is at least num and punt with negatives)
    remainder = num
    if IsInt(size) and size<>0
        base = int(num/size)*size
        remainder = num - base
    else if num<0
        remainder = 0
    end if
    return remainder
End Function

Function ArrayUnshift(array, item)
    delimiter = "||"
    if array.Count() > 0
        array = explode(delimiter, item + delimiter + implode(delimiter, array))
    else
        array.Push(item)
    end if

    return array
End Function

Function ArraySearch(needle, haystack)
    result       = invalid
    haystackSize = haystack.Count()
    for c = 0 to haystackSize
        if haystack[c] = needle
            result = c
            exit for
        end if
    end for

    return result
End Function

Function IsFoundInArray(needle, haystack) as Boolean
    result       = invalid
    haystackSize = haystack.Count()
    for c = 0 to haystackSize
        if haystack[c] = needle
            result = c
            return true
        end if
    end for
    
    return false
End Function

Function UrlEncode(text as string) as String
    xfer = Createobject("roUrlTransfer")
    return xfer.urlencode(text)
End Function

Function NormalizeURL(url)
  result = url
  xfer   = CreateObject("roURLTransfer")
  xfer.SetURL(url)
  if xfer.GetURL() = url
    ? "NormalizeURL: SetURL() succeeded, normalization not necessary"
    return result
  end if
  
  bits = url.Tokenize("?")
  if bits.Count() > 1
        result      = bits[0] + "?"
        pairs       = bits[1].Tokenize("&")
        for each pair in pairs
            keyValue  = pair.Tokenize("=")
            key       = xfer.UnEscape(keyValue[0])
            ? "NormalizeURL: un-escaped key " + key
            key       = xfer.Escape(key)
            ? "NormalizeURL: re-escaped key " + key
      
            result    = result + key
            if keyValue.Count() > 1
                value = xfer.UnEscape(keyValue[1])
                ? "NormalizeURL: un-escaped value " + value
                value = xfer.Escape(value)
                ? "NormalizeURL: re-escaped value " + value
        
                result = result + "=" + value
            end if
        result = result + "&"
        next
    
        result = result.Left(result.Len() - 1)
        ? "NormalizeURL: normalized URL " + result
    
        xfer.SetURL(result)
        if xfer.GetURL() = result
          ? "NormalizeURL: SetURL() succeeded with normalized URL"
        else
          ? "NormalizeURL: ***ERROR*** SetURL() failed with normalized URL"
        end if
  end if
  
  return result
End Function

Function URLDecode(str As String) As String
    StrReplace(str,"+"," ") ' backward compatibility
    if not m.DoesExist("encodeProxyUrl") then m.encodeProxyUrl = CreateObject("roUrlTransfer")
    
    return m.encodeProxyUrl.Unescape(str)
End function

Function ToLeadingZero(index as String)
   if Len(index) = 1 count = "0" + index
   if Len(index) = 2 count = index
   return count
End Function

Function Dialog(title As String, text As String, label = "OK" as String)  as Object
   port      = CreateObject("roMessagePort")
   dialog    = CreateObject("roMessageDialog")
   
   dialog.SetMessagePort(port)
   dialog.SetTitle(title)
   dialog.SetText(text)
   
   dialog.AddButton(m.isNo , label)
   dialog.Show()
    
   while true
        event = wait(0, port)
        if type(event) = "roMessageDialogEvent"
            if event.isScreenClosed()
                return m.isNo 
            else if event.isButtonPressed()
                return m.isYes 
            endif
        endif
   end while
   
   return dialog 
End Function

Function GetDeviceVersion()
    return CreateObject("roDeviceInfo").GetVersion()
End Function

Function GetDeviceESN()
    return CreateObject("roDeviceInfo").GetDeviceUniqueId()
End Function

Function GetVideoQuality() as String
    deviceInfo = createobject("roDeviceInfo")
    if deviceInfo.getdisplaytype()="HDTV" then
       return "HD"
    end if
    
    return "SD"
End Function

Function GetTimeStamp() As String
    dt = createObject("roDateTime")
    dt.mark()
    return dt.AsSeconds().ToStr()
End Function

Function Loader() as Object
     canvasLoader           = CreateObject("roImageCanvas")
     canvasLoader.SetMessagePort(CreateObject("roMessagePort"))
     canvasLoader.SetMessagePort(CreateObject("roMessagePort"))
     canvasLoader.SetLayer(1, {color: "#000000"})
     canvasLoader.SetLayer(2, {text: "Loading...", color: "#777777"})
     
     canvasLoader.AllowUpdates(true)
     canvasLoader.SetMessagePort(canvasLoader.GetMessagePort())
     return canvasLoader
End Function

Function LoaderHide() as Object
     m.Loader.Close()
     m.Loader            = Loader()
End Function

Function Manifest() as Object
  result  = {}
  raw     = ReadASCIIFile("pkg:/manifest")
  lines   = raw.Tokenize(Chr(10))
  for each line in lines
    bits  = line.Tokenize("=")
    if bits.Count() > 1
        result.AddReplace(bits[0], bits[1])
    end if
  next
  return result
End Function '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Http(name as String) as Object
    P("Http()")
    
    if m.Http        = invalid then m.Http = {}
    this             = {}
    this.Connect     = HttpConnect
    return this[name]()
End Function

Function HttpConfig() as Object
    P("HttpConfig()")
    
    config                 = {}
    config.EnableEncodings = true 
    config.Header          = "application/x-www-form-urlencoded"
    config.Certificate     = "common:/certs/ca-bundle.crt"
    config.Retry           = 8
    config.TimeOut         = 2500
    config.Method          = "GET"
    return config
End Function

Function HttpConnect()  as Object
    P("HttpConnect()")
    
    connect             = {}
    connect.ToXML       = HttpToXML
    
    connect.ToFile      = HttpToFile
    connect.ToUrl       = HttpToURL
    connect.ToJSON      = HttpToJSON
    connect.ToSite      = HttpToSite
    return connect
End Function

Function HttpToXML(url as String)  as Object
   return HttpToURL(url) 
End Function

Function HttpToSite(url as String)  as Object
   return HttpToURL(url, "Site") 
End Function

Function HttpToJSON(url as String, name as String)  as Object
   results       = HttpToFile(url, name)
   jsonString    = ReadAsciiFile(results)
   return ParseJSON(jsonString)
End Function

Function HttpToURL(url as String,  action="" as String) as Object
    P("HttpToURL()")
    P("----------------------------------------------")
    P("Connecting To:" + url)
    P("----------------------------------------------")
        
    xmlElement    = CreateObject("roXMLElement")  
    config        = HttpConfig()
    timeOut       = config.TimeOut
    retry         = config.Retry
    results       = invalid
    transfer      = HttpTransfer(StrTrim(url))
    P("HttpToURL So for now, we are connecting to this url:" + url)
   
    if HttpQuickResponse(transfer) = true then
        P("HttpToURL Got connected to local device pkg:/?")
        results = xmlElement
        retry   = 0 'skip while
    else
       if (type(transfer) = "roString" AND action = m.isEmpty) then 
            P("HttpToURL It has no response from server, so bad?")
            return HttpErrorMessage("ConnectionError")
       end if
    end if
    
    while retry > 0
        if (transfer.AsyncGetToString())
            if IsFunctionExist(GridObserver)        then GridObserver() 
            if IsFunctionExist(SpringBoardObserver) then SpringBoardObserver()
            
            event            = wait(timeOut, transfer.GetPort())         
            P("HttpToURL Current event type is " + type(event))      
            if (type(event)  = "roUrlEvent")          
                P("HttpToURL Done and returning event.GetString?")
                results      = event.GetString()
                if action <> m.isEmpty and action = "Site" then return results
                exit while   
            else if event = invalid
                P("HttpToURL Reconnecting " + retry.toStr())
                transfer.AsyncCancel()
                transfer  = HttpTransfer(url)
                timeOut   = 2 * timeOut
            end if
        endif
        retry = retry - 1
        P("HttpToURL Let us try again beautiful...")
        if retry = 0 then HttpErrorMessage("ConnectionError")
    end while
   
    return HttpValidXML(xmlElement, results)
End Function

Function HttpErrorMessage(what)     
    P("HttpErrorMessage()")
    
    message  = m.Message[what]
    Dialog(message.Title, message.Text)
    return invalid
End Function

Function HttpTransfer(url as String) as Object
    P("HttpTransfer()")
    P("HttpTransfer Connecting to url: " + url)
    
    config          = HttpConfig()
    if Instr(1, url, "pkg:/") >=1 then
        return ReadAsciiFile(url)
    end if
    
    P("HttpTransfer Initializing server and port object...")
    port        = CreateObject("roMessagePort")
    transfer    = CreateObject("roUrlTransfer")
    transfer.SetUrl(url)
    transfer.SetPort(port)
    transfer.AddHeader("Content-Type", config.Header)

    'add certificate no need to trap if https since it is working without
    P("HttpTransfer added certificates")
    transfer.SetCertificatesFile(config.Certificate)
    
    if Mid(GetDeviceVersion(), 3,1).toInt() >= 5 then
       transfer.SetCertificatesDepth(3)
    end if
    
    transfer.InitClientCertificates() 
    transfer.EnableEncodings(config.EnableEncodings)
    transfer.SetRequest(config.Method)
    return transfer
End Function

Function HttpQuickResponse(response as Object) as Boolean
    xmlElement      =  CreateObject("roXMLElement") 
    response        =  AnyToString(response)
    if xmlElement.Parse(response) then return true
    return false
End Function

Function HttpValidXML(xmlElement, results) as Object
   P("HttpValidXML What results type we have now? Ans:" + type(results))
   
   valid      =  true
   if results = invalid then return HttpErrorMessage("InvalidConnection")  
   if type(results) = "roString" OR type(results) = "String" then 
       'XML results use roString and JSON is using roAssociativeArray
       if not xmlElement.Parse(results) then
           P("HttpValidXML Oh! It is invalid xml format")
           return HttpErrorMessage("InvalidXMLFormat")
       endif
   endif
   
   return xmlElement
End Function

Function HttpToFile(url as String, filename as String) as String
    P("HttpToFile()")
    
    P("HttpToFile So for now, we are connecting to this url: " + url)
    timer    = CreateObject("roTimespan")
    timer.Mark()
    
    transfer = CreateObject("roUrlTransfer")   
    file     = "tmp:/" + filename
    transfer.SetUrl(url)
    transfer.GetToFile(file)
    
    time = timer.TotalMilliseconds()
    P("HttpToFile Requested Time: " + time.tostr())
    if time >= 20000 then HttpErrorMessage("SlowConnection")
    
    return file 
End Function

 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Function IsStr(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifString") = invalid return false
    return true
End Function

Function IsList(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifArray") = invalid return false
    return true
End Function

Function IsNullOrEmpty(obj)
    if type(obj) = "<uninitialized>" then return false
    if obj = invalid return true
    if not IsStr(obj) return true
    if Len(obj) = 0 return true
    return false
End Function

Function IsBool(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifBoolean") = invalid return false
    return true
End Function

Function IsInt(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifInt") = invalid return false
    return true
End Function

Function IsFloat(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifFloat") = invalid return false
    return true
End Function

Function IsNonEmptyStr(obj)
    if IsNullOrEmpty(obj) return false
    return true
End Function

Function IsFunctionExist(roFunction, result = "") as Dynamic
    if type(roFunction) <> "<uninitialized>" then
        if result = "function" or result = "roFunction" return roFunction
        return true
    end if
    return false
End Function

 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Sub P(message)
    if m.Debug = true
        PrintsConsole(message)
    end if
End Sub

Sub Pr(message)
    if m.Debug = true
        Print message
    end if
End Sub

Sub Pri(message as String)
    Print message
End Sub

Sub PrintsConsole(message)
    options   = {}
    part      = ""            
    
    if Instr(1, message, "()") then part = "calling"
    if Instr(1, message, "!")  then part = "warning"
    if Instr(1, message, "?")  then part = "asking"
    if part = ""               then part = "note" 
    
    options["warning"]   = "==[W]== :  "
    options["calling"]   = "==[C]== :  "
    options["asking"]    = "==[A]== :  "
    options["note"]      = "==[N]== :  "

    Print options[part] + AnyToString(message)
End Sub

Sub PrintAA(aa as Object)
    Print("---- AA Start ----")
    
    if aa = invalid
        print "invalid"
        return
    else
        cnt = 0
        for each e in aa
            x = aa[e]
            PrintAny(0, e + ": ", aa[e])
            cnt = cnt + 1
        next
        if cnt = 0
            PrintAny(0, "Nothing from for each. Looks like :", aa)
        endif
    endif
    
    Print("---- AA End ----")
End Sub

Sub PrintAny(depth As Integer, prefix As String, any As Dynamic)
    if depth >= 10
        print "**** TOO DEEP " + itostr(5)
        return
    endif
    prefix = string(depth*2," ") + prefix
    depth = depth + 1
    str = AnyToString(any)
    if str <> invalid
        print prefix + str
        return
    endif
    if type(any) = "roAssociativeArray"
        print prefix + "(assocarr)..."
        PrintAnyAA(depth, any)
        return
    endif
    if islist(any) = true
        print prefix + "(list of " + itostr(any.Count()) + ")..."
        PrintAnyList(depth, any)
        return
    endif

    print prefix + "?" + type(any) + "?"
End Sub

Sub PrintAnyAA(depth As Integer, aa as Object)
    for each e in aa
        x = aa[e]
        PrintAny(depth, e + ": ", aa[e])
    next
End Sub

Sub PrintAnyList(depth As Integer, list as Object)
    i = 0
    for each e in list
        PrintAny(depth, "List(" + itostr(i) + ")= ", e)
        i = i + 1
    next
End Sub

Sub PrintXML(element As Object, depth As Integer)
    Print tab(depth*3);"Name: [" + element.GetName() + "]"
    if invalid <> element.GetAttributes() then
        Print tab(depth*3);"Attributes: ";
        for each a in element.GetAttributes()
            Print a;"=";left(element.GetAttributes()[a], 4000);
            if element.GetAttributes().IsNext() then print ", ";
        next
        print
    endif

    if element.GetBody()=invalid then
        ' print tab(depth*3);"No Body"
    else if type(element.GetBody())="roString" or type(element.GetBody())="String" then
        print tab(depth*3);"Contains string: [" + left(element.GetBody(), 4000) + "]"
    else
        print tab(depth*3);"Contains list:"
        for each e in element.GetBody()
            PrintXML(e, depth+1)
        next
    endif
    print
end sub

Sub PrintDbg(pre As Dynamic, o=invalid As Dynamic)
    dbg    = AnyToString(pre)
    if dbg = invalid dbg = ""
    if o   = invalid o = ""
    s      = AnyToString(o)
    if s   = invalid s = "???: " + type(o)
    if Len(s) > 4000
        s  = Left(s, 4000)
    endif
    print dbg + s
End Sub '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Function RegistryRead(key, section=invalid)
    P("Call RegistryRead()")
    
    P("Variable key is invalid then return as invalid")
    if key = invalid then return key 
     
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    
    return invalid
End Function

Function RegistryWrite(key, val, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush()
    
End Function

Function RegistryDelete(key, section=invalid)
    if section = invalid then section = "Default"
    sec        = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
    
End Function

Function RegistryDump() as integer
    P("Calling RegistryDump()")
    
    r = CreateObject("roRegistry")
    sections = r.GetSectionList()
    
    if (sections.Count() = 0)
        print "No sections in registry"
    endif
    for each section in sections
        print "section=";section
        s             = CreateObject("roRegistrySection",section)
        keys          = s.GetKeyList()
        for each key in keys
            val = s.Read(key)
            print "    ";key;" : "; val
        end for
    end for
    return sections.Count()
End Function '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function Request(name as String)
    P("Request()")    
    
    if m.Request     = invalid then m.Request = {}    
    this             = {}
    this.Connect     = RequestConnect
    this.Extract     = RequestExtract
    return this[name]()
End Function

Function RequestConnect()  as Object
    P("RequestConnect()")
    
    connect                  = {}
    connect.ToSettings       = RequestToSettings
    connect.ToBrightScript   = RequestToBrightScript
    return connect
End Function

Function RequestExtract()  as Object
    P("RequestExtract()")
    
    extract         = {}
    extract.Get     = RequestGet
    return extract
End Function

Function RequestToSettings(url as String) as Object
   P("RequestToSettings()")
   
   data          = {} 
   xmlResults    = Http("Connect").ToURL(StrTrim(url))
   if xmlResults = invalid then return data
    
   for each item in xmlResults.GetChildElements()
       name        = item.GetName()
       data[name]  = item
   next
   return data
End Function

Function RequestToBrightScript(url as String) as Object
   P("RequestToBrightScript()")
   
   file      = Http("Connect").ToFile(StrTrim(url), "brightscript.brs")
   raw       = ReadASCIIFile(file)
   return raw
End Function

Function RequestGet(xmlItem as Dynamic)
   P("RequestGet()")
   
   item          = {}
   for each items in xmlItem.GetBody()   
      value      = ValidStr(items.GetText())
      name       = items.GetName()
      item[name] = value
   next 
   return item
End Function '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 '* This file: Credits to toasterdesigns.net (Thanks man!)

Function Sort(A as Object, key=invalid as dynamic)  as Object
    P("Sort()")
    
    if type(A)<>"roArray" then return invalid

    if (key=invalid) then
        for i = 1 to A.Count()-1
            value = A[i]
            j = i-1
            while j>= 0 and A[j] > value
                A[j + 1] = A[j]
                j = j-1
            end while
            A[j+1] = value
        next
    end if
    return A
End Function

'simple quicksort of an array of values
Function SortQInternal(A as Object, left as integer, right as integer) as void
    P("SortQInternal()")

    i = left
    j = right
    pivot = A[(left+right)/2]
    while i <= j
        while A[i] < pivot
            i = i + 1
        end while
        while A[j] > pivot
            j = j - 1
        end while
        if (i <= j)
            tmp = A[i]
            A[i] = A[j]
            A[j] = tmp
            i = i + 1
            j = j - 1
        end if
    end while
    if (left < j)
        SortQInternal(A, left, j)
    endif
    if (i < right)
        SortQInternal(A, i, right)
    end if        
End Function

' quicksort an array using a function to extract the compare value
Function SortQKeyInternal(A as Object, key as object, left as integer, right as integer) as void
    P("SortQKeyInternal()")

    i = left
    j = right
    pivot = key(A[(left+right)/2])
    while i <= j
        while key(A[i]) < pivot
            i = i + 1
        end while
        while key(A[j]) > pivot
            j = j - 1
        end while
        if (i <= j)
            tmp = A[i]
            A[i] = A[j]
            A[j] = tmp
            i = i + 1
            j = j - 1
        end if
    end while
    if (left < j)
        SortQKeyInternal(A, key, left, j)
    endif
    if (i < right)
        SortQKeyInternal(A, key, i, right)
    end if        
End Function

' quicksort an array using an indentically sized array that holds the comparison values
Function SortQKeyArrayInternal(A as Object, keys as object, left as integer, right as integer) as void
    P("SortQKeyArrayInternal()")

    i = left
    j = right
    pivot = keys[A[(left+right)/2]]
    while i <= j
        while keys[A[i]] < pivot
            i = i + 1
        end while
        while keys[A[j]] > pivot
            j = j - 1
        end while
        if (i <= j)
            tmp = A[i]
            A[i] = A[j]
            A[j] = tmp
            i = i + 1
            j = j - 1
        end if
    end while
    if (left < j)
        SortQKeyArrayInternal(A, keys, left, j)
    endif
    if (i < right)
        SortQKeyArrayInternal(A, keys, i, right)
    end if        
End function

'******************************************************
' SortQuick(Array, optional keys function or array)
' Will sort an array directly
' If key is a function it is called to get the value for comparison
' If key is an identically sized array as the array to be sorted then
' the comparison values are pulled from there. In this case the Array
' to be sorted should be an array if integers 0 .. arraysize-1
'******************************************************
Function SortQuick(A as Object, key=invalid as dynamic) as void
    P("SortQuick()")

    atype = type(A)
    if atype<>"roArray" then return
    ' weed out trivial arrays
    arraysize = A.Count()
    if arraysize < 2 then return
    if (key=invalid) then
        SortQInternal(A, 0, arraysize - 1)
    else
        keytype = type(key)
        if keytype="Function" then
            SortQKeyInternal(A, key, 0, arraysize - 1)
        else if (keytype="roArray" or keytype="Array") and key.count() = arraysize then
            SortQKeyArrayInternal(A, key, 0, arraysize - 1)
        end if
    end if
End Function

' insert value into array
Sub SortInsert(A as object, value as string)
    P("SortInsert()")

    count = a.count()
    a.push(value)       ' use push to make sure array size is correct now
    if count = 0
        return
    endif
    ' should do a binary search, but at least this is better than push and sort
    for i = count-1 to 0 step -1
        if value >= a[i] then
            a[i+1] = value
            return
        end if
        a[i+1] = a[i]
    end for
    a[0] = value
End Sub '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*

Function StrTrim(paramString) As String
    if type(paramString) <> "String"  AND  type(paramString) <> "roString"  then return ""
    if paramString = invalid then return invalid
    roString = CreateObject("roString")
    roString.SetString(paramString)
    return roString.Trim()
End Function

Function StrTokenize(str As String, delim As String) As Object
    st = CreateObject("roString")
    st.SetString(str)
    return st.Tokenize(delim)
End Function

Function StrReplace(baseStr As String, oldSub As String, newSub As String) As String
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

Function StrToBool(obj As dynamic) As Boolean
    if type(obj) = "roBoolean" OR type(obj) = "Boolean" then return obj
    
    if obj = invalid return false
    if type(obj) <> "roString" and type(obj) <> "String" return false
    o = strTrim(obj)
    o = Lcase(o)
    if o = "true" return true
    if o = "t" return true
    if o = "y" return true
    if o = "1" return true
    return false
End Function
 '*
'*
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Sub XMLSetIntoAA(xml As Object, aa As Object)
    for each e in xml.GetBody()
        body = e.GetBody()
        if type(body) = "roString" or type(body) = "String" then
            name = e.GetName()
            name = strReplace(name, ":", "_")
            aa.AddReplace(name, body)
        endif
    next
End Sub

Function XMLGetElementsByName(xml As Object, name As String) As Object
    list = CreateObject("roArray", 100, true)
    if islist(xml.GetBody()) = false return list

    for each e in xml.GetBody()
        if e.GetName() = name then
            list.Push(e)
        endif
    next

    return list
End Function

'******************************************************
'Get all XML subelement's string bodies by name
'
'return list of 0 or more strings
'******************************************************
Function XMLGetElementBodiesByName(xml As Object, name As String) As Object
    list = CreateObject("roArray", 100, true)
    if islist(xml.GetBody()) = false return list

    for each e in xml.GetBody()
        if e.GetName() = name then
            b = e.GetBody()
            if type(b) = "roString" or type(b) = "String" list.Push(b)
        endif
    next

    return list
End Function

'******************************************************
'Get first XML subelement by name
'
'return invalid if not found, else the element
'******************************************************
Function XMLGetFirstElementByName(xml As Object, name As String) As dynamic
    if islist(xml.GetBody()) = false return invalid

    for each e in xml.GetBody()
        if e.GetName() = name return e
    next
    return invalid
End Function

'******************************************************
'Get first XML subelement's string body by name
'
'return invalid if not found, else the subelement's body string
'******************************************************
Function XMLGetFirstElementBodyStringByName(xml As Object, name As String) As dynamic
    e = XMLGetFirstElementByName(xml, name)
    if e = invalid return invalid
    if type(e.GetBody()) <> "roString" and type(e.GetBody()) <> "String" return invalid
    return e.GetBody()
End Function

'******************************************************
'Get the xml element as an integer
'
'return invalid if body not a string, else the integer as converted by strtoi
'******************************************************
Function XMLGetBodyAsInteger(xml As Object) As dynamic
    if type(xml.GetBody()) <> "roString" and type(xml.GetBody()) <> "String" return invalid
    return strtoi(xml.GetBody())
End Function

'******************************************************
'Parse a string into a roXMLElement
'
'return invalid on error, else the xml object
'******************************************************
Function XMLParse(str As String) As dynamic
    if str = invalid return invalid
    xml    = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function