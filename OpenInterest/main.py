import requests
import json


#https://iss.moex.com/iss/engines/futures/markets/forts/boards/rfud/securities/RIZ1/candles.json?period=10&from=2021-11-03&till=2021-11-09

url = 'https://iss.moex.com/iss/analyticalproducts/futoi/securities/RI.json?iss.meta=off&iss.only=futoi'


cookies = """moexMarketUserType=1; """

#moexMarketService=[{"ID":"CNM7T","Service":{"Type":112,"Name":"","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":"","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"TRKmc","Service":{"Type":112,"Name":" ","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":" ","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"WknEb","Service":{"Type":103,"Name":"Reference Data","NameEn":"Reference Data"},"Data":[{"MarketType":103,"NameMarket":" ","NameMarketEn":"Reference Data","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2022-02-02","Till":"2022-2-1","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":"0.00","PriceUsd":"0.00"}]; __utmz=241266590.1636378403.24.9.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not provided); MPTrack=7faa6cd1.5d05336db175f;"""



cookies = {'MicexPassportCert':'FEBAKqkM7vqSW874sdeytAUAAADbhp84EOFe5xyIXP1T0Zcs4fwfWGbNQ_yVPkkAXDbIc_Mf9JsmxONnzpZ7XCS-ZUDbZ5O8-aRxH8dDpScAFQNMcibyiicN9TxCV2ZT-ZvxrNP6lAG7egaEoCt_aTOcxL5Hdja8dag5hfPtOpgkSc_xjuKXGRRG2CqyrDYaH7kl3o51Qukr0'}
#           'moexMarketService' : """[{"ID":"CNM7T","Service":{"Type":112,"Name":"","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":"","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"TRKmc","Service":{"Type":112,"Name":"","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":"","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"WknEb","Service":{"Type":103,"Name":"Reference Data","NameEn":"Reference Data"},"Data":[{"MarketType":103,"NameMarket":"","NameMarketEn":"Reference Data","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2022-02-02","Till":"2022-2-1","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":"0.00","PriceUsd":"0.00"}]""",
#                      'dtCookie':'v_4_srv_6_sn_BA4D1316E49DA47ACD17B3A08B4DB34A_perc_100000_ol_0_mul_1_app-3Aea7c4b59f27d43eb_1', 'moexMarketServiceChecked':'true' 
#           }


#_ym_uid=1613837024842950042; __utmc=241266590; _ym_d=1633961090; MicexTrackID=178.236.212.50.1634651558519922; dtCookie=v_4_srv_6_sn_BA4D1316E49DA47ACD17B3A08B4DB34A_perc_100000_ol_0_mul_1_app-3Aea7c4b59f27d43eb_1; moexMarketServiceChecked=true; _ga=GA1.2.1046597800.1633961077; moexMarketUserType=1; moexMarketService=[{"ID":"CNM7T","Service":{"Type":112,"Name":"Открытые позиции","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":"Открытые позиции","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"TRKmc","Service":{"Type":112,"Name":"Открытые позиции","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":"Открытые позиции","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"WknEb","Service":{"Type":103,"Name":"Reference Data","NameEn":"Reference Data"},"Data":[{"MarketType":103,"NameMarket":"Справочные данные","NameMarketEn":"Reference Data","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2022-02-02","Till":"2022-2-1","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":"0.00","PriceUsd":"0.00"}]; __utmz=241266590.1636378403.24.9.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not provided); MPTrack=7faa6cd1.5d05336db175f; __utma=241266590.1046597800.1633961077.1636436946.1636452671.28; _ym_isad=2; _ym_visorc=w; __utmb=241266590.2.9.1636452705275; MicexPassportCert=U5Gx5Lt73ZD_D9r6x4pJiQIAAADPemEmwXbK83SGbGNAkOHD2UCvaLd5ZLcTkpdTCyIZWTAwF_o27jr2GbkAvGiJnyYKuKw5_42DlD6tWJxfvPCfD1cSMZS68K09b4ZwKmquDV4AglayQOYQX8GmseLFZoEs63Q-7nQ7qIJFtKVc3P9xa56Kvu_Na_1oDkZ8CLkzfgpjPHwr0



#_ym_uid=1613837024842950042; __utmc=241266590; _ym_d=1633961090; MicexTrackID=178.236.212.50.1634651558519922; dtCookie=v_4_srv_6_sn_BA4D1316E49DA47ACD17B3A08B4DB34A_perc_100000_ol_0_mul_1_app-3Aea7c4b59f27d43eb_1; moexMarketServiceChecked=true; _ga=GA1.2.1046597800.1633961077; moexMarketUserType=1; moexMarketService=[{"ID":"CNM7T","Service":{"Type":112,"Name":"Открытые позиции","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":"Открытые позиции","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"TRKmc","Service":{"Type":112,"Name":"Открытые позиции","NameEn":"Open interest"},"Data":[{"MarketType":112,"NameMarket":"Открытые позиции","NameMarketEn":"Open interest","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2021-11-30","Till":"2021-11-30","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":0,"PriceUsd":0},{"ID":"WknEb","Service":{"Type":103,"Name":"Reference Data","NameEn":"Reference Data"},"Data":[{"MarketType":103,"NameMarket":"Справочные данные","NameMarketEn":"Reference Data","TypeArchiveData":0,"StartDate":"2021-11-02","EndDate":"2022-02-02","Till":"2022-2-1","From":"2021-11-02","VatIncludePrice":0,"VatIncludePriceUSD":0,"Data":""}],"Price":"0.00","PriceUsd":"0.00"}]; __utmz=241266590.1636378403.24.9.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not provided); MPTrack=7faa6cd1.5d05336db175f; __utma=241266590.1046597800.1633961077.1636436946.1636452671.28; _ym_isad=2; _ym_visorc=w; __utmb=241266590.2.9.1636452705275; MicexPassportCert=U5Gx5Lt73ZD_D9r6x4pJiQIAAADPemEmwXbK83SGbGNAkOHD2UCvaLd5ZLcTkpdTCyIZWTAwF_o27jr2GbkAvGiJnyYKuKw5_42DlD6tWJxfvPCfD1cSMZS68K09b4ZwKmquDV4AglayQOYQX8GmseLFZoEs63Q-7nQ7qIJFtKVc3P9xa56Kvu_Na_1oDkZ8CLkzfgpjPHwr0


r = requests.get(url, cookies=cookies)

var = json.loads(r.content)

results = []

for v in var['futoi']['data']:
    d = {}
    for idx, value in enumerate(v):
        d[var['futoi']['columns'][idx]] = value

    results.append(d)

print(results)

#print(results[0]['clgroup'])
#print(results[0])


#for idx, value in enumerate(var['futoi']['data']):
#    r = 0


#print('')

