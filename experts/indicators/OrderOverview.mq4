//+------------------------------------------------------------------+
//|                                                OrderOverview.mq4 |
//|                                                       Momo Fujii |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Momo Fujii"
#property link      "http://www.metaquotes.net"

//#property indicator_separate_window
#property indicator_chart_window
int windowNumber = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----	
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
	//----
	removeAllLabels(windowNumber);
	//----
	return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
	int buyOrders[];
	int sellOrders[];
	int buyStopOrders[];
	int sellStopOrders[];
	int buyLimitOrders[];
	int sellLimitOrders[];
	
	string labelArray[12]= {"","","","","","","","","","","",""};
	
	int orderCount = 0;
	int ticket;
	
	resetArray(buyOrders);
	resetArray(sellOrders);
	resetArray(buyStopOrders);
	resetArray(sellStopOrders);
	resetArray(buyLimitOrders);
	resetArray(sellLimitOrders);
	
	//if( WindowsTotal() > 0 )
	//	windowNumber = 1;
		
	removeAllLabels(windowNumber);
	
	for( int k = 0; k < OrdersTotal(); k++ )          // Loop through orders     
	{      
		if( OrderSelect(k, SELECT_BY_POS, MODE_TRADES) == true ) // If there is the next one        
		{
			ticket = OrderTicket();
			switch(OrderType())
			{
				case OP_BUY:
					addOrderDetails(buyOrders, ticket);
					break;
				case OP_SELL:
					addOrderDetails(sellOrders, ticket);
					break;
				case OP_BUYSTOP:
					addOrderDetails(buyStopOrders, ticket);
					break;
				case OP_SELLSTOP:
					addOrderDetails(sellStopOrders, ticket);
					break;
				case OP_BUYLIMIT:
					addOrderDetails(buyLimitOrders, ticket);
					break;
				case OP_SELLLIMIT:
					addOrderDetails(sellLimitOrders, ticket);
					break;
				default:
					break;
			}
		}
	}
	
	createDescription(windowNumber, orderCount);
	orderCount += 2;
	
	
	for(k = 0; k < ArraySize(buyOrders); k++)
	{
		createOrderLabel(buyOrders[k], windowNumber, orderCount);
		getLabel(buyOrders[k], labelArray);
		setLabel(buyOrders[k], labelArray);
		orderCount++;
	}
	
	for(k = 0; k < ArraySize(sellOrders); k++)
	{
		createOrderLabel(sellOrders[k], windowNumber, orderCount);
		getLabel(sellOrders[k], labelArray);
		setLabel(sellOrders[k], labelArray);
		orderCount++;
	}

	for(k = 0; k < ArraySize(buyStopOrders); k++)
	{
		createOrderLabel(buyStopOrders[k], windowNumber, orderCount);
		getLabel(buyStopOrders[k], labelArray);
		setLabel(buyStopOrders[k], labelArray);
		orderCount++;
	}
	
	for(k = 0; k < ArraySize(sellStopOrders); k++)
	{
		createOrderLabel(sellStopOrders[k], windowNumber, orderCount);
		getLabel(sellStopOrders[k], labelArray);
		setLabel(sellStopOrders[k], labelArray);
		orderCount++;
	}
	
	for(k = 0; k < ArraySize(buyLimitOrders); k++)
	{
		createOrderLabel(buyLimitOrders[k], windowNumber, orderCount);
		getLabel(buyLimitOrders[k], labelArray);
		setLabel(buyLimitOrders[k], labelArray);
		orderCount++;
	}
	
	for(k = 0; k < ArraySize(sellLimitOrders); k++)
	{
		createOrderLabel(sellLimitOrders[k], windowNumber, orderCount);
		getLabel(sellLimitOrders[k], labelArray);
		setLabel(sellLimitOrders[k], labelArray);
		orderCount++;
	}
	return(0);
 }
//+------------------------------------------------------------------+

