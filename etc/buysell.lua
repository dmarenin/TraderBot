--[[
1. Мониторим один инструмент, по нему же открываем позицию. Класс и код инструмента задается константами SEC и CLASS.
2. В константе MIN_P_SPREAD задается пороговый процент спреда (в процентах). Например 0,1.
3. Следим за лучшими аск и бид по указанной бумаге.
4. Если спред расширяется до MIN_P_SPREAD или более и время сессии торговое, то становимся лучшим бидом в размере 1 лот. Если спред сужается ниже порогового - уходим.
5. Если второй под нами человек в стакане опускается, и нам есть куда опуститься, мы тоже опускаемся, оставаясь лучшими.
6. Если нас акцептовали, образовалась длинная позиция по нашему инструменту, то мы его тут же выставляем на продажу (1 лот), встав лучшими на офере. Если нас обгоняют на офере, мы тоже обгоняем. Если второй офер над нами подымается, мы тоже поднимаемся. Т.е. поддерживаем цену заявки такой, чтобы она была лучшей в стакане.
7. Продав имеющуюся бумагу, начинаем алгоритм по новой.
]]

MIN_P_SPREAD = 0.1 			-- минимальный пороговый процент спреда
MIN_SPREAD_STEP =5 			-- минимальное количество шагов спреда, когда открываем позицию
SEC = "CHM4"				-- кож инстурмента
CLASS = "SPBFUT"			-- код класса инструмента
PRICE_STEP = 1 				-- шаг цены по инструменту
PRICE_SCALE = 0 			-- кол-во знаков после запятой
TRADE_ACC   = "1500nc3"  	-- торговый счет
CLIENT_CODE = "1500nc3"     -- код клиента

CURRENT_STATE = '0'
current_order_num = 0    
current_order_price = 0  
uniq_trans_id = 0        

------------------------
is_run = true

function OnStop(s)
  is_run = false
end
function main()
  while is_run do
    sleep(50)				
  end
end

------------------------


function MakeStringPrice(price)

  local n,m = math.modf(price)
  n = tostring(n)
  if PRICE_SCALE > 0 then
    m = math.floor(m * 10^PRICE_SCALE + 0.01)
    if m > 0.1 then
      m = string.sub(tostring(m), 1, PRICE_SCALE)
      m = string.rep('0', PRICE_SCALE - string.len(m)) .. m
    else
      m = string.rep('0', PRICE_SCALE)
    end
    m = '.' .. m
  else
    m = ''
  end
  
  return (n .. m)

end


function KillOrder()

  if (CURRENT_STATE ~= 'N') and (CURRENT_STATE ~= 'L') then  
    return
  end

  uniq_trans_id = uniq_trans_id + 1

  local trans = {
          ["ACTION"] = "KILL_ORDER",
          ["CLASSCODE"] = CLASS,
          ["SECCODE"] = SEC,
          ["ORDER_KEY"] = tostring(current_order_num),
          ["TRANS_ID"] = tostring(uniq_trans_id)
                }

  local res = sendTransaction(trans)
message("Kill : " .. res, 2)


  if CURRENT_STATE == 'N' then
    CURRENT_STATE = 'MB'     -- N --> MB
  else
    CURRENT_STATE = 'MS'     -- L --> MS
  end

end


function SendOrder(buy_sell, price)

  uniq_trans_id = uniq_trans_id + 1

  local trans = {
          ["ACTION"] = "NEW_ORDER",
          ["CLASSCODE"] = CLASS,
          ["SECCODE"] = SEC,
          ["ACCOUNT"] = TRADE_ACC,
          ["OPERATION"] = buy_sell,
          ["PRICE"] = MakeStringPrice(price),
          ["QUANTITY"] = tostring(1),
          ["TRANS_ID"] = tostring(uniq_trans_id)
                }

  local res = sendTransaction(trans)
message("Send : " .. res, 2)
  current_order_price = price

end


function MakeOrderBuy()

  if (CURRENT_STATE ~= '0') then  
    return
  end

  local qt = getQuoteLevel2(CLASS, SEC)
  if qt == nil then         
    return                     
  end
  message(tostring(qt.bid_count+0) .. " -- " .. tostring(qt.offer_count+0), 2)
  if ((qt.bid_count+0 == 0) or (qt.offer_count+0 == 0)) then
    return                     
  end
    
  local bid = qt.bid[qt.bid_count+0].price
  local offer = qt.offer[1].price
  local p_spread = (offer - bid) / bid * 100
  local spread_step = math.floor((offer - bid) / PRICE_STEP + 0.01)

  message("bid=" .. tostring(bid) .. " offer=" .. tostring(offer) .. " %=" .. tostring(p_spread) .. " s_step=" .. tostring(spread_step) .. " CURRENT_STATE=" .. CURRENT_STATE, 1)
  
  if (p_spread >= MIN_P_SPREAD) and (spread_step >= MIN_SPREAD_STEP) then
