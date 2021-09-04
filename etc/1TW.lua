if string.find(package.path,'C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.lua')==nil then
   package.path=package.path..';C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.lua;'
end
if string.find(package.path,'C:\\Program Files\\Lua\\5.1\\lua\\?.lua')==nil then
   package.path=package.path..';C:\\Program Files\\Lua\\5.1\\lua\\?.lua;'
end
if string.find(package.path,'C:\\Program Files\\Lua\\5.1\\lua\\?.lua')==nil then
   package.path=package.path..';'..getScriptPath()..'\\?.lua;'
end
require"QL_beta"
VERSION='0.2.0'
log=getScriptPath().."\\"..getTradeDate().."Tradewind.log"
ini_file=getScriptPath().."\\".."tw020_ini.lua"
dofile ( ini_file )
----------------------------------
account="" --�������� ����
spot_account="" --�������� ���� ��� �����
client_code="" --��� �������
uid="" --��� ������� ��� �����
comment="tradewind"
-- ���� �� ��������� � ����� ini, ����� ������������ ��������� ��������:
Vane="RTSI" --����� ��������
trade_volume=1 --����� ���������� �����, ������� �������� � ���� ��������.
stop_steps=5 --������ ����� � ����� ����.
maxloss = 200 -- ������������ ������, ��� ������� �������� �� ������� ������������
--max_volume=1 --������������ ���������� ����� �����������
brake=0.3 --����������� ��� �����, �������� � ����� ����
--[[
�� �������� �������� �� ������ �������� ������� � ���������������� SMA_����� LMA_����� � HMA_�����. ��� ����� - ��� �������� �� ���. ������� ����������. �������� LMA_MICEXO&G
�� �������� �������� �� ������� ��������� ������������ ������� � ���������������� SMA_����� � LMA_����� � HMA_�����. �������� SMA_GAZP
--]]
-----------------------------------
table_mask={}
table_mask.comment=comment
-----------------------------------
function OnInit()
is_run = true
info=""
--������� ������� ����
	t2t=QTable:new()
