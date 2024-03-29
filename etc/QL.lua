LIBVERSION='0.5.4.3'
LIBVERSIONINT=543
-- �� ���� �������� ����� ������ ��� - forum.qlua.org 
package.cpath=".\\?.dll; .\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\loadall.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\loadall.dll;C:\\Program Files\\Lua\\5.1\\?.dll;C:\\Program Files\\Lua\\5.1\\?51.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files\\Lua\\5.1\\loadall.dll;C:\\Program Files\\Lua\\5.1\\clibs\\loadall.dll;"..package.cpath
package.path=package.path..";.\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.luac;C:\\Program Files\\Lua\\5.1\\lua\\?.lua;C:\\Program Files\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\?.lua;C:\\Program Files\\Lua\\5.1\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\lua\\?.luac;"
require"socket"
local math_floor=math.floor
local math_ceil=math.ceil
local math_random=math.random
local math_randomseed=math.randomseed
local string_format=string.format
local string_gsub=string.gsub
local string_gmatch=string.gmatch
local string_find=string.find
local string_lower=string.lower
local string_len=string.len
local string_sub=string.sub
local string_upper=string.upper
local table_insert=table.insert
local table_remove=table.remove
local RANDOM_SEED=socket.gettime()*10000

FUT_OPT_CLASSES="FUTUX,OPTUX,SPBOPT,SPBFUT"
DATETIME_MIN_VALUE={['day']=1,['week_day']=1,['hour']=0,['ms']=0,['min']=0,['month']=1,['sec']=0,['year']=1700}
DATETIME_MAX_VALUE={['day']=31,['week_day']=7,['hour']=23,['ms']=999,['min']=59,['month']=12,['sec']=59,['year']=9999}
-- Standart Colors
WHITE=16777215
BLACK=0
GREEN=32768
RED=255
LIGHT_GREEN=8454016
LIGHT_RED=8421631
ORANGE=33023
PURPLE=8388736
BLUE=16711680
YELLOW=65535
-- for custom colors you may use this tool http://www.colorspire.com/rgb-color-wheel/

-- terminal versions globals
VERSIONLESS6713=false
VERSIONLESS660118=false
TERMINAL_VERSION=getInfoParam('VERSION')
local ordernumberfieldname='order_num'
local securityfiledname='sec_code'
function versionLess(ver1,ver2)
	local begin,ver_1=0
	for ver_2 in string_gmatch(ver2,'%d+') do
		_,begin,ver_1=string_find(ver1,'(%d+)',begin+1)
		if ver_1~=ver_2 then return not ver_1 or ver_1+0<ver_2+0 end
	end
	return false
end
if versionLess(TERMINAL_VERSION,'6.7.1.3') then
	require"bit"
	VERSIONLESS6713=true
end
if versionLess(TERMINAL_VERSION,'6.6.0.118') then
	VERSIONLESS660118=true
	ordernumberfieldname='ordernum'
	securityfiledname='seccode'
end
if DEFAULT_COLOR==nil then DEFAULT_COLOR=-1 end
--if QTABLE_NO_INDEX==nil then QTABLE_NO_INDEX=-1 end
--[[
Trading Module
]]--
function sendLimit(class,security,direction,price,volume,account,client_code,comment,execution_condition,expire_date,market_maker)
	if string_find(FUT_OPT_CLASSES,class)~=nil then
		return sendLimitFO(class,security,direction,price,volume,account,comment,execution_condition,expire_date,market_maker)
	else
		return sendLimitSpot(class,security,direction,price,volume,account,client_code,comment,market_maker)
	end
end
function sendLimitFO(class,security,direction,price,volume,account,comment,execution_condition,expire_date,market_maker)
	-- �������� �������������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- �����! ���� ������ ���� �������� � ����������� ������ ����� ����� ��� ������ ������
	-- ���� ��� ������� ��� - ������������ ���� (��� ����-������)
	-- execution_condition ����� ��������� 2 �������� - FILL_OR_KILL(���������� ��� ���������),KILL_BALANCE(����� �������). ���� �������� �� ������ �� �� ��������� ��������� � �������. ��������! �������� ������ �� ������� �����!
	-- expire_date - ����������� ��� �������� ������ �� ������� �����
	-- market_maker - ������� ������ ������-�������. true\false
	-- ������ ������� ���������� 2 ���������
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil) then
		return nil,"QL.sendLimitFO(): Can`t send order. Nil parameters."
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="���� ������",
		["CLASSCODE"]=class,
		["���"]="��������������",
		["������� ����������"]="��������� � �������",
		["�����"]=class,
		["����������"]=security,
		["����������"]=string_format("%d",tostring(volume)),
		["����"]=toPrice(security,price,class),
		["�������� ����"]=tostring(account)
	}
	if direction=='B' then transaction['�/�']='�������' else transaction['�/�']='�������' end
	if comment~=nil then
		transaction['�����������']=string_sub(tostring(comment),0,20)
	else
		transaction['�����������']='QL'
	end
	if expire_date~=nil then
		transaction['���������� ������']='��'
		transaction['���� ����������']=tostring(expire_date)
	end
	if execution_condition~=nil then
		if string_upper(execution_condition)=='FILL_OR_KILL' then
			transaction["������� ����������"]='���������� ��� ���������'
		elseif string_upper(execution_condition)=='KILL_BALANCE' then
			transaction["������� ����������"]='����� �������'
		end
	end
	if market_maker~=nil and market_maker then
		transaction['MARKET_MAKER_ORDER']='YES'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendLimitFO():"..res
	else
		return trans_id, "QL.sendLimitFO(): Limit order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendLimitSpot(class,security,direction,price,volume,account,client_code,comment,market_maker)
	-- �������� �������������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- �����! ���� ������ ���� �������� � ����������� ������ ����� ����� ��� ������ ������
	-- ���� ��� ������� ��� - ������������ ����
	-- market_maker - ������� ������ ������-�������. true\false
	-- ������ ������� ���������� 2 ���������
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil) then
		return nil,"QL.sendLimitSpot(): Can`t send order. Nil parameters."
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=string_format("%d",tostring(volume)),
		["PRICE"]=toPrice(security,price,class),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if comment~=nil then
		transaction.client_code=string_sub(transaction.client_code..'/'..tostring(comment),0,20)
	else
		transaction.client_code=string_sub(transaction.client_code,0,20)
	end
	if market_maker~=nil and market_maker then
		transaction['MARKET_MAKER_ORDER']='YES'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendLimitSpot():"..res
	else
		return trans_id, "QL.sendLimitSpot(): Limit order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendIceberg(class,security,direction,price,show_volume,volume,account,client_code,comment)
	-- �������� �������������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- �����! ���� ������ ���� �������� � ����������� ������ ����� ����� ��� ������ ������
	-- ���� ��� ������� ��� - ������������ ����
	-- market_maker - ������� ������ ������-�������. true\false
	-- ������ ������� ���������� 2 ���������
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or show_volume==nil or account==nil or client_code==nil) then
		return nil,"QL.sendIceberg(): Can`t send order. Nil parameters."
	end
	
	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="���� ������� ������",
		["CLASSCODE"]=class,
		["�����"]=class,
		["����������"]=security,
		["����"]=string_format("%d",tostring(volume)),
		["������� ����������"]=string_format("%d",tostring(show_volume)),
		["����"]=toPrice(security,price,class),
		["�������� ����"]=tostring(account),
		["����������"]=tostring(client_code),
		["���"]="��������������",
		["��� �� ����"]="�� ������ �����",
		["��� �� �������"]="��������� � �������",
		["��� ����� �������� ����"]="�� ����",
	}
	
	if direction=='B' then transaction['�/�']='�������' else transaction['�/�']='�������' end
	
	if comment~=nil then
		transaction["����������"]=string_sub(transaction.client_code..'/'..tostring(comment),0,20)
	else
		transaction["����������"]=string_sub(transaction.client_code..'/QL',0,20)
	end
	if market_maker~=nil and market_maker then
		transaction['MARKET_MAKER_ORDER']='YES'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendLimitSpot():"..res
	else
		return trans_id, "QL.sendLimitSpot(): Limit order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendMarket(class,security,direction,volume,account,client_code,comment)
	-- �������� �������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ������ ������� ���������� 2 ���������
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil  or volume==nil or account==nil) then
		return nil,"QL.sendMarket(): Can`t send order. Nil parameters."
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["TYPE"]="M",
		["QUANTITY"]=string_format("%d",tostring(volume)),
		["ACCOUNT"]=account
	}
	if client_code==nil then
		transaction.client_code=account
	else
		transaction.client_code=client_code
	end
	if string_find(FUT_OPT_CLASSES,class)~=nil then
		local sign=0
		if direction=="B" then
			transaction.price=getParamEx(class,security,"pricemax").param_value
			if transaction.price==0 then
				transaction.price=getParamEx(class,security,"offer").param_value+10*getParamEx(class,security,"SEC_PRICE_STEP").param_value
			end
			--toLog(Log,'IN pricemax ='..transaction.price)
			sign=1
		else
			transaction.price=getParamEx(class,security,"pricemin").param_value
			--firat chance
			if transaction.price==0 then
				transaction.price=getParamEx(class,security,"bid").param_value-10*getParamEx(class,security,"SEC_PRICE_STEP").param_value
			end
			--toLog(Log,'IN pricemin ='..transaction.price)
			sign=-1
		end
		-- last chance
		if transaction.price==0 then
			transaction.price=getParamEx(class,security,"last").param_value+sign*10*getParamEx(class,security,"SEC_PRICE_STEP").param_value
		end
		transaction.price=toPrice(security,transaction.price,class)
	else
		transaction.price="0"
	end
	if comment~=nil then
		transaction.client_code=string_sub(transaction.client_code..'/'..tostring(comment),0,20)
	else
		transaction.client_code=string_sub(transaction.client_code..'/QL',0,20)
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendMarket():"..res
	else
		return trans_id, "QL.sendMarket(): Market order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id..' Price='..transaction.price
	end
