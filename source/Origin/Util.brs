 '*
 '* These are my complete Roku BrightScript codes written for legacy players.
 '* Developer Christopher Natan
 '* Email chris.natan@gmail.com
 '*
Function DSUtil()
   
    m.Http               = Function(url as String) as Object
        this             = {}
        this.url         = StrTrim(url)
        this.m           = m
        
        DSCONFIG                   = Function() as Object
            config                 = {}
            config.EnableEncodings = true 
            config.Header          = "application/x-www-form-urlencoded"
            config.Certificate     = "common:/certs/ca-bundle.crt"
            config.Retry           = 10
            config.TimeOut         = 2500
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
           m.Prints(this.url)
           return this
        End Function
        
        DSHEADERS                    = Function(this)
            
            this.transfer.AddHeader("CN-08201979", this.m.device.serial)
            this.transfer.AddHeader("CN-02082015", this.m.manifest.access_key)
            'this.transfer.AddHeader("CN-06282012", this.headerParams) 
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
                print "-- retry : "; retry  
           end while
           if ValidStr(results) = "" then results = invalid
           
           return results
       End Function
       
       this.config      =  dsConfig()
       this.dsHeaders   =  dsHeaders
       this.dsTransfer  =  dsTransfer
       results          =  dsConnect(this)
       if results = invalid then Dialog(this.m.message["InvalidConnection"].title, this.m.message["InvalidConnection"].text)
       
       return results 
   End Function       
   
   m.EndGate            = Function()
        return invalid
   End Function
   
   m.Registry           = Function(name as String, value = "" as String) as String
       this             = {}
       this.KeyId       = "KEYID"
       this.ItemId      = "ITEMID" 
       if this[name]    = invalid then return invalid
       
       if value         = "" then  
            RegistryRead(name)
            return name
       else 
            return RegistryRead(name)
       end if
        
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
   
   m.Prints     = Function(stringToPrint as String)
        Print "-------------------------------------------"
        Print stringToPrint
        Print "-------------------------------------------"
   End Function

 End Function'Remove

