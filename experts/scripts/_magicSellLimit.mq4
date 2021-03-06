//+------------------------------------------------------------------+
//|                                                        _Sell.mq4 |
//|                                                       Momo Fujii |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Momo Fujii"
#property link      "http://www.metaquotes.net"

#include <processError.mqh>
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   	double   buyLots,
               minLots,// Minimal number of lots    
               freeMargin,// Free margin   
               priceOneLot, // Price of 1 lot   
               steps;           // Step is changed    

      string symb = Symbol();
      int timeframe = Period();
      int ticket;
               
      double price = WindowPriceOnDropped();
   
	   // Order value   
	   RefreshRates();                                    // Refresh rates   
	   minLots = MarketInfo(symb,MODE_MINLOT);             // Minimal number of lots    
	   freeMargin   = AccountFreeMargin();                // Free margin   
	   priceOneLot= MarketInfo(symb,MODE_MARGINREQUIRED); // Price of 1 lot   
	   steps   = MarketInfo(symb,MODE_LOTSTEP);           // Step is changed    

	   
   	buyLots = 0.1;                                // work with them
   	
		if( buyLots < minLots)
	   { 
   	   Alert("Specified lot size too small! Minimum of ", minLots, " lots!");
   	   return;
	   }   
   
	   if ( buyLots * priceOneLot > freeMargin )                      // Lot larger than free margin     
	   {      
   	   Alert(" Not enough money for ", buyLots," lots. ", buyLots * priceOneLot, "necesarry!");      
   	   return;                                   // Exit start()     
	   }
		
		if( price < Bid)
		{
			Alert("Invalid price for sellStop!");
			return;
		}
		
	   //--------------------------------------------------------------- 8 --   
	   // Opening orders   

	   while(true)                                  // Orders opening loop     
	   {  
   	   RefreshRates();                        // Refresh rates
   	  	ticket = OrderSend( symb, OP_SELLLIMIT, buyLots, price, 1, 0, 0, "", timeframe, 0, Red );//Opening Buy

   	   if(ticket > 0)                        // Success :)           
   	   {            
      	   Alert ("Opened order SELLStop ",ticket, ", price ", price);            
      	   return;                             // Exit start()           
   	   }         
   
   	   if(processError( GetLastError() ) == 1 )      // Processing errors            
      	   continue;                           // Retrying         
   
   	   return;                                // Exit start()        
	   }
//----
   return(0);
  }
//+------------------------------------------------------------------+