##example of usage in MD file

##used to initiate login proces and getting token for all other calls
SETEVE <-function(appname, 
                  clientid, 
                  secret, 
                  eveauthorize = "https://login-tq.eveonline.com/oauth/authorize/", 
                  evetoken = "https://login-tq.eveonline.com/oauth/token/",
                  evescope = "publicData"){
  
  library(httr)
  library(jsonlite)  
  
  myapp <- oauth_app(appname, clientid, secret)
  
  eve_token <- oauth2.0_token(oauth_endpoint(authorize = eveauthorize, access = evetoken), myapp, scope = evescope)
  
  token <- config(token = eve_token)
  
  token
}


##simple GET, You pass it token object produced by SETEVE() and URL You want to look at 
##and it will return body of response in data.frame format
GETEVE<- function(get,token){
  
  library(httr)
  library(jsonlite)
  
  req <- GET(get, token)
  result <- content(req, type = "application/json; charset=utf-8")
  result<-fromJSON(toJSON(result))
  result
  
}


##uses token from SETEVE() and GET() function to look trough crest endpoint for item with matching name
##and returns an URL to be passed later to market endpoint
##it returns null if the exact item is not found (case sensitive) on all the pages
GETEVE_itemtypes<-function(type, token){
  if(is.character(type)){
    maincrest<-GETEVE(token = token,get = "https://crest-tq.eveonline.com/")
    itemcrest<-GETEVE(token = token,get = maincrest$itemTypes$href)
    
    while(length(itemcrest$items[itemcrest$items$name ==type,"href"])==0 & !is.null(itemcrest$`next`)){
      itemcrest<-GETEVE(token = token,get = itemcrest$`next`$href)
    }
  
    if(length(itemcrest$items[itemcrest$items$name ==type,"href"])==0) {
      return(NULL)
    }    else {
      return(itemcrest$items[itemcrest$items$name == type,"href"][[1]])
    }
  
  }
  
}


##uses token from SETEVE() and GET() function to look trough crest endpoint for region with matching name
##and returns an URL to be passed later to market endpoint
##it returns null if the exact region is not found (case sensitive) on all the pages (altough there is only one page)
GETEVE_regionmarket<-function(region, token){
  if(is.character(region)){
    maincrest<-GETEVE(token = token,get = "https://crest-tq.eveonline.com/")
    regioncrest<-GETEVE(token = token,get = maincrest$regions$href)
    
    while(length(regioncrest$items[regioncrest$items$name ==region,"href"])==0 & !is.null(regioncrest$`next`)){
      regioncrest<-GETEVE(token = token,get = regioncrest$`next`$href)
    }
    
    if(length(regioncrest$items[regioncrest$items$name ==region,"href"])==0) {
      return(NULL)
    }    else {
      reg<-regioncrest$items[regioncrest$items$name == region,"href"][[1]]
      regionmarket<-GETEVE(token = token,get = reg)
      marketlinks<-c(regionmarket$marketSellOrders$href,regionmarket$marketBuyOrders$href)
      names(marketlinks)<-c("sell","buy")
      return(marketlinks)
    }
    
  }
  
}

##core function, uses all of the above in combination to get list of all bu and sell orders
GETEVE_marketorders<-function(region, item, token, buysell = c("sell","buy")){
  
  reg<-GETEVE_regionmarket(region, token = token)
  type<-GETEVE_itemtypes(item, token = token)
  
  buy<-GETEVE(get=paste(reg["buy"],"?type=",type,sep = ""),token = token)
  sell<-GETEVE(get=paste(reg["sell"],"?type=",type,sep = ""),token = token)
  orders<-list(buy$items, sell$items)
  names(orders)<-c("buy","sell")
  return(orders)
  
}

##example of usage in MD file
