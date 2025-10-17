library(dplyr)
library(TDX)
library(git2r)

client_id="robert1328.mg10-5fef152e-ee4f-4cfb"
client_secret="591fe8aa-6fdc-4c3b-9663-428a62ec8863"
access_token=get_token(client_id, client_secret)

TIME=as.POSIXct(Sys.time(), tz="Asia/Taipei")
url="https://tdx.transportdata.tw/api/basic/v2/Bus/RealTimeNearStop/City/Taipei/307?&%24format=JSON"
x=GET(url, add_headers(Accept="application/+json", Authorization=paste("Bearer", access_token)))
bus_a2=fromJSON(content(x, as="text"))%>%
  select(PlateNumb, RouteUID, RouteName, SubRouteUID, SubRouteName, Direction, StopUID, StopName, StopSequence, DutyStatus, BusStatus, A2EventType, GPSTime, TripStartTime, TripStartTimeType)
bus_a2$RouteName=bus_a2$RouteName$Zh_tw
bus_a2$SubRouteName=bus_a2$SubRouteName$Zh_tw
bus_a2$StopName=bus_a2$StopName$Zh_tw

write.csv(bus_a2, paste0("A2_Realtime/", gsub("-|:", "_", substr(as.character(TIME), 1, regexpr("\\.", as.character(TIME))-1)), ".csv"), row.names=F)

add(repo, path=paste0("A2_Realtime/", gsub("-|:", "_", substr(as.character(TIME), 1, regexpr("\\.", as.character(TIME))-1)), ".csv"))

usethis::create_github_token()
gitcreds::gitcreds_set()
repo=repository()

git2r::push(repo, credentials=git2r::cred_token(token="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"))

usethis::use_git()



