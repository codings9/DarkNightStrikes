#========================================================

#------------------STRIKE COMMANDLETS------------------

function RequestTicker { #START FUNCTION

    $Page = "https://etfdb.com/etf/<TICKER>/#holdings"
    $Page2 = "https://uk.finance.yahoo.com/quote/<TICKER>/holdings"
    $Page3 = "https://uk.finance.yahoo.com/quote/<TICKER>"
#    https://www.morningstar.co.uk/uk/etf/snapshot/snapshot.aspx?id=0P00014E81
#    https://markets.ft.com/data/etfs/tearsheet/holdings?s=ARKK

    $TICKER = read-host "Enter ticker to search "
    $TICKER = $TICKER.ToUpper()
    Set-Variable Ticker $TICKER -Scope Script

    $WebPage = $Page.replace("<TICKER>","$TICKER")
    $Page3 = $Page3.replace("<TICKER>","$TICKER")

    $TestPage = Invoke-WebRequest $WebPage -DisableKeepAlive -UseBasicParsing -Method Head -ErrorAction SilentlyContinue
#    https://petri.com/testing-uris-urls-powershell
    
    if ($TestPage -ne $null) {Set-Variable WWW "ETFDB" -Scope Script}

    if ($TestPage -eq $null) {
    
        $WebPage = $Page2.replace("<TICKER>","$TICKER")
        Set-Variable WWW "Yahoo" -Scope Script
        
    }

    Set-Variable WebPage $WebPage -Scope Script
    Set-Variable Page3 $Page3 -Scope Script

    #$WebPage

} #END FUNCTION

