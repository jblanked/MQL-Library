//+------------------------------------------------------------------+
//|                                                       JB-Log.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <panel-draw.mqh>
#include <jb-cache.mqh>
#include <jb-array.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLog: public CJBArray
  {

public:
                     CLog::CLog(const string logName = "JB-Log", const bool showChartPanel = true)
     {
      this.cHeight = (int)::ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      this.cWidth  = (int)::ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      this.cache   = new CCache(logName);
      if(showChartPanel)
        {
         this.panel = new CPanelDraw(logName, 0, this.cHeight - (this.cHeight/3), this.cWidth,this.cHeight, 0);
         this.panel.CreateList(listView,logName + "-ListView",clrBlack,itemsToDraw,20,20,this.panel.Width()-20,this.panel.Height()-20);
         this.panel.CreatePanel();
        }
      this.m_name = logName;
      this.displayPanel = showChartPanel;
     }

   CLog::           ~CLog()
     {
      if(this.displayPanel)
        {
         this.panel.Destroy();
        }
      delete this.cache;
      delete this.panel;
     }

   template <typename T>
   void              Alert(const T alertMessage)
     {
      ::Alert(alertMessage);
      this.add(string(alertMessage));
     }

   template <typename T>
   void              Comment(const T commentMessage)
     {
      ::Comment(commentMessage);
      this.add(string(commentMessage));
     }

   void              onChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
     {
      if(this.displayPanel)
        {
         this.panel.PanelChartEvent(id,lparam,dparam,sparam);
        }
     }

   template <typename T>
   void              Print(const T printMessage)
     {
      ::Print(printMessage);
      this.add(string(printMessage));
     }

   template <typename T>
   void              SendNotification(const T notificationMessage)
     {
      ::SendNotification(notificationMessage);
      this.add(string(notificationMessage));
     }

private:
   CPanelDraw        *panel;
   CListView         listView;
   CCache            *cache;
   JSON              json;
   int               cHeight;
   int               cWidth;
   string            m_name;
   int               nInt;
   string            tempName;
   string            itemsToDraw[];
   bool              displayPanel;


   void              add(const string item)
     {
      // temp name
      this.tempName = this.time() + " - " + item;

      // add to chart panel
      if(this.displayPanel)
        {
         this.panel.addItemToList(this.listView,this.tempName);
        }

      // append to array
      this.nInt = this.Count(this.itemsToDraw);
      this.Increase(this.itemsToDraw);
      this.itemsToDraw[nInt] = this.tempName;

      // set cache
      this.json.Clear();

      for(int j = 0; j < this.Count(this.itemsToDraw); j++)
        {
         this.json[j] = this.itemsToDraw[j];
        }

      // add to log cache
      this.cache.setCJAVal(this.m_name + "CListViewItems", this.json, 60 * 60 * 24, false);
     };

   string            time(void)
     {
      return ::TimeToString(json.TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
     }

  };
//+------------------------------------------------------------------+
