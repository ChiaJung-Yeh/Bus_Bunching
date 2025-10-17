library(dplyr)
library(TDX)
library(git2r)
library(lubridate)
library(data.table)

client_id="robert1328.mg10-5fef152e-ee4f-4cfb"
client_secret="591fe8aa-6fdc-4c3b-9663-428a62ec8863"
access_token=get_token(client_id, client_secret)


repeat{
  TIME=as.POSIXct(Sys.time(), tz="Asia/Taipei")
  url="https://tdx.transportdata.tw/api/basic/v2/Bus/RealTimeNearStop/City/Taipei/307?&%24format=JSON"
  x=GET(url, add_headers(Accept="application/+json", Authorization=paste("Bearer", access_token)))
  bus_a2=fromJSON(content(x, as="text"))%>%
    select(PlateNumb, RouteUID, RouteName, SubRouteUID, SubRouteName, Direction, StopUID, StopName, StopSequence, DutyStatus, BusStatus, A2EventType, GPSTime, TripStartTime, TripStartTimeType)
  bus_a2$RouteName=bus_a2$RouteName$Zh_tw
  bus_a2$SubRouteName=bus_a2$SubRouteName$Zh_tw
  bus_a2$StopName=bus_a2$StopName$Zh_tw
  
  # Export A2 Data (by minute)
  write.csv(bus_a2, paste0("A2_Realtime/", gsub("-|:", "_", substr(as.character(TIME), 1, regexpr("\\.", as.character(TIME))-1)), ".csv"), row.names=F)
  
  
  # Export the latest 60 minute data (model input data)
  all_files=dir("A2_Realtime", pattern="2025_")
  
  temp=difftime(TIME, as.POSIXct(gsub(".csv", "", all_files), format="%Y_%m_%d %H_%M_%S", tz="Asia/Taipei"), units="min")
  all_files=all_files[temp<=60]
  all_files=paste0("A2_Realtime/", all_files)
  exp_fil=rbindlist(lapply(all_files, fread))%>%
    unique()
  fwrite(exp_fil, "A2_Realtime/A2Hour.csv", row.names=F)
  
  
  
  system("git init")
  system("git add .")
  # system('git config --global user.email "robert1328.mg10@nycu.edu.tw"')
  # system('git config --global user.name "ChiaJung-Yeh"')
  system('git commit -m "initial commit"')
  system("git push origin main")
  # system("git pull origin main")
  
  # Log progress
  message(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " — script executed")
  
  Sys.sleep(55)
}





