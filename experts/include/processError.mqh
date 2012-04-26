//+------------------------------------------------------------------+
//|                                                 processError.mq4 |
//|                                                       Momo Fujii |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Momo Fujii"
#property link      "http://www.metaquotes.net"

int processError( int error )                        // Function of processing errors  
{   
   switch(error)     
   {                                          
   // Not crucial errors                  
      case  4: Alert("Trade server is busy. Trying once again..");         
               Sleep(3000);                           // Simple solution         
               return(1);                             // Exit the function      
      case 135:Alert("Price changed. Trying once again..");         
               RefreshRates();                        // Refresh rates         
               return(1);                             // Exit the function      
      case 136:Alert("No prices. Waiting for a new tick..");         
               Sleep(5000);                           // Pause in the loop         
               RefreshRates();           // Till a new tick            
               return(1);                             // Exit the function      
      case 137:Alert("Broker is busy. Trying once again..");         
               Sleep(3000);                           // Simple solution         
               return(1);                             // Exit the function
      case 138:Alert("Price rejected. Trying again");         
               //while(RefreshRates()==false)           // Till a new tick            
               //Sleep(1);                           // Pause in the loop         
               return(1);                             // Exit the function                
      case 146:Alert("Trading subsystem is busy. Trying once again..");         
               Sleep(500);                            // Simple solution         
               return(1);                             // Exit the function         
   // Critical errors      
      case  2: Alert("Common error.");         
               return(0);                             // Exit the function      
      case  5: Alert("Old terminal version.");         
                                           // Terminate operation         
               return(0);                             // Exit the function      
      case 64: Alert("Account blocked.");         
                            // Terminate operation         
               return(0);                             // Exit the function      
      case 133:Alert("Trading forbidden.");         
               return(0);                             // Exit the function      
      case 134:Alert("Not enough money to execute operation.");         
               return(0);                             // Exit the function      
      default: Alert("Error occurred: ",error); // Other variants            
               return(0);                             // Exit the function     
   }  
}

