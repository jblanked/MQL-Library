//+------------------------------------------------------------------+
//|                                                   Chart-Draw.mqh |
//|                                          Copyright 2023,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,JBlanked"
#property link      "https://www.jblanked.com/"
enum enum_up_down{Up,Down};
class CChartDraw
{
private:
   string object_name;
   
   
public:
   bool ObjectFound(string name){return ObjectFind(0, name) < 0 ? false : true;}
   void Chart_Zone(string name, datetime time_1, double price_1, datetime time_2, double price_2, color color_type, int border_width,int sub_window = 0);
   void Chart_Angled_Text(string name, double price, datetime time, string text, int fontsize, color color_type, int sub_window = 0, int angle = 90);
   void Chart_Arrow(string object_name, enum_up_down up_down, double price, datetime time, color color_type, int width = 3, int sub_window = 0);
   void ChartLabel(string name, string text, string font, int font_size, color color_type, int x_distance, int y_distance, int corner, int sub_window = 0);
   void Chart_H_Line(string name, double price, int width, color color_type, int sub_window = 0);
   void Chart_V_Line(string name, double price, datetime time, int width, color color_type, int sub_window = 0);
   void Chart_Trend_Line(string name, datetime time_1, double price_1, datetime time_2, double price_2, int width, color color_type, int sub_window = 0);
   void ChartText(string object_name, string text, string font, int font_size, color color_type, datetime time, double price, ENUM_ANCHOR_POINT anchor,int sub_window = 0);
   void ChartBox(string name, int x_distance, int y_distance, int x_size,int y_size, color color_type, int corner, int border_width, int sub_window = 0);
   void Chart_Text_2(string name, double price, datetime time, string text, color color_type, int sub_window = 0);
   
   double ChartPriceMin(const long chart_ID=0,const int sub_window=0)
     {
   //--- prepare the variable to get the result
      double result=EMPTY_VALUE;
   //--- reset the error value
      ResetLastError();
   //--- receive the property value
      if(!ChartGetDouble(chart_ID,CHART_PRICE_MIN,sub_window,result))
        {
         //--- display the error message in Experts journal
         Print(__FUNCTION__+", Error Code = ",GetLastError());
        }
   //--- return the value of the chart property
      return(result);
     }
    double ChartPriceMax(const long chart_ID=0,const int sub_window=0)
     {
   //--- prepare the variable to get the result
      double result=EMPTY_VALUE;
   //--- reset the error value
      ResetLastError();
   //--- receive the property value
      if(!ChartGetDouble(chart_ID,CHART_PRICE_MAX,sub_window,result))
        {
         //--- display the error message in Experts journal
         Print(__FUNCTION__+", Error Code = ",GetLastError());
        }
   //--- return the value of the chart property
      return(result);
     }
};

void CChartDraw::Chart_Zone(string name, datetime time_1, double price_1, datetime time_2, double price_2, color color_type, int border_width,int sub_window = 0)
{
   object_name = name;
   
   if (!ObjectFound(object_name))
   {
   ObjectCreate(0, name, OBJ_RECTANGLE, sub_window, time_1, price_1, time_2, price_2);

   ObjectSetInteger(0, object_name, OBJPROP_COLOR, color_type); 
   ObjectSetInteger(0, object_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, object_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, object_name, OBJPROP_WIDTH, border_width);
   ObjectSetInteger(0, object_name, OBJPROP_BACK, true);
   ObjectSetInteger(0, object_name, OBJPROP_FILL, true);
   ObjectSetInteger(0, object_name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, object_name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, object_name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, object_name, OBJPROP_ZORDER, 10);
   }
}

void CChartDraw::Chart_Angled_Text(string name, double price, datetime time, string text, int fontsize, color color_type, int sub_window = 0, int angle = 90)
{
   object_name = name + "AngTxt";
   
   if(!ObjectFound(object_name))
   {
  ObjectCreate(0,object_name,OBJ_TEXT,sub_window,time,price); 
  ObjectSetInteger(0,object_name,OBJPROP_YDISTANCE,5); 
  ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type);
  ObjectSetDouble(0,object_name,OBJPROP_ANGLE,angle);
  ObjectSetString(0,object_name,OBJPROP_TEXT,text);
  ObjectSetInteger(0,object_name,OBJPROP_BACK,true); 
  ObjectSetInteger(0,object_name,OBJPROP_FONTSIZE,fontsize); 
  }         
}

void CChartDraw::Chart_Arrow(string name, enum_up_down up_down, double price, datetime time, color color_type, int width = 3, int sub_window = 0)
{
   object_name = name;
        
   if(!ObjectFound(object_name))
   {
   ObjectCreate(0,object_name,up_down == Up ? OBJ_ARROW_BUY : OBJ_ARROW_SELL,sub_window, time, price);
   ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type);
   ObjectSetInteger(0, object_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, object_name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, object_name, OBJPROP_BACK, true);
   ObjectSetInteger(0, object_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, object_name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, object_name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, object_name, OBJPROP_ZORDER, 0);
   ObjectSetInteger(0, object_name, OBJPROP_FILL, true);
   }
}

void CChartDraw::ChartLabel(string name, string text, string font, int font_size, color color_type, int x_distance, int y_distance, int corner, int sub_window = 0)
  {
  
  object_name = name;
  
  if(!ObjectFound(object_name))
   {
   ObjectCreate(0,object_name, OBJ_LABEL, sub_window, 0, 0);
   ObjectSetInteger(0,object_name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0,object_name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0,object_name, OBJPROP_YDISTANCE, y_distance);
   ObjectSetString(0,object_name,OBJPROP_TEXT,text);
   ObjectSetString(0,object_name,OBJPROP_FONT, font);
   ObjectSetInteger(0,object_name,OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0,object_name,OBJPROP_COLOR, color_type);
  }
}

