//+------------------------------------------------------------------+
//|                                               DoubleMAMinMax.mq4 |
//|                                                       Momo Fujii |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Momo Fujii"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Green
//--- input parameters
extern int       minmaxPeriod = 12;
extern int       SmallPeriod = 12;
extern int       BigPeriod   = 26;
//--- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
	if(Bars<=BigPeriod) 
		return(0);
		
   	int countedBars		= IndicatorCounted();
  	int i 				= Bars - countedBars;
  	int history 		= 5000;
  	string symbol		= Symbol();
  	int timeframe 		= Period();
	
	  	
  	if(i > history)
		i = history;  
  
   	while (i >= 0)
  	{
  		ExtMapBuffer1[i] = iMA(NULL,0,SmallPeriod,0,MODE_EMA,PRICE_CLOSE,i);
  		ExtMapBuffer2[i] = iMA(NULL,0,BigPeriod,0,MODE_EMA,PRICE_CLOSE,i);
  		
  		for( int j = 0; j < SmallPeriod; j++)
  		{
  			if (j == 0)
  			{
  				ExtMapBuffer3[i] = iLow(symbol,timeframe,i);
  			}else if (ExtMapBuffer3[i] > iLow(symbol,timeframe,i+j))
  			{
  				ExtMapBuffer3[i] = iLow(symbol,timeframe,i+j);
  			}
  		}
  		
  		for( j = 0; j < minmaxPeriod; j++)
  		{
  			if (j == 0)
  			{
  				ExtMapBuffer4[i] = iHigh(symbol,timeframe,i);
  			}else if (ExtMapBuffer4[i] < iHigh(symbol,timeframe,i+j))
  			{
  				ExtMapBuffer4[i] = iHigh(symbol,timeframe,i+j);
  			}
  		}
  		
  		i--;
  	}
//----
   return(0);
  }
//+------------------------------------------------------------------+