end
function sendStop(class,security,direction,stopprice,dealprice,volume,account,exp_date,client_code,comment)
	-- �������� ������� ����-������
	-- ��� ��������� ����� ���� �������,���������� � ������� ����� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ���� ����� ����� �� ������� - �� ������ "�� ������"
	-- ������ ������� ���������� 2 ���������
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or stopprice==nil or volume==nil or account==nil or dealprice==nil) then
		return nil,"QL.sendStop(): Can`t send order. Nil parameters."
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_STOP_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=string_format("%d",tostring(volume)),
		["STOPPRICE"]=toPrice(security,stopprice,class),
		["PRICE"]=toPrice(security,dealprice,class),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if exp_date==nil then
		transaction["EXPIRY_DATE"]="GTC"
	else
		transaction['EXPIRY_DATE']=tostring(exp_date)
	end
	if comment~=nil then
		transaction.client_code=string_sub(transaction.client_code..'/'..tostring(comment),0,20)
	else
		transaction.client_code=string_sub(transaction.client_code..'/QL',0,20)
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendStop():"..res
	else
		return trans_id, "QL.sendStop(): Stop-order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." StopPrice="..stopprice.." DealPrice="..dealprice.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendTPSL(class,security,direction,price,volume,tpoffset,sloffset,maxoffset,defspread,account,exp_date,client_code,comment)
	-- �������� ������� ����-������
	-- ��� ��������� ����� ���� �������,���������� � ������� ����� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ���� ����� ����� �� ������� - �� ������ "�� ������"
	-- ������ ������� ���������� 2 ���������
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or stopprice==nil or volume==nil or account==nil or dealprice==nil) then
		return nil,"QL.sendStop(): Can`t send order. Nil parameters."
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_STOP_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=string_format("%d",tostring(volume)),
		["STOPPRICE"]=toPrice(security,stopprice,class),
		["PRICE"]=toPrice(security,dealprice,class),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if exp_date==nil then
		transaction["EXPIRY_DATE"]="GTC"
	else
		transaction['EXPIRY_DATE']=tostring(exp_date)
	end
	if comment~=nil then
		transaction.comment=tostring(comment)
		if string_find(FUT_OPT_CLASSES,class)~=nil then	transaction.client_code=string_sub('/QL'..comment,0,20) else transaction.client_code=string_sub(transaction.client_code..'//QL'..comment,0,20) end
	else
		transaction.comment=tostring(comment)
		if string_find(FUT_OPT_CLASSES,class)~=nil then	transaction.client_code=string_sub('/QL',0,20) else transaction.client_code=string_sub(transaction.client_code..'//QL',0,20) end
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendStop():"..res
	else
		return trans_id, "QL.sendStop(): Stop-order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." StopPrice="..stopprice.." DealPrice="..dealprice.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendTakeProfitAndStopLimit(class,security, direction, price, stopprice, stopprice2, volume, offset, offsetunits, deffspread, deffspreadunits, account, exp_date, client_code, comment)

   if class==nil or security==nil or direction==nil or price==nil or stopprice==nil or stopprice2==nil or volume==nil or account==nil or offset==nil or offsetunits==nil or deffspread==nil or deffspreadunits==nil then
      return nil, "QL.sendTakeProfitAndStopLimit(): Can`t send order. Nil parameters.";
   end

   local trans_id = random_max();
   
   local transaction = {
      ["TRANS_ID"]           = tostring(trans_id),
      ["ACTION"]             = "NEW_STOP_ORDER",
      ["CLASSCODE"]          = class,
      ["SECCODE"]            = security,
      ["STOP_ORDER_KIND"]    = 'TAKE_PROFIT_AND_STOP_LIMIT_ORDER',
      ["OPERATION"]          = direction,
      ["QUANTITY"]           = string_format("%d", tostring(volume)),
      ["PRICE"]              = toPrice(security, price, class),       -- ���� ������, �� ������� �����������.
      ["STOPPRICE"]          = toPrice(security, stopprice, class),   -- ����-������
      ["STOPPRICE2"]         = toPrice(security, stopprice2, class),  -- ����-�����
      ["OFFSET_UNITS"]       = offsetunits,
      ["SPREAD_UNITS"]       = deffspreadunits,
      ["OFFSET"]             = tostring(offset),
      ["SPREAD"]             = tostring(deffspread),
      ["ACCOUNT"]            = tostring(account),
      ["MARKET_STOP_LIMIT"]  = "NO",
      ["MARKET_TAKE_PROFIT"] = "NO",
      ["ACCOUNT"]            = tostring(account),
   }
   
   if client_code == nil then
      transaction.client_code = tostring(account);
   else
      transaction.client_code = tostring(client_code);
   end
   
   if exp_date == nil then
      transaction["EXPIRY_DATE"] = "GTC";
   else
      transaction['EXPIRY_DATE'] = tostring(exp_date);
   end
   
   if comment ~= nil then
      transaction.client_code = string_sub(transaction.client_code .. '/' .. tostring(comment), 0, 20);
   else
      transaction.client_code = string_sub(transaction.client_code .. '/QL', 0, 20);
   end
   
   local res = sendTransaction(transaction);
   
   if res ~= "" then
      return nil, "QL.sendTakeProfitAndStopLimit():" .. res;
   else
      return trans_id, "QL.sendTakeProfitAndStopLimit(): Take-profit-and-Stop-Limit sended sucesfully. Class=" ..class.. " Sec=" ..security.. " Dir=" ..direction.. " Price=" ..price.. " Offset=" ..offset.. ' OffsetUnits=' ..offsetunits.. ' Spread=' ..deffspread.. ' SpreadUnits=' ..deffspreadunits.. " Vol=" ..volume.. " Acc=" ..account.. " Trans_id=" ..trans_id;
   end
   