message("TRY TO OPEN POSITION", 2)
    SendOrder('B', bid + PRICE_STEP)
    CURRENT_STATE = 'OB'    
  end

end



function MakeOrderSell()

  if (CURRENT_STATE ~= '1') then  
    return
  end

  local qt = getQuoteLevel2(CLASS, SEC)
  if ((qt.bid_count+0 == 0) or (qt.offer_count+0 == 0)) then
    return                     
  end
    
  local offer = qt.offer[1].price
  message("MakeOrderSell offer=" .. tostring(offer), 1)
  SendOrder('S', offer - PRICE_STEP)
  CURRENT_STATE = 'OS'     

end


function CheckBidPosition()

  if (CURRENT_STATE ~= 'N') then  
    return
  end

  local qt = getQuoteLevel2(CLASS, SEC)
  if ((qt.bid_count+0 == 0) or (qt.offer_count+0 == 0)) then
    return                    
  end
    
  local bid = tonumber(qt.bid[qt.bid_count+0].price)  
  

  if (bid - current_order_price) > (PRICE_STEP / 2) then
    KillOrder()
	return
  end
  

  if (qt.bid_count+0 > 1) then  
    local prev_bid = tonumber(qt.bid[qt.bid_count-1].price)
    if (current_order_price - prev_bid) > (PRICE_STEP * 1.5) then
      KillOrder()
      return
	 end
  end

end



function CheckOfferPosition()

  if (CURRENT_STATE ~= 'L') then  
    return
  end

  local qt = getQuoteLevel2(CLASS, SEC)
  if ((qt.bid_count+0 == 0) or (qt.offer_count+0 == 0)) then
    return                     
  end
    
  local offer = tonumber(qt.offer[1].price)   
  

  if (current_order_price - offer) > (PRICE_STEP / 2) then
    KillOrder()
	return
  end
  

  if (qt.offer_count+0 > 1) then  
    local prev_offer = tonumber(qt.offer[2].price)
    if (prev_offer - current_order_price) > (PRICE_STEP * 1.5) then
      KillOrder()
      return
	 end
  end

end




function OnInit(s)
  MakeOrderBuy()
end


function OnQuote(class_code, sec_code)


  if (class_code ~= CLASS) or (sec_code ~= SEC) then
    return
  end

  message("OnQuote: CURRENT_STATE=" .. CURRENT_STATE, 1)


  if (CURRENT_STATE ~= '0') and (CURRENT_STATE ~= 'N') and (CURRENT_STATE ~= 'L') then
    return
  end

  if     (CURRENT_STATE == '0') then  
    MakeOrderBuy()            
  elseif (CURRENT_STATE == 'N') then  
    CheckBidPosition()            
  elseif (CURRENT_STATE == 'L') then  
    CheckOfferPosition()         
  end

end


function OnTransReply(repl)
  
  message("TrRepl = " .. tostring(repl.status) .. " o_num=" .. tostring(repl.ordernum) .. " R=" .. tostring(repl.R) .. " [" .. repl.result_msg .. "]" .. " uid=" .. tostring(repl.uid) .. " price=" .. tostring(repl.price) .. " quantity=" .. tostring(repl.quantity) ..  " cl_code=" .. tostring(repl.client_code) .. " CURRENT_STATE=" .. CURRENT_STATE, 2)

  if (uniq_trans_id ~= repl.R) then
    message("TrRepl NO LAST TRAN", 3)
    return
  end


  if     (CURRENT_STATE == 'OB') then  
    current_order_num = repl.ordernum
	if current_order_num ~= 0 then 
	  CURRENT_STATE = 'N'
	 else
	  CURRENT_STATE = '0'
	 end
  elseif (CURRENT_STATE == 'MB') then  
    if (repl.status == 3) then  
      CURRENT_STATE = '0'  
      MakeOrderBuy()        
    end
  elseif (CURRENT_STATE == 'OS') then  
    current_order_num = repl.ordernum
	if current_order_num ~= 0 then  
	  CURRENT_STATE = 'L'
	 else
	  CURRENT_STATE = '1'
	 end
  elseif (CURRENT_STATE == 'MS') then  
    if (repl.status == 3) then  
      CURRENT_STATE = '1'  
      MakeOrderSell()      
    end
  end

end


function OnTrade(trade)

  message("OnTrade: CURRENT_STATE=" .. CURRENT_STATE, 1)

  if     (CURRENT_STATE == 'N') or (CURRENT_STATE == 'OB') or (CURRENT_STATE == 'MB') then    
    CURRENT_STATE = '1'
    MakeOrderSell()                     
  elseif (CURRENT_STATE == 'L') or (CURRENT_STATE == 'OS') or (CURRENT_STATE == 'MS') then    
    CURRENT_STATE = '0'
    MakeOrderBuy()                      
  end

end
