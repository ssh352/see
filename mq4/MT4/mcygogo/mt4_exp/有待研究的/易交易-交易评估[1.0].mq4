#property copyright "laoyee"
#property link      "qq:921795"
//指标在主图显示
#property indicator_chart_window
extern bool DisplayText=true;
extern color TextColor=Yellow;
int cnt;
string TextBarString,DotBarString,HLineBarString,VLineBarString; 
double myLots; //当前持仓总量
color myLineColor; //线色变量

int start()
{
    iDisplayText(); //信息模块
    iDrawLine(); //画线模块
    return(0);
}

void iDisplayText()
{
    if (DisplayText==false) return(0);
    //定义统计变量
    int BuyHistoryOrders,SellHistoryOrders,HistoryOrderTotal; //买入历史订单、卖出历史订单、历史订单总数
    int WinHistory,LossHistory; //历史盈利、亏损单累计
    double TotalHistoryLots;//历史交易总手数
    double TotalHistoryProfit,TotalHistoryLoss;//盈利总数、亏损总数变量
    double myWinRate; //胜率变量
    double myWinAvg,myLossAvg; //平均盈利、亏损
    double myOdds; //赔率变量
    double myKelly; //凯利指标变量
    double myMaxLots; //持仓限制变量
    //计算相关变量
    for (cnt=0;cnt<=OrdersHistoryTotal()-1;cnt++)
    {
        if (OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)
            && OrderSymbol()==Symbol() //选择当前货币对
            && (OrderType()==OP_BUY || OrderType()==OP_SELL)
           )
        {
            if (OrderType()==OP_BUY) BuyHistoryOrders=BuyHistoryOrders+1; //买入单累计
            if (OrderType()==OP_SELL) SellHistoryOrders=SellHistoryOrders+1; //买入单累计
            if (OrderProfit()>=0)
            {
                WinHistory=WinHistory+1; //盈利单（含保本单）数量累计
                TotalHistoryProfit=TotalHistoryProfit+OrderProfit(); //总盈利金额累计
            }
            if (OrderProfit()<0)
            {
                LossHistory=LossHistory+1; //亏损单数量累计
                TotalHistoryLoss=TotalHistoryLoss+OrderProfit(); //总亏损数量累计
            }
            TotalHistoryLots=TotalHistoryLots+OrderLots(); //交易总量（手）
        }
    }
    HistoryOrderTotal=BuyHistoryOrders+SellHistoryOrders; //历史单数量总计
    //计算胜率
    if (WinHistory+LossHistory>0)
    {
        myWinRate=(WinHistory*1.00)/((WinHistory+LossHistory)*1.00)*100; //胜率变量，int类型转double类型
    }
    if (WinHistory>0) myWinAvg=TotalHistoryProfit/WinHistory; //计算平均盈利
    if (LossHistory>0) myLossAvg=TotalHistoryLoss/LossHistory; //计算平均亏损
    //计算赔率
    if (myLossAvg!=0) myOdds=MathAbs(myWinAvg/myLossAvg); //计算赔率=平均盈利/平均亏损
    //计算凯利指标
    if (myOdds!=0) myKelly=MathAbs(((myOdds+1)*(myWinRate/100)-1)/myOdds);
    //计算最大持仓限制
    if (MarketInfo(Symbol(), MODE_MARGINREQUIRED)!=0)
    {
        myMaxLots=AccountBalance()*myKelly/MarketInfo(Symbol(), MODE_MARGINREQUIRED);
    }

    
    
    //显示统计信息
    iDisplayInfo("jypg-Author", "[联系老易 QQ:921795]",0,210,1,7,"",Gray);
    iDisplayInfo("jypg-Times","动态报价时间:"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+" 星期"+DayOfWeek(),0,4,15,9,"Verdana",TextColor);
    iDisplayInfo("jypg-HistoryOrderTotal", "历史交易单总计:"+HistoryOrderTotal+"  其中买入单:"+BuyHistoryOrders+"  卖出单:"+SellHistoryOrders,0,4,35,9,"",TextColor);
    iDisplayInfo("jypg-HistoryWinLoss", "历史盈利单总计:"+WinHistory+"  历史亏损单:"+LossHistory+"  胜率:"+DoubleToStr(myWinRate,2)+"%",0,4,50,9,"",TextColor);
    iDisplayInfo("jypg-HistoryLots", "历史总下单量:"+DoubleToStr(TotalHistoryLots,2)+"手"+"  总盈利:"+DoubleToStr(TotalHistoryProfit,2)+"  总亏损:"+DoubleToStr(TotalHistoryLoss,2),0,4,65,9,"",TextColor);
    iDisplayInfo("AverageRate", "账户利润:"+DoubleToStr(TotalHistoryProfit+TotalHistoryLoss,2)+"  平均盈利:"+DoubleToStr(myWinAvg,2)+"  平均亏损:"+DoubleToStr(myLossAvg,2),0,4,80,9,"",TextColor);
    iDisplayInfo("Kelly", "赔率:"+DoubleToStr(myOdds,2)+"  凯利指标:"+DoubleToStr(myKelly*100,2)+"%"+"  最大持仓限制:"+DoubleToStr(myMaxLots,2)+"手",0,4,95,9,"",TextColor);

}

