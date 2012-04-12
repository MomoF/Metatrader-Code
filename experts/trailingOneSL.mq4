//+------------------------------------------------------------------+
//|                                                        EMAEA.mq4 |
//|                                                       Momo Fujii |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Momo Fujii"
#property link      "http://www.metaquotes.net"

#include <processError.mqh>

extern bool allSymbols = true;
extern bool closeBlacklisted = false;
extern bool moveToMinDist = false;
extern bool DEBUG = true;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   return(0);
}

int deinit()
{
   return(0);
}

int isInArray2D(int& array[][2], int key)
{
	int pos = -1;
	for(int i = 0; i < (ArraySize(array)/2); i++){
		if(array[i][0] == key)
		{
			pos = i;
			break;
		}
	}
	return(pos);
}

int isInArray1D(int& array[], int key)
{
	int pos = -1;
	for(int i = 0; i < ArraySize(array); i++){
		if(array[i] == key)
		{
			pos = i;
			break;
		}
	}
	return(pos);
}

void add2Blacklist(int& array[], int key)
{
	int currentSize = ArraySize(array);
	ArrayResize(array, currentSize + 1);
	array[currentSize] = key;
}

void addTicketTime(int& array[][2], int key, int now)
{
	int currentSize = (ArraySize(array)/2);
	ArrayResize(array, currentSize + 1);
	array[currentSize][0] = key;
	array[currentSize][1] = now;
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
    bool 		valid		= false;
    datetime 	now;
    double 		trailingSL 	= 0;
    int 		barsAgo 	= 0;
    int 		ticket 		= 0;
    int 		timeframe;
    int 	   	type;
    int 	   	pos;
    string		symb		= Symbol();

    // static arrays for keeping track of managed trades
    static int 			managedOrders[][2];
    static int 			blacklist[];
    int 				blacklistOld[];
    
    if(ArraySize(blacklist)>0)
    {  
        ArrayCopy(blacklistOld,blacklist);
        ArrayResize(blacklist,0);
    }
    
    // check if there are enough bars int the window, otherwise return
    if( Bars < 3 )
    {      
	    Alert("Not enough bars in the window. EA doesn\'t work.");
	    return(false);                                   // Exit start()    
    }   

	// cycle through all available orders
    for( int l = 0; l < OrdersTotal(); l++ )
    {      
		if( OrderSelect(l, SELECT_BY_POS, MODE_TRADES) == true )
		{  
			// geto order ticket number and type
			ticket 	= OrderTicket();
			type     = OrderType(); 
			
			//check if valid magic number is set, otherwise skip trade
			switch(OrderMagicNumber())
			{
				case PERIOD_M1: 	valid 		= True;
									timeframe	= PERIOD_M1;
									break;
				case PERIOD_M5: 	valid 		= True;
									timeframe	= PERIOD_M5;
									break;
				case PERIOD_M15: 	valid 		= True;
									timeframe	= PERIOD_M15;
								  	break;
				case PERIOD_M30: 	valid 		= True;
									timeframe	= PERIOD_M30;
								  	break;
				case PERIOD_H1: 	valid 		= True;
									timeframe	= PERIOD_H1;
									break;
				case PERIOD_H4: 	valid 		= True;
									timeframe	= PERIOD_H4;
								 	break;
				case PERIOD_D1: 	valid 		= True;
									timeframe	= PERIOD_D1;
								 	break;
				case PERIOD_W1: 	valid 		= True;
									timeframe	= PERIOD_W1;
								 	break;
				case PERIOD_MN1: 	valid 		= True;
									timeframe	= PERIOD_MN1;
								 	break;
				default:		    valid 		= False;
			}
			
			// skip if order is blacklisted <=> should have already been closed
			if (isInArray1D(blacklistOld,ticket) < 0)
			{
				if(closeBlacklisted==true)
					closeByTicket(ticket);
				add2Blacklist(blacklist,ticket);
				valid = false;
			}
			
			// do not change pending orders
			if (( type <= 1 ) && 
				 ( valid == true ) && 
				 ( (allSymbols == true ) || ( OrderSymbol() == symb ) ) // if allSymbols mode is set, change all orders!
				 )
			{  
				// get order symbol if in allSymbols mode
				if( allSymbols == true )
				{
					symb = OrderSymbol();
					Print("Setting Symbol to " + symb);
				}
				
				// debug printing          
				if(DEBUG==True)
				{
					Print("Found order: " + ticket);
					Print("Timeframe:   " + timeframe);
					Print("Symbol:      " + symb);
				}
				
				// check if order is in managedOrders array
				pos 		= isInArray2D(managedOrders, ticket);
				if( ( pos >= 0) )
				{
					if(DEBUG==True)
					{
						Print("Order is already in dynamic array at pos " + pos);
						Print("Was updated " + iBarShift(symb, timeframe, managedOrders[pos][1]) + " bars ago");
					}
					// check if SL was already changed during this bar
					if (iBarShift(symb, timeframe, managedOrders[pos][1]) == 0)
						continue;
				}
				
				// get how many bars of assigned timeframe ago this order was opened
				barsAgo				= iBarShift(symb, timeframe, OrderOpenTime());
				
				// get new SL value for this order
				if (getTrailingSL(trailingSL, barsAgo, type, timeframe, symb) == true)
				{
					if(DEBUG==True)
					{
						Print("Order was opened " + barsAgo + " bars ago!");
						Print("New SL is " + trailingSL);
					}
					
					// change SL if different from current SL
					if( ( trailingSL == OrderStopLoss() ) || (moveSL( ticket, type, symb, trailingSL ) ) )
					{
						// try to move SL, if it fails, order will be processed again upon the next incoming tick
						// update mangedOrders array upon success
						now = TimeCurrent();
						pos = isInArray2D(managedOrders, ticket);
						if ( pos >= 0 )
						{
							Print("Order is in Array, updating time");
							managedOrders[pos][1]=now;
						}else{
						    Print("Adding order to Array");
							addTicketTime(managedOrders, ticket, now);
						}							
					}
				}else
				{
					if(closeBlacklisted==true)
						closeByTicket(ticket);
					add2Blacklist(blacklist,ticket);
				}
				
			}
		}
	}
	return(0);
}