end
function sendTake(class,security,direction,price,volume,offset,offsetunits,deffspread,deffspreadunits,account,exp_date,client_code,comment)
	-- �������� ������� ����-������
	-- ��� ��������� ����� ���� �������,���������� � ������� ����� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ���� ����� ����� �� ������� - �� ������ "�� ������"
	-- ������ ������� ���������� 2 ���������
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil or offset==nil or offsetunits==nil or deffspread==nil or deffspreadunits==nil) then
		return nil,"QL.sendTake(): Can`t send order. Nil parameters."
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_STOP_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["STOP_ORDER_KIND"]='TAKE_PROFIT_STOP_ORDER',
		["OPERATION"]=direction,
		["QUANTITY"]=string_format("%d",tostring(volume)),
		["STOPPRICE"]=toPrice(security,price,class),
		["OFFSET_UNITS"]=offsetunits,
		["SPREAD_UNITS"]=deffspreadunits,
		["OFFSET"]=tostring(offset),
		["SPREAD"]=tostring(deffspread),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if exp_date==nil then
		transaction["EXPIRY_DATE"]="GTC"
	else
		transaction['EXPIRY_DATE']=tostring(exp_date)
	end
	if comment~=nil then
		transaction.client_code=string_sub(transaction.client_code..'/'..tostring(comment),0,20)
	else
		transaction.client_code=string_sub(transaction.client_code..'/QL',0,20)
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendTake():"..res
	else
		return trans_id, "QL.sendTake(): Take-profit sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Offset="..offset..' OffsetUnits='..offsetunits..' Spread='..deffspread..' SpreadUnits='..deffspreadunits.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function moveOrder(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	-- ����������� ������
	-- ����������� ����� ���������� mode,fo_number,fo_p
	-- � ����������� �� ������ ������ ������ ����� ������� ������� ����������� ���� ��� ���� ���� �������� �����
	if (fo_number==nil or fo_p==nil or mode==nil) then
		return nil,"QL.moveOrder(): Can`t move order. Nil parameters."
	end
	local forder=getRowFromTable("orders",ordernumberfieldname,fo_number)
	if forder==nil then
		return nil,"QL.moveOrder(): Can`t find order_number="..fo_number.." in orders table!"
	end
	if string_find(FUT_OPT_CLASSES,forder.class_code)~=nil then
		return moveOrderFO(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	else
		return moveOrderSpot(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	end
end
function moveOrderSpot(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	-- ����������� ������ ��� ����� ����
	-- ����������� ����� ���������� mode,fo_number,fo_p
	-- ���������� 2 ���������� ������+���������� ��� ������ �� ��������� ������
	-- ���������� 2 ��������� :
	-- 1. Nil - ���� ������� ��� ����� ���������� (2-� ���� 2 ������)
	-- 2. �������������� ���������
	if (fo_number==nil or fo_p==nil) then
		return nil,"QL.moveOrderSpot(): Can`t move order. Nil parameters."
	end
	local forder=getRowFromTable("orders",ordernumberfieldname,fo_number)
	if forder==nil then
		return nil,"QL.moveOrderSpot(): Can`t find order_number="..fo_number.." in orders table!"
	end
	if (orderflags2table(forder.flags).cancelled or (orderflags2table(forder.flags).done and forder.balance==0)) then
		return nil,"QL.moveOrderSpot(): Can`t move cancelled or done order!"
	end
	if mode==0 then
		--���� MODE=0, �� ������ � ��������, ���������� ����� ������ FIRST_ORDER_NUMBER � SECOND_ORDER_NUMBER, ���������.
		--� �������� ������� ������������ ��� ����� ������, ��� ���� ���������� ������ ���� ������, ���������� �������� �������;
		if so_number~=nil and so_p~=nil then
			_,ms=killOrder(fo_number,forder[securityfiledname],forder.class_code)
			--toLog("ko.txt",ms)
			trid,ms1=sendLimit(forder.class_code,forder[securityfiledname],orderflags2table(forder.flags).operation,fo_p,tostring(forder.balance),forder.account,forder.client_code,forder.comment)
			local sorder=getRowFromTable("orders",ordernumberfieldname,so_number)
			if sorder==nil then
				return nil,"QL.moveOrderSpot(): Can`t find order_number="..so_number.." in orders table!"
			end
			_,ms=killOrder(so_number,sorder[securityfiledname],sorder.class_code)
			--toLog("ko.txt",ms)
			trid2,ms2=sendLimit(sorder.class_code,sorder[securityfiledname],orderflags2table(sorder.flags).operation,so_p,tostring(sorder.balance),sorder.account,sorder.client_code,sorder.comment)
			if trid~=nil and trid2~=nil then
				return trid2,"QL.moveOrderSpot(): Orders moved. Trans_id1="..trid.." Trans_id2="..trid2
			else
				return nil,"QL.moveOrderSpot(): One or more orders not moved! Msg1="..ms1.." Msg2="..ms2
			end
		else
			_,ms=killOrder(fo_number,forder[securityfiledname],forder.class_code)
			--toLog("ko.txt",ms)
			local trid,ms=sendLimit(forder.class_code,forder[securityfiledname],orderflags2table(forder.flags).operation,fo_p,tostring(forder.balance),forder.account,forder.client_code,forder.comment)
			if trid~=nil then
				return trid,"QL.moveOrderSpot(): Order moved. Trans_Id="..trid
			else
				return nil,"QL.moveOrderSpot(): Order not moved! Msg="..ms
			end
		end
	elseif mode==1 then
		--���� MODE=1, �� ������ � ��������, ���������� ����� ������ FIRST_ORDER_NUMBER � SECOND_ORDER_NUMBER, ���������.
		--� �������� ������� ������������ ��� ����� ������, ��� ���� ��������� ��� ���� ������, ��� � ����������;
		if so_number~=nil and so_p~=nil and so_q~=nil then
			_,_=killOrder(fo_number,forder[securityfiledname],forder.class_code)
			local trid,ms1=sendLimit(forder.class_code,forder[securityfiledname],orderflags2table(forder.flags).operation,fo_p,tostring(fo_q),forder.account,forder.client_code,forder.comment)
			local sorder=getRowFromTable("orders",ordernumberfieldname,so_number)
			if sorder==nil then
				return nil,"QL.moveOrderSpot(): Can`t find order_number="..so_number.." in orders table!"
			end
			_,_=killOrder(so_number,sorder[securityfiledname],sorder.class_code)
			local trid2,ms2=sendLimit(sorder.class_code,sorder[securityfiledname],orderflags2table(sorder.flags).operation,so_p,tostring(so_q),sorder.account,sorder.client_code,sorder.comment)
			if trid~=nil and trid2~=nil then
				return trid2,"QL.moveOrderSpot(): Orders moved. Trans_id1="..trid.." Trans_id2="..trid2
			else
				return nil,"QL.moveOrderSpot(): One or more orders not moved! Msg1="..ms1.." Msg2="..ms2
			end
		else
			_,_=killOrder(fo_number,forder[securityfiledname],forder.class_code)
			local trid,ms=sendLimit(forder.class_code,forder[securityfiledname],orderflags2table(forder.flags).operation,fo_p,tostring(fo_q),forder.account,forder.client_code,forder.comment)
			if trid~=nil then
				return trid,"QL.moveOrderSpot(): Order moved. Trans_Id="..trid
			else
				return nil,"QL.moveOrderSpot(): Order not moved! Msg="..ms
			end
		end
	elseif mode==2 then
		--���� MODE=2,  �� ������ � ��������, ���������� ����� ������ FIRST_ORDER_NUMBER � SECOND_ORDER_NUMBER, ���������.
		--���� ���������� ����� � ������ �� ������ ������ ��������� �� ����������, ���������� ����� FIRST_ORDER_NEW_QUANTITY � SECOND_ORDER_NEW_QUANTITY, �� � �������� ������� ������������ ��� ����� ������ � ���������������� �����������.
		if so_number~=nil and so_p~=nil and so_q~=nil then
			local sorder=getRowFromTable("orders",ordernumberfieldname,so_number)
			if sorder==nil then
				return nil,"QL.moveOrderSpot(): Can`t find order_number="..so_number.." in orders table!"
			end
			_,_=killOrder(fo_number,forder[securityfiledname],forder.class_code)
			_,_=killOrder(so_number,sorder[securityfiledname],sorder.class_code)
			if forder.balance==fo_q and sorder.balance==so_q then
				local trid,ms1=sendLimit(forder.class_code,forder[securityfiledname],orderflags2table(forder.flags).operation,fo_p,tostring(fo_q),forder.account,forder.client_code,forder.comment)
				local trid2,ms2=sendLimit(sorder.class_code,sorder[securityfiledname],orderflags2table(sorder.flags).operation,so_p,tostring(so_q),sorder.account,sorder.client_code,sorder.comment)
				if trid~=nil and trid2~=nil then
					return trid2,"QL.moveOrderSpot(): Orders moved. Trans_id1="..trid.." Trans_id2="..trid2
				else
					return nil,"QL.moveOrderSpot(): One or more orders not moved! Msg1="..ms1.." Msg2="..ms2
				end
			else
				return nil,"QL.moveOrderSpot(): Mode=2. Orders balance~=new_quantity"
			end
		else
			_,_=killOrder(fo_number,forder[securityfiledname],forder.class_code)
			local trid,ms=sendLimit(forder.class_code,forder[securityfiledname],orderflags2table(forder.flags).operation,fo_p,tostring(fo_q),forder.account,forder.client_code,forder.comment)
			if trid~=nil then
				return trid,"QL.moveOrderSpot(): Order moved. Trans_Id="..trid
			else
				return nil,"QL.moveOrderSpot(): Order not moved! Msg="..ms
			end
		end
	else
		return nil,"QL.moveOrder(): Mode out of range! Mode can be from {0,1,2}"
	end
end
function moveOrderFO(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	-- ����������� ������ ��� �������� �����
	-- �������� "����������" ���������� �����
	if (fo_number==nil or fo_p==nil or mode==nil) then
		return nil,"QL.moveOrderFO(): Can`t move order. Nil parameters."
	end
	local transaction={}
	if mode==0 then
		if so_number~=nil and so_p~=nil then
			transaction["SECOND_ORDER_NUMBER"]=tostring(so_number)
			transaction["SECOND_ORDER_NEW_PRICE"]=so_p
			transaction["SECOND_ORDER_NEW_QUANTITY"]="0"
		end
		transaction["FIRST_ORDER_NUMBER"]=tostring(fo_number)
		transaction["FIRST_ORDER_NEW_PRICE"]=fo_p
		transaction["FIRST_ORDER_NEW_QUANTITY"]="0"
		transaction["MODE"]=tostring(mode)
	elseif mode==1 then
		if fo_q==nil or fo_q==0 then
			return nil,"QL.moveOrder(): Mode=1. First Order Quantity can`t be nil or zero!"
		end
		if so_number~=nil and so_p~=nil and so_q>0 then
			transaction["SECOND_ORDER_NUMBER"]=tostring(so_number)
			transaction["SECOND_ORDER_NEW_PRICE"]=so_p
			transaction["SECOND_ORDER_NEW_QUANTITY"]=tostring(so_q)
		end
		transaction["FIRST_ORDER_NUMBER"]=tostring(fo_number)
		transaction["FIRST_ORDER_NEW_PRICE"]=fo_p
		transaction["FIRST_ORDER_NEW_QUANTITY"]=tostring(fo_q)
		transaction["MODE"]=tostring(mode)
	elseif mode==2 then
		if fo_q==nil or fo_q==0 then
			return nil,"QL.moveOrder(): Mode=2. First Order Quantity can`t be nil or zero!"
		end
		if so_number~=nil and so_p~=nil and so_q>0 then
			transaction["SECOND_ORDER_NUMBER"]=tostring(so_number)
			transaction["SECOND_ORDER_NEW_PRICE"]=so_p
			transaction["SECOND_ORDER_NEW_QUANTITY"]=tostring(so_q)
		end
		transaction["FIRST_ORDER_NUMBER"]=tostring(fo_number)
		transaction["FIRST_ORDER_NEW_PRICE"]=fo_p
		transaction["FIRST_ORDER_NEW_QUANTITY"]=tostring(fo_q)
		transaction["MODE"]=tostring(mode)
	else
		return nil,"QL.moveOrder(): Mode out of range! mode can be from {0,1,2}"
	end

	local trans_id=random_max()
	local order=getRowFromTable("orders",ordernumberfieldname,fo_number)
	if order==nil then
		return nil,"QL.moveOrderFO(): Can`t find order_number="..fo_number.." in orders table!"
	end
	transaction["TRANS_ID"]=tostring(trans_id)
	transaction["CLASSCODE"]=order.class_code
	transaction["SECCODE"]=order[securityfiledname]
	transaction["ACTION"]="MOVE_ORDERS"

	--toLog("move.txt",transaction)
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.moveOrderFO():"..res
	else
		return trans_id, "QL.moveOrderFO(): Move order sended sucesfully. Mode="..mode.." FONumber="..fo_number.." FOPrice="..fo_p
	end
end
function sendRPS(class,security,direction,price,volume,account,client_code,partner)
    -- ������� �������� ������ �� ����������� ������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil or partner==nil) then
		return nil,"QL.sendRPS(): Can`t send order. Nil parameters."
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_NEG_DEAL",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=volume,
		["PRICE"]=price,
		["ACCOUNT"]=account,
		["PARTNER"]=partner,
		["SETTLE_CODE"]="B0"
	}
	if client_code==nil then
		transaction.client_code=account
	else
		transaction.client_code=client_code
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendRPS():"..res
	else
		return trans_id, "QL.sendRPS(): RPS order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Partner="..partner.." Trans_id="..trans_id
	end
end
function sendReportOnRPS(class,operation,key)
    -- �������� ������ �� ������ ��� ����������
	if(class==nil or operation==nil or key==nil) then
		return nil,"QL.sendRPS(): Can`t send order. Nil parameters."
	end
	--local trans_id=tostring(math.ceil(os.clock()))..tostring(math.random(os.clock()))

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_REPORT",
		["CLASSCODE"]=class,
		["NEG_TRADE_OPERATION"]=operation,
		["NEG_TRADE_NUMBER"]=key
	}
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendReportOnRPS():"..res
	else
		return trans_id, "QL.sendReportOnRPS(): ReportOnRPS order sended sucesfully. Class="..class.." Oper="..operation.." Key="..key.." Trans_id="..trans_id
	end
end
function killOrder(orderkey,security,class)
	-- ������� ������ �������������� ������ �� ������
	-- ��������� ������� 1 �������
	-- �����! ������ ������� �� ����������� ������ ������
	-- ���������� ��������� ������� � ������ ������ ���������� �������� ���� ���� ������ � ����������� � ����������
	if orderkey==nil or tonumber(orderkey)==0 then
		return nil,"QL.killOrder(): Can`t kill order. OrderKey nil or zero"
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="KILL_ORDER",
		["ORDER_KEY"]=tostring(orderkey)
	}
	if security then
		transaction.seccode=security
		transaction.classcode=class or getSecurityInfo("",security).class_code
	else
		local order=getRowFromTable("orders",ordernumberfieldname,orderkey)
		if order==nil then return nil,"QL.killOrder(): Can`t kill order. No such order in Orders table." end
		transaction.classcode=order.class_code
		transaction.seccode=order[securityfiledname]
	end
	--toLog("ko.txt",transaction)
	local res=sendTransaction(transaction)
	if res~="" then
		return nil,"QL.killOrder(): "..res
	else
		return trans_id,"QL.killOrder(): Limit order kill sended. Class="..transaction.classcode.." Sec="..transaction.seccode.." Key="..orderkey.." Trans_id="..trans_id
	end
end
function killStopOrder(orderkey,security,class)
	-- ������� ������ ����-������ �� ������
	-- ��������� ������� 1 �������
	-- �����! ������ ������� �� ����������� ������ ������
	-- ���������� ��������� ������� � ������ ������ ���������� �������� ���� ���� ������ � ����������� � ����������
	if orderkey==nil or tonumber(orderkey)==0 then
		return nil,"QL.killStopOrder(): Can`t kill order. OrderKey nil or zero"
	end

	local trans_id=random_max()
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="KILL_STOP_ORDER",
		["STOP_ORDER_KEY"]=tostring(orderkey)
	}
	if security==nil or class==nil then
		local order=getRowFromTable("stop_orders",ordernumberfieldname,orderkey)
		if order==nil then return nil,"QL.killStopOrder(): Can`t kill order. No such order in StopOrders table." end
		transaction.classcode=order.class_code
		transaction.seccode=order[securityfiledname]
	else
		transaction.seccode=security
		transaction.classcode=class
	end
	--toLog("ko.txt",transaction)
	if string_find(FUT_OPT_CLASSES,transaction.classcode)~=nil then transaction['BASE_CONTRACT']=getParamEx(transaction.classcode,transaction.seccode,'optionbase').param_image end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil,"QL.killStopOrder(): "..res
	else
		return trans_id,"QL.killStopOrder(): Stop-order kill sended. Class="..transaction.classcode.." Sec="..transaction.seccode.." Key="..orderkey.." Trans_id="..trans_id
	end