-- ��������� �������
	t2t:AddColumn("TIME",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("SEC",QTABLE_STRING_TYPE,8)
	t2t:AddColumn("POSITION",QTABLE_STRING_TYPE,8)
	t2t:AddColumn("�����",QTABLE_STRING_TYPE,16)
	t2t:AddColumn("�����",QTABLE_STRING_TYPE,16)
	t2t:AddColumn("�������",QTABLE_STRING_TYPE,16)
	t2t:AddColumn("�������",QTABLE_STRING_TYPE,16)
	t2t:AddColumn("SIGNAL",QTABLE_STRING_TYPE,32)
	t2t:AddColumn("STOPSIGNAL",QTABLE_STRING_TYPE,24)
	t2t:AddColumn("PRICE",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("PROFIT",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("VARMARGIN",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("INFO",QTABLE_STRING_TYPE,120)
-- ��������� �������� ��� �������
	t2t:SetCaption('-=TRADE WIND=- V.'..VERSION)
-- ���������� �������
	t2t:Show()
if file_exists(getScriptPath().."\\".."WC.txt") then
-- ��������� ���������� �������� ����
WCoord={}
WCoord=table.load(getScriptPath().."\\".."WC.txt")
-- ����������� ������� �� ����������� ��� ������ ����������
	t2t:SetPosition(WCoord.x, WCoord.y, WCoord.dx, WCoord.dy)
end
for i=1, #Tickers,1 do
	-- ��������� ������ ������
	line=t2t:AddLine()
end
end
function OnStop(s)
is_run = false
Tickers={}
Wcoord={}
-- �������� ���������� �������� ���� � ��������� ��.
Wcoord.x,Wcoord.y,Wcoord.dx,Wcoord.dy=t2t:GetPosition()
table.save(Wcoord,getScriptPath().."\\".."WC.txt")
    -- ���������� ������� ����
  t2t:delete()
--  message ("Sailing stopped", 2)
table_mask.comment=comment
_,report=	killAllOrders(table_mask)
--toLog(log,report)
end

function main()

  while is_run do
-- �������� ����� � �������, ���� ��� �������� - ����� ���������
	stime=getSTime() or tonumber(os.date("%H%M%S"))

	if (stime>100030 and stime<184500) or (stime>190030 and stime<235000) then --�� ������� ��� ������

	for key,sec in pairs(Tickers) do

--	Vane_class=getSecurityInfo("",(sec.Vane or Vane)).class_code or ""
	sec.class=getSecurityInfo("",sec.name).class_code
	sec.lot=getParamEx(sec.class,sec.name,"lotsize").param_value
	sec.step=getParamEx(sec.class,sec.name,"SEC_PRICE_STEP").param_value
	info=""
-- ���� ����������- �����, ��������� �� ����� �������� �������
if sec.class=="SPBFUT" then sec.spot,sec.account=false,account else sec.spot,sec.account=true,spot_account end
if sec.spot and stime > 184500 then sec.enabled,sec.stopped=false,true else sec.stopped=false end
if isConnected ~= 0 and not sec.stopped  then  -- ���� ��� �������� ��� ������ �� ��������� - ������� �� ���������, � ������ �� �����������, ������� �� ��������� � �� ���������
	--�������� ��������� ������ �� ���������� �����������
	last=tonumber(getParamEx(sec.class,sec.name,"last").param_value)

	--�������� ������ ������� ��� �������� � �����������
	Storm = IsTrend(tostring("LMA_"..(sec.Vane or Vane)),tostring("HMA_"..(sec.Vane or Vane)))
	Scud = IsTrend(tostring("SMA_"..(sec.Vane or Vane)),tostring("LMA_"..(sec.Vane or Vane)))
	Stream = IsTrend(tostring("LMA_"..sec.name),tostring("HMA_"..sec.name))
	Rudder = IsTrend(tostring("SMA_"..sec.name),tostring("LMA_"..sec.name))

--�������� ����� � ��������� ������� - ��� �������� �������
	smachart=tostring("SMA_"..sec.name)
	sma_n = tonumber(getNumCandles (smachart))
-- ��������� ������ ����� -- ���������� �����
sma1, sma0= GetGraphValueByCandle(smachart, 1, 0),GetGraphValueByCandle(smachart, 0, 0) or sma1

	--��������� �������� �� ������� � ������� �� ��������� ������� (���� ������ �������� ��� disabled �������� � ������ ���������)
	trend_detector="NOTHING_TO_DO"
	if Scud=="UPTREND" and Rudder=="UPTREND"  then
		trend_detector="BUY"
		if Storm=="UPTREND" or Stream=="UPTREND" then
		trend_detector="STRONG_BUY"
			if Storm=="UPTREND" and Stream=="UPTREND"then
			trend_detector="EXTRA_BUY"
			end
		end
	elseif Scud=="DOWNTREND" and Rudder=="DOWNTREND"  then
		trend_detector="SELL"
		if Storm=="DOWNTREND" or Stream=="DOWNTREND" then
		trend_detector="STRONG_SELL"
			if Storm=="DOWNTREND" and Stream=="DOWNTREND" then
			trend_detector="EXTRA_SELL"
			end
		end
	end
-- ������� �������� �������
OpenLong=false
OpenShort=false
if  trend_detector=="STRONG_BUY" or trend_detector=="EXTRA_BUY" then
OpenLong=true
elseif  trend_detector=="STRONG_SELL" or trend_detector=="EXTRA_SELL" then
OpenShort=true
end
-- ������� �������� �������
StopSignalShort = false
StopSignalLong = false
if tonumber(sma0.close) - tonumber(sma1.close) > (sec.brake or brake)*sec.step then
StopSignalShort = true
elseif tonumber(sma1.close) - tonumber(sma0.close) > (sec.brake or brake)*sec.step then
StopSignalLong = true
end
	--�������� ������
	net_price,balance,varmargin=getFbalance(sec.name, sec.account)
if varmargin + sec.maxloss < 0 then sec.enabled = false end

	--�������� ������. ���� ������ ������.
	local qt = getQuoteLevel2(sec.class, sec.name)
	local bid_1 = toPrice(sec.name, qt.bid[tonumber(qt.bid_count)+0].price)
	local offer_1 = toPrice(sec.name, qt.offer[1].price)
if sec.enabled then	--� ������ ���������  ������� �� ��������� (�� ������� �����)
	--�������� �������
	if  (stime>100030 and stime<183000) or (stime>190030 and stime<233000) then
		if  OpenLong and balance<(sec.trade_volume or trade_volume) and not StopSignalLong then --*sec.lot
			send_limit_buy, reply=sendLimit(sec.class,sec.name,"B",bid_1+sec.step,1,sec.account,client_code, comment.."+")
			--send_limit_buy, reply=sendMarket(sec.class,sec.name,"B",1,sec.account,client_code,comment.."+")
		end
		if  OpenShort and balance>(sec.trade_volume or trade_volume)*-1 and not StopSignalShort then --*sec.lot
			if sec.market then
				send_market_sell, reply=sendMarket(sec.class,sec.name,"S",1,sec.account,client_code,comment.."-")
			else
				send_limit_sell, reply=sendLimit(sec.class,sec.name,"S",offer_1-sec.step,1,sec.account,client_code, comment.."-")
			end
		end
	end -- �������� ������� ������
end -- sec.enabled?
	--�������� �������
	if (stime>100030 and stime<184500) or (stime>190030 and stime<235000) then
		if balance>0 and (StopSignalLong or	(net_price-offer_1)>(sec.stop_steps or stop_steps)*sec.step) and not OpenLong then   -- Scud=="DOWNTREND"  or
		--toLog (log, "we're inside sell out signal")
			if sec.market then
				send_market_sell_out, reply=sendMarket(sec.class,sec.name,"S",1,sec.account,client_code, comment)
			else
				send_limit_sell_out, reply=sendLimit(sec.class,sec.name,"S",offer_1-sec.step,1,sec.account,client_code, comment)
			end
			--toLog(log, sec.name.." "..reply)
		elseif balance<0 and (StopSignalShort or (bid_1-net_price)>(sec.stop_steps or stop_steps)*sec.step) and not OpenShort then	-- or Scud=="UPTREND" or
			--toLog (log, "we're inside buy out signal")
			if sec.market then
				send_market_buy_out, reply=sendMarket(sec.class,sec.name,"B",1,sec.account,client_code, comment)
			else
				send_limit_buy_out, reply=sendLimit(sec.class,sec.name,"B",bid_1+sec.step,1,sec.account,client_code, comment)
			end
			--toLog(log, sec.name.." "..reply)
		end
	end
end -- sec.stopped?
	SEMAFOR="BLOCKED-FLAT"
	if StopSignalLong  then SEMAFOR = "STOP LONG"
	elseif StopSignalShort then SEMAFOR = "STOP SHORT"
	end

	if trend_detector~="NOTHING_TO_DO" then
	toLog (log, "VANE: "..(sec.Vane or Vane).." Storm: "..Storm.."  Scud: "..Scud.."  RUDDER: "..Rudder.." Stream: "..Stream)
	toLog(log, sec.name.." balance="..balance)
	toLog(log,sec.name.." SMA:  "..math_round((sma0.close-sma1.close),2))
	toLog (log, trend_detector)
	toLog (log, SEMAFOR)
	end
if sec.spot then
if balance==0 then priceinfo=last*sec.lot else priceinfo=net_price*sec.lot end
varmargin = math_round((last*sec.lot-priceinfo)*balance,2)
else
if balance==0 then priceinfo=last else priceinfo=net_price end
--varmargin = math_round((last-priceinfo)*balance,2)
end
status="FLAT"
if OpenLong then status = "LONG" elseif OpenShort then status="SHORT" end
if sec.enabled then tickerstatus = " ENABLED " else tickerstatus = " DISABLED " end
if sec.stopped then stopstatus,priceinfo,varmargin,balance = "STOPPED",0,0,0
Storm,Scud,Rudder,Stream,trend_detector,SEMAFOR = "NO_DATA","NO_DATA","NO_DATA","NO_DATA","NO_DATA","NO_DATA"
else stopstatus = "RUNNING" end
info = info.." "..status.." | "..(sec.Vane or Vane).." | "..sec.class.." | "..tickerstatus.." | "..stopstatus
		t2t:SetValue(key,"TIME",stime)
		t2t:SetValue(key,"SEC",sec.name)
		t2t:SetValue(key,"POSITION",balance)
		t2t:SetValue(key,"�����",Storm)
		t2t:SetValue(key,"�����",Scud)
		t2t:SetValue(key,"�������",Rudder)
		t2t:SetValue(key,"�������",Stream)
		t2t:SetValue(key,"SIGNAL",trend_detector)
		t2t:SetValue(key,"STOPSIGNAL",SEMAFOR )
		t2t:SetValue(key,"PRICE",tostring(priceinfo))
		t2t:SetValue(key,"PROFIT",tostring(math_round((last-net_price)*balance,2)) )
		t2t:SetValue(key,"VARMARGIN",tostring(varmargin))
		t2t:SetValue(key,"INFO",info)
end --����� �������� �����
	sleep(7000)
	table_mask.comment=comment
	killAllOrders(table_mask)
sleep(100)
  end
  end --����� ����� "�� ������� ��� ������"
end
----------------------------
-- ���������� ���������������� �������
----------------------------
function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
----------------------------
function math_round( roundIn , roundDig ) -- ������ �������� - ����� ������� ���� ���������, ������ �������� - ���������� �������� ����� �������.
     local mul = math.pow( 10, roundDig )
     return ( math.floor( ( roundIn * mul ) + 0.5 )/mul )
end
----------------------------
-- ����������� �������
function getFbalance(fsec,facc)
local class_code=getSecurityInfo("",fsec).class_code
if class_code=="SPBFUT" then -- ���������� ������� ���������� ��� ����� ��� �������
	for i=0,getNumberOf("futures_client_holding")-1 do
		local row=getItem("futures_client_holding",i)
		if  row~=nil and row.sec_code==fsec and row.trdaccid==facc then return (row.avrposnprice or 0),(row.totalnet or 0),(row.varmargin or 0) end
	end
	return 0,0,0
else
	for i=0,getNumberOf("depo_limits")-1 do
	local row = getItem("depo_limits", i)
		if row~=nil and row.sec_code == fsec and row.trdaccid == facc then
		return row.awg_position_price,row.currentbal,0 end
	end
	return 0,0,0
end

end
------------------------------
-- ����������� ������ �� ���� ��������
function IsTrend(label_mashort,label_malong)
local s1=GetGraphValueByCandle(label_mashort, 1, 0)
local s2=GetGraphValueByCandle(label_mashort, 2, 0)
local s0=GetGraphValueByCandle(label_mashort, 0, 0) or s1
local l1=GetGraphValueByCandle(label_malong, 1, 0)
local l2=GetGraphValueByCandle(label_malong, 2, 0)
local l0=GetGraphValueByCandle(label_malong, 0, 0) or l1
local magap0 = math.abs(tonumber(s0.close)-tonumber(l0.close))
local magap1 = math.abs(tonumber(s1.close)-tonumber(l1.close))
local magap2 = math.abs(tonumber(s2.close)-tonumber(l2.close))
local result="FLAT"
if magap0>magap1 and magap1>magap2  then
	if tonumber(s0.close) > tonumber(l0.close) and tonumber(s1.close) > tonumber(l1.close) 	and tonumber(s2.close)>tonumber(l2.close) then
	result="UPTREND"
	elseif tonumber(s0.close) < tonumber(l0.close) and tonumber(s1.close) < tonumber(l1.close) and tonumber(s2.close)<tonumber(l2.close) then
	result="DOWNTREND"
	end
end
return result
end
------------------------------
--------------------------------
function GetGraphValueByCandle(tag, candle_num, line)
--[[
tag - ��� �������\����������, candle_num - ����� ������������� �����(������)
������: 0 - ������� �����, 1 - ���������� ���, line - ����� ����� �������\����������
������� ���������� ����� �������������� ������, �� ���� �������
]]
    local CandleCount = getNumCandles(tag)
    local LinesCount = getLinesCount(tag)
    local c_num = candle_num
    if ( candle_num == nil or candle_num==0 ) then
        c_num = CandleCount-1
    end
    if (candle_num>0)then
        c_num = CandleCount-1-candle_num
    end
    if ( line == nil ) then
        line = 0
    end
    if (CandleCount == nil or LinesCount == nil) then
        message("qlib.GetGraphValueByCandle(): error occured, cannot aqquire candle or line data",3)
        return 0
    end
    if (tag == nil) then
        message("qlib.GetGraphValueByCandle(): error occured, tag is nil",3)
        return 0
    end
    t, num, legend = getCandlesByIndex(tag, line, c_num, 1)
    if ( num == 0 ) then
        message("qlib.GetGraphValueByCandle(): error occured, no candles aqquired",3)
        return 0
    end
    return t[0]
end
------------------------------
--[[
   Save Table to File
   Load Table from File
   v 1.0

   Lua 5.2 compatible

   Only Saves Tables, Numbers and Strings
   Insides Table References are saved
   Does not save Userdata, Metatables, Functions and indices of these
   ----------------------------------------------------
   table.save( table , filename )

   on failure: returns an error msg

   ----------------------------------------------------
   table.load( filename or stringtable )

   Loads a table that has been saved via the table.save function

   on success: returns a previously saved table
   on failure: returns as second argument an error msg
   ----------------------------------------------------

   Licensed under the same terms as Lua itself.
]]--
--do
   -- declare local variables
   --// exportstring( string )
   --// returns a "Lua" portable version of the string
   local function exportstring( s )
      return string.format("%q", s)
   end

   --// The Save Function
   function table.save(  tbl,filename )
      local charS,charE = "   ","\n"
      local file,err = io.open( filename, "wb" )
      if err then return err end

      -- initiate variables for save procedure
      local tables,lookup = { tbl },{ [tbl] = 1 }
      file:write( "return {"..charE )

      for idx,t in ipairs( tables ) do
         file:write( "-- Table: {"..idx.."}"..charE )
         file:write( "{"..charE )
         local thandled = {}

         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               file:write(  charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then

               local str = ""
               local stype = type( i )
               -- handle index
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end

               if str ~= "" then
                  stype = type( v )
                  -- handle value
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     file:write( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     file:write( str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     file:write( str..tostring( v )..","..charE )
                  end
               end
            end
         end
         file:write( "},"..charE )
      end
      file:write( "}" )
      file:close()
   end

   --// The Load Function
   function table.load( sfile )
      local ftables,err = loadfile( sfile )
      if err then return _,err end
      local tables = ftables()
      for idx = 1,#tables do
         local tolinki = {}
         for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
         end
         -- link indices
         for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
         end
      end
      return tables[1]
   end
-- close do
--end