// function to move SL
bool moveSL(int ticket, int type, string symb, double newSL)
{
	double 	currentSL 	= OrderStopLoss();
	double	minDist  	= MarketInfo(symb, MODE_STOPLEVEL);
	double 	openPrice 	= OrderOpenPrice();	
	double 	currentTP;
	double 	currentPrice;
	bool ans;
	
	// enter loop in order to deal with error occurence
	while(true)
	{
		if (type == OP_BUY)
		{	
			currentPrice  = MarketInfo(symb,MODE_BID);
			
			// check if the new SL is valid, use minimum valid SL if in moveToMinDist mode
   			if( ( newSL > ( currentPrice - ( minDist * Point ) ) ) )  
      		{
      			if (moveToMinDist)
      			{
      				newSL = ( currentPrice - ( minDist * Point ) );
      			}else
      			{
      				Alert("StopLoss too close!");
					return(false);
				}
			}

   			currentTP = OrderTakeProfit();
			
			// try to modify order, process error, if neccessary
			if(OrderModify( ticket, openPrice, newSL, currentTP, 0))
			{
   				Alert("Long order ", ticket, " modified! Former SL was ", currentSL, ", new SL is ", newSL,"." );          
   				return(true);   				
			}else
			{
				if( processError(GetLastError()) > 0)
      				continue;
   				else       
      				return;
			}
		}else if (type == OP_SELL)
		{
			currentPrice  = MarketInfo(symb,MODE_ASK);
			
			// check if the new SL is valid, use minimum valid SL if in moveToMinDist mode
   			if( newSL < (currentPrice + (minDist * Point) ) )
   			{
   				if (moveToMinDist)
      			{
      				newSL = currentPrice + (minDist * Point);
      			}else
      			{
   					Alert("StopLoss too close!");
					return(false);
				}
			}
   	
  			currentTP = OrderTakeProfit();
	   		
			// try to modify order, process error, if neccessary
			if(OrderModify( ticket, openPrice, newSL, currentTP, 0))
			{
				Alert("Short Order ", ticket, " modified! Former SL was ", currentSL, ", new SL is ", newSL,"." );
				return(true);
			}else
			{
   				if( processError(GetLastError()) > 0)
      				continue;
   				else         
      				return(false);	
			}
		}
		break;
	}
	return(false);
}