end
function killAllOrders(table_mask)
	-- ������ ������� �������� ���������� �� ������ �������� ������ ��������������� ������� ���������� ��� �������� �������� table_mask
	-- ������ ���� ��������� ����������  : ACCOUNT,CLASSCODE,SECCODE,OPERATION,CLIENT_CODE,COMMENT
	-- ���� ������� ������� � ���������� nil - �������� ��� �������� ������
	local i,key,val,result_num=0,0,0,0
	local tokill=true
	local row={}
	local result_str=""

	for i=0,getNumberOf("orders")-1,1 do
		row=getItem("orders",i)
		tokill=false
		--toLog(log,"Row "..i.." onum="..row.order_num)
		if orderflags2table(row.flags).active then
			tokill=true
			--toLog(log,"acitve")
			if table_mask~=nil then
				for key,val in pairs(table_mask) do
					--toLog(log,"check key="..key.." val="..val)
					--toLog(log,"strlowe="..string.lower(key).." row="..row[string.lower(key)].." tbl="..val)
					if string_lower(key)=='comment' then
						if string_find(string_lower(row.brokerref),string_lower(val))==nil then	tokill=false break end
					else
						if row[string_lower(key)]~=val then tokill=false	break end
					end
				end
			end
		end
		if tokill then
			--toLog(log,"kill onum"..row.order_num)
			res,ms=killOrder(tostring(row.order_num),row[securityfiledname],row.class_code)
			result_num=result_num+1
			--toLog(log,ms)
			if res then
				result_str=result_str..row.order_num..","
			else
				result_str=result_str.."!"..row.order_num..","
			end
		end
	end
	return true,"QL.killAllOrders(): Sended "..result_num.." transactions. order_nums:"..result_str
end
function killAllStopOrders(table_mask)
	-- ������ ������� �������� ���������� �� ������ �������� ����-������ ��������������� ������� ���������� ��� �������� �������� table_mask
	-- ������ ���� ��������� ����������  : ACCOUNT,CLASSCODE,SECCODE,OPERATION,CLIENT_CODE,COMMENT
	-- ���� ������� ������� � ���������� nil - �������� ��� �������� ������
	local i,key,val,result_num=0,0,0,0
	local tokill=true
	local row={}
	local result_str=""
	for i=0,getNumberOf("stop_orders")-1,1 do
		row=getItem("stop_orders",i)
		tokill=false
		--toLog(log,"Row "..i.." onum="..row.order_num)
		if stoporderflags2table(row.flags).active then
			tokill=true
			--toLog(log,"acitve")
			if table_mask~=nil then
				for key,val in pairs(table_mask) do
					--toLog(log,"check key="..key.." val="..val)
					--toLog(log,"strlowe="..string.lower(key).." row="..row[string.lower(key)].." tbl="..val)
					if string_lower(key)=='comment' then
						if string_find(string_lower(row.brokerref),string_lower(val))==nil then	tokill=false break end
					else
						if row[string_lower(key)]~=val then tokill=false	break end
					end
				end
			end
		end
		if tokill then
			--toLog(log,"kill onum"..row.order_num)
			res,ms=killStopOrder(tostring(row.order_num),row[securityfiledname],row.class_code)
			result_num=result_num+1
			--toLog(log,ms)
			if res then
				result_str=result_str..row.order_num..","
			else
				result_str=result_str.."!"..row.order_num..","
			end
		end
	end
	return true,"QL.killAllStopOrders(): Sended "..result_num.." transactions. order_nums:"..result_str
end
function getPosition(security,account,limit_kind,class_code)
    --���������� ������ ������� �� �����������  � ���� ������������
	-- ��� �������� ����� �������� ����� �����, ��� ����-����� ���-�������
	-- ����� ��� ����-����� ���� ����������� ������� ��� ������ (�� ��������� 0!)
	if class_code==nil then class_code=getSecurityInfo("",security).class_code end
    if string_find(FUT_OPT_CLASSES,class_code)~=nil then
	--futures
		for i=1,getNumberOf("futures_client_holding") do
			local row=getItem("futures_client_holding",i)
			if row~=nil and row[securityfiledname]==security and row.trdaccid==account then
				return tonumber(row['totalnet']),tonumber(getParamEx(class_code,security,'last').param_value)
			end
		end
	else
	-- spot
		--toLog(log,'posnum='..getNumberOf("depo_limits"))
		for i=1,getNumberOf("depo_limits") do
			local row=getItem("depo_limits",i)
			--toLog(log,row)
			if row~=nil and row[securityfiledname]==security and row.client_code==account  and (row.limit_kind==limit_kind or 0) then
				return tonumber(row['currentbal']), tonumber(row['awg_position_price'])
			end
		end
	end
    return 0,0
end
--[[
Quik Table class QTable
-- only for Quik version 6.6+
]]
QTable ={}
QTable.__index = QTable
function QTable:new()
     -- ������� � ���������������� ��������� ������� QTable
	 if VERSIONLESS660118 then message("QTable: Quik Tables available ONLY in Quik 6.6+ version!",1) return nil end
	 local t_id = AllocTable()
     if t_id then
        q_table = {}
        setmetatable(q_table, QTable)
        q_table.t_id=t_id
        q_table.caption = ""
        q_table.created = false
		q_table.curr_col=0
		q_table.curr_line=0
        --������� � ��������� ���������� ��������
        q_table.columns={}
		--������� � ������� ��������
		q_table.data={}
         return q_table
     else
         return nil
     end
end
function QTable:Show()
	-- ���������� � ��������� ���� � ��������� ��������
	CreateWindow(self.t_id)
	if self.caption ~="" then
		-- ������ ��������� ��� ����
		SetWindowCaption(self.t_id, tostring(self.caption))
	end
	self.created = true
end
function QTable:IsClosed()
     --���� ���� � �������� �������, ���������� �true�
	 return IsWindowClosed(self.t_id)
end
function QTable:delete()
     -- ������� �������
     return DestroyTable(self.t_id)
end
function QTable:GetCaption()
	-- ���������� ������, ���������� ��������� �������
	if not IsWindowClosed(self.t_id) then
		self.caption = GetWindowCaption(self.t_id)
	end
	return self.caption
end
function QTable:SetCaption(s)
   -- ������ ��������� ������� (��� ���������� ��������������� ���, ���� ��� ������� ����� ����������)
   self.caption = s or self.caption
   if IsWindowClosed(self.t_id) then return nil end
   return SetWindowCaption(self.t_id, tostring(self.caption))