function SearchPrice { #START FUNCTION

    $DateTime3 = Get-Date -format "dd/MMM/yy @ HH:mm"

#    $Page3="https://finance.yahoo.com/quote/<TICKER>"
#    $Page3 = $Page3.replace("<TICKER>","$TICKER")
    $WebResponse = Invoke-WebRequest $Page3
    $content = $WebResponse.RawContent

    if ($matches -ne $null) { Clear-Variable matches }
    $TickerName = $content -match 'h1 class[\s\S]*?</h1>' | Out-Null
    $TickerName = $matches
    $TickerName = $TickerName | foreach{$_.values}
    $TickerName = $TickerName.replace("h1 class=`"D(ib) Fz(18px)`" data-reactid=`"7`">","")
    $TickerName = $TickerName.replace("</h1>","")
#    $TickerName

    if ($matches -ne $null) { Clear-Variable matches }
    $Price = $content -match '-4px[\s\S]*?</span><span' | Out-Null
    $Price = $matches
    $Price = $Price | foreach{$_.values}
    $Price = $Price.replace("-4px) D(ib)`" data-reactid=`"32`">","")
    $Price = $Price.replace("</span><span","")
#    $Price
    
    if ($matches -ne $null) { Clear-Variable matches }
    $Currency = $content -match 'Currency in [\s\S]*?</span>' | Out-Null
    $Currency = $matches
    $Currency = $Currency | foreach{$_.values}
    $Currency = $Currency.replace("Currency in ","")
    $Currency = $Currency.replace("</span>","")
#    $Currency

    if ($Currency -eq "GBp"){$Price = $Price/100 }

    if ($matches -ne $null) { Clear-Variable matches }
    $SearchTime = $content -match '>As of[\s\S]*?. Market open.' | Out-Null

    #write-host "SearchTime = $matches" -f white -b red

    if ($matches -ne $null) { #"hello"

        $SearchTime = $matches
        $SearchTime = $SearchTime | foreach{$_.values}
        $SearchTime = $SearchTime.replace(">As of  ","")
        $SearchTime = $SearchTime.replace(". Market open.","")

        $SearchTimeCode = "write-host -nonewline `"Market Time, `$SearchTime`" -f black -b green"

    }

    if ($matches -eq $null) { #"nope"
        
        $SearchTime = $content -match '>At close:[\s\S]*?</span>' | Out-Null
        $SearchTime = $matches
        $SearchTime = $SearchTime | foreach{$_.values}
        $SearchTime = $SearchTime.replace(">At close:  ","")
        $SearchTime = $SearchTime.replace("</span>","")

        $SearchTimeCode = "write-host -nonewline `"Market Closed, `$SearchTime`" -f white -b red"

    }

    write-host -nonewline "$TickerName | " -f cyan -b black
    write-host -nonewline "$Price $Currency | " -f yellow -b black
    Invoke-Expression $SearchTimeCode
    write-host " | Local Time, $DateTime3" -f magenta -b black

} #END FUNCTION

function StrikePrice { #START FUNCTION

    function 18MonthStrike_1 { #START FUNCTION

#        write-host "$CurrentPrice" -f green        
#        $CurrentPrice.GetType()

        $18MonCalc = ($TwoYearPerformance / 1.5)
#        $18MonCalc = "{0:N2}" -f $18MonCalc
#        write-host "$18MonCalc" -f yellow

        $18MonShave = ($18MonCalc * 0.9)
#        $18MonShave = "{0:N2}" -f $18MonShave
#        write-host "$18MonShave" -f green

        $18MonShave = [math]::Round($18MonShave,2)
#        write-host "$18MonShave" -f cyan
#        $18MonShave.GetType()

        $18StrikeP = $CurrentPrice + $18MonShave
#        write-host "$18StrikeP" -f cyan -b blue

        $18MonthNumbers = $18MonCalc, $18MonShave, $18StrikeP
        $18MonthCalc = "{0:N2}" -f $18MonthNumbers
        $18MonthShave = "{1:N2}" -f $18MonthNumbers
        $18StrikePrice = "{2:N2}" -f $18MonthNumbers

        $18StrikePrice = [System.Convert]::ToDecimal($18StrikePrice)

#        write-host "$18MonthCalc" -f darkgreen -b cyan
#        write-host "$18MonthShave" -f darkred -b cyan
#        write-host "$18StrikePrice" -f blue -b cyan
        
        Set-Variable 18MonthCalc $18MonthCalc -Scope Script
        Set-Variable 18MonthShave $18MonthShave -Scope Script
        Set-Variable 18StrikePrice $18StrikePrice -Scope Script

    } #END FUNCTION

    function 09MonthStrike_1 { #START FUNCTION

#        write-host "$CurrentPrice" -f green        
#        $CurrentPrice.GetType()

        $09MonCalc = ($OneYearPerformance * 0.75)
#        $09MonCalc = "{0:N2}" -f $09MonCalc
#        write-host "$09MonCalc" -f yellow

        $09MonShave = ($09MonCalc * 0.9)
#        $09MonShave = "{0:N2}" -f $09MonShave
#        write-host "$09MonShave" -f green

        $09MonShave = [math]::Round($09MonShave,2)
#        write-host "$09MonShave" -f cyan
#        $09MonShave.GetType()

        $09StrikeP = $CurrentPrice + $09MonShave
#        write-host "$09StrikeP" -f cyan -b blue

        $09MonthNumbers = $09MonCalc, $09MonShave, $09StrikeP
        $09MonthCalc = "{0:N2}" -f $09MonthNumbers
        $09MonthShave = "{1:N2}" -f $09MonthNumbers
        $09StrikePrice = "{2:N2}" -f $09MonthNumbers

#        write-host "$09MonthCalc" -f darkgreen -b cyan
#        write-host "$09MonthShave" -f darkred -b cyan
#        write-host "$09StrikePrice" -f blue -b cyan
        
        Set-Variable 09MonthCalc $09MonthCalc -Scope Script
        Set-Variable 09MonthShave $09MonthShave -Scope Script
        Set-Variable 09StrikePrice $09StrikeP -Scope Script

    } #END FUNCTION

    function 06MonthStrike_1 { #START FUNCTION

#        write-host "$CurrentPrice" -f green        
#        $CurrentPrice.GetType()

        $06MonCalc = ($OneYearPerformance * 0.5)
#        $06MonCalc = "{0:N2}" -f $06MonCalc
#        write-host "$06MonCalc" -f yellow

        $06MonShave = ($06MonCalc * 0.9)
#        $06MonShave = "{0:N2}" -f $06MonShave
#        write-host "$06MonShave" -f green

        $06MonShave = [math]::Round($06MonShave,2)
#        write-host "$06MonShave" -f cyan
#        $06MonShave.GetType()

        $06StrikeP = $CurrentPrice + $06MonShave
#        write-host "$06StrikeP" -f cyan -b blue

        $06MonthNumbers = $06MonCalc, $06MonShave, $06StrikeP
        $06MonthCalc = "{0:N2}" -f $06MonthNumbers
        $06MonthShave = "{1:N2}" -f $06MonthNumbers
        $06StrikePrice = "{2:N2}" -f $06MonthNumbers

#        write-host "$06MonthCalc" -f darkgreen -b cyan
#        write-host "$06MonthShave" -f darkred -b cyan
#        write-host "$06StrikePrice" -f blue -b cyan
        
        Set-Variable 06MonthCalc $06MonthCalc -Scope Script
        Set-Variable 06MonthShave $06MonthShave -Scope Script
        Set-Variable 06StrikePrice $06StrikeP -Scope Script

    } #END FUNCTION

    function 03MonthStrike_1 { #START FUNCTION

#        write-host "$CurrentPrice" -f green        
#        $CurrentPrice.GetType()

        $03MonCalc = ($SixMonthPerformance * 0.5)
#        $03MonCalc = "{0:N2}" -f $03MonCalc
#        write-host "$03MonCalc" -f yellow

        $03MonShave = ($03MonCalc * 0.9)
#        $03MonShave = "{0:N2}" -f $03MonShave
#        write-host "$03MonShave" -f green

        $03MonShave = [math]::Round($03MonShave,2)
#        write-host "$03MonShave" -f cyan
#        $03MonShave.GetType()

        $03StrikeP = $CurrentPrice + $03MonShave
#        write-host "$03StrikeP" -f cyan -b blue

        $03MonthNumbers = $03MonCalc, $03MonShave, $03StrikeP
        $03MonthCalc = "{0:N2}" -f $03MonthNumbers
        $03MonthShave = "{1:N2}" -f $03MonthNumbers
        $03StrikePrice = "{2:N2}" -f $03MonthNumbers

#        write-host "$03MonthCalc" -f darkgreen -b cyan
#        write-host "$03MonthShave" -f darkred -b cyan
#        write-host "$03StrikePrice" -f blue -b cyan
        
        Set-Variable 03MonthCalc $03MonthCalc -Scope Script
        Set-Variable 03MonthShave $03MonthShave -Scope Script
        Set-Variable 03StrikePrice $03StrikeP -Scope Script

    } #END FUNCTION

    #----------------------------------

    function 18MonthStrike_2 { #START FUNCTION

#        $CurrentPrice = 58.84
#        $TwoYearPerformance = 9.57

        $18MonCalc_2 = ($TwoYearPerformance / 1.5)
        $18MonTTL_2 = $CurrentPrice + $18MonCalc_2

        $18MonShave_2 = ($18MonTTL_2 * 0.1)

        $18StrikeP_2 = $18MonTTL_2 - $18MonShave_2
        #$18StrikeP_2 = [math]::Round($18StrikeP_2,2)

        $18MonthNumbers_2 = $18MonCalc_2, $18MonTTL_2, $18MonShave_2, $18StrikeP_2
        $18MonthCalc_2 = "{0:N2}" -f $18MonthNumbers_2
        $18MonthTotal_2 = "{1:N2}" -f $18MonthNumbers_2
        $18MonthShave_2 = "{2:N2}" -f $18MonthNumbers_2
        $18StrikePrice_2 = "{3:N2}" -f $18MonthNumbers_2

        $18StrikePrice_2 = [System.Convert]::ToDecimal($18StrikePrice_2)

#        write-host "$18MonthCalc_2" -f darkgreen -b yellow
#        write-host "$18MonthTotal_2" -f darkred -b yellow
#        write-host "$18MonthShave_2" -f darkred -b yellow
#        write-host "$18StrikePrice_2" -f blue -b yellow
        
        Set-Variable 18MonthCalc_2 $18MonthCalc_2 -Scope Script
        Set-Variable 18MonthTotal_2 $18MonthTotal_2 -Scope Script
        Set-Variable 18MonthShave_2 $18MonthShave_2 -Scope Script
        Set-Variable 18StrikePrice_2 $18StrikePrice_2 -Scope Script

    } #END FUNCTION

    function 09MonthStrike_2 { #START FUNCTION

        $09MonCalc_2 = ($OneYearPerformance * 0.75)
        $09MonTTL_2 = $CurrentPrice + $09MonCalc_2

        $09MonShave_2 = ($09MonTTL_2 * 0.1)

        $09StrikeP_2 = $09MonTTL_2 - $09MonShave_2
        #$09StrikeP_2 = [math]::Round($09StrikeP_2,2)

        $09MonthNumbers_2 = $09MonCalc_2, $09MonTTL_2, $09MonShave_2, $09StrikeP_2
        $09MonthCalc_2 = "{0:N2}" -f $09MonthNumbers_2
        $09MonthTotal_2 = "{1:N2}" -f $09MonthNumbers_2
        $09MonthShave_2 = "{2:N2}" -f $09MonthNumbers_2
        $09StrikePrice_2 = "{3:N2}" -f $09MonthNumbers_2

        $09StrikePrice_2 = [System.Convert]::ToDecimal($09StrikePrice_2)

#        write-host "$09MonthCalc_2" -f darkgreen -b yellow
#        write-host "$09MonthTotal_2" -f darkred -b yellow
#        write-host "$09MonthShave_2" -f darkred -b yellow
#        write-host "$09StrikePrice_2" -f blue -b yellow
        
        Set-Variable 09MonthCalc_2 $09MonthCalc_2 -Scope Script
        Set-Variable 09MonthTotal_2 $09MonthTotal_2 -Scope Script
        Set-Variable 09MonthShave_2 $09MonthShave_2 -Scope Script
        Set-Variable 09StrikePrice_2 $09StrikePrice_2 -Scope Script

    } #END FUNCTION

    function 06MonthStrike_2 { #START FUNCTION

        $06MonCalc_2 = ($OneYearPerformance * 0.5)
        $06MonTTL_2 = $CurrentPrice + $06MonCalc_2

        $06MonShave_2 = ($06MonTTL_2 * 0.1)

        $06StrikeP_2 = $06MonTTL_2 - $06MonShave_2
        #$06StrikeP_2 = [math]::Round($06StrikeP_2,2)

        $06MonthNumbers_2 = $06MonCalc_2, $06MonTTL_2, $06MonShave_2, $06StrikeP_2
        $06MonthCalc_2 = "{0:N2}" -f $06MonthNumbers_2
        $06MonthTotal_2 = "{1:N2}" -f $06MonthNumbers_2
        $06MonthShave_2 = "{2:N2}" -f $06MonthNumbers_2
        $06StrikePrice_2 = "{3:N2}" -f $06MonthNumbers_2

        $06StrikePrice_2 = [System.Convert]::ToDecimal($06StrikePrice_2)

#        write-host "$06MonthCalc_2" -f darkgreen -b yellow
#        write-host "$06MonthTotal_2" -f darkred -b yellow
#        write-host "$06MonthShave_2" -f darkred -b yellow
#        write-host "$06StrikePrice_2" -f blue -b yellow
        
        Set-Variable 06MonthCalc_2 $06MonthCalc_2 -Scope Script
        Set-Variable 06MonthTotal_2 $06MonthTotal_2 -Scope Script
        Set-Variable 06MonthShave_2 $06MonthShave_2 -Scope Script
        Set-Variable 06StrikePrice_2 $06StrikePrice_2 -Scope Script

    } #END FUNCTION

    function 03MonthStrike_2 { #START FUNCTION

        $03MonCalc_2 = ($SixMonthPerformance * 0.5)
        $03MonTTL_2 = $CurrentPrice + $03MonCalc_2

        $03MonShave_2 = ($03MonTTL_2 * 0.1)

        $03StrikeP_2 = $03MonTTL_2 - $03MonShave_2
        #$03StrikeP_2 = [math]::Round($03StrikeP_2,2)

        $03MonthNumbers_2 = $03MonCalc_2, $03MonTTL_2, $03MonShave_2, $03StrikeP_2
        $03MonthCalc_2 = "{0:N2}" -f $03MonthNumbers_2
        $03MonthTotal_2 = "{1:N2}" -f $03MonthNumbers_2
        $03MonthShave_2 = "{2:N2}" -f $03MonthNumbers_2
        $03StrikePrice_2 = "{3:N2}" -f $03MonthNumbers_2

        $03StrikePrice_2 = [System.Convert]::ToDecimal($03StrikePrice_2)

#        write-host "$03MonthCalc_2" -f darkgreen -b yellow
#        write-host "$03MonthTotal_2" -f darkred -b yellow
#        write-host "$03MonthShave_2" -f darkred -b yellow
#        write-host "$03StrikePrice_2" -f blue -b yellow
        
        Set-Variable 03MonthCalc_2 $03MonthCalc_2 -Scope Script
        Set-Variable 03MonthTotal_2 $03MonthTotal_2 -Scope Script
        Set-Variable 03MonthShave_2 $03MonthShave_2 -Scope Script
        Set-Variable 03StrikePrice_2 $03StrikePrice_2 -Scope Script

    } #END FUNCTION

    #----------------------------------

    function FindTickerName { #START FUNCTION

        if ($matches -ne $null) { Clear-Variable matches }
        $TickerName = $content -match 'h1 class[\s\S]*?</h1>' | Out-Null
        $TickerName = $matches
        $TickerName = $TickerName | foreach{$_.values}
        $TickerName = $TickerName.replace("h1 class=`"D(ib) Fz(18px)`" data-reactid=`"7`">","")
        $TickerName = $TickerName.replace("</h1>","")
        Set-Variable TickerName $TickerName -Scope Script

#        $TickerName

    } #END FUNCTION

    function FindCurrentPrice { #START FUNCTION

        if ($matches -ne $null) { Clear-Variable matches }
        $Price = $content -match '-4px[\s\S]*?</span><span' | Out-Null
        $Price = $matches
        $Price = $Price | foreach{$_.values}
        $Price = $Price.replace("-4px) D(ib)`" data-reactid=`"32`">","")
        $Price = $Price.replace("</span><span","")
        $CurrentPrice = [System.Convert]::ToDecimal($Price)
        Set-Variable CurrentPrice $CurrentPrice -Scope Script

#        $CurrentPrice = 225.53

    } #END FUNCTION

    function Find52WeekHigh { #START FUNCTION

        if ($matches -ne $null) { Clear-Variable matches }
#        $52WkHGH = $content2 -match 'price-wrapper[\s\S]*?</span>' | Out-Null
        $52WkHGH = $content2 -match '52-Week[\s\S]*?</tr>' | Out-Null  
        $52WkHGH = [string]$matches.values -match '<td class="cell-period-high"> <div class="price-wrapper"> <div class="price"> <span>(.*?)</span>'
        $52WkHGH = $matches| foreach{$_.values}
        $52WkHGH = $52WkHGH[0]
#        write-host "$52WkHGH" -f yellow 
        $52WkHigh = [System.Convert]::ToDecimal($52WkHGH)
        Set-Variable 52WkHigh $52WkHigh -Scope Script

#        $52WkHigh.GetType()

    } #END FUNCTION

    function FindSixMnthPerf { #START FUNCTION

        if ($matches -ne $null) { Clear-Variable matches }
        $SixMnthPerf = $content2 -match '6-Month[\s\S]*?</tr>' | Out-Null  
        $SixMnthPerf = [string]$matches.values -match '<td class="cell-period-change"> <div class="price  raising "> <span>(.*?)</span>'
#        $matches
        $SixMnthPerf = $matches| foreach{$_.values}
        $SixMnthPerf = $SixMnthPerf[0]
#        write-host "$SixMnthPerf" -f yellow
        if ($SixMnthPerf -like "+*"){
    
            $SixMnthPerf = $SixMnthPerf.replace("+","")
            $PosOrNeg = "POS"
#            $PosOrNeg
    
        }
        if ($SixMnthPerf -like "-*"){
    
            $SixMnthPerf = $SixMnthPerf.replace("-","")
            $PosOrNeg = "NEG"
#            $PosOrNeg
    
        }
#        write-host "$SixMnthPerf" -f cyan
        $SixMonthPerformance = [System.Convert]::ToDecimal($SixMnthPerf)
        Set-Variable SixMonthPerformance $SixMonthPerformance -Scope Script

#        write-host "$SixMonthPerformance" -f green
#        $SixMonthPerformance.GetType()
#        $SixMonthPerformance = 87.41

    } #END FUNCTION

    function FindOneYrPerf { #START FUNCTION

        if ($matches -ne $null) { Clear-Variable matches }
        #$52WkHGH = $content2 -match 'price-wrapper[\s\S]*?</span>' | Out-Null
        $OneYrPerf = $content2 -match '52-Week[\s\S]*?</tr>' | Out-Null  
        $OneYrPerf = [string]$matches.values -match '<td class="cell-period-change"> <div class="price  raising "> <span>(.*?)</span>'
#        $matches
        $OneYrPerf = $matches| foreach{$_.values}
        $OneYrPerf = $OneYrPerf[0]
#        write-host "$OneYrPerf" -f yellow
        if ($OneYrPerf -like "+*"){
    
            $OneYrPerf = $OneYrPerf.replace("+","")
            $PosOrNeg = "POS"
#            $PosOrNeg
    
        }
        if ($OneYrPerf -like "-*"){
    
            $OneYrPerf = $OneYrPerf.replace("-","")
            $PosOrNeg = "NEG"
#            $PosOrNeg
    
        }
#        write-host "$OneYrPerf" -f cyan
        $OneYearPerformance = [System.Convert]::ToDecimal($OneYrPerf)
        Set-Variable OneYearPerformance $OneYearPerformance -Scope Script

#        write-host "$OneYearPerformance" -f green
#        $OneYearPerformance.GetType()
#        $OneYearPerformance = 87.41

    } #END FUNCTION

    function FindTwoYrPerf { #START FUNCTION

        if ($matches -ne $null) { Clear-Variable matches }
        $TwoYrPerf = $content2 -match '2-Year[\s\S]*?</tr>' | Out-Null  
        $TwoYrPerf = [string]$matches.values -match '<td class="cell-period-change"> <div class="price  raising "> <span>(.*?)</span>'
#        $matches
        $TwoYrPerf = $matches| foreach{$_.values}
        $TwoYrPerf = $TwoYrPerf[0]
#        write-host "$TwoYrPerf" -f yellow
        if ($TwoYrPerf -like "+*"){
    
            $TwoYrPerf = $TwoYrPerf.replace("+","")
            $PosOrNeg = "POS"
    
        }
        if ($TwoYrPerf -like "-*"){
    
            $TwoYrPerf = $TwoYrPerf.replace("-","")
            $PosOrNeg = "NEG"
    
        }
        $TwoYearPerformance = [System.Convert]::ToDecimal($TwoYrPerf)
        Set-Variable TwoYearPerformance $TwoYearPerformance -Scope Script

#        write-host "$TwoYearPerformance" -f green
#        $TwoYearPerformance.GetType()
#        $TwoYearPerformance = 113.51

    } #END FUNCTION

    #----------------------------------

#    $TICKER = "MSFT"
#    RequestTicker

    $Barchart_DateTime = Get-Date -format "dd/MMM/yy @ HH:mm"

    $Page4 = "https://www.barchart.com/stocks/quotes/<TICKER>/performance"
    $Page4 = $Page4.replace("<TICKER>","$TICKER")

    $WebResponse = Invoke-WebRequest $Page3
    $WebResponse4 = Invoke-WebRequest $Page4
    $content = $WebResponse.RawContent
    $content2 = $WebResponse4.RawContent

#----------------------------------

    FindTickerName
    FindCurrentPrice
    Find52WeekHigh

    $PercentOfHigh = "{0:N2}" -f (($CurrentPrice / $52WkHigh) * 100)
    $PercentOfHigh = [math]::Round($PercentOfHigh,2)
#    write-host "$PercentOfHigh%" -f yellow
    if ($CurrentPrice -ge $52WkHigh){$52WkYesNo = "YES"}
    if ($CurrentPrice -lt $52WkHigh){$52WkYesNo = "NO"}
    
    FindSixMnthPerf
    FindOneYrPerf
    FindTwoYrPerf

#----------------------------------

    03MonthStrike_1
    06MonthStrike_1
    09MonthStrike_1
    18MonthStrike_1
    ""
    03MonthStrike_2
    06MonthStrike_2
    09MonthStrike_2
    18MonthStrike_2

#----------------------------------

    function WriteStrikePrice_1 { #START FUNCTION

        write-host -nonewline " Two-Year, 18-month Exit : `$$18MonthCalc | Shaved Exit @ 90% : `$$18MonthShave | Strike : "
        write-host "`$$18StrikePrice" -f yellow -b darkgreen
        write-host -nonewline " One-Year, 09-month Exit : `$$09MonthCalc | Shaved Exit @ 90% : `$$09MonthShave | Strike : "
        write-host "`$$09StrikePrice" -f yellow -b darkred
        write-host -nonewline " One-Year, 06-month Exit : `$$06MonthCalc | Shaved Exit @ 90% : `$$06MonthShave | Strike : "
        write-host "`$$06StrikePrice" -f cyan -b blue
        write-host -nonewline "Six-Month, 03-month Exit : `$$03MonthCalc | Shaved Exit @ 90% : `$$03MonthShave | Strike : "
        write-host "`$$03StrikePrice" -f green -b darkcyan

    } #END FUNCTION

    function WriteStrikePrice_2 { #START FUNCTION

        write-host -nonewline " Two-Year, 18-month Exit : `$$18MonthCalc_2 | 10% Shave : `$$18MonthShave_2 | Strike : "
        write-host "`$$18StrikePrice_2" -f yellow -b darkgreen
        write-host -nonewline " One-Year, 09-month Exit : `$$09MonthCalc_2 | 10% Shave : `$$09MonthShave_2 | Strike : "
        write-host "`$$09StrikePrice_2" -f yellow -b darkred
        write-host -nonewline " One-Year, 06-month Exit : `$$06MonthCalc_2 | 10% Shave : `$$06MonthShave_2 | Strike : "
        write-host "`$$06StrikePrice_2" -f cyan -b blue
        write-host -nonewline "Six-Month, 03-month Exit : `$$03MonthCalc_2 | 10% Shave : `$$03MonthShave_2 | Strike : "
        write-host "`$$03StrikePrice_2" -f green -b darkcyan

    } #END FUNCTION

#----------------------------------

    function TickerHeader { #START FUNCTION
    
#        $filename = split-path $MyInvocation.PSCommandPath -Leaf
        $line_A_2 = $Ticker
        $line_B_2 = $TickerName
#        $Drive = Get-Location | foreach {$_.Drive.Name}
#        Set-Variable Drive $Drive -Scope Global
    
        #--------------- SIZE CHARACTERS FOR LINE 1 ---------------

        $count_A_2 = $line_A_2 | measure-object –character
        $lineLength_A_2 = $count_A_2.characters
        if (($lineLength_A_2 % 2 -eq 0) -eq $false ) {$line_A_2 = $line_A_2+" "}
        $count_A_2 = $line_A_2 | measure-object –character
        $lineLength_A_2 = $count_A_2.characters
        $length_A_2 = $lineLength_A_2 + 30
        $halfLength_A_2 = $length_A_2 / 2
    
        #--------------- SIZE CHARACTERS FOR LINE 2 ---------------

        $count_B_2 = $line_B_2 | measure-object -character
        $lineLength_B_2 = $count_B_2.characters
        if (($lineLength_B_2 % 2 -eq 0) -eq $false ) {$line_B_2 = $line_B_2+" "}
        $count_B_2 = $line_B_2 | measure-object -character
        $lineLength_B_2 = $count_B_2.characters
        $length_B_2 = $lineLength_B_2 + 30
        $halfLength_B_2 = $length_B_2 / 2

        #--------------- CALCULATE CHARACTERS FOR HEADER ---------------

        $maxvariablelength_2 = ($lineLength_A_2,$lineLength_B_2 | measure-object -maximum).maximum
        $totalHeaderLength_2 = $maxvariablelength_2 + 30

        $vertLine_2 = "|"
        $linesHyphen_2 = "=" * $totalHeaderLength_2
        $blanks_2 = " " * $totalHeaderLength_2
    
        $halfLength_A_2 = ($totalHeaderLength_2 - $lineLength_A_2) / 2
        $halfLength_B_2 = ($totalHeaderLength_2 - $lineLength_B_2) / 2

    
        $halfBlanks_A_2 = " " * $halfLength_A_2
        $halfBlanks_B_2 = " " * $halfLength_B_2

        #--------------- HEADER PRINT FILENAME ---------------

            write-host " $linesHyphen_2 " -f white

            write-host -nonewline "$vertLine_2" -f white
            write-host -nonewline "$halfBlanks_A_2" -b black
            write-host -nonewline "$line_A_2" -f cyan -b black
            write-host -nonewline "$halfBlanks_A_2" -b black
            write-host "$vertLine_2" -f white

#            write-host -nonewline "$vertLine_2" -f white
#            write-host -nonewline "$blanks_2" -b black
#            write-host "$vertLine_2" -f white

            write-host -nonewline "$vertLine_2" -f white
            write-host -nonewline "$halfBlanks_B_2" -b black
            write-host -nonewline "$line_B_2" -f white -b black
            write-host -nonewline "$halfBlanks_B_2" -b black
            write-host "$vertLine_2" -f white

            write-host " $linesHyphen_2 " -f white

        #--------------- END SCRIPT HEADER PRINT ---------------

    } #END FUNCTION

    TickerHeader

#    write-host ""
#    write-host "=============================================================" 
#    write-host "                       $Ticker                       " -f cyan -b black
#    write-host "          $TickerName          " -b black
#    write-host "=============================================================" 
    write-host ""
    write-host -nonewline "Current Price : "
    write-host "`$$CurrentPrice" -f yellow -b black
    write-host ""
    write-host "-------------------------------------------------------------------------------------"
    write-host -nonewline "52-Week High? : "
    if ($52WkYesNo -eq "NO") {write-host -nonewline "$52WkYesNo" -f cyan -b darkgray}
    if ($52WkYesNo -eq "YES") {write-host -nonewline "$52WkYesNo" -f white -b red}
    write-host -nonewline " | Previous 52-Week High : "
    write-host -nonewline "`$$52WkHigh | Percentage of 52Wk : "
    if ($52WkYesNo -eq "NO") {write-host "$PercentOfHigh%"}
    if ($52WkYesNo -eq "YES") {write-host "$PercentOfHigh%" -f white -b red}
    write-host "-------------------------------------------------------------------------------------"
    write-host "                          Two-Year Performance  = `$$TwoYearPerformance" -f cyan
    write-host "                          One-Year Performance  = `$$OneYearPerformance" -f cyan
    write-host "                          Six Month Performance = `$$SixMonthPerformance" -f cyan
    write-host ""
    write-host "                                                              $Barchart_DateTime GMT" -f yellow
    write-host "                                                           data from : barchart.com" -f cyan

    write-host "-------------------------------------------------------------------------------------"
    write-host ""
    write-host "                              **  STRIKE PRICE **                                " -f yellow
    write-host "-------------------------------------------------------------------------------------"
    WriteStrikePrice_1
    #write-host "-------------------------------------------------------------------------------------"
    #write-host ""
    #write-host "                                STRIKE PRICE METHOD 2                                " -f yellow
    #write-host "-------------------------------------------------------------------------------------"
    #WriteStrikePrice_2
    write-host "-------------------------------------------------------------------------------------"
    write-host ""

#----------------------------------

    #write-host "                              STRIKE PRICE 2 METHOD AVERAGE                         "
    #write-host "====================================================================================="
    #write-host -nonewline "2-Year Strike Price (18 Months) : "
    #write-host -nonewline " ((`$$18StrikePrice + `$$18StrikePrice_2) / 2) = " -f darkgray
    #$18StrikePriceAverage = (($18StrikePrice + $18StrikePrice_2) / 2)
    #$18StrikePriceAverage = [math]::Round($18StrikePriceAverage,2)
    #write-host "`$$18StrikePriceAverage" -f yellow -b darkgreen

    #write-host -nonewline " 1-Year Strike Price (9 Months) : "
    #write-host -nonewline " ((`$$09StrikePrice + `$$09StrikePrice_2) / 2) = " -f darkgray
    #$09StrikePriceAverage = (($09StrikePrice + $09StrikePrice_2) / 2)
    #$09StrikePriceAverage = [math]::Round($09StrikePriceAverage,2)
    #write-host "`$$09StrikePriceAverage" -f yellow -b darkred

    #write-host -nonewline " 1-Year Strike Price (6 Months) : "
    #write-host -nonewline " ((`$$06StrikePrice + `$$06StrikePrice_2) / 2) = " -f darkgray
    #$06StrikePriceAverage = (($06StrikePrice + $06StrikePrice_2) / 2)
    #$06StrikePriceAverage = [math]::Round($06StrikePriceAverage,2)
    #write-host "`$$06StrikePriceAverage" -f cyan -b blue

    #write-host -nonewline "6-Month Strike Price (3 Months) : "
    #write-host -nonewline " ((`$$03StrikePrice + `$$03StrikePrice_2) / 2) = " -f darkgray
    #$03StrikePriceAverage = (($03StrikePrice + $03StrikePrice_2) / 2)
    #$03StrikePriceAverage = [math]::Round($03StrikePriceAverage,2)
    #write-host "`$$03StrikePriceAverage" -f green -b darkcyan
    
    #write-host "====================================================================================="
    #if ($52WkYesNo -eq "YES"){write-host "Remember, this is at a 52-week high, never go in at the high point" -f white -b red}
    #write-host ""
    #write-host ""

} #END FUNCTION

function FAQs { #START FUNCTION
   
    write-host ""
    write-host "                                                                                            " -b black
    write-host " FAQs:                                                                                      " -b black
    write-host "                                                                                            " -b black
    write-host -nonewline "- If you see a " -b black
    write-host -nonewline "`"The remote server returned an error: (404) Not Found`"" -f red -b black
    write-host " this can be a         " -b black
    write-host "  normal error as the script is testing pages before searching BUT check the ticker.        " -b black
    write-host "                                                                                            " -b black
    write-host -nonewline "- If you see a lot of " -f yellow -b black
    write-host -nonewline "red errors" -f red -b black
    write-host ", please check the ticker you entered. This script will     " -f yellow -b black
    write-host "  not work for tickers are not searchable on barchart.com.                                  " -f yellow -b black
    write-host "                                                                                            " -b black
    write-host "- If you see 0's for the strike prices again, please check the ticker you entered.          " -b black
    write-host "                                                                                            " -b black
    write-host "- There are two methods for strike price. The first (strike price 1) is discussed on this   " -f yellow -b black
    write-host -nonewline "  YouTube video > " -f yellow -b black
    write-host -nonewline "https://youtu.be/jmyrwWN_Tlg" -f white -b red
    write-host " < and the second method (strike price 2) is  " -f yellow -b black
    write-host -nonewline "  discussed from 25:00 on this YouTube video > " -f yellow -b black
    write-host -nonewline "https://youtu.be/dheuSkRelE8?t=1500" -f white -b red
    write-host " < the    " -f yellow -b black
    write-host "  AVERAGE of method 1 and method 2 is then used to provide the final strike price in        " -f yellow -b black
    write-host "  this script. Both methods and the average are shown for transparency.                     " -f yellow -b black
    write-host "                                                                                            " -b black

} #END FUNCTION

#========================================================

#------------------BASELINE COMMANDLETS------------------

function HeaderInfo { #START FUNCTION
    
    $filename = split-path $MyInvocation.PSCommandPath -Leaf
    $dateOfRelease="Released version: 04 Sep 2020"
    $author="Script author: DanTheMan"
    $nosupport="Script is not supported-Modified By MunYa"            
    $credit="All knowledge credit to: @IamMarkMonroe" 
    $line_A = $filename
    $line_B = $dateOfRelease
    $line_C = $author
    $line_D = $nosupport
    $line_E = $credit
    $Drive = Get-Location | foreach {$_.Drive.Name}
    Set-Variable Drive $Drive -Scope Global
    
    #--------------- SIZE CHARACTERS FOR LINE A ---------------

    $count_A = $line_A | measure-object –character
    $lineLength_A = $count_A.characters
    if (($lineLength_A % 2 -eq 0) -eq $false ) {$line_A = $line_A+" "}
    $count_A = $line_A | measure-object –character
    $lineLength_A = $count_A.characters
    $length_A = $lineLength_A + 30
    $halfLength_A = $length_A / 2
    
    #--------------- SIZE CHARACTERS FOR LINE B ---------------

    $count_B = $line_B | measure-object -character
    $lineLength_B = $count_B.characters
    if (($lineLength_B % 2 -eq 0) -eq $false ) {$line_B = $line_B+" "}
    $count_B = $line_B | measure-object -character
    $lineLength_B = $count_B.characters
    $length_B = $lineLength_B + 30
    $halfLength_B = $length_B / 2

    #--------------- SIZE CHARACTERS FOR LINE C ---------------

    $count_C = $line_C | measure-object -character
    $lineLength_C = $count_C.characters
    if (($lineLength_C % 2 -eq 0) -eq $false ) {$line_C = $line_C+" "}
    $count_C = $line_C | measure-object -character
    $lineLength_C = $count_C.characters
    $length_C = $lineLength_C + 30
    $halfLength_C = $length_C / 2

    #--------------- SIZE CHARACTERS FOR LINE D ---------------

    $count_D = $line_D | measure-object -character
    $lineLength_D = $count_D.characters
    if (($lineLength_D % 2 -eq 0) -eq $false ) {$line_D = $line_D+" "}
    $count_D = $line_D | measure-object -character
    $lineLength_D = $count_D.characters
    $length_D = $lineLength_D + 30
    $halfLength_D = $length_D / 2

    #--------------- SIZE CHARACTERS FOR LINE E ---------------

    $count_E = $line_E | measure-object -character
    $lineLength_E = $count_E.characters
    if (($lineLength_E % 2 -eq 0) -eq $false ) {$line_E = $line_E+" "}
    $count_E = $line_E | measure-object -character
    $lineLength_E = $count_E.characters
    $length_E = $lineLength_E + 30
    $halfLength_E = $length_E / 2

    #--------------- CALCULATE CHARACTERS FOR HEADER ---------------

    $maxvariablelength = ($lineLength_A,$lineLength_B,$lineLength_C,$lineLength_D,$lineLength_E | measure-object -maximum).maximum
    $totalHeaderLength = $maxvariablelength + 30

    $vertLine = "|"
    $linesHyphen = "-" * $totalHeaderLength
    $blanks = " " * $totalHeaderLength
    
    $halfLength_A = ($totalHeaderLength - $lineLength_A) / 2
    $halfLength_B = ($totalHeaderLength - $lineLength_B) / 2
    $halfLength_C = ($totalHeaderLength - $lineLength_C) / 2
    $halfLength_D = ($totalHeaderLength - $lineLength_D) / 2
    $halfLength_E = ($totalHeaderLength - $lineLength_E) / 2

    
    $halfBlanks_A = " " * $halfLength_A
    $halfBlanks_B = " " * $halfLength_B
    $halfBlanks_C = " " * $halfLength_C
    $halfBlanks_D = " " * $halfLength_D
    $halfBlanks_E = " " * $halfLength_E

    #--------------- HEADER PRINT FILENAME ---------------

        write-host " $linesHyphen " -f green

        write-host -nonewline "$vertLine" -f green
        write-host -nonewline "$halfBlanks_A" -b darkGreen
        write-host -nonewline "$line_A" -f green -b darkGreen
        write-host -nonewline "$halfBlanks_A" -b darkGreen
        write-host "$vertLine" -f green

        write-host -nonewline "$vertLine" -f green
        write-host -nonewline "$blanks" -b darkGreen
        write-host "$vertLine" -f green

        write-host -nonewline "$vertLine" -f green
        write-host -nonewline "$halfBlanks_B" -b darkGreen
        write-host -nonewline "$line_B" -f green -b darkGreen
        write-host -nonewline "$halfBlanks_B" -b darkGreen
        write-host "$vertLine" -f green

        write-host -nonewline "$vertLine" -f green
        write-host -nonewline "$halfBlanks_C" -b darkGreen
        write-host -nonewline "$line_C" -f gray -b darkGreen
        write-host -nonewline "$halfBlanks_C" -b darkGreen
        write-host "$vertLine" -f green

        write-host -nonewline "$vertLine" -f green
        write-host -nonewline "$halfBlanks_D" -b darkGreen
        write-host -nonewline "$line_D" -f gray -b darkGreen
        write-host -nonewline "$halfBlanks_D" -b darkGreen
        write-host "$vertLine" -f green

        write-host -nonewline "$vertLine" -f green
        write-host -nonewline "$blanks" -b darkGreen
        write-host "$vertLine" -f green

        write-host -nonewline "$vertLine" -f green
        write-host -nonewline "$halfBlanks_E" -b darkGreen
        write-host -nonewline "$line_E" -f cyan -b darkGreen
        write-host -nonewline "$halfBlanks_E" -b darkGreen
        write-host "$vertLine" -f green

        write-host " $linesHyphen " -f green

    #--------------- END SCRIPT HEADER PRINT ---------------

} #END FUNCTION

#---------------------------------------------------
#------------------ RUN FUNCTIONS ------------------
#---------------------------------------------------

HeaderInfo

#---------------------------------------------
#--------------- RUN FUNCTIONS ---------------
#---------------------------------------------

RequestTicker

do {

#" "
#write-host "If you see `"The remote server returned an error: (404) Not Found.`" error above, you can ignore." -f darkgray
" "
write-host "Type the letter in brackets for the required function..." -f darkgray
" "
write-host " [P] : Search Price ONLY"
write-host " [D] : Find Strike Price"
write-host " [N] : Enter New Ticker"
write-host " "
write-host " [F] : FAQs"
write-host " [E/X] : Exit"
" "
write-host -nonewline " >> " -f yellow
$choose = read-host 

    if ($choose -eq "P") {SearchPrice}
    if ($choose -eq "D") {StrikePrice}
    if ($choose -eq "N") {RequestTicker}
    if ($choose -eq "F") {FAQs}

}
until ($choose -eq "E" -or $choose -eq "X")