string getLabel(int ticket, string& arrayLabel[12])
{
	int 		type;
	double 		openPrice;
	string 		symbol;
	double 		currentSL;
	double 		currentTP;
	double 		lots;
	double 		bid;
   	double 		ask;
	double 		tickValue;
	double 		lotSize;
	double 		point;
	double	 	spread;
	double      tickSize;
	int 		magic;
	double		secTill;
	
	int 		openSince; 
	datetime 	openTime;
	double 		currentWin = 0;
	double 		price;
	double		possibleLoss = 0;
	string 		timeframe;
	string   	typeString;
	string 		timeTillNextBar = "";
	
	if (OrderSelect(ticket, SELECT_BY_TICKET) == true)
	{
		RefreshRates();
		type     	= OrderType();
		openPrice 	= OrderOpenPrice();
		symbol 		= OrderSymbol();
		currentSL 	= OrderStopLoss();
		lots		= OrderLots();
		magic 		= OrderMagicNumber();
		bid   		= MarketInfo(symbol,MODE_BID);
   		ask   		= MarketInfo(symbol,MODE_ASK);
		tickValue 	= MarketInfo(symbol, MODE_TICKVALUE);
		lotSize  	= MarketInfo(symbol, MODE_LOTSIZE);
		point    	= MarketInfo(symbol, MODE_POINT);
		spread   	= MarketInfo(symbol, MODE_SPREAD);
		tickSize  	= MarketInfo(symbol, MODE_TICKSIZE);
		openTime 	= OrderOpenTime();


		switch(magic)
		{
			case PERIOD_M1:	timeframe	= "M1";
									break;
			case PERIOD_M5: 	timeframe	= "M5";
									break;
			case PERIOD_M15: 	timeframe	= "M15";
								  	break;
			case PERIOD_M30: 	timeframe	= "M30";
								  	break;
			case PERIOD_H1: 	timeframe	= "H1";
									break;
			case PERIOD_H4: 	timeframe	= "H4";
								 	break;
			case PERIOD_D1: 	timeframe	= "D1";
								 	break;
			case PERIOD_W1: 	timeframe	= "W1";
								 	break;
		 	case PERIOD_MN1: 	timeframe	= "MN1";
		 	break;
			default:		      timeframe 	= "Not applicable";
		}
		
		if( timeframe != "Not applicable")
		{
			openSince 		= iBarShift(symbol, magic, OrderOpenTime());
			secTill 		= iTime(NULL,magic,0)+magic*60-TimeCurrent();
			if( secTill > 3600)
			{
				if(secTill >= 36000)
					timeTillNextBar = StringConcatenate(timeTillNextBar, DoubleToStr(MathFloor(secTill / 3600),0), ":");
				else
					timeTillNextBar = StringConcatenate(timeTillNextBar, "0", DoubleToStr(MathFloor(secTill / 3600),0), ":");
				secTill = MathMod(secTill, 3600);
			}else 
			{
				timeTillNextBar = StringConcatenate(timeTillNextBar,  "00:");
			}
			
			if ( secTill > 60)
			{
				if ( secTill >= 600)
					timeTillNextBar = StringConcatenate(timeTillNextBar, DoubleToStr(MathFloor(secTill / 60),0), ":");
				else
					timeTillNextBar = StringConcatenate(timeTillNextBar, "0", DoubleToStr(MathFloor(secTill / 60),0), ":");
				secTill = MathMod(secTill, 60);
			}else
			{
				timeTillNextBar = StringConcatenate(timeTillNextBar, "00:");
			}
			
			if ( secTill >= 10)
				timeTillNextBar = StringConcatenate(timeTillNextBar, DoubleToStr(MathFloor(secTill),0));
			else
				timeTillNextBar = StringConcatenate(timeTillNextBar, "0", DoubleToStr(MathFloor(secTill),0));
		}
			
		if (currentSL > 0)
			possibleLoss 	= EquityAtRisk(lots, currentSL, type, symbol, openPrice);
			
		switch(type)
		{
			case OP_BUY:
				typeString		= "Buy";
				currentWin 		+= OrderProfit();
				//currentWin 		= NormalizeDouble( (openPrice - bid) * ( lots * lotSize * tickValue * point / tickSize ), 2);
				price			= bid;
				break;
			case OP_BUYLIMIT:
				typeString		= "BuyLimit";
				price			= bid;
				break;
			case OP_BUYSTOP:
				typeString		= "BuyStop";
				price			= bid;
				break;
			case OP_SELL:
				typeString		= "Sell";
				currentWin 		+= OrderProfit();
				//currentWin 		+= NormalizeDouble( (ask - openPrice) * ( lots * lotSize * tickValue * point / tickSize ), 2);	
				price			= ask;
				break;
			case OP_SELLLIMIT:
				typeString		= "SellLimit";
				price			= ask;
				break;
			case OP_SELLSTOP:
				typeString		= "SellStop";
				price			= ask;
				break;
			default:
				return("Invalid");
				break;
		}
		
		
		
		switch(type)
		{
			case OP_BUY:
			case OP_SELL:
				arrayLabel[0] = ticket;
				arrayLabel[1] = typeString;
				arrayLabel[2] = symbol;
				arrayLabel[3] = DoubleToStr(lots,2);
				arrayLabel[4] = DoubleToStr(price,5);
				arrayLabel[5] = DoubleToStr(openPrice,5);
				arrayLabel[6] = DoubleToStr(currentSL,5);
				arrayLabel[7] = TimeToStr(openTime);
				arrayLabel[8] = DoubleToStr(currentWin,2);
				arrayLabel[9] = DoubleToStr(possibleLoss,2);
				arrayLabel[10] = timeframe;
				arrayLabel[11]= timeTillNextBar;
				break;
			default:
				arrayLabel[0] = ticket;
				arrayLabel[1] = typeString;
				arrayLabel[2] = symbol;
				arrayLabel[3] = DoubleToStr(lots,2);
				arrayLabel[4] = DoubleToStr(price,5);
				arrayLabel[5] = DoubleToStr(openPrice,5);
				arrayLabel[6] = DoubleToStr(currentSL,5);
				arrayLabel[7] = "-----";
				arrayLabel[8] = "00.00";
				arrayLabel[9] = DoubleToStr(possibleLoss,2);
				arrayLabel[10] = timeframe;
				arrayLabel[11]= timeTillNextBar;
		}
	}
	return("");
}