end
function QTable:AddColumn(name, c_type, width, ff )
    -- �������� �������� ������� name ���� C_type � �������
	-- ff � ������� �������������� ������ ��� �����������
	local col_desc={}
	self.curr_col=self.curr_col+1
    col_desc.c_type = c_type
	col_desc.format_function = ff
    col_desc.id = self.curr_col
	self.columns[name] = col_desc
    -- name ������������ � �������� ��������� �������
    return AddColumn(self.t_id, self.curr_col, name, true, c_type, width)
end
function QTable:Clear()
   -- �������� �������
   self.data={}
   self.curr_line=0
   return Clear(self.t_id)
end
function QTable:SetValue(row, col_name, data, formatted)
	-- ���������� �������� � ������
	local col_ind = self.columns[col_name].id or nil
	if col_ind == nil then
		return false
	end
	local col_type = self.columns[col_name].c_type
	if self.data[row][col_ind]==data then return true end
	self.data[row][col_ind]=data
	local col_type = self.columns[col_name].c_type
	-- ���� ��� ��������� ������� ���� ���������� ��������, �� ��������� � ���� tonumber
	if type(data) ~= "number" and (col_type==QTABLE_INT_TYPE or col_type==QTABLE_DOUBLE_TYPE or col_type==QTABLE_INT64_TYPE) then
		data = tonumber(data) or 0
	end
	-- ���� ��� ������������ �������� ��� ��� ����������������� �������, �� ������� ������������ ��
	if formatted and col_type~=QTABLE_STRING_TYPE and col_type~=QTABLE_CACHED_STRING_TYPE then
		return SetCell(self.t_id, row, col_ind, formatted, data)
	end
	-- ���� ��� ������� ������ ������� ��������������, �� ��� ������������
	local ff = self.columns[col_name].format_function
	if type(ff) == "function" then
		-- � �������� ���������� ������������� ������������
		-- ��������� ���������� ������� ��������������
		if col_type==QTABLE_STRING_TYPE or col_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, ff(data))
		else
			return SetCell(self.t_id, row, col_ind, ff(data), data)
		end
	else
		if col_type==QTABLE_STRING_TYPE or col_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, tostring(data))
		else
			return SetCell(self.t_id, row, col_ind, tostring(data), data)
		end
	end
end
function QTable:AddLine(key)
   -- ��������� ������ ������� � ����� key ��� � ����� ������� � ���������� �� �����
   local line=InsertRow(self.t_id, key or -1)
   if line==-1 then return nil else self.curr_line=self.curr_line+1 table_insert(self.data,line,{}) return line end
end
function QTable:DeleteLine(key)
   -- ������� ������� � ����� key ��� � ����� �������
   key = key or self.curr_line
   self.curr_line=self.curr_line-1
   table_remove(self.data,key)
   return DeleteRow(self.t_id,key)
end
function QTable:GetSize()
     -- ���������� ������ �������, ���������� ����� � ��������
     return GetTableSize(self.t_id)
end
function QTable:GetValue(row, name)
	 -- �������� ������ �� ������ �� ������ ������ � ����� �������
	 local t={}
	 local col_ind = self.columns[name].id
     if col_ind == nil then
		return nil
     end
	 t = GetCell(self.t_id, row, col_ind)
     return t
end
function QTable:SetPosition(x, y, dx, dy)
	-- ������ ���������� ����: x,y - ���������� ������ �������� ����; dx,dy - ������ � ������
	-- ��� �� GetPosition � SetSizeSuitable ���������� ������� ���� � ����� SetPosition ��� ���������� ������ ���� �� �� �����
	self.x, self.y, self.dx, self.dy = (x or self.x), (y or self.y), (dx or self.dx), (dy or self.dy)
	return SetWindowPos(self.t_id, self.x, self.y, self.dx, self.dy)
end
function QTable:GetPosition(size_wnd_title)
	-- ���������� ���������� ���� (x, y, dx, dy), ������ ��� SetPosition: x,y - ���������� ������ �������� ����; dx,dy - ������ � ������
	if not IsWindowClosed(self.t_id) then
		local top, left, bottom, right = GetWindowRect(self.t_id)
		self.x, self.y, self.dx, self.dy = left, top-(size_wnd_title or 60), right-left, bottom-top
	end
	return self.x, self.y, self.dx, self.dy
end
function QTable:SetSizeSuitable(rows,cols,size_wnd_title,size_col_title,size_row,size_scroll)
	-- ������ ������ ���� ������� � ������������ � ����������� ������������ ����� � ��������
	-- ���-�� �������� ���� �� ������������ (�� ����, ��� � ��� ������), �� ���� ��� �� nil, �� � ������ ���� ������� ����������� ������ ����������
	-- ��� ��������� rows ������ ������������ ������ ���� ������� � ������������ � ������� ����������� ������������ �����
	-- ��������� �������� � ������ ��� �������� � �������� http://forum.qlua.org/topic172.html
	local top, left, bottom, right = GetWindowRect(self.t_id)
	self.x, self.y, self.dx, self.dy = left, top, right-left, bottom-top
	if cols then self.dx = self.dx + (size_scroll or 16) end
	self.dy = (size_wnd_title or 60)+(size_col_title or 42) + (rows or self.curr_line) * (size_row or 15)
	return SetWindowPos(self.t_id, self.x, self.y, self.dx, self.dy)
end
-- only for Quik version 6.7+
function QTable:SetColor(row,col_name,b_color,f_color,sel_b_color,sel_f_color)
	-- set color for cell, row or column
	if VERSIONLESS6713 then return false end
	local col_ind,row_ind=nil,nil
	--toLog(log,'setcol params='..tostring(row)..tostring(col_name)..tostring(b_color))
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.SetColor(): No such column name - '..col_name)
			return false
		end
	end
	--toLog(log,'SetColors row:col='..tostring(row_ind)..':'..tostring(col_ind)..' - '..tostring(b_color)..tostring(f_color)..tostring(sel_b_color)..tostring(sel_f_color))
	local bcnum,fcnum,selbcnum,selfcnum=0,0,0,0
	if b_color==nil or b_color=='DEFAULT_COLOR' then bcnum=16777215 else bcnum=RGB2number(b_color) end
	if f_color==nil or f_color=='DEFAULT_COLOR' then fcnum=0 else fcnum=RGB2number(f_color) end
	if sel_b_color==nil or sel_b_color=='DEFAULT_COLOR' then selbcnum=16777215 else selbcnum=RGB2number(sel_b_color) end
	if sel_f_color==nil or sel_f_color=='DEFAULT_COLOR' then selfcnum=0 else selfcnum=RGB2number(sel_f_color) end
	return SetColor(self.t_id,row_ind,col_ind,bcnum,fcnum,selbcnum,selfcnum)
end
function QTable:Highlight(row,col_name,b_color,f_color,timeout)
	-- ��������� ������, �������, ������� - � ����������� �� ���������� row,col_name�. ���� ���� - b_color, ���� ������ - f_color, ��������� - timeout ��
	if VERSIONLESS6713 then return false end
	local col_ind,row_ind=nil,nil
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.Highlight(): No such column name - '..col_name)
			return false
		end
	end
	local bcnum,fcnum=0,0
	if b_color==nil or b_color=='DEFAULT_COLOR' then bcnum=16777215 else bcnum=RGB2number(b_color) end
	if f_color==nil or f_color=='DEFAULT_COLOR' then fcnum=0 else fcnum=RGB2number(f_color) end
	--toLog(log,'High par='..tostring(row)..tostring(col_name)..tostring(b_color)..tostring(f_color)..tostring(timeout))
	--toLog(log,'HP2 ='..row_ind..col_ind..' b='..bcnum..' f='..fcnum..' t='..timeout)
	return Highlight(self.t_id,row_ind,col_ind,bcnum,fcnum,timeout)
end
function QTable:StopHighlight(row,col_name)
	-- ������ ���������
	if VERSIONLESS6713 then return false end
	local col_ind,row_ind=nil,nil
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.StopHighlight(): No such column name - '..col_name)
			return false
		end
	end
	return Highlight(self.t_id,row_ind,col_ind,nil,nil,0)
end
function QTable:SetTableNotificationCallback(func)
	-- ������� ������� ��������� ������ ��� ��������� ������� � �������
	if VERSIONLESS6713 then return false end
	if func~=nil and type(func)=='function' then
		return SetTableNotificationCallback(self.t_id,func)
	end
	return false
end
--[[
Graphics functions
]]
function isChartExist(chart_name)
	-- ���������� true, ���� ������ � ��������������� chart_name ��������� ����� false
	if chart_name==nil or chart_name=='' then return false end
	local n=getNumCandles(chart_name)
	if n==nil or n<1 then return false end
	return true
end
function getCandle(chart_name,bar,line)
	-- ���������� ����� �� ������� bar �� ��������� ������������ ��� ������� � ��������������� chart_name
	-- �������� line �� ������������ (�� ��������� 0)
	-- �������� bar �� ������������ (�� ��������� 0)
	-- ���������� ������� ��� � ������������� ������ ��� nil � ��������� � ������������
	if not isChartExist(chart_name) then return nil,'Chart doesn`t exist' end
	local n=getNumCandles(chart_name)
	local lline=0
	local lbar=n-1
	if line~=nil then lline=tonumber(line) end
	if bar~=nil then lbar=lbar-tonumber(bar) end
	if lbar>n or lbar<1 then return nil,'Spacified bar='..bar..' doesn`t exist' end
	local t,n,p=getCandlesByIndex(chart_name,lline,lbar,1)
	if t~=nil and n>=1 and t[0]~=nil and t[0].doesExist==1 then return t[0] else return nil,'Error gettind Candles from '..chart_name end
