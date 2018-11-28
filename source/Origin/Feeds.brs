 '*
 '* These are my complete Roku BrightScript codes written for legacy players.
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function DSFeeds()    
    
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
       
       for each item in results.items
           items.push(item)
       next 
              
       this.m.CacheSet(this, items) 
       return items
   End Function
   
   m.FeedsYoutube   = Function(this, start) as Object
        content     = this.content
        content[start].ContentId = content[start].ContentId
        details     = Http("Connect").ToSite("http://www.youtube.com/get_video_info?video_id=" + content[start].contentId)
        if details  = invalid then return invalid
        
        format      = YoutubeFormat(details)
        bitrates    = []
        urls        = []
        qualities   = []
        if format   = invalid then return invalid
        
        for each format in format
            bitrates.Push(format["bitrate"])
            urls.Push(format["url"])
            qualities.Push(format["quality"])
        next 
           
        media = {}
        media.StreamBitrates   = bitrates
        media.StreamUrls       = urls
        media.StreamQualities  = qualities
        media.StreamFormat     = "mp4"
        media.Title            = content[start].Title
        media.ContentId        = content[start].ContentId
        return media
   End Function 
   
   m.FeedsVimeo       = Function(this, start)
       content        = this.content
       item           = content[start]
       playStreamUrl  = StrTrim(StrReplace( this.m.settings.vimeo.PlayStream, "{VIDEOID}", item.MetaData))
       response       = this.m.Http(playStreamUrl)
       result         = ParseJson(response)
       
       if response              = invalid then return invalid
       if response              = "" then return invalid
       if result.request        = invalid then return invalid
       if result.request.files  = invalid then return invalid
       
       if result.request.files.h264 <> invalid then
           if result.request.files.h264.hd <> invalid then
               if result.request.files.h264.hd.url <> invalid then
                    item.StreamUrls      = [StrTrim(result.request.files.h264.hd.url)]
                    item.StreamBitrates  = [result.request.files.h264.hd.bitrate]        
                    
                    return item
               end if 
           end if 
            
           if result.request.files.h264.sd <> invalid then
               if result.request.files.h264.sd.url <> invalid then
                    item.StreamUrls      = [StrTrim(result.request.files.h264.sd.url)]
                    item.StreamBitrates  = [result.request.files.h264.sd.bitrate]        
                    
                    return item
               end if 
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
   
End Function'Remove