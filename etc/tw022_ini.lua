----- INI-FILE -----
--------------------
VBU3 = {}
VBU3.name = "VBU3"
VBU3.Vane = "RTSI"
VBU3.enabled = false
VBU3.market = false
VBU3.brake=0.3
VBU3.channel = 19
VBU3.trade_volume=2
VBU3.stop_steps=11
VBU3.maxloss=100
--------------------
SRU3 = {}
SRU3.name = "SRU3"
SRU3.Vane = "RTSI"
SRU3.enabled = false
SRU3.market = false
SRU3.brake=0.3
SRU3.channel = 21
SRU3.trade_volume=1
SRU3.stop_steps=12
SRU3.maxloss=100
--------------------
GZU3={}
GZU3.name="GZU3"
GZU3.Vane="MICEXO&G"
GZU3.enabled = false
GZU3.market=true
GZU3.brake=0.3
GZU3.channel = 21
GZU3.trade_volume=1
GZU3.stop_steps=17
GZU3.maxloss=150
--------------------
RIU3={}
RIU3.name="RIU3"
RIU3.Vane="RTSI"
RIU3.enabled = false
RIU3.market = false
RIU3.brake=0.3
RIU3.channel=35
RIU3.trade_volume=1
RIU3.stop_steps=15
RIU3.maxloss=400
--------------------
VTBR={}
VTBR.name="VTBR"
VTBR.Vane="VBU3"
VTBR.enabled = false
VTBR.market = true
VTBR.brake=0.3
VTBR.channel = 19
VTBR.trade_volume=1
VTBR.stop_steps=5
VTBR.maxloss =10
--------------------
--------------------
Tickers = {VBU3,SRU3,GZU3,RIU3,VTBR}
--Tickers={}
--Tickers["VBU3"]=VBU3
--Tickers["SRU3"]=SRU3
--Tickers["LKU3"]=GZU3
--Tickers["LKU3"]=RIU3
--Tickers["RNU3"]=RNU3
--Tickers["LKU3"]=LKU3
--Tickers["VTBR"]=VTBR
toLog(log,"ini read")
toLog(log, Tickers)