void createOrderLabel(string name, int window, int offset)
{
	string labelName;
	int 	dist[12] 	= {10,70,60,60,40,50,70,70,100,90,90,100};
	int 	j			= 0;
	int 	sum 		= 0; 
	
	for( int i = 0; i <= 11; i++)
	{
		labelName = name +"_" +  i;
		sum = 0;
		for( j = 0; j <= i; j++)
		{
			sum += dist[j];
		}
		
		ObjectCreate(labelName, OBJ_LABEL, window, 0, 0);
		ObjectSet(labelName, OBJPROP_CORNER, 0);    // Reference corner
   		ObjectSet(labelName, OBJPROP_XDISTANCE, sum);// X coordinate
   		ObjectSet(labelName, OBJPROP_YDISTANCE, 15 * (offset + 1));// Y coordinate	
   		ObjectSet(labelName, OBJPROP_SCALE, 1000);
   	}
}

void createDescription(int window, int offset)
{
	string 	labelName;
	string 	desc[12] 	= {"Ticket", "Type", "Symbol", "Size", "Price", "OpenPrice", "Current SL", "Open Time", "Current Profit", "Possible Loss", "TrailingSL TF", "timeTillNextBar"};
	int 	dist[12] 	= {10,70,60,60,40,50,70,70,100,90,90,100};
	int 	j			= 0;
	int 	sum 		= 0; 
	for( int i = 0; i <= 11; i++)
	{
		labelName = "_" +  i;
		sum = 0;
		for( j = 0; j <= i; j++)
		{
			sum += dist[j];
		}
		
		ObjectCreate(labelName, OBJ_LABEL, window, 0, 0);
		ObjectSet(labelName, OBJPROP_CORNER, 0);    // Reference corner
   		ObjectSet(labelName, OBJPROP_XDISTANCE, sum);// X coordinate
   		ObjectSet(labelName, OBJPROP_YDISTANCE, 15 * (offset + 1));// Y coordinate	
   		ObjectSet(labelName, OBJPROP_SCALE, 1000);
   		ObjectSetText(labelName, desc[i], 10, "Arial", Black);
   	}
}

