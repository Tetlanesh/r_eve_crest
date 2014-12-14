r_eve_crest
===========

REQUIRMENT: callback_url set to:
http://localhost:1410/

Used to access eve authenticated crest endpoint.
Focusing of market orders but can be used to access all of auth crest endpoints

IMPORTANT NOTE: no caching at this point, so it goes back to crest tree everytime You make a call

Another important note: no debugging or error handling in here whatsoever, it assumes all will work fine

R httr library handles refresh tokens very well so I didnt even had to write single character of code for it :) Whenever You will see "Auto-refreshing stale OAuth token." You can thank the developer for it :)

##simple example of usage:

```R
token<-SETEVE("yourappname", "yourclientid", "yoursecret")
orders<-GETEVE_marketorders("The Forge","Moros Blueprint",token)
orders$buy[c("price","volume")]
```

```
       price volume
1          1      1
2    2111.11     11
3 1620001002      1
4  1.621e+09      1
5     220000      2
6 1621000000      2
```

##accessing endpoints diffrent than market

```R
GETEVE("URL of endpoint", token) returns body of a call, so starting with:
GETEVE("https://crest-tq.eveonline.com/",token) and following $href of endpoint can get You anywhere within the CREST
```

#for example:

```R
corporationRoles
token<-SETEVE("appname", "clientid", "secret")
crest<-GETEVE("https://crest-tq.eveonline.com/",token)
roles<-GETEVE(crest$corporationRoles$href,token)
roles$message
[1] "This is not third party enabled... yet" (CCP FoxFour is trolling my example :P)
```
