 '*
 '* These are my complete Roku BrightScript codes written for legacy players.
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
 
Function DSAd()
   
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
      this.item                    = this.m.settings.vasts
      this.m                       = m
               
      dsRESOLVEDURL                = Function(url) as String
         return url
      End Function
      
      dsGET                             = Function(this) as Integer
         item                           = this.item
         if item[0]                     = invalid then return this.m.isYes
         item[0].Column                 = 0
         item[0].Render                 = "player" 
         item[0].NoRemote               = true
         item[0].ScreenBeforeEachVideo  = true 
         item[0].Forever                = false
         item[0].NoCallBeforeEachVideo  = true
       
         for each item in this.item
            url       = this.dsRESOLVEDURL(item.Url)
            content   = this.nwmVast.GetPrerollFromURL(url)
         next
      End Function
      
      this.dsResolvedUrl            = dsResolvedUrl
      dsGet(this)
      
      return this.m.isYes
   End Function   
     
     
End Function'Remove