end
function getPrevCandle(chart_name,line)
	-- ���������� ����-��������� ����� ��� ������� � ��������������� chart_name
	-- �������� line �� ������������ (�� ��������� 0)
	-- ���������� ������� ��� � ������������� ������ ��� nil � ��������� � ������������
	if not isChartExist(chart_name) then return nil,'Chart doesn`t exist' end
	local n=getNumCandles(chart_name)
	return getCandle(chart_name,1,line)
end
function getLastCandle(chart_name,line)
	-- ���������� ��������� ����� ��� ������� � ��������������� chart_name
	-- �������� line �� ������������ (�� ��������� 0)
	-- ���������� ������� ��� � ������������� ������ ��� nil � ��������� � ������������
	return getCandle(chart_name,nil,line)
end
--[[
Commmon Trading Signals
]]
function crossOver(bar,chart_name1,val2,parameter,line1,line2)
	-- ���������� true ���� ������ � ��������������� chart_name1 ������� ����� ����� ������ (��� ��������) val2 � ���� �� ��������� bar.
	-- ��������� parameter,line1,line2 �������������. �� ��������� ����� close,0,0 ��������������
	-- ������ ���������� ������������ ����� ����������� (����)
	if bar==nil or chart_name1==nil or val2==nil then return false,'Bad parameters' end
	local candle1l=getCandle(chart_name1,bar,line1)
	local candle1p=getCandle(chart_name1,bar+1,line1)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name1 end
	local par=parameter or 'close'
	--toLog(log,'par='..par)
	if type(val2)=='string' then
		local candle2l=getCandle(val2,bar,line2)
		local candle2p=getCandle(val2,bar+1,line2)
		if candle2l==nil or candle2p==nil then return false,'Eror on getting candles for '..val2 end
		if candle1l[par]>candle2l[par] and candle1p[par]<=candle2p[par] then
			local p=(candle2p[par]*(candle1l[par]-candle1p[par])-candle1p[par]*(candle2l[par]-candle2p[par]))/((candle1l[par]-candle1p[par])-(candle2l[par]-candle2p[par]))
			return true,tonumber(p)
		else return false end
	elseif type(val2)=='number' then
		if candle1l[par]>val2 and candle1p[par]<=val2 then return true else return false end
	else
		return false,'Unsupported type for 3rd parameter'
	end
end
function crossUnder(bar,chart_name1,val2,parameter,line1,line2)
	-- ���������� true ���� ������ � ��������������� chart_name1 ������� ������ ����  ������ (��� ��������) val2 � ���� bar.
	-- ��������� parameter,line1,line2 �������������. �� ��������� ����� close,0,0 ��������������
	-- ������ ���������� ������������ ����� ����������� (����), ���� ���� �����������
	if bar==nil or chart_name1==nil or val2==nil then return false,'Bad parameters' end
	local candle1l=getCandle(chart_name1,bar,line1)
	local candle1p=getCandle(chart_name1,bar+1,line1)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name1 end
	local par=parameter or 'close'
	if type(val2)=='string' then
		local candle2l=getCandle(val2,bar,line2)
		local candle2p=getCandle(val2,bar+1,line2)
		if candle2l==nil or candle2p==nil then return false,'Eror on getting candles for '..val2 end
		if candle1l[par]<candle2l[par] and candle1p[par]>=candle2p[par] then
			local p=(candle2p[par]*(candle1l[par]-candle1p[par])-candle1p[par]*(candle2l[par]-candle2p[par]))/((candle1l[par]-candle1p[par])-(candle2l[par]-candle2p[par]))
			--toLog(Log,'-----')
			--toLog(Log,candle2l)
			--toLog(Log,'-----')
			--toLog(Log,candle2p)

			return true,tonumber(p)
		else return false end
	elseif type(val2)=='number' then
		if candle1l[par]<val2 and candle1p[par]>=val2 then return true else return false end
	else
		return false,'Unsupported type for 3rd parameter'
	end
end
function turnDown(bar,chart_name,parameter,line)
	-- ���������� true ���� ������ � ��������������� chart_name "����������� ����". �.�. �������� ������� � ���� bar ������ �������� � ���� bar-1.
	-- ��������� parameter,line �������������. �� ��������� ����� close,0 ��������������
	if bar==nil or chart_name==nil then return false,'Bad parameters' end
	local candle1l,candle1p=getCandle(chart_name,bar,line),getCandle(chart_name,bar+1,line)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name end
	local par=parameter or "close"
	if candle1l[par]<candle1p[par] then return true else return false end
end
function turnUp(bar,chart_name,parameter,line)
	-- ���������� true ���� ������ � ��������������� chart_name "����������� �����". �.�. �������� ������� � ���� bar ������ �������� � ���� bar-1.
	-- ��������� parameter,line �������������. �� ��������� ����� close,0 ��������������
	if bar==nil or chart_name==nil then return false,'Bad parameters' end
	local candle1l,candle1p=getCandle(chart_name,bar,line),getCandle(chart_name,bar+1,line)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name end
	local par=parameter or "close"
	if candle1l[par]>candle1p[par] then return true else return false end
end
--[[
Logging class
]]--
QLog={}
QLog.__index=QLog
function QLog:new(file_path,log_level)
	if file_path==nil then return nil end
	q_log={}
	setmetatable(q_log,QLog)
	q_log.path=file_path
	q_log.to_write={}
	q_log.file_available=true
	if log_level==nil then log_level='INFO' else log_level=string.upper(log_level) end
	q_log.level=log_level
	if log_level=='ERROR' then
		q_log.levelint=1
	elseif log_level=='WARNING' then
		q_log.levelint=2
	elseif log_level=='INFO' then
		q_log.levelint=3
	elseif log_level=='DEBUG' then
		q_log.levelint=4
	elseif log_level=='TRACE' then
		q_log.levelint=5
	else
		toLog(file_path,"QLog. Unknown error level "..tostring(log_level)..'. Error level set to INFO.')
	end
	return q_log
end
function QLog:Log(value)
	-- log with logging object level
	Write(self,self.level,value)
	--[[
	if value~=nil then
		lf=io.open(self.path,"a+")
		if lf~=nil then
			if type(value)=="string" or type(value)=="number" then
				if io.type(lf)~="file" then	lf=io.open(self.path,"a+") end
				lf:write(getHRDateTime()..": "..self.level..value.."\n")
			elseif type(value)=='boolean' then
				if io.type(lf)~="file" then	lf=io.open(self.path,"a+") end
				lf:write(getHRDateTime()..": "..self.level..tostring(value).."\n")
			elseif type(value)=="table" then
				if io.type(lf)~="file" then	lf=io.open(self.path,"a+") end
				lf:write(getHRDateTime()..": "..self.level..table2string(value).."\n")
			end
			if io.type(lf)~="file" then	lf=io.open(self.path,"a+") end
			lf:flush()
			if io.type(lf)=="file" then	lf:close() end
		end
	end
	]]--
end
function QLog:Error(value)
	Write(self,self.level,value)
end
function QLog:Warning(value)
	if self.levelint>=2 then Write(self,'WARNING',value) end
end
function QLog:Info(value)
	if self.levelint>=3 then Write(self,'INFO',value) end
end
function QLog:Debug(value)
	if self.levelint>=4 then Write(self,'DEBUG',value) end
end
function QLog:Trace(value)
	if self.levelint>=5 then Write(self,'TRACE',value) end
end
function Write(obj,level,value)
	local str=''
	if type(value)=="string" or type(value)=="number" then
		str=getHRDateTime()..": "..level..' - '..value.."\n"
	elseif type(value)=='boolean' then
		str=getHRDateTime()..": "..level..' - '..tostring(value).."\n"
	elseif type(value)=="table" then
		str=getHRDateTime()..": "..level..' - '..table2string(value).."\n"
	else
		str=getHRDateTime()..": "..level..' - '..tostring(value).."\n"
	end
	if obj.file_available then
		obj.file_available=false
		local lf=io.open(obj.path,'a+')
		if #obj.to_write~=0 then
			for _,ostr in pairs(obj.to_write) do
				lf:write(ostr)
			end
			obj.to_write={}
		end
		lf:write(str)
		lf:flush()
		lf:close()
		obj.file_available=true
	else
		table.insert(obj.to_write,str)
	end
end
--[[
Support Functions
]]--
function getTradeAccount(class_code)
   -- ������� ���������� ������� � ��������� ��������� ����� ��� �������������� ���� ������
   for i=0,getNumberOf("trade_accounts")-1 do
      local trade_account=getItem("trade_accounts",i)
      if string_find(trade_account.class_codes,class_code,1,1) then return trade_account end
   end
   return nil
end
function RGB2number(color)
	-- for internal use makes Quik RGB type from string 'RRR GGG BBB'
	if VERSIONLESS6713 then return false end
	if type(color)=='number' then return color end
	local i=1
	local a={}
	for cl in color:gmatch('%d+') do
		a[i]=0+cl
		i=i+1
	end
	return RGB(a[1],a[2],a[3])
end
function getClass(security)
	-- ���������� ����� ��� ������ security
	return getSecurityInfo('',security).class_code
end
function getSecurityClass(classes_list,sec_code)
   -- ������� ���������� ��� ������ ��� ������ �� ������������ ����� ��� ������ ������ ��� ������ �� ������ ������� ��� �� getClassesList(), ���� ������ �������� ������
   if classes_list=="" then classes_list=getClassesList()
   elseif classes_list=="MICEX-Spot" then classes_list="TQBR,TQBS,TQNL,TQLV,TQNE"
   elseif classes_list=="SMAL" then classes_list="SMAL"
   elseif classes_list=="UX-Spot" then classes_list="GTS"
   elseif classes_list=="UX-Fut" then classes_list="FUTUX"
   elseif classes_list=="UX-Opt" then classes_list="OPTUX"
   elseif classes_list=="RTS-Fut" then classes_list="SPBFUT"
   elseif classes_list=="RTS-Opt" then classes_list="SPBOPT"
   elseif classes_list=="Demo-Quik" then classes_list="QJSIM"
   end
   for class_code in string.gmatch(classes_list,"%a+") do
      if getSecurityInfo(class_code,sec_code) then return class_code end
   end
   return nil
end
function getParam(security,param_name,class)
	--�������� ����������� ������� getParamEx. ������������� ������� ��� ������ ���� �� �� ������. ���������� �������� � ���������� �������. � ������ ������ ���������� ����������� ������ ����������
	if security==nil or security=='' or param_name==nil or param_name=='' then return nil,'Bad arguments' end
	local t=getParamEx(class or getSecurityInfo('',security).class_code,security,param_name)
	if t.result~='1' then return nil,param_name..' for '..security..' nor found' end
	if t.param_type=='3' then
		return t.param_image
	else
		return tonumber(t.param_value)
	end
end
function toLog(file_path,value)
	-- ������ � ��� ��������� value
	-- value ����� ���� ������, ������� ��� ��������
	-- file_path  -  ���� � �����
	-- ���� ����������� �� �������� � ����������� ����� ������ ������
	if file_path~=nil and value~=nil then
		lf=io.open(file_path,"a+")
		if lf~=nil then
			if type(value)=="string" or type(value)=="number" then
				if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
				lf:write(getHRDateTime().." "..value.."\n")
			elseif type(value)=='boolean' then
				if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
				lf:write(getHRDateTime().." "..tostring(value).."\n")
			elseif type(value)=="table" then
				if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
				lf:write(getHRDateTime().." "..table2string(value).."\n")
			end
			if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
			lf:flush()
			if io.type(lf)=="file" then	lf:close() end
		end
	end
end
function getHRTime()
   -- ���������� ����� � ������������� � ���� ������
   local now=socket.gettime()
   return string_format("%s,%03d",os.date("%X",now),select(2,math.modf(now))*1000)
end
function getHRDateTime()
   -- ���������� ������ � ������� ����� � ����� � �������������
   local now=socket.gettime()
   return string_format("%s,%03d",os.date("%c",now),select(2,math.modf(now))*1000)
end
function toPrice(security,value,class)
	-- �������������� �������� value � ���� ����������� ����������� ������� (�������� ������ ����� ����� �����������)
	-- ���������� ������
	if (security==nil or value==nil) then return nil end
	local scale=getSecurityInfo(class or getSecurityInfo("",security).class_code,security).scale
	return string_format("%."..string_format("%d",scale).."f",tonumber(value))
end
function toPriceRound(security,value,class)
	-- �������������� �������� value � ���� ����������� ����������� ������� � �������������� �����������
	-- ���������� ������
	if (security==nil or value==nil) then return nil end
	local class=class or getSecurityInfo("",security).class_code
	local scale=getSecurityInfo(class,security).scale
	local pr_step=0+getParam(security,"SEC_PRICE_STEP",class)
	return string_format("%."..string_format("%d",scale).."f",tonumber(toScale(value,pr_step)))
end
function getOrderStatus(order)
	-- return order status - active,done,cancelled
	local active
	local band=bit.band
	--local tobit=bit.tobit
	if band(order.flags,2)~=0 then return "cancelled"
	elseif band(order.flags,1)==0 then 
		return "done" 
	else return "active" end
end
function orderflags2table(flags)
	-- ������� ���������� ������� � ������ ��������� ������ �� ������
	--[[ �������� :
	active, cancelled, done,operation("B" for Buy, "S" for Sell),limit(true - limit order, false - market order),
	mte(�������� ���������� ������ ����������� ��������),fill_or_kill(��������� ������ ���������� ��� �����),
	mmorder(������ ������-�������. ��� �������� ������ ������� ���������� �����������),received(��� �������� ������ ������� �������� �� �����������),
	cancell_rest(����� �������),iceberg
	]]
	local t={}
	local band=bit.band
	--local tobit=bit.tobit
	if band(flags,1)~=0 then t.active=true	else t.active = false end
	if band(flags,2)~=0 then t.cancelled=true
	else
		if not t.active then t.done=true else t.done=false end
		t.cancelled=false
	end
	if band(flags, 4)~=0 then t.operation="S" else t.operation = "B" end
	if band(flags, 8)~=0 then t.limit=true else t.limit = false end
	if band(flags,16)~=0 then t.mte=true	else t.mte=false end
	if band(flags,32)~=0 then t.fill_or_kill=true else t.fill_or_kill=false end
	if band(flags,64)~=0 then t.mmorder=true else t.mmorder=false end
	if band(flags,128)~=0 then t.received=true else t.received=false end
	if band(flags,256)~=0 then t.cancell_rest=true else t.cancell_rest=false end
	if band(flags,512)~=0 then t.iceberg=true else t.iceberg=false end
	if t.cancelled and t.done then message("Erorr in orderflags2table order cancelled and done!",2)	end
	return t
end
function tradeflags2table(flags)
	-- ������� ���������� ������� � ������ ��������� ������ �� ������
	--[[ �������� :operation("B" for Buy, "S" for Sell, "" for not defined(index for example))
	]]
	local t={}
	local band=bit.band
	--local tobit=bit.tobit
	if band(flags, 4)~=0 then t.operation="S" else t.operation='B' end
	return t
end
function alltradeflags2table(flags)
	-- ������� ���������� ������� � ������ ��������� ������ �� ������
	--[[ �������� :operation("B" for Buy, "S" for Sell, "" for not defined(index for example))
	]]
	local t={}
	local band=bit.band
	--local tobit=bit.tobit
	if band(flags, 1)~=0 then t.operation="S" end
	if band(flags, 2)~=0 then t.operation='B' end
	return t
end
function stoporderflags2table(flags)
	-- ������� ���������� ������� � ������ ��������� ����-������ �� ������
	--[[ �������� :
	active, cancelled, done,operation("B" for Buy, "S" for Sell),limit(true - limit order, false - market order),
	mte(�������� ���������� ������ ����������� ��������),wait_activation(����-������ ������� ���������),
	another_server(����-������ � ������� �������),tplopf(��������������� � ������ ����-������ ���� ����-������� �� ������, � ������ ����� �������� ������ �������� ��������� � �� ������������ ����-������ ������ �� ����������� ����� ������ ����������� ������� ���������),
	manually_activated(����-������ ������������ �������),rejected(����-������ ���������, �� ���� ���������� �������� ��������),
	rejected_limits(����-������ ���������, �� �� ������ �������� �������),cdtloc(����-������ �����, ��� ��� ����� ��������� ������),
	cdtloe(����-������ �����, ��� ��� ��������� ������ ���������),minmaxcalc(���� ������ ��������-���������)
	]]
	local t={}
	local band=bit.band
	--local tobit=bit.tobit
	if band(flags, 1)~=0 then t.active=true else t.active = false end
	if band(flags,2)~=0 then t.cancelled=true
	else
		if not t.active then t.done=true else t.done=false end
		t.cancelled=false
	end
	if band(flags, 4)~=0 then t.operation="S" else t.operation = "B" end
	if band(flags, 8)~=0 then t.limit=true else t.limit = false end
	if band(flags,32)~=0 then t.wait_activation=true else t.wait_activation=false end
	if band(flags,64)~=0 then t.another_server=true else t.another_server=false end
	if band(flags,256)~=0 then t.tplopf=true else t.tplopf=false end
	if band(flags,512)~=0 then t.manually_activated=true else t.manually_activated=false end
	if band(flags,1024)~=0 then t.rejected=true else t.rejected=false end
	if band(flags,2048)~=0 then t.rejected_limits=true else t.rejected_limits=false end
	if band(flags,4096)~=0 then t.cdtloc=true else t.cdtlo=false end
	if band(flags,8192)~=0 then t.cdtloe=true else t.cdtloe=false end
	if band(flags,32768)~=0 then t.minmaxcalc=true else t.minmaxcalc=false end
	return t
end
function stoporderextflags2table(flags)
	-- ������� ���������� ������� � �������������� ��������� ����-������ �� ������
	--[[ �������� :
	userest(������������ ������� �������� ������), cpf(��� ��������� ���������� ������ ����� ����-������), asolopf(������������ ����-������ ��� ��������� ���������� ��������� ������),
	percent(������ ����� � ���������, ����� � � ������� ����),defpercent(�������� ����� ����� � ���������, ����� � � ������� ����),
	this_day(���� �������� ����-������ ��������� ����������� ����),interval(���������� �������� ������� �������� ����-������),
	markettp(���������� ����-������� �� �������� ����),marketstop(���������� ����-������ �� �������� ����),
	]]
	local t={}
	local band=bit.band
	local tobit=bit.tobit
	if band(tobit(flags), 1)~=0 then t.userest=true else t.userest = false end
	if band(tobit(flags),2)~=0 then t.cpf=true t.cpf=false	end
	if band(tobit(flags), 4)~=0 then t.asolopf=true else t.asolopf =false end
	if band(tobit(flags), 8)~=0 then t.percent=true else t.percent = false end
	if band(tobit(flags),16)~=0 then t.defpercent=true else t.defpercent=false end
	if band(tobit(flags),32)~=0 then t.this_day=true else t.this_day=false end
	if band(tobit(flags),64)~=0 then t.interval=true else t.interval=false end
	if band(tobit(flags),128)~=0 then t.markettp=true else t.markettp=false end
	if band(tobit(flags),256)~=0 then t.marketstop=true else t.marketstop=false end
	return t
end
function bit_set( flags, index )
	--������� ���������� true, ���� ��� [index] ���������� � 1
	local n=1
    n=bit.lshift(1, index)
    if bit.band(flags, n)~=0 then
       return true
    else
       return false
    end
end
function HiResTimer()
-- ��������� ������ http://lua-users.org/wiki/HiResTimer
-- ������������� �������� ������ ������
	local alien=require"alien"

	--
	-- get the kernel dll
	--
	local kernel32=alien.load("kernel32.dll")

	--
	-- get dll functions
	--
	local QueryPerformanceCounter=kernel32.QueryPerformanceCounter
	QueryPerformanceCounter:types{ret="int",abi="stdcall","pointer"}
	local QueryPerformanceFrequency=kernel32.QueryPerformanceFrequency
	QueryPerformanceFrequency:types{ret="int",abi="stdcall","pointer"}
	--------------------------------------------
	--- utility : convert a long to an unsigned long value
	-- (because alien does not support longlong nor ulong)
	--------------------------------------------
	local function lu(long)
		return long<0 and long+0x80000000+0x80000000 or long
	end

	--------------------------------------------
	--- Query the performance frequency.
	-- @return (number)
	--------------------------------------------
	local function qpf()
		local frequency=alien.array('long',2)
		QueryPerformanceFrequency(frequency.buffer)
		return  math.ldexp(lu(frequency[1]),0)
				+math.ldexp(lu(frequency[2]),32)
	end

	--------------------------------------------
	--- Query the performance counter.
	-- @return (number)
	--------------------------------------------
	local function qpc()
		local counter=alien.array('long',2)
		QueryPerformanceCounter(counter.buffer)
		return	 math.ldexp(lu(counter[1]),0)
				+math.ldexp(lu(counter[2]),32)
	end

	--------------------------------------------
	-- get the startup values
	--------------------------------------------
	local f0=qpf()
	local c0=qpc()
	local c1=qpc()
	return (c1-c0)/f0
end
-- time and date helpers
function getSTime()
	--���������� ������� ����� ������� � ���� ����� ������� HHMMSS
	local t = ""
	local a = tostring(getInfoParam("SERVERTIME"))
	for s in a:gmatch('%d+') do
		t=t..s
	end
	return tonumber(t)
end
function getLTime()
	-- ���������� ������� ����� ���������� � ���� ����� ������� HHMMSS
	return os.date("%H%M%S")
end
function getDate()
	-- ���������� ������� �������� ���� � ���� ����� ������� YYYYMMDD
	local t = ""
	local a = tostring(getInfoParam("TRADEDATE"))
	for s in a:gmatch('%d+') do
		t=s..t
	end
	return tonumber(t)
end
function isTradeTime(exchange, shift)
	--���������� true ���� ������� ��������� ����� �������� �������� ��� ����� exchange � false ���� ��� (�������, ��� ������)
	-- ��������� ������� ���� - UX,MICEX,FORTS
	-- � ��������� shift ������� ������� ����� ������� ������� ������� ������������ ������� ���� MICEX,FORTS (������� ��������� � ������� ��������)
	if exchange==nil then return false end
	local time=getSTime()
	while time==nil do
		sleep(100)
		time=getSTime()
		toLog('ql_error.log','Can`t get server time!')
	end
	local sp=0
	if shift~=nil then sp=tonumber(shift) end
	if exchange=='UX'  and time+sp>103000 and time+sp<173000 then return true end
	if exchange=='MICEX' and time+sp>100000 and time+sp<184000 then return true end
	if exchange=='FORTS' and ((time+sp>100000 and time+sp<140000) or (time+sp>140300 and time+sp<184500) or (time+sp>190000 and time+sp<235000)) then return true end
	return false
end
function datetime2string(dt)
	-- ����������� ������ datetime � ������ ������� YYYYMMDDHHMMSS
	local s=''
	if string_len(tostring(dt.year))<4 then s=s..'20'..dt.year else s=s..dt.year end
	if string_len(tostring(dt.month))<2 then s=s..'0'..dt.month else s=s..dt.month end
	if string_len(tostring(dt.day))<2 then s=s..'0'..dt.day else s=s..dt.day end
	if string_len(tostring(dt.hour))<2 then s=s..'0'..dt.hour else s=s..dt.hour end
	if string_len(tostring(dt.min))<2 then s=s..'0'..dt.min else s=s..dt.min end
	if string_len(tostring(dt.sec))<2 then s=s..'0'..dt.sec else s=s..dt.sec end
	return s
end
function datetimediff(t1,t2)
	-- ���������� ������� � �������� ����� t2 � t1 (��� ������������ ���� datetime ���������� qlua)
	return (((((t2.year-t1.year)*12+t2.month-t1.month)*30+t2.day-t1.day)*24+t2.hour-t1.hour)*60+t2.min-t1.min)*60+t2.sec-t1.sec
	--return math.abs(d)
end
-- string & table helpers
function trim(s)
	-- ������� ������� � ������ � � ����� ������
	return s:match'^%s*(.*%S)' or ''
end
function table2string(table)
	local k,v,str=0,0,""
	for k,v in pairs(table) do
		if type(v)=="string" or type(v)=="number" then
			str=str..k.."="..v..';'
		elseif type(v)=="table"then
			str=str..k.."={"..table2string(v).."};"
		elseif type(v)=="function" or type(v)=='boolean' then
			str=str..k..'='..tostring(v)..';'
		end
	end
	return str
end
function getPosFromTable(table,value)
	-- ���������� ���� �������� value �� ������� table, ����� -1
	if (table==nil or value==nil) then
		return -1
	else
		local k,v
		for k,v in pairs(table) do
			if v==value then
				return k
			end
		end
		return -1
	end
end
function getRowFromTable(table_name,key,value)
	-- ���������� ������ (������� ���) �� ������� table_name � �������� key ������ value.
	-- table_name[key].value
	local i
	for i=getNumberOf(table_name)-1,0,-1 do
		if getItem(table_name,i)[key]==value then
			return getItem(table_name,i)
		end
	end
	return nil
end
function isEqual(tbl1,tbl2)
    -- ���������� true ���� ������� tbl1 � tbl2 ��������� ���������
	if isSubTable(tbl1,tbl2) and isSubTable(tbl2,tbl1) then return true else return false end
end
function isSubTable(sub,main)
	-- ���������� true ���� ������� sub ��������� � � �������� ���������� � ������� main
	for k, v in pairs(sub ) do
        if ( type(v) == "table" and type(main[k]) == "table" ) then
            if ( not isSubTable( v, main[k] ) ) then return false end
        else
            if ( v ~= main[k] ) then return false end
        end
    end
	return true
end
-- number formatting
function formatNumber(amount)
	-- ��������� ������ � �������� ������ ����������� �� ������� (100000 --> 100 000)
	local formatted, k = amount
	while k~=0 do
		formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")
	end
	return formatted
end
function formatNumber0(amount)
	-- ��������� ������ � �������� ������ ����������� �� ������� (100000 --> 100 000)
	-- ����� ���� ��������� ����� �� ������
	local formatted, k = math_floor((amount or 0)+0.5)
	while k~=0 do
		formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")
	end
	return formatted
end
function formatNumber2(amount, scale)
	-- ��������� ������ � �������� ������ ����������� �� ������� (1000000 --> 1 000 000)
	-- ��� �� ����������� ������������ ���-�� ������ ����� �������
	-- ���� ���-�� ������ ����� ������� �� �����������, �� ������� 2 �����
	local formatted, k = string_format("%."..(scale or 2).."f",amount or 0)
	while k~=0 do
		formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")
	end
	return formatted
end
function toScale(number,scale,dir)
	-- ���������� ����� �� scale ���� ��� dir==floor, ����� ��� dir==ceil ��� �������������� ��� dir==nil
	if not dir then
		return math_floor((0.5*scale+number)/scale)*scale -- math rounding
	elseif dir=='floor' then
		return math_floor(number/scale)*scale  -- floor rounding
	elseif dir=='ceil' then   
		return math_ceil(number/scale)*scale  -- ceil rounding
	end
end
function checkVersion(version)
-- ��������� �� ���� �� ������ ���������� ���� ����������
	return versionLess(TERMINAL_VERSION,version)
end
-- randomizers
function random(m,n)
	-- ���������� ��������� ����� �� m �� n
	local res=(16807*(RANDOM_SEED or 137137))%2147483647
	RANDOM_SEED=res
	res=res*4.6566128752458E-10
	if n and m then res=math_floor(res*(n-m+1))+m else if m then res=math_floor(res*m)+1 end end
	return res
end
function random1()
	-- �� ��������� ��������� � ���������� �� 0 �� 1
	local res=(16807*(RANDOM_SEED or 137137))%2147483647
	RANDOM_SEED=res
	res=res*4.6566128752458E-10
	return res
end
function random_max()
	-- �� ��������� ��������� � ���������� �� 0 �� 2147483647 (����. �����. 32 ������ �����) �������� ��� ��� ����������
	local res=(16807*(RANDOM_SEED or 137137))%2147483647
	RANDOM_SEED=res
	return res
end
function randomseed(x)
	RANDOM_SEED=math_floor(tonumber(x))
end
-- file helers
function directoryExists(directory)
-- �������� ������������� �����
-- ���������� true/false ��������� ����������
-- ������ ����������� ��� nil � ������ ������
-- ��� ����� � ������ ������
	return os.rename(directory,directory)
end
function fileSize(file)
-- ��������� ������� �����
-- �������� - ��� ����� ���� ���������� ��� ��������� �����
-- ���������� ����� ����� ��� nil � ����������� ������ ����������
	local size
    if type(file) == "string" then
		local f,err = io.open(file,"r")
		if not f then return nil,err end
		size = fileSize(f)
		f:close()
	else
		local current_position = file:seek()
		size = file:seek("end")
		file:seek("set",current_position)
		end
	return size
end
function fileExists(file)
	local f=io.open(file)
	if f~=nil then io.close(f) return true else return false end
end

function Assert(cond)
	if cond then
		a='Assertion!'..nil
	end
end