void iDrawLine()
{
   //画历史单
   //遍历历史订单，计算相关信息
   for (cnt=0;cnt<=OrdersHistoryTotal()-1;cnt++)
   {
      if (OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
      {
         if (OrderType()==OP_BUY)
         {
            if (OrderProfit()>0)  myLineColor=Blue;
            if (OrderProfit()<0)  myLineColor=Red;
            if (OrderSymbol()==Symbol()) //只画当前货币对图形
            {
               iTwoPointsLine(TimeToStr(OrderOpenTime()),OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice(),2,myLineColor);
               iDrawSign("Text",iBarShift(OrderSymbol(),0,OrderOpenTime()),OrderOpenPrice(),myLineColor,0,DoubleToStr(OrderTicket(),0)+" buy",8);
            }
         }
         if (OrderType()==OP_SELL)
         {
            if (OrderProfit()>0)  myLineColor=Blue;
            if (OrderProfit()<0)  myLineColor=Red;
            if (OrderSymbol()==Symbol()) //只画当前货币对图形
            {
               iTwoPointsLine(TimeToStr(OrderOpenTime()),OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice(),3,myLineColor);
               iDrawSign("Text",iBarShift(OrderSymbol(),0,OrderOpenTime()),OrderOpenPrice(),myLineColor,0,DoubleToStr(OrderTicket(),0)+" sell",8);
            }
         }
      }
   }
   //画持仓单
   for (cnt=0;cnt<OrdersTotal();cnt++)
   {
      if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
      {
         myLots=myLots+OrderLots();
         //画持仓单线段，动态
         if (OrderProfit()>0)  myLineColor=Blue;
         if (OrderProfit()<0)  myLineColor=Red;
         if (OrderSymbol()==Symbol() && OrderType()==OP_BUY)
         {
            ObjectDelete(TimeToStr(OrderOpenTime()));
            ObjectDelete("Text"+OrderOpenTime());
            iTwoPointsLine(TimeToStr(OrderOpenTime()),OrderOpenTime(),OrderOpenPrice(),Time[0],Bid,2,myLineColor);
            iDrawSign("Text",iBarShift(OrderSymbol(),0,OrderOpenTime()),OrderOpenPrice(),myLineColor,0,DoubleToStr(OrderTicket(),0)+" buy",8);
         }
         if (OrderSymbol()==Symbol() && OrderType()==OP_SELL)
         {
            ObjectDelete(TimeToStr(OrderOpenTime()));
            ObjectDelete("Text"+OrderOpenTime());
            iTwoPointsLine(TimeToStr(OrderOpenTime()),OrderOpenTime(),OrderOpenPrice(),Time[0],Ask,3,myLineColor);
            iDrawSign("Text",iBarShift(OrderSymbol(),0,OrderOpenTime()),OrderOpenPrice(),myLineColor,0,DoubleToStr(OrderTicket(),0)+" sell",8);
         }
      }
   }
}

int init()
{
   return(0);
}

int deinit()
{
   Comment("");
   ObjectsDeleteAll(0);
   return(0);
}

/*
函    数：在屏幕上显示文字标签
输入参数：string LableName 标签名称，如果显示多个文本，名称不能相同
          string LableDoc 文本内容
          int Corner 文本显示角
          int LableX 标签X位置坐标
          int LableY 标签Y位置坐标
          int DocSize 文本字号
          string DocStyle 文本字体
          color DocColor 文本颜色
输出参数：在指定的位置（X,Y）按照指定的字号、字体及颜色显示指定的文本
算法说明：
*/
void iDisplayInfo(string LableName,string LableDoc,int Corner,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
   {
      if (Corner == -1) return(0);
      ObjectCreate(LableName, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor);
      ObjectSet(LableName, OBJPROP_CORNER, Corner);
      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX);
      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY);
   }
