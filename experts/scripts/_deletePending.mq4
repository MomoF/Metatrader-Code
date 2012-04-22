//+------------------------------------------------------------------+
//|                                               _deletePending.mq4 |
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
    string symb  = Symbol();                               // Security name
    int ticket = -1;
    double distance = 0;
    double newSL = WindowPriceOnDropped();

    for( int i = 0; i < OrdersTotal(); i++ )          // Loop through orders     
    {      
        if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true ) // If there is the next one        
        {                                         
            if ( OrderSymbol() == symb)               // Another security   
            {
                if ( OrderType() > 1)
                {
                    if ( ( i == 0) || ( MathAbs(WindowPriceOnDropped() - OrderOpenPrice()) < distance ) )
                    {
                        distance = MathAbs(WindowPriceOnDropped() - OrderOpenPrice());
                        ticket =OrderTicket();
                    }
                }
            }
        }     
    }
    
    if (ticket >= 0)
    {
   	    while(true)
   	    {
      	    if( OrderDelete( ticket ))
      	    {
         	    Alert("Pending order ", ticket, " was deleted");
         	    break;
      	    }
      	
      	    if( processError( GetLastError() ) == 1 )      // Processing errors            
        		    continue;                           // Retrying
        	
     	    return;                                // Exit start()
  	    }
    }
//----
   return(0);
}
//+------------------------------------------------------------------+