void setLabel(string name,string array[12])
{
	string labelName;
	for( int i = 0; i <= 11; i++)
	{
		labelName = name +"_" + i;
		ObjectSetText(labelName, array[i], 10, "Times New Roman", Black);
	}
}

void removeAllLabels(int window)
{
	ObjectsDeleteAll(window);
}

void addOrderDetails(int& array[], int key)
{
	int currentSize = ArraySize(array);
	ArrayResize(array, currentSize + 1);
	array[currentSize] = key;
}

void resetArray(int& array[])
{
	ArrayResize(array, 0);
}

double EquityAtRisk(double LotSize, double StopLossPrice, int CurrentOrderType, string CurrentSymbol, double openPrice)
{  // EquityAtRisk body start
   	double   CalculatedEquityAtRisk=0.;
	int CurrentSymbolType = SymbolType(CurrentSymbol);
	string CurrentCounterPairForCross = CounterPairForCross(CurrentSymbol);
   	double bid = MarketInfo(CurrentSymbol,MODE_BID);
   	double ask = MarketInfo(CurrentSymbol,MODE_ASK);
   
   	switch(CurrentSymbolType) // Determine the equity at risk based on the SymbolType for the financial instrument
    {
      case 1   :  switch(CurrentOrderType)
                     {
                     case OP_BUY		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (bid - StopLossPrice)/StopLossPrice , 2));
                     case OP_BUYSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (openPrice - StopLossPrice)/StopLossPrice , 2));
                     case OP_SELL		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (StopLossPrice - ask)/StopLossPrice , 2));
                     case OP_SELLSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (StopLossPrice - openPrice)/StopLossPrice , 2));
                     //case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(StopLossPrice-Ask)/StopLossPrice; break;
                     //case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(Bid-StopLossPrice)/StopLossPrice; break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 2   :  switch(CurrentOrderType)
                     {
                     case OP_BUY		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (bid - StopLossPrice) , 2));
                     case OP_BUYSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (openPrice - StopLossPrice) , 2));
                     case OP_SELL		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (StopLossPrice - ask) , 2));
                     case OP_SELLSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (StopLossPrice - openPrice) , 2));
                     //case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(StopLossPrice-Ask); break;
                     //case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(Bid-StopLossPrice); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 3   :  // e.g. Symbol() = CHFJPY, the counter currency is JPY and the USD is the base to the JPY in the pair USDJPY
                  // falls thru and is treated the same as SymbolType()==4 for the purpose of these calculations
      case 4   :  switch(CurrentOrderType)  // e.g. Symbol() = AUDCAD, the counter currency is CAD and the USD is the base to the CAD in the pair USDCAD
                     {
                     case OP_BUY		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (bid - StopLossPrice) / MarketInfo(CurrentCounterPairForCross, MODE_BID) , 2));
                     case OP_BUYSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (openPrice - StopLossPrice) / MarketInfo(CurrentCounterPairForCross, MODE_BID) , 2));
                     case OP_SELL		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (StopLossPrice - ask) / MarketInfo(CurrentCounterPairForCross, MODE_ASK) , 2));
                     case OP_SELLSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * LotSize * (StopLossPrice - openPrice) / MarketInfo(CurrentCounterPairForCross, MODE_ASK), 2));
                     //case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(StopLossPrice-Ask)/MarketInfo(CurrentCounterPairForCross,MODE_BID); break;
                     //case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*LotSize*(Bid-StopLossPrice)/MarketInfo(CurrentCounterPairForCross,MODE_ASK); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      case 5   :  switch(CurrentOrderType)  // e.g. Symbol() = EURGBP, the counter currency is GBP and the USD is the counter to the GBP in the pair GBPUSD
                     {
                     case OP_BUY		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * MarketInfo(CurrentCounterPairForCross, MODE_BID) * LotSize * (bid - StopLossPrice) , 2));
                     case OP_BUYSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * MarketInfo(CurrentCounterPairForCross, MODE_BID) * LotSize * (openPrice - StopLossPrice) , 2));
                     case OP_SELL		: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * MarketInfo(CurrentCounterPairForCross, MODE_ASK) * LotSize * (StopLossPrice - ask) , 2));
                     case OP_SELLSTOP	: return(NormalizeDouble( - MarketInfo(CurrentSymbol, MODE_LOTSIZE) * MarketInfo(CurrentCounterPairForCross, MODE_ASK) * LotSize * (StopLossPrice - openPrice) , 2));
                     //case OP_BUY    :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*MarketInfo(CurrentCounterPairForCross,MODE_BID)*LotSize*(StopLossPrice-Ask); break;
                     //case OP_SELL   :  CalculatedEquityAtRisk=-MarketInfo(CurrentSymbol,MODE_LOTSIZE)*MarketInfo(CurrentCounterPairForCross,MODE_ASK)*LotSize*(Bid-StopLossPrice); break;
                     default        :  Print("Error encountered in the OrderType() routine for calculating the EquityAtRisk"); // The expression did not generate a case value
                     }
                  break;
      default        :  Print("Error encountered in the SWITCH routine for calculating the EquityAtRisk"); // The expression did not generate a case value
      }
   
  return(CalculatedEquityAtRisk);
}


int SymbolType(string CurrentSymbol)
{  // SymbolType body start
   	int   	CalculatedSymbolType	= 6;
   	string 	SymbolBase				= "";
   	string 	SymbolCounter			= "";
   	string 	postfix					= "";
   
   	SymbolBase		= StringSubstr(CurrentSymbol,0,3);
   	SymbolCounter	= StringSubstr(CurrentSymbol,3,3);
  	postfix			= StringSubstr(CurrentSymbol,6);
   
   	if(SymbolBase==AccountCurrency()) 
   		CalculatedSymbolType=1;
   		
   	if(SymbolCounter==AccountCurrency()) 
   		CalculatedSymbolType=2;
   
   	

   	if(CalculatedSymbolType!=1 && CalculatedSymbolType!=2)
    {
  		// Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
  		if(MarketInfo(StringConcatenate(AccountCurrency(),SymbolCounter,postfix),MODE_LOTSIZE)>0)
     		CalculatedSymbolType = 4; // SymbolType can also be 3 but this will be determined later when the Base pair is identified
      	else if(MarketInfo(StringConcatenate(SymbolCounter,AccountCurrency(),postfix),MODE_LOTSIZE)>0)
        	CalculatedSymbolType = 5;
      
      	// Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
      	if(MarketInfo(StringConcatenate(AccountCurrency(),SymbolBase,postfix),MODE_LOTSIZE)>0)
        	CalculatedSymbolType=3;
	}
      
   	if(CalculatedSymbolType==6) Print("Error occurred while identifying SymbolType(), calculated SymbolType() = ",CalculatedSymbolType);
   
   	return(CalculatedSymbolType);
}  // SymbolType body end
   



string CounterPairForCross(string CurrentSymbol)
{  // CounterPairForCross body start
   	string SymbolBase="";
   	string SymbolCounter="";
   	string postfix="";
   	string CalculatedCounterPairForCross="";
   
   	SymbolBase		= StringSubstr(CurrentSymbol,0,3);
   	SymbolCounter	= StringSubstr(CurrentSymbol,3,3);
   	postfix			= StringSubstr(CurrentSymbol,6);
   
   	switch(SymbolType(CurrentSymbol)) // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
    {
    	case 1   : 	break;
      	case 2   : 	break;
      	case 3   : 	CalculatedCounterPairForCross	=	StringConcatenate(AccountCurrency(),SymbolCounter,postfix);
        	       	break;
      	case 4   : 	CalculatedCounterPairForCross=StringConcatenate(AccountCurrency(),SymbolCounter,postfix);
					break;
      	case 5   :  CalculatedCounterPairForCross=StringConcatenate(SymbolCounter,AccountCurrency(),postfix);
                  	break;
      	case 6   :  Print("Error occurred while identifying SymbolType(), calculated SymbolType() = 6"); break;
      	default  :  Print("Error encountered in the SWITCH routine for identifying CounterPairForCross on financial instrument ",CurrentSymbol); // The expression did not generate a case value
    }
   
	return(CalculatedCounterPairForCross);
   
} 