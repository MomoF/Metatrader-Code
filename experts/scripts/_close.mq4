//+------------------------------------------------------------------+
//|                                                       _close.mq4 |
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
	int type           = OrderType();                    // Type of selected order         
	double orderPrice     = OrderOpenPrice();               // Price of selected order         
	double orderStopLoss  = OrderStopLoss();                // SL of selected order         
	double orderTakeProfit= OrderTakeProfit();              // TP of selected order         
	double orderLots      = OrderLots();                    // Amount of lots
	bool ans;
    string symb  = Symbol();                               // Security name
    int ticket = -1;
    double distance = 0;
    double dropped = WindowPriceOnDropped();
    
    for( int i = 0; i < OrdersTotal(); i++ )          // Loop through orders     
    {      
        if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true ) // If there is the next one        
        {                                         
            if ( OrderSymbol() == symb)               // Another security   
            {
                if ( OrderType() <= 1)
                {
                    
                    if ( ( ticket < 0) || ( MathAbs(dropped - OrderOpenPrice()) < distance ) )
                    {
                        ticket         = OrderTicket();                  // Number of selected order         
     	              type           = OrderType();                    // Type of selected order         
     	              orderPrice     = OrderOpenPrice();               // Price of selected order         
     	              orderStopLoss  = OrderStopLoss();                // SL of selected order         
     	              orderTakeProfit= OrderTakeProfit();              // TP of selected order         
     	              orderLots      = OrderLots();                    // Amount of lots
                    }
                }
            }
        }     
    }
   
    if (ticket >= 0)
    {
        i = 0;
   	    while(i <= 5)
   	    {
   	        i++;
      	   if ( type == 0)              // Order Buy is opened..        
	         	{                                       // and there is criterion to close         
   	         	  RefreshRates();                        // Refresh rates         
   	         	  ans = OrderClose( ticket, orderLots, Bid, 5, Green );      // Closing Buy
         
   	         	  if ( ans )                         // Success :)           
   	         	  {            
      	         	  Alert( "Closed order Buy ", ticket );            
      	         	  break;                              // Exit closing loop           
   	         	  }     
   	         	  if ( processError( GetLastError() ) == 1 )      // Processing errors            
      	         	  continue;                           // Retrying
   	         	  return;                                // Exit start()        
	         	}else if ( type == 1)                // Order Sell is opened..        
	         	{                                       // and there is criterion to close         
   	         	
   	         	  RefreshRates();                        // Refresh rates         
   	         	  ans = OrderClose( ticket, orderLots, Ask, 5, Red );      // Closing Sell         
   	         	  if (ans )                         // Success :)           
   	         	  {            
      	         	  Alert ("Closed order Sell ", ticket);            
      	         	  break;                              // Exit closing loop           
   	         	  }
   
   	         	  if ( processError( GetLastError() ) == 1 )      // Processing errors            
      	         	  continue;                           // Retrying         
   	         	  return;                                // Exit start()        
	         	}      
	         	break;
  	    }
    }
//----
   return(0);
}
//+------------------------------------------------------------------+