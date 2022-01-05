//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


#property description  "Tool used to calculate the correct lot size to trade, given a fixed risk and a number of pips."
#property description  "Simply enter the number of pips of your desired stop loss order, and the indicator will show you "
#property description  "the number of lots to trade based on your total account amount, your account currency and present chart currency pair."

#property strict
#property indicator_chart_window
#property indicator_plots 0

#define MODE_TICKVALUE
#define MODE_TICKSIZE
#define MODE_DIGITS

double a[]; //price
datetime b[];
double price1 = 0;
double price2 = 0;
int NewSize = 0;
bool crosshair_active = false;
double Pips = 10.00;
//double Pips2 = 10.00;

//input int Pips = 10; // Stop loss distance from open order
input double Risk = 0.25; // Risk 1
input double RiskTwo = 0.5; // Risk 2
input double RiskThree = 1.0; // Risk 3
input bool useAccountBalance = true; // Check to read the actual free margin of your balance, uncheck to specify it
input int AccountBalance = ACCOUNT_EQUITY; // Specify here a simulated balance value
double point;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   ArraySetAsSeries(a, true);
//--- enable CHART_EVENT_MOUSE_MOVE messages
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);

// Broker digits
   point = _Point;
//Print(point);

   double Digits = _Digits;
//if((_Digits == 3) || (_Digits == 5))
//  {
//   point*=10;
//  }
   return(INIT_SUCCEEDED);

//--- forced updating of chart properties ensures readiness for event processing
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| MouseState                                                       |
//+------------------------------------------------------------------+
string MouseState1(uint state)
  {
   return(state);
  }

//+------------------------------------------------------------------+
//| Custom indicator de-init function                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");  // Cleanup
   Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason));
   return;
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
               )
  {
   string CommentString = "";

   string DepositCurrency = AccountInfoString(ACCOUNT_CURRENCY);

   double freeMargin = 0;
   if(useAccountBalance)
     {
      freeMargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
     }
   else
     {
      freeMargin = AccountBalance;
     }

//double PipValue = ((((SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE))*point)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE))) * LotSize);

   Pips = NormalizeDouble(Pips,2);
   double PipValue = (((SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE))*point)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE)));
//Print(PipValue);
   double lots = ((Risk/100) * freeMargin) / Pips;
   double lotsTwo = ((RiskTwo/100) * freeMargin) / Pips;
   double lotsThree = ((RiskThree/100) * freeMargin) / Pips;

// Truncate lot quantity to 2 decimal digits without rounding it
   lots = floor(lots * 100) / 100;

   CommentString+="\n" + "Your free margin: "+ DepositCurrency + " " + DoubleToString(freeMargin, 2) + "\n";
   CommentString+="Risk Point : "+ (string)Pips + " points\n";
   //CommentString+="Risk selected: " + DepositCurrency + " " + DoubleToString(Risk * freeMargin, 2) + "\n";
//CommentString+="Value of one pip trading 1 lot of " + Symbol() + ": " + DepositCurrency + " " + DoubleToString(PipValue, 3) + "\n";
   CommentString+="--------------------------------------------------------------------------\n";
   CommentString+="Risk 1: " + DoubleToString(Risk, 2) + "%" + " or "+ DepositCurrency + " " + DoubleToString((Risk/100) * freeMargin, 2) + " || Max lots : " + DoubleToString(lots, 2) + " lot\n";
   CommentString+="Risk 2: " + DoubleToString(RiskTwo, 2) + "%" + " or "+ DepositCurrency + " " + DoubleToString((RiskTwo/100) * freeMargin, 2) + " || Max lots : " + DoubleToString(lotsTwo, 2) + " lot\n";
   CommentString+="Risk 3: " + DoubleToString(RiskThree, 2) + "%" + " or "+ DepositCurrency + " " + DoubleToString((RiskThree/100) * freeMargin, 2) + " || Max lots : " + DoubleToString(lotsThree, 2) + " lot\n";
   CommentString+="--------------------------------------------------------------------------\n";
   CommentString+= "Created By : n.pranyoto@gmail.com";

   Comment(CommentString);

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode) // Return reason for De-init function
  {
   string text="";

   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";
         break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";
         break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";
         break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";
         break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";
         break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";
         break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";
         break;
      default:
         text="Another reason";
     }

   return text;
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(MouseState1((uint)sparam) == 16)
     {
      crosshair_active=true;
     }
   if(crosshair_active==true)
     {
      //Print(MouseState1((uint)sparam));
      if(MouseState1((uint)sparam) != 0 && MouseState1((uint)sparam) != 16)
        {
         //Print(MouseState1((uint)sparam));
         int      x     =(int)lparam;
         int      y     =(int)dparam;
         datetime dt    =0;
         double   price =0;
         int      window=0;
         ChartXYToTimePrice(0,x,y,window,dt,price);
         //Print("timenya= " + dt);
         double P0 = 0;
         datetime dP0 = 0;
         if(P0 != price && dP0 != dt)
           {
            P0 = price;
            dP0 = dt;
            NewSize +=  1;
            ArrayResize(a, NewSize);
            ArrayFill(a,0,1,P0);
            ArrayResize(b, NewSize);
            ArrayFill(b,0,1,dP0);
           }
         ChartRedraw();
        }
      if(id == 4 || id == 0)
        {
         crosshair_active=false;
         //ArrayPrint(b);
         int TotalArray = ArraySize(a);
         //printf(a[0]);
         //Print(a[TotalArray-=1]);
         price1 = StringToDouble(a[0]);
         price2 = StringToDouble(a[TotalArray-=1]);
         double digitkali = _Digits;
         double digitkalix = 100000;
         if(digitkali == 2)
           {
            digitkalix = 100;
           }
         else
            if(digitkali == 3)
              {
               digitkalix = 1000;
              }
         //else if(digitkali == 5)
         //{
         //digitkalix = 1000;
         //}
         Pips = (price1 - price2) * digitkalix;
         //Pips2 = (price1 - price2);
         if(Pips == 0)
           {
            Pips = 10000;
           }
         if(Pips < 0)
           {
            Pips *= -1;
           }
         //Print(_Digits);
         Print(Pips);
         //Print(Pips2);
         //datetime dt1 = b[0];
         //datetime dt2 = b[TotalArray-=1];
         //ObjectCreate(0, "Rectangle", OBJ_RECTANGLE, 0, dt1, price1, dt2, price2);
         NewSize = 0;
         ArrayResize(a,0);
         ArrayResize(b,0);
         ChartRedraw();
        }
     }
  }
//+------------------------------------------------------------------+
