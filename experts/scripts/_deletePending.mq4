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
      int orderType,ticket;
      for( int i = 0; i < OrdersTotal(); i++ )          // Loop through orders     
      {      
         if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true ) // If there is the next one        
         {                                         
            if ( OrderSymbol() == symb)               // Another security   
            {            
            	orderType 	= OrderType();
            	ticket		= OrderTicket();
            
            	if ( ( orderType == OP_SELLLIMIT) || ( orderType == OP_SELLSTOP) )                     // Pending order found           
            	{            
               	while(true){
                  	if( OrderDelete( ticket ))
                  	{
                     	Alert("Pending Sell order ", ticket, " was deleted");
                     	break;
                  	}
                  	if( processError( GetLastError() ) == 1 )      // Processing errors            
         	        		continue;                           // Retrying
         	        	
      	         	return;                                // Exit start()
      	      	}
            	}
            
            
            	if ( ( orderType == OP_BUYLIMIT) || ( orderType == OP_BUYSTOP) )                     // Pending order found           
            	{            
               	while(true){
                  	if( OrderDelete( ticket ))
                  	{
                     	Alert("Pending Buy order ", ticket, " was deleted");
                     	break;
                  	}
                  	if( processError( GetLastError() ) == 1 )      // Processing errors            
         	        		continue;                           // Retrying
         	        		
      	         	return;                                // Exit start(
      	      	}
            	}        
        		}
         }     
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+