/*
函    数：两点间连线(主图)
输入参数：string myLineName  线段名称
          int myFirstTime  起点时间
          int myFirstPrice  起点价格
          int mySecondTime  终点时间
          int mySecondPrice  终点价格
          int myLineStyle  线型 0-实线 1-断线 2-点线 3-点划线 4-双点划线
          color myLineColor 线色
输出参数：在指定的两点间连线
算法说明：
*/
void iTwoPointsLine(string myLineName,int myFirstTime,double myFirstPrice,int mySecondTime,double mySecondPrice,int myLineStyle,color myLineColor)
   {
      ObjectCreate(myLineName,OBJ_TREND,0,myFirstTime,myFirstPrice,mySecondTime,mySecondPrice);//确定两点坐标
      ObjectSet(myLineName,OBJPROP_STYLE,myLineStyle); //线型
      ObjectSet(myLineName,OBJPROP_COLOR,myLineColor); //线色
      ObjectSet(myLineName,OBJPROP_WIDTH, 1); //线宽
      ObjectSet(myLineName,OBJPROP_BACK,false);
      ObjectSet(myLineName,OBJPROP_RAY,false);
   }
   
/*
函    数：标注符号和画线、文字
参数说明：string myType 标注类型：Dot画点、HLine画水平线、VLine画垂直线、myString显示文字
          int myBarPos 指定蜡烛坐标
          double myPrice 指定价格坐标
          color myColor 符号颜色
          int mySymbol 符号代码，108为圆点
          string myString 文字内容，在指定的蜡烛位置显示文字
函数返回：在指定的蜡烛和价格位置标注符号或者画水平线、垂直线
*/
void iDrawSign(string myType,int myBarPos,double myPrice,color myColor,int mySymbol,string myString,int myDocSize)
      {
         if (myType=="Text")
            {
               TextBarString=myType+Time[myBarPos];
               ObjectCreate(TextBarString,OBJ_TEXT,0,Time[myBarPos],myPrice);
               ObjectSet(TextBarString,OBJPROP_COLOR,myColor);//颜色
               ObjectSet(TextBarString,OBJPROP_FONTSIZE,myDocSize);//大小
               ObjectSetText(TextBarString,myString);//文字内容
               ObjectSet(TextBarString,OBJPROP_BACK,true);
            }
         if (myType=="Dot")
            {
               DotBarString=myType+Time[myBarPos];
               ObjectCreate(DotBarString,OBJ_ARROW,0,Time[myBarPos],myPrice);
               ObjectSet(DotBarString,OBJPROP_COLOR,myColor);
               ObjectSet(DotBarString,OBJPROP_ARROWCODE,mySymbol);
               ObjectSet(DotBarString,OBJPROP_BACK,false);
            }
         if (myType=="HLine")
            {
               HLineBarString=myType+Time[myBarPos];
               ObjectCreate(HLineBarString,OBJ_HLINE,0,Time[myBarPos],myPrice);
               ObjectSet(HLineBarString,OBJPROP_COLOR,myColor);
               ObjectSet(HLineBarString,OBJPROP_BACK,false);
            }
         if (myType=="VLine")
            {
               VLineBarString=myType+Time[myBarPos];
               ObjectCreate(VLineBarString,OBJ_VLINE,0,Time[myBarPos],myPrice);
               ObjectSet(VLineBarString,OBJPROP_COLOR,myColor);
               ObjectSet(VLineBarString,OBJPROP_BACK,false);
            }
     }