// funtion for retrieving a new SL 
bool getTrailingSL(double & trailingSL,int openedBarsAgo, int type, int timeframe, string symb)
{
	bool 		innenstabAktiv 	= false;
	double 		aussenstabLow 	= 0;
  	double 		aussenstabHigh 	= 0;
	int 		offset;
	
	trailingSL 	= 0;
	
	// iterate over all past bars and get 
	for(int i = 0; i <= openedBarsAgo; i++)
	{
		// offset for shift used in iIndicators
		offset = openedBarsAgo - i;
		switch(i)
		{
			// for the first bar, the SL is always set to the High/Low
			case 0:
				if (type == OP_BUY)
					trailingSL = iLow(symb, timeframe, offset);
				else if (type == OP_SELL)
					trailingSL = iHigh(symb, timeframe, offset);
				break;
			// the SL does not change on the second bar 
			case 1:
				if (type == OP_BUY)
					trailingSL = iLow(symb, timeframe, offset + 1);
				else if (type == OP_SELL)
					trailingSL = iHigh(symb, timeframe, offset + 1);
				break;
			// SL is moved to the previous bar High/Low as long we haven't encountered an Innenstab on the second bar.
			// In this case the SL is set 10% of the first bar range above the first SL
			case 2:
				if (type == OP_BUY){
					if ( iClose(symb, timeframe, offset + 1 ) <= iHigh(symb, timeframe, offset + 2) )
					{
						trailingSL 		= (iLow(symb, timeframe, offset + 2) - 0.1*( iHigh(symb, timeframe, offset + 2) * iLow(symb, timeframe, offset + 2) ));
						innenstabAktiv = true;
						aussenstabLow 	= iLow(symb, timeframe, offset + 2);
						aussenstabHigh = iHigh(symb, timeframe, offset + 2);
					}else
						trailingSL = iLow(symb, timeframe, offset + 1);
				}else if (type == OP_SELL)
				{
					if ( iClose(symb, timeframe, offset + 1 ) >= iLow(symb, timeframe, offset + 2) )
					{
						trailingSL = (iHigh(symb, timeframe, offset + 2) + 0.1*( iHigh(symb, timeframe, offset + 2) * iLow(symb, timeframe, offset + 2) ));
						innenstabAktiv = true;
						aussenstabLow 	= iLow(symb, timeframe, offset + 2);
						aussenstabHigh = iHigh(symb, timeframe, offset + 2);
					}else
						trailingSL = iHigh(symb, timeframe, offset + 1);
				}
				break;
			//default behaviour, sufficient for every bar after the third
			default:
				// check wether we are in an Innenstab situation
				if(innenstabAktiv)
				{
					// check if the closeprice has left the Innenstab corridor.
					// close the order, if it left the corridor in the wrong direction.
					// if it left the corridor in the right direction, end the Innenstab situation
					if (type == OP_BUY)
					{ 
						if( iClose(symb, timeframe, offset + 1) < aussenstabLow )
						{
							return(false);
							innenstabAktiv = false;
						}else if( iClose(symb, timeframe, offset + 1) > aussenstabHigh )
						{
							trailingSL = iLow(symb, timeframe, i + 1);
							innenstabAktiv = false;
						}
					}else if (type == OP_SELL)
					{
						if(iClose(symb, timeframe, i + 1) > aussenstabHigh)
						{
							return(false);
							innenstabAktiv = false;
						}else if( iClose(symb, timeframe, i + 1) < aussenstabLow)
						{
							trailingSL = iHigh(symb, timeframe, i + 1);
							innenstabAktiv = false;
						}
					}	
				}else
				{
					// we haven't been in an Innenstab situation previously
					// check if we have entered an Innenstab
					if( ( iOpen(symb,timeframe, offset + 1) 	<= iHigh(symb,timeframe, offset + 2) ) &&
		 				( iOpen(symb,timeframe, offset + 1) 	>= iLow(symb,timeframe, offset + 2)  ) &&
		 				( iClose(symb,timeframe, offset + 1) 	<= iHigh(symb,timeframe, offset + 2) ) &&
		 	          	( iClose(symb,timeframe, offset + 1) 	>= iLow(symb,timeframe, offset + 2)  ) )
					{
						innenstabAktiv = true;
						aussenstabHigh = iHigh(symb, timeframe, offset + 2);
						aussenstabLow 	= iLow(symb, timeframe, offset + 2);
						
						// encountered a new Innenstab case
						// set the SL to the pre-Aussenstab level, if it makes sense.
						// otherwise search 5 bars before Aussenstab
						if (type == OP_BUY)
						{
							if( iLow(symb, timeframe, offset + 3) < aussenstabLow)
							{
								trailingSL = iLow(symb, timeframe, offset + 3);
							}else
							{
								int j = 4;
								trailingSL = aussenstabLow - ( (aussenstabHigh - aussenstabLow) * 0.1 );
					
								while( j < 10)
								{
									if(iLow(symb, timeframe, offset + j) < aussenstabLow)
									{
										trailingSL = iLow(symb, timeframe, offset + j);
										break;
									}
									j++;
								}
							}
						}else if (type == OP_SELL)
						{
							if( iHigh(symb, timeframe, offset + 3) > aussenstabHigh)
							{
								trailingSL = iHigh(symb, timeframe, offset + 3);
							}else
							{
								int k = 4;
								trailingSL = aussenstabHigh + ( (aussenstabHigh - aussenstabLow) * 0.1 );
								
								while(k < 10)
								{
									if( iHigh(symb, timeframe, offset + k) > aussenstabHigh )
									{
										trailingSL = iHigh(symb, timeframe, offset + k);
										break;
									}
									k++;
								}
							}
						}
					}else
					{
						// if we encountered a normal case, just set Sl to previous bar high/low
						if (type == OP_BUY)
						{			
							if(iOpen(symb, timeframe, offset) >= iLow(symb, timeframe, offset + 1))
							{
								trailingSL = iLow(symb, timeframe, offset + 1);
							}
						}else if (type == OP_SELL)
						{
							if( iOpen(symb, timeframe, i) <= iHigh(symb, timeframe, i + 1) )
							{
								trailingSL = iHigh(symb, timeframe, 1);
							}
						}
					}
				}
		}	
	}
	return(true);
}

