-- 2013 PASHAsoft, getSecurityClass

local ScriptPath=getScriptPath()
if not string.find(package.path,ScriptPath,1,1) then package.path=';'..ScriptPath..'\\?.lua;'..package.path end
require"QL"
require"iuplua"

local is_run=false
local log="getSecurityClass_debug.log"
--params
--var
--functions
local math_floor=math.floor
-- создаем таблицу  вик
local t=QTable:new()

function OnInit()
	log=ScriptPath.."\\"..log
	--toLog(log,"Initialization...")
end

function OnStop()
	--toLog(log,"Stop pressed!")
	is_run=false
end

function getSecurityClass(classes_list,sec_code)
	-- ‘ункци€ возвращает код класса дл€ бумаги на определенном рынке или режиме торгов или просто по списку классов или по getClassesList(), если первый параметр пустой
	if classes_list=="" then classes_list=getClassesList()
	elseif classes_list=="MICEX-Spot" then classes_list="EQBR,EQBS,EQNL,EQLV,EQNE"
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

function main()
	t.caption="getSecurityInfo Tester"
	t:AddColumn("Log",QTABLE_STRING_TYPE,100)
	-- показываем таблицу
	t:Show()

	is_run=true
	--toLog(log,"Start main.")
	while is_run do
		if t:IsClosed() then
			--toLog(log,"Table closed!")
			is_run=false
			break
		end
		--¬водим торговый инструмент
		_,sec_code=iup.GetParam("Trade instrument",nil,"Ticker: %s\n","")
		if not sec_code then
			--toLog(log,"Cancel pressed!")
			is_run=false
			break
		end
		sec_code=string.match(sec_code,"%a+")
		t:Clear()
		local class_code=getSecurityClass(getClassesList(),sec_code)
		if class_code then
			toLog(log,sec_code.." -- class found. Class="..class_code.." - "..getParamEx(class_code,sec_code,"SHORTNAME").param_image)
			t:SetValue(t:AddLine(),"Log",sec_code.." -- class found. Class="..class_code.." - "..getParamEx(class_code,sec_code,"SHORTNAME").param_image)
		else
			toLog(log,sec_code.." -- class not found!!!")
			t:SetValue(t:AddLine(),"Log",sec_code.." -- class not found!!!")
		end
		sleep(1000)
	end
	--toLog(log,"Stop main.")

	-- уничтожаем таблицу  вик
	--t:delete()
end
