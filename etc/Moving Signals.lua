require"QL"
require"iuplua"

log="moving_signals.log"
--�������������� ��������
chart1="short_mov"
chart2="long_mov"

is_run = true

function OnStop()
  is_run = false
  toLog(log,'OnStop. Script finished manually')
  -- ���������� ������� ����
  t:delete()
end

function main()
	log=getScriptPath()..'\\'..log
	toLog(log,"Start main")
	--������� ������� ����
	t=QTable:new()
	-- ��������� 2 �������
	t:AddColumn("TREND DETECTOR",QTABLE_STRING_TYPE,45)
	t:AddColumn("SIGNAL",QTABLE_STRING_TYPE,30)
	-- ��������� �������� ��� �������
	t:SetCaption('Moving Signals')
	-- ���������� �������
	t:Show()
	-- ��������� ������ ������
	line=t:AddLine()

	while is_run do
		--�������� �������� �����������

		--���������� � ��������� �������
		if not isChartExist(chart1) then
			toLog(log,'Can`t get data from chart '..chart1)
			message('�� ����� �������� ������ � ������� '..chart1,1)
			is_run=false
			break
		end
		--���������� � �������� �������
		if not isChartExist(chart2) then
			toLog(log,'Can`t get data from chart '..chart2)
			message('�� ����� �������� ������ � ������� '..chart2,1)
			is_run=false
			break
		end
		
		--�������� ������
		if turnUp(1,chart1) and turnUp(1,chart2) then
			toLog(log,'TrendUp detected')
			TREND_DETECTOR="��� ������� ������. ����� �����" --������� ���������� TREND_DETECTOR � ������� �����.
		elseif turnDown(1,chart1) and turnDown(1,chart2) then
			toLog(log,'TrendDown detected')
			TREND_DETECTOR="��� ������� ������. ����� ��������" --������� ���������� TREND_DETECTOR � ������� �����.
		else
			TREND_DETECTOR="��� ����������� ������"
		end
	
		--��������� ��������.

		--������� �����
		if crossOver(1,chart1,chart2) then
			iup.Message('����� ������!','������� �����')	
			toLog (log, "Golden Cross detected")
			SIGNAL="GOLDEN CROSS" --������� � ������� �����.
		--̸����� �����
		elseif crossUnder(1,chart1,chart2) then
			iup.Message('����� ������!','̨����� �����')	
			toLog (log, "Dead Cross detected")
			SIGNAL="DEAD CROSS" --������� � ������� �����.
		else
			SIGNAL="NO SIGNAL" --������� � ������� �����.
		end
		-- ��������� �������� ��� ����� �������
		t:SetValue(line,"TREND DETECTOR",TREND_DETECTOR)
		t:SetValue(line,"SIGNAL",SIGNAL)

		sleep(1000)
	end
	toLog(log,"Main ended")
	iup.ExitLoop()
	iup.Close()
end