bool closeByTicket(int ticket)
{
	int type;
	double orderLots;
	bool ans;
	string symb;
	
	if (OrderSelect(ticket, SELECT_BY_TICKET) == true)
	{
		type           = OrderType();                    // Type of selected order           
		orderLots      = OrderLots();                    // Amount of lots
		symb           = OrderSymbol();
    
		while(true)                                  // Loop of closing orders     
		{      
			if ( type == 0)              // Order Buy is opened..        
			{                                       // and there is criterion to close         
				RefreshRates();                        // Refresh rates         
				ans = OrderClose( ticket, orderLots, MarketInfo(symb,MODE_BID), 5 );      // Closing Buy

				if ( ans )                         // Success :)           
					return(true);                              // Exit closing loop           
			  
				if ( processError( GetLastError() ) == 1 )      // Processing errors            
					continue;                           // Retrying

				return(false);                                // Exit start()        
			}

			if ( type == 1)                // Order Sell is opened..        
			{                                       // and there is criterion to close         
				RefreshRates();                        // Refresh rates         
				ans = OrderClose( ticket, orderLots, MarketInfo(symb,MODE_ASK), 5 );      // Closing Sell         
				if (ans )                         // Success :)                      
					return(true);

				if ( processError( GetLastError() ) == 1 )      // Processing errors            
					continue;                           // Retrying         
				
				return(false);                                // Exit start()        
			}      
			break;                                    // Exit while     
		}
	}
	return(false);
}