void CChartDraw::Chart_H_Line(string name, double price, int width, color color_type, int sub_window = 0)
{
  object_name = name;
  
  if(!ObjectFound(object_name))
   {
   ObjectCreate(0,object_name,OBJ_HLINE,sub_window,0,price);
   ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type); 
   ObjectSetInteger(0,object_name,OBJPROP_STYLE,STYLE_SOLID); 
   ObjectSetInteger(0,object_name,OBJPROP_WIDTH,width); 
   ObjectSetInteger(0,object_name,OBJPROP_BACK,true); 
   ObjectSetInteger(0,object_name,OBJPROP_SELECTABLE,false); 
   ObjectSetInteger(0,object_name,OBJPROP_SELECTED,false); 
   ObjectSetInteger(0,object_name,OBJPROP_HIDDEN,true); 
   ObjectSetInteger(0,object_name,OBJPROP_ZORDER,0); 
  }
}

void CChartDraw::Chart_V_Line(string name, double price, datetime time, int width, color color_type, int sub_window = 0)
  {
  object_name = name;
  
  if(!ObjectFound(object_name))
   {
   ObjectCreate(0,object_name,OBJ_VLINE,0,time,price);
   ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type); 
   ObjectSetInteger(0,object_name,OBJPROP_STYLE,STYLE_SOLID); 
   ObjectSetInteger(0,object_name,OBJPROP_WIDTH,width); 
   ObjectSetInteger(0,object_name,OBJPROP_BACK,true); 
   ObjectSetInteger(0,object_name,OBJPROP_SELECTABLE,false); 
   ObjectSetInteger(0,object_name,OBJPROP_SELECTED,false); 
   ObjectSetInteger(0,object_name,OBJPROP_HIDDEN,true); 
   ObjectSetInteger(0,object_name,OBJPROP_ZORDER,0); 
   }
}

void CChartDraw::Chart_Trend_Line(string name, datetime time_1, double price_1, datetime time_2, double price_2, int width, color color_type, int sub_window = 0)
{
   object_name = name;
  
  if(!ObjectFound(object_name))
   {
      ObjectCreate(0, object_name, OBJ_TREND, sub_window, time_1, price_1, time_2, price_2);
      ObjectSetInteger(0, object_name, OBJPROP_COLOR, color_type);
      ObjectSetInteger(0, object_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, object_name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, object_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, object_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, object_name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, object_name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, object_name, OBJPROP_ZORDER, 0);
   }
}

void CChartDraw::ChartText(string name, string text, string font, int font_size, color color_type, datetime time, double price, ENUM_ANCHOR_POINT anchor,int sub_window = 0)
{
  object_name = name;
  
  if(!ObjectFound(object_name))
   {
   ObjectCreate(0,object_name,OBJ_TEXT,sub_window,time,price);
   ObjectSetString(0,object_name,OBJPROP_TEXT,text); 
   ObjectSetString(0,object_name,OBJPROP_FONT,font); 
   ObjectSetInteger(0,object_name,OBJPROP_FONTSIZE,font_size); 
   ObjectSetDouble(0,object_name,OBJPROP_ANGLE,0); 
   ObjectSetInteger(0,object_name,OBJPROP_ANCHOR,anchor); 
   ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type); 
   ObjectSetInteger(0,object_name,OBJPROP_BACK,false); 
   ObjectSetInteger(0,object_name,OBJPROP_SELECTABLE,false); 
   ObjectSetInteger(0,object_name,OBJPROP_SELECTED,false); 
   ObjectSetInteger(0,object_name,OBJPROP_HIDDEN,true); 
   ObjectSetInteger(0,object_name,OBJPROP_ZORDER,0); 
  }
}

void CChartDraw::ChartBox(string name, int x_distance, int y_distance, int x_size,int y_size, color color_type, int corner, int border_width, int sub_window = 0)
  {
  object_name = name;
  
  if(!ObjectFound(object_name))
   {
   ObjectCreate(0,object_name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0, object_name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, object_name, OBJPROP_YDISTANCE, y_distance);
   ObjectSetInteger(0,object_name,OBJPROP_XSIZE,x_size);  // increase the width
   ObjectSetInteger(0,object_name,OBJPROP_YSIZE,y_size);  // increase the height
   ObjectSetInteger(0,object_name,OBJPROP_BGCOLOR,color_type);
   ObjectSetInteger(0,object_name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,object_name,OBJPROP_CORNER,corner);
   ObjectSetInteger(0,object_name,OBJPROP_COLOR,clrLightCyan);
   ObjectSetInteger(0,object_name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,object_name,OBJPROP_WIDTH,border_width);
   ObjectSetInteger(0,object_name,OBJPROP_BACK,false);
   ObjectSetInteger(0,object_name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,object_name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,object_name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,object_name,OBJPROP_ZORDER,10);
   }
}

void CChartDraw::Chart_Text_2(string name, double price, datetime time, string text, color color_type, int sub_window = 0)
{
   object_name = name + "Txt";
   
   if(!ObjectFound(object_name))
   {
  ObjectCreate(0,object_name,OBJ_TEXT,sub_window,time,price,(CHART_PRICE_MIN+CHART_PRICE_MAX)/2); 
  ObjectSetInteger(0,object_name,OBJPROP_YDISTANCE,5); 
  ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type);
  ObjectSetString(0,object_name,OBJPROP_TEXT,text);
  ObjectSetInteger(0,object_name,OBJPROP_BACK,true);  
  }        
}
