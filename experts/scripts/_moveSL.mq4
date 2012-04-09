//+------------------------------------------------------------------+
//|                                                      _moveSL.mq4 |
//|                                                       Momo Fujii |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Momo Fujii"
#property link      "http://www.metaquotes.net"

#include <processError.mqh>
#include <countOrders.mqh>
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int   type,
         ticket,
         minDist;
         
   double   currentPrice,
            openPrice,
            currentSL,
            currentTP;
            
   bool  ans;
   
   double newSL = WindowPriceOnDropped();
   
   string symb  = Symbol();
   
   if( countMarketOrders( symb ) != 1 )
   {
   	Alert("Invalid order count!");
   	return;
   }
   
   for( int i = 0; i < OrdersTotal(); i++ )          // Loop through orders     
   {      
      if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true ) // If there is the next one        
      {                                         // Analyzing orders:               
         if( OrderSymbol() == symb )
         {
         	type     = OrderType();
         	ticket   = OrderTicket();                        
         	minDist  = MarketInfo(Symbol(), MODE_STOPLEVEL);
         	openPrice = OrderOpenPrice();
         	currentSL = OrderStopLoss();
            
         	while(true)
         	{
            	if( type == 0 )                        // buy order found
            	{
               	currentPrice  = Bid;                      // get the current value
         
               	if( ( newSL > ( currentPrice - ( minDist * Point ) ) ) )  // check if the new SL is valid, otherwise use minimum valid SL
                  {
                  	Alert("StopLoss too close!");
							return;
						}
            
               	currentTP = OrderTakeProfit();
               	ans  = OrderModify( ticket, openPrice, newSL, currentTP, 0);
      
               	if(!ans){                              
                  	if( processError(GetLastError()) > 0)
                     	continue;
                  	else       
                     	return;
               	}else{
                  	Alert("Long order ", ticket, " modified! Former SL was ", currentSL, ", new SL is ", newSL,"." );          
                  	return(true);
               	}
               	
            	}else if( type == 1 )                        // sell order
            	{
               	currentPrice  = Ask;                      // get the current value
               	
                  if( ( newSL < currentPrice + (minDist * Point) ) )// check if the new SL is valid, otherwise use minimum valid SL
                  {
                  	Alert("StopLoss too close!");
							return;
						}
                  	
                 	currentTP = OrderTakeProfit();
                  ans  = OrderModify( ticket, openPrice, newSL, currentTP, 0);
            
               	if(!ans){
                  	if( processError(GetLastError()) > 0)
                     	continue;
                  	else         
                     	return;
               	}else{
                  	Alert("Short Order ", ticket, " modified! Former SL was ", currentSL, ", new SL is ", newSL,"." );
                  	return(true);
               	}
               }
               break;
         	}
         }
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+