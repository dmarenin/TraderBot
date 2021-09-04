require "QL" --���������� ����������
require "iuplua" --���������� ����������

--����� ���������� ����������.
is_run = false --���������� ��� �������-��������� ������� main
log="AvrVol.log" --����� ���-����
ticker_list ="UNAF,CEEN,ALMK,MSICH" --����� ������ ������������, �� ������� ������� ������� �����
data={} -- ������� � ������� ����� ������� ��� ����������� ����������
trades={} -- "������������" ������� ��� ������������ ������. � �� ������� �� ����� ������������ ������ �� � �������� ����� � � ������� ������ �� ���
--������ ������� ����������
mainbox=iup.vbox{} -- ������� ������������ ���� � ������� ����� �������� �������� ��� ������ ������
Dialog=iup.dialog{mainbox; title="Average Volume", size="THIRDxTHIRD"} -- ������� ���������� ����
--����� �������� ��� �������� ����������� ����������
function Dialog:close_cb()
	toLog(log,"Interface close button pressed")
	is_run = false
end
--������� OnInit ���������� ���������� QUIK ����� ������� ������� main(). � �������� ��������� ��������� �������� ������� ���� � ������������ �������. 
function OnInit(path)
  is_run = true
  -- �������� ���� � ����� �� ������� �����������
  log=getScriptPath().."\\"..log
  data_file=getScriptPath().."\\AverageVolume_"..getTradeDate()..".csv"
end
--������� ���������� ���������� QUIK ��� ��������� ������� �� ������� ����������. 
function OnStop()
  toLog(log,"Script stopped")
  is_run = false
end
-- ������� ����� ������� ���������� ��� ��������� ����� ������������ ������
function OnAllTrade(trade)
	-- ���� ������ �� ������� ��� ������ �� ������ �� �� ������ ������ - �� ������ �� ��������������
	if is_run and data[trade.seccode]~=nil then
		trades[#trades+1]=trade
	end
end
--�������� ������� �������. � ��� ��� ������ ������ � �� ����������� � ������ � ����
function AvrVol(trade)
	-- ��� ��������� ��������� � ������ ������� ��������� ����������
	local dat=data[trade.seccode]
	toLog(log,"New trade for "..trade.seccode.." Num="..trade.tradenum)
	-- ����������� �������� ����������� ��� �������� �������
	dat.trade_num=dat.trade_num+1
	dat.vol=dat.vol+trade.qty
	dat.avr_vol=dat.vol/dat.trade_num
	-- ���������� ����������� ������ (������� �� ���������� QL)
	local dir=tradeflags2table(trade.flags).operation
	dat[dir..'trade_num']=dat[dir..'trade_num']+1
	dat[dir..'vol']=dat[dir..'vol']+trade.qty
	dat['avr_'..dir..'vol']=dat[dir..'vol']/dat[dir..'trade_num']
	-- ��������� ���� �� ��������
	local file=io.open(data_file,'a')
	-- ���������� ������� � ������ ����������
	file:write(trade.seccode..","..dat.avr_vol..","..dat.avr_Bvol..","..dat.avr_Svol.."\n") --����� ��������� ������� �������� �������� � ����
	file:flush()
	-- ��������� ����
	file:close()
	-- �������� ��������������� �������� � ����������. ��������� �� ������ �������� �� ������ � ������� � �������
	dat.avr_lbl.title='Average='..string.format('%.2f',dat.avr_vol)
	dat.bavr_lbl.title='Buy Average='..string.format('%.2f',dat.avr_Bvol)
	dat.savr_lbl.title='Sell Average='..string.format('%.2f',dat.avr_Svol)
	toLog(log," Average calculated. New values "..trade.seccode.." Average Volume="..dat.avr_vol.." Average Buy Volume="..dat.avr_Bvol.." Average Sell Volume="..dat.avr_Svol)
end
-- ������� �������������. �� ������ ������� ��� ����������� �������
function OnInitDo(list)
	toLog(log,"Start initialization...")
	local sec=""
	local ticker_lbl,avr_lbl,barv_lbl,savr_lbl,hbox
	-- ���� �� ������ � ��������
	for sec in string.gmatch(list,"%a+") do
		-- �������� ���������� ��� �������� ������ ��� ������ sec
		data[sec]={}
		data[sec].avr_vol=0
		data[sec].vol=0
		data[sec].trade_num=0
		data[sec].avr_Bvol=0
		data[sec].Bvol=0
		data[sec].Btrade_num=0
		data[sec].avr_Svol=0
		data[sec].Svol=0
		data[sec].Strade_num=0
		-- �������� ���������� ���������
		ticker_lbl=iup.label{title=sec,expand="YES"}
		data[sec].avr_lbl=iup.label{title='Average=',expand="YES"}
		data[sec].bavr_lbl=iup.label{title='Buy Average=',expand="YES"}
		data[sec].savr_lbl=iup.label{title='Sell Average=',expand="YES"}
		hbox=iup.hbox{ticker_lbl,data[sec].avr_lbl,data[sec].bavr_lbl,data[sec].savr_lbl}
		-- ���������� ���������� ��������������� ����� � ���������� � ������� ���� ����������
		if iup.Append(mainbox,hbox)==nil then toLog(log,"Can`t append interface element") return false end
		toLog(log,sec..' added to list')
	end
	-- �������� ����� � ���������� �������
	local f=io.open(data_file,'w+')
	if f==nil then 
		toLog(log,"Can`t create data file at "..data_file)
		return false
	end
	f:write('TICKER,AVERAGE_VOLUME,AVERAGE_BUY_VOLUME,AVERAGE_SELL_VOLUME\n') 
	f:flush() 
	f:close() 
	toLog(log,'Initialization ended')
	return true
end
--������� ������� �������, ������� �������� � ����������� �����
function main()
	is_run=OnInitDo(ticker_list)
	if is_run then
		toLog(log,"Main started")
		Dialog:show() --�������� ����� show ����������� ����������
		local i=0
		toLog(log,"#all_trades="..getNumberOf('all_trades'))
		for i=0,getNumberOf('all_trades') do
			row=getItem('all_trades',i)
			if data[row.seccode]~=nil then AvrVol(row) end
		end
		toLog(log,"Old trades processed.")
	end
	while is_run do
		if #trades~=0 then
			local t=table.remove(trades,1)
			if t==nil then toLog(log,"Nil trade on remove") else AvrVol(t) end
		else 
			iup.LoopStep()
			sleep(1)
		end
	end
	Dialog:destroy()
	iup.ExitLoop()
	iup.Close()
	toLog(log,"Main ended")
end