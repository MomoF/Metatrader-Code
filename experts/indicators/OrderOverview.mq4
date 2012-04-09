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
	
	string labelArray[11]= {"","","","","","","","","","",""};
	
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
	orderCount++;
	
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

string getLabel(int ticket, string& arrayLabel[11])
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
			
		switch(type)
		{
			case OP_BUY:
				typeString		= "Buy";
				currentWin 		= NormalizeDouble( (openPrice - bid) * ( lots * lotSize * tickValue ), 2);
				if (currentSL > 0)
					possibleLoss 	= NormalizeDouble( (openPrice - currentSL) * ( lots * lotSize * tickValue ), 2);
				price			= bid;
				break;
			case OP_BUYLIMIT:
				typeString		= "BuyLimit";
				price			= bid;
				break;
			case OP_BUYSTOP:
				typeString		= "BuyStop";
				if (currentSL > 0)
					possibleLoss += NormalizeDouble( (openPrice - currentSL) * ( lots * lotSize * tickValue ), 2) ;
				price			= bid;
				break;
			case OP_SELL:
				typeString		= "Sell";
				currentWin 		+= NormalizeDouble( (ask - openPrice) * ( lots * lotSize * tickValue ), 2);
				if (currentSL > 0)
					possibleLoss 	+= NormalizeDouble( (currentSL - openPrice) * ( lots * lotSize * tickValue ), 2);
				price			= ask;
				break;
			case OP_SELLLIMIT:
				typeString		= "SellLimit";
				price			= ask;
				break;
			case OP_SELLSTOP:
				typeString		= "SellStop";
				if (currentSL > 0)
					possibleLoss 	+= NormalizeDouble( (currentSL - openPrice) * ( lots * lotSize * tickValue ), 2);
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
				arrayLabel[3] = DoubleToStr(price,5);
				arrayLabel[4] = DoubleToStr(openPrice,5);
				arrayLabel[5] = DoubleToStr(currentSL,5);
				arrayLabel[6] = openTime;
				arrayLabel[7] = DoubleToStr(currentWin,2);
				arrayLabel[8] = DoubleToStr(possibleLoss,2);
				arrayLabel[9] = timeframe;
				arrayLabel[10]= timeTillNextBar;
				break;
			default:
				arrayLabel[0] = ticket;
				arrayLabel[1] = typeString;
				arrayLabel[2] = symbol;
				arrayLabel[3] = DoubleToStr(price,5);
				arrayLabel[4] = DoubleToStr(openPrice,5);
				arrayLabel[5] = DoubleToStr(currentSL,5);
				arrayLabel[6] = openTime;
				arrayLabel[7] = "00.00";
				arrayLabel[8] = DoubleToStr(possibleLoss,2);
				arrayLabel[9] = timeframe;
				arrayLabel[10]= timeTillNextBar;
		}
	}
	return("");
}

void createOrderLabel(string name, int window, int offset)
{
	string labelName;
	for( int i = 0; i <= 10; i++)
	{
		labelName = name +"_" +  i;
		ObjectCreate(labelName, OBJ_LABEL, window, 0, 0);
		ObjectSet(labelName, OBJPROP_CORNER, 0);    // Reference corner
   		ObjectSet(labelName, OBJPROP_XDISTANCE, 10 + (i*100));// X coordinate
   		ObjectSet(labelName, OBJPROP_YDISTANCE, 15 * (offset + 1));// Y coordinate	
   		ObjectSet(labelName, OBJPROP_SCALE, 1000);
   	}
}

void createDescription(int window, int offset)
{
	string labelName;
	string desc[11] = {"Ticket", "Type", "Symbol", "Price", "OpenPrice", "Current SL", "Open Time", "Current Profit", "Possible Loss", "TrailingSL TF", "timeTillNextBar"};
	for( int i = 0; i <= 10; i++)
	{
		labelName = "_" +  i;
		ObjectCreate(labelName, OBJ_LABEL, window, 0, 0);
		ObjectSet(labelName, OBJPROP_CORNER, 0);    // Reference corner
   		ObjectSet(labelName, OBJPROP_XDISTANCE, 10 + (i*100));// X coordinate
   		ObjectSet(labelName, OBJPROP_YDISTANCE, 15 * (offset + 1));// Y coordinate	
   		ObjectSet(labelName, OBJPROP_SCALE, 1000);
   		ObjectSetText(labelName, desc[i], 12, "Arial", Black);
   	}
}

void setLabel(string name,string array[11])
{
	string labelName;
	for( int i = 0; i <= 10; i++)
	{
		labelName = name +"_" + i;
		ObjectSetText(labelName, array[i], 12, "Arial", Black);
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