--[[

������ �� ����� ������ ���� 
���� �������: �� ���������� � ����������� ��������

http://narod.ru/disk/44642845001.c7d241e5c905fa6ea63c44d3f4d4e30e/K.Fejs%20Put%20Cherepah.%20Iz%20diletantov%20v%20legendarnye%20trejdery.rar.html


������ ��������� �� �������� ��������� �������.

1. ��� ��������� ������ �� Lua � Quik. ����� ����������. 
http://forum.qlua.org/topic34.html

2. � �������� ��������� ���������� �������� ��������� ��� �������� ���������� ��������� Price Channel. ����������� ��� ���:
http://radikal.ua/data/upload/6895e/4efc3/4bcfd54945.gif
(��������� ������ 20 ��� 55 � ����������� �� ������ ������� 1 ��� ������� 2)

http://radikal.ua/data/upload/69fda/6895e/97f1e9df78.gif
(� �������� �������������� ����� ��������� ���������� t. ������ ��� �������� :)))) )

3. ������� ���� ���� ����������� �������������:

http://radikal.ua/data/upload/4efc3/c2184/3ff1b83c96.gif

(������������� - ��������� ���������� p)

4. ��������� � ������� ������� ���������� ����� � ��������, ������� ����� ����������. ������ ����� ����� ������� �������� ���������� � ��������, ����� ������ ���� ���������� � ������� �� ������. �������, ���� �������. ����������� �������, ����� ������ �� �������� ��� ��������. ���� ������, ������� ������ ������� ������ TURTLE ADVISER � ��������� ��� �� �����. ������� ��������� - ������� �������.
 
��� ��������� ��� �������� ������������:
 
http://radikal.ua/data/upload/69fda/04012/3dc9e5a0c2.gif
 
--]]

require"QL"
log="TURTLES.log"
--�������������� ��������
chart_inst="t" --������������� ���������� Price Channel
price_chart="p"	--������������� ������� ���� Price
is_run = true

function OnStop()
  is_run = false
  --toLog(log,'OnStop. Script finished manually')
  -- ���������� ������� ����
  t:delete()
end

function main()
	log=getScriptPath()..'\\'..log
	--toLog(log,"Start main")
	--������� ������� ����
	t=QTable:new()
	-- ��������� 2 �������
	t:AddColumn("SIGNAL",QTABLE_STRING_TYPE,45)


	-- ��������� �������� ��� �������
	t:SetCaption('TURTLE ADVISER')
	-- ���������� �������
	t:Show()
	
	-- ��������� ������ ������
	line=t:AddLine()
	
	while is_run do
	sleep (10)
	
	--�������� ���� ��������� ������ � ������� ����
	num = getNumCandles (price_chart)	
	
	if num==nil or num==0 then
		while num==nil or num==0 do
			sleep (100)
			num = getNumCandles (price_chart)
		end
	end
	
	t_cur = getCandlesByIndex(price_chart,0,num-1,1)
	if t_cur[0]==nil then
		while t_cur[0]==nil do
			sleep (100)
			num = getNumCandles (price_chart)	
			t_cur = getCandlesByIndex(price_chart,0,num-1,1)
		end
	end
	
	last_price=t_cur[0].close
	
	--�������� ������ ���������� "Price Channel"

		price_channel_n = getNumCandles (chart_inst)
		if price_channel_n==nil or price_channel_n==0 then
			while price_channel_n==nil or price_channel_n==0 do
				sleep (100)

				price_channel_n = getNumCandles (chart_inst)
			end
		end
				
		if price_channel_n~=nil then
		
			--������� ������� Price Channel
			if getCandlesByIndex(chart_inst,0,price_channel_n-1,1)[0]~=nil then 
				line_10 = getCandlesByIndex(chart_inst,0,price_channel_n-1,1)[0].close
			end
			
			--���������� ������� Price Channel
			if getCandlesByIndex(chart_inst,0,price_channel_n-2,1)[0]~=nil then
				line_11 = getCandlesByIndex(chart_inst,0,price_channel_n-2,1)[0].close 
			end
			
			--�������������� ������� Price Channel
			if getCandlesByIndex(chart_inst,0,price_channel_n-3,1)[0]~=nil then
				line_12 = getCandlesByIndex(chart_inst,0,price_channel_n-3,1)[0].close 
			end
			
			--����-�������������� ������� Price Channel
			if getCandlesByIndex(chart_inst,0,price_channel_n-4,1)[0]~=nil then
				line_13 = getCandlesByIndex(chart_inst,0,price_channel_n-4,1)[0].close
			end
			
			--������� ������ Price Channel
			if getCandlesByIndex(chart_inst,2,price_channel_n-1,1)[0]~=nil then
				line_30 = getCandlesByIndex(chart_inst,2,price_channel_n-1,1)[0].close 
			end
			
			--���������� ������ Price Channel
			if getCandlesByIndex(chart_inst,2,price_channel_n-2,1)[0]~=nil then
				line_31 = getCandlesByIndex(chart_inst,2,price_channel_n-2,1)[0].close
			end
		
			
			--�������������� ������ Price Channel
			if getCandlesByIndex(chart_inst,2,price_channel_n-3,1)[0]~=nil then
				line_32 = getCandlesByIndex(chart_inst,2,price_channel_n-3,1)[0].close
			end
			
			--����-�������������� ������ Price Channel
			if getCandlesByIndex(chart_inst,2,price_channel_n-4,1)[0]~=nil then
				line_33 = getCandlesByIndex(chart_inst,2,price_channel_n-4,1)[0].close
			end
			
		end
		
		--�������� �������
		SIGNAL="NO SIGNAL"
	
		if (last_price>line_11 and line_11==line_12) or (last_price>line_12 and line_12==line_13) then
			SIGNAL="BUY"
		end
		
		if (last_price<line_31 and line_31==line_32) or (last_price<line_32 and line_32==line_33) then
			SIGNAL="SELL"
		end
			
		-- ��������� �������� ��� ����� �������
		t:SetValue(line,"SIGNAL",SIGNAL)
		sleep(100)
	end
end