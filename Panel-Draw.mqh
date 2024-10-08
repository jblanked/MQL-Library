//+------------------------------------------------------------------+
//|                                                   Panel-Draw.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <Canvas\Canvas.mqh> // https://github.com/jblanked/MQL-Library/blob/main/Canvas.mqh (make sure to put in Canvas folder)
#include <jb-array.mqh>    // https://github.com/jblanked/MQL-Library/blob/main/JB-Array.mqh
#include <chart-draw.mqh>  // https://github.com/jblanked/MQL-Library/blob/main/Chart-Draw.mqh
/*
   Example:


   1. #include <panel-draw.mqh>

   2. CPanelDraw *draw;

   3. In OnInit:

      draw = new CPanelDraw("Your-Panel-Name", NULL, NULL);

      // set your labels, buttons etc
      draw.CreateLabel("TestLabel","TestLabel",clrBlue,18,5,5,1,1);

      // set panel
      if(!draw.CreatePanel())
      {
      return INIT_FAILED;
      }

      return INIT_SUCCEEDED;

   4. In OnChartEvent

      draw.PanelChartEvent(id,lparam,dparam,sparam);

   5. In OnDeInit

      draw.Destroy(reason);

      delete draw;
*/

//+------------------------------------------------------------------+
//|  The progress bar class using two colors                         |
//+------------------------------------------------------------------+
class CColorProgressBar : public CCanvas
  {
private:
   color             m_goodcolor, m_badcolor;   // "good" and "bad" colors
   color             m_backcolor, m_bordercolor; // background and border colors
   int               m_x;                       // X coordinate of the upper-left corner
   int               m_y;                       // Y coordinate of the upper-left corner
   int               m_widthh;                   // width
   int               m_heightt;                  // height
   int               m_borderwidth;             // border width
   bool              m_passes[];                // number of handled passes
   int               m_lastindex;               // last pass index
   color             savedGood, savedBad;
public:
   //--- constructor
                     CColorProgressBar::CColorProgressBar(): m_lastindex(0), m_goodcolor(savedGood), m_badcolor(savedBad)
     {
      //--- setting the passes array size to be a bit oversized
      ArrayResize(m_passes, 5000, 1000);
      ArrayInitialize(m_passes, 0);
      //---
     }
   //--- remove/destroy
   CColorProgressBar::~CColorProgressBar()
     {
      CCanvas::Destroy();
      ChartRedraw();
     }

   //--- initializing
   bool              CreateBar(const string name, int x, int y, int width, int height, ENUM_COLOR_FORMAT clrfmt, const color goodColor = clrGreen, const color badColor = clrRed);
   //--- resetting the counter to zero
   void              Reset(void) { m_lastindex = 0;     };
   //--- background, border and line color
   void              BackColor(const color clr)  { m_backcolor = clr;   };
   void              BorderColor(const color clr) { m_bordercolor = clr; };
   //---             switches color representation from color to uint type
   uint              uCLR(const color clr) { return(XRGB((clr) & 0x0FF, (clr) >> 8, (clr) >> 16));};
   //--- border and line width
   void              BorderWidth(const int w) { m_borderwidth = w;      };
   //--- adding result for drawing the line in the progress bar
   void              AddResult(bool good);
   //--- updating the progress bar on the chart
   void              Update(void);

   void              CreateProgressBar(
      const string progressBarame,
      const double progressVal,
      const int x1 = 20,
      const int y1 = 100,
      const int width = 500,
      const int height = 20,
      const color goodColor = clrGreen,
      const color badColor = clrRed
   )
     {
      int width_, height_;
      this.CreateBar(progressBarame, x1, y1, width, height, COLOR_FORMAT_XRGB_NOALPHA, goodColor, badColor);
      this.BackColor(clrIvory);
      this.BorderColor(clrGray);
      this.BorderWidth(1);
      this.FontSet("Arial", -210);
      this.TextSize(progressBarame, width_, height_);
      this.TextOut(int(width / 2), int(height / 2), progressBarame, ColorToARGB(clrWhite, 255));
      this.Update();

      for(int i = 0; i < width; i++)
        {
         this.AddResult(i < ((progressVal / 100) * width) ? true : false);
        }
     }

   //+------------------------------------------------------------------+

  };
//+------------------------------------------------------------------+
//|  Initializing                                                    |
//+------------------------------------------------------------------+
bool CColorProgressBar::CreateBar(const string name, int x, int y, int width, int height, ENUM_COLOR_FORMAT clrfmt, const color goodColor = clrGreen, const color badColor = clrRed)
  {
   bool res = false;
//--- invoking the parent class to create canvas
   if(CCanvas::CreateBitmapLabel(name, x, y, width, height, clrfmt))
     {
      //--- storing width and height
      m_heightt = height;
      m_widthh = width;
      savedGood = goodColor;
      savedBad = badColor;
      m_badcolor = badColor;
      m_goodcolor = goodColor;
      res = true;
     }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//|  Adding the result                                               |
//+------------------------------------------------------------------+
void CColorProgressBar::AddResult(bool good)
  {
   m_passes[m_lastindex] = good;
//--- adding one more vertical line having necessary color to the progress bar
   LineVertical(m_lastindex, m_borderwidth, m_heightt - m_borderwidth, uCLR(good ? m_goodcolor : m_badcolor));
//--- update on the chart
   CCanvas::Update();
//--- updating the index
   m_lastindex++;
   if(m_lastindex >= m_widthh)
      m_lastindex = 0;
//---
  }
//+------------------------------------------------------------------+
//|  Updating the chart                                              |
//+------------------------------------------------------------------+
void CColorProgressBar::Update(void)
  {
//--- filling the background with the border color
   CCanvas::Erase(CColorProgressBar::uCLR(m_bordercolor));
//--- drawing a rectangle using the background color
   CCanvas::FillRectangle(m_borderwidth, m_borderwidth,
                          m_widthh - m_borderwidth - 1,
                          m_heightt - m_borderwidth - 1,
                          CColorProgressBar::uCLR(m_backcolor));
//--- updating the chart
   CCanvas::Update();
  }
//+------------------------------------------------------------------+
struct ProgressBarStruct
  {
   string            name;
   double            percent;
   bool              goodOrBad;
  };
//+------------------------------------------------------------------+
//|                           Include                                |
//+------------------------------------------------------------------+
#include <Controls\Defines.mqh>     // import defines
#include <Canvas\Canvas.mqh>

#undef CONTROLS_FONT_NAME
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG

#define CONTROLS_FONT_NAME "Consolas"
#define CONTROLS_DIALOG_COLOR_CLIENT_BG C'0x20, 0x20, 0x20'

#include <Controls\Dialog.mqh>      // import panel
#include <Controls\Label.mqh>       // import labels
#include <Controls\Button.mqh>      // import buttons
#include <Controls\Edit.mqh>        // import text input
#include <Controls\Scrolls.mqh>     // import scrolls object
#include <Controls\BmpButton.mqh>   // import bitmap picture 
#include <Controls\ListView.mqh>    // import list
#include <Controls\ComboBox.mqh>    // import dropdown list
//+------------------------------------------------------------------+
//| Class CPanelDraw (create a panel and add objects                 |
//+------------------------------------------------------------------+
class CPanelDraw: public CAppDialog
  {
public:

   void              CreateLabel(
      const string labelName,    // Name of Label
      const string labelText,    // Text to be displayed
      const color labelColor,    // Color of the Text
      const int labelFontSize,   // Fontsize of the Text
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateLabel(
      CLabel & labelObject,      // CLabel object to inherit properties
      const string labelName,    // Name of Label
      const string labelText,    // Text to be displayed
      const color labelColor,    // Color of the Text
      const int labelFontSize,   // Fontsize of the Text
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateLabel(
      const string labelName,    // Name of Label
      const string labelText,    // Text to be displayed
      const color labelColor,    // Color of the Text
      const color labelBackgroundColor, // Background Color of the Label
      const int labelFontSize,   // Fontsize of the Text
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateLabel(
      CLabel & labelObject,      // CLabel object to inherit properties
      const string labelName,    // Name of Label
      const string labelText,    // Text to be displayed
      const color labelColor,    // Color of the Text
      const color labelBackgroundColor, // Background Color of the Label
      const int labelFontSize,   // Fontsize of the Text
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateButton(
      const string buttonName,   // Name of Button
      const string buttonText,   // Text to be displayed
      const color buttonColor,   // Color of the Text
      const color buttonBackgroundColor, // Background Color of the Button
      const int buttonFontSize,  // Fontsize of the Text
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateButton(
      CButton & buttonObject,    // CButton object to inherit properties
      const string buttonName,   // Name of Button
      const string buttonText,   // Text to be displayed
      const color buttonColor,   // Color of the Text
      const color buttonBackgroundColor, // Background Color of the Button
      const int buttonFontSize,  // Fontsize of the Text
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateBitmap(
      const string bitmapName,   // Name of Bitmap
      const string bitmapPath,   // Path to Bitmap (import as resource like #resource "\\Images\\jblanked.bmp"
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateBitmap(
      CBmpButton & bitmapObject,  // CBmpButton object to inherit properties
      const string bitmapName,   // Name of Bitmap
      const string bitmapPath,   // Path to Bitmap (import as resource like #resource "\\Images\\jblanked.bmp"
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateInput(
      const string inputName,    // Name of Input/Textbox
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateInput(
      CEdit & inputObject,       // CEdit object to inherit properties
      const string inputName,    // Name of Input/Textbox
      const int x1,              // X Position
      const int y1,              // Y Position
      const int x2 = 5,          // X-2 Position
      const int y2 = 5           // Y-2 Position
   );

   void              CreateList(
      const string listName,     // Name of List
      const color listBackgroundColor,// Color of the background
      string & listItems[],      // List Items
      const int x1 = 10,          // X Position
      const int y1 = 10,          // Y Position
      const int x2 = NULL,       // X-2 Position
      const int y2 = NULL        // Y-2 Position
   );

   void              CreateList(
      CListView & listObject,    // CListView object to inhert properties
      const string listName,     // Name of List
      const color listBackgroundColor,// Color of the background
      string & listItems[],      // List Items
      const int x1 = 10,          // X Position
      const int y1 = 10,          // Y Position
      const int x2 = NULL,       // X-2 Position
      const int y2 = NULL        // Y-2 Position
   );

   string            OnListItemClick(ENUM_DATATYPE returnType = TYPE_STRING); // Prints the List item Clicked

   void              CreateDropdownMenu(
      const string dropdownName, // Name of Dropdown Menu
      string & dropdownItems[],  // Drop Down Items
      const int x1 = 10,          // X Position
      const int y1 = 10,          // Y Position
      const int x2 = NULL,       // X-2 Position
      const int y2 = NULL        // Y-2 Position
   );

   void              CreateDropdownMenu(
      CComboBox & dropdownObject,//CComboBox object to inhert properties
      const string dropdownName, // Name of Dropdown Menu
      string & dropdownItems[],  // Drop Down Items
      const int x1 = 10,          // X Position
      const int y1 = 10,          // Y Position
      const int x2 = NULL,       // X-2 Position
      const int y2 = NULL        // Y-2 Position
   );

   void              CreateProgressBar(
      CColorProgressBar & pBar,
      const string progressBarame,
      const double progressVal,
      const int x1 = 20,
      const int y1 = 100,
      const int width = 500,
      const int height = 20,
      const color goodColor = clrGreen,
      const color badColor = clrRed
   );

   void              CreateProgressBar(
      const string progressBarame,
      const double progressVal,
      const int x1 = 20,
      const int y1 = 100,
      const int width = 500,
      const int height = 20,
      const color goodColor = clrGreen,
      const color badColor = clrRed
   );

   void              CreateProgressBarPanel(
      const string progressBarPanelName,
      ProgressBarStruct &progressBars[],
      const int x = 10,
      const int y = 100,
      const int width = 520,
      const color boxColor = clrBeige,
      const color fontColor = clrBlack,
      const color goodColor = clrGreen,
      const color badColor = clrRed,
      const ENUM_BASE_CORNER baseCorner = CORNER_LEFT_UPPER
   );

   void              UpdateProgressBarPanel(
      const string progressBarPanelName,
      ProgressBarStruct &progressBars[],
      const int x = 10,
      const int y = 100,
      const int width = 520,
      const color boxColor = clrBeige,
      const color fontColor = clrBlack,
      const color goodColor = clrGreen,
      const color badColor = clrRed,
      const ENUM_BASE_CORNER baseCorner = CORNER_LEFT_UPPER
   );

   int               Height() {return ClientAreaHeight();}
   int               Width() {return ClientAreaWidth(); }

   // constructor
   void              CPanelDraw::CPanelDraw(const bool isAware)
     {

     }

   // constructor
   void              CPanelDraw::CPanelDraw(
      const string name,
      const int x1 = 0,
      const int y1 = 0,
      const int x2 = NULL,
      const int y2 = NULL,
      const int subWindow = 0

   )
     {

      if(y2 == NULL && y1 == 0)
        {
         this.chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - 10;
        }
      else
        {
         this.chart_height = MathAbs(y2 - y1);
        }

      if(x2 == NULL && x1 == 0)
        {
         this.chart_width = (int)(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) / 2.5);
        }
      else
        {
         this.chart_width = MathAbs(x2 - x1);
        }

      this.chart_name = name;
      this.sub_window = subWindow;


      // create dialog panel
      this.Create(NULL, this.chart_name, this.sub_window, x1, y1, x2, y2);

     }

   // deconstructor
   void CPanelDraw::~CPanelDraw(void)
     {
      this.numberOfLists = 0;
      this.deletePointer(createLabels);
      this.deletePointer(createButtons);
      this.deletePointer(createBitmaps);
      this.deletePointer(createInputs);
      this.deletePointer(createLists);
      this.deletePointer(createDropdown);

      for(int cb = 0; cb < ArraySize(this.createProgressBars); cb++)
        {
         this.deletePointer(createProgressBars[cb]);
         this.deletePointer(this.pointers[cb]);
        }

      if(this.panelBarName != "")
        {
         ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, false);
        }

     }

   //--- delete pointer safely
   bool              deletePointer(void *ptr)
     {
      if(CheckPointer(ptr) == POINTER_DYNAMIC)
        {
         delete ptr;
         ptr = NULL;
         return true;
        }
      return false;
     }

   // chart event handler
   void              PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   // set panel
   bool              CreatePanel();


   struct listProperty
     {
      string         name;
      string         values[];
     };

   listProperty      listProperties[];

   void              addItemToList(CListView & listObject, const string itemToAdd, const int listIndex = 0);

private:
   CColorProgressBar *createProgressBars[];

   // private variables
   CScrollV          m_scroll_v;

   // bitmap button
   CBmpButton        *createBitmaps;

   // labels
   CLabel            *createLabels;

   // buttons
   CButton           *createButtons;

   // text input
   CEdit             *createInputs;

   // list view
   CListView         *createLists;

   // dropdown menu
   CComboBox         *createDropdown;

   void              *pointers[];

   int               chart_height, chart_width, sub_window;
   string            chart_name;
   int               numberOfLists;

   string            clickedValue;
   int               clickedIndex;
   string            tempName;
   long              tempX, tempY;

   int               lastY, lastX;
   bool              MouseDown, MouseClicked;
   string            panelBarName;
   long              panelXposition, panelYposition, panelWidth, panelHeight;

   string            panelBarAddons[];

   void              MoveCanvas(const string prefix, int mouseXold, int mouseYold, int mouseXnew, int mouseYnew)
     {

      for(int co =  0; co < ArraySize(panelBarAddons); co++)
        {
         tempName = panelBarAddons[co];
         ObjectSetInteger(0, tempName, OBJPROP_XDISTANCE, (ObjectGetInteger(0, tempName, OBJPROP_XDISTANCE) + (mouseXnew - mouseXold)));
         ObjectSetInteger(0, tempName, OBJPROP_YDISTANCE, (ObjectGetInteger(0, tempName, OBJPROP_YDISTANCE) + (mouseYnew - mouseYold)));
        }

      ChartRedraw();
     }

   string            MouseLeftButtonState(uint state)
     {
      string res;
      res += (((state & 1) == 1) ? "DN" : "UP"); // mouse left
      return(res);
     }

protected:
   //--- create dependent controls
   bool              CreateEdit(void);
   virtual bool      OnResize(void);
  };

//+------------------------------------------------------------------+
//| Handler of resizing                                              |
//+------------------------------------------------------------------+
bool CPanelDraw::OnResize(void)
  {
//--- call method of parent class
   if(!CDialog::OnResize())
      return(false);

//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDraw::CreatePanel()
  {

// run panel
   if(!this.Run())
     {
      Print("Failed to run panel");
      return false;
     }

   ChartRedraw();

   this.Maximize();

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateLabel(
   const string labelName,
   const string labelText,
   const color labelColor,
   const int labelFontSize,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   createLabels = new CLabel();

   createLabels.Create(NULL, labelName, this.sub_window, x1, y1, x2, y2);

   createLabels.Text(labelText);
   createLabels.Color(labelColor);
   createLabels.FontSize(labelFontSize);
   CDialog::Add(createLabels);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateLabel(
   CLabel & labelObject,
   const string labelName,
   const string labelText,
   const color labelColor,
   const int labelFontSize,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {
   labelObject.Create(NULL, labelName, this.sub_window, x1, y1, x2, y2);

   labelObject.Text(labelText);
   labelObject.Color(labelColor);
   labelObject.FontSize(labelFontSize);
   CDialog::Add(labelObject);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateLabel(
   const string labelName,
   const string labelText,
   const color labelColor,
   const color labelBackgroundColor,
   const int labelFontSize,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   createLabels = new CLabel();

   createLabels.Create(NULL, labelName, this.sub_window, x1, y1, x2, y2);

   createLabels.Text(labelText);
   createLabels.Color(labelColor);
   createLabels.ColorBackground(labelBackgroundColor);
   createLabels.FontSize(labelFontSize);
   CDialog::Add(createLabels);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateLabel(
   CLabel & labelObject,
   const string labelName,
   const string labelText,
   const color labelColor,
   const color labelBackgroundColor,
   const int labelFontSize,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   labelObject.Create(NULL, labelName, this.sub_window, x1, y1, x2, y2);

   labelObject.Text(labelText);
   labelObject.Color(labelColor);
   labelObject.ColorBackground(labelBackgroundColor);
   labelObject.FontSize(labelFontSize);
   CDialog::Add(labelObject);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateButton(
   const string buttonName,
   const string buttonText,
   const color buttonColor,
   const color buttonBackgroundColor,
   const int buttonFontSize,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   createButtons = new CButton();

   createButtons.Create(NULL, buttonName, this.sub_window, x1, y1, x2, y2);


   createButtons.Text(buttonText);
   createButtons.Color(buttonColor);
   createButtons.ColorBackground(buttonBackgroundColor);
   createButtons.FontSize(buttonFontSize);
   CDialog::Add(createButtons);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateButton(
   CButton & buttonObject,
   const string buttonName,
   const string buttonText,
   const color buttonColor,
   const color buttonBackgroundColor,
   const int buttonFontSize,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   buttonObject.Create(NULL, buttonName, this.sub_window, x1, y1, x2, y2);


   buttonObject.Text(buttonText);
   buttonObject.Color(buttonColor);
   buttonObject.ColorBackground(buttonBackgroundColor);
   buttonObject.FontSize(buttonFontSize);
   CDialog::Add(buttonObject);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateBitmap(
   const string bitmapName,
   const string bitmapPath,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   createBitmaps = new CBmpButton();

   createBitmaps.Create(NULL, bitmapName, this.sub_window, x1, y1, x2, y2);

   createBitmaps.BmpNames(bitmapPath, bitmapPath);
   this.Add(createBitmaps);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateBitmap(
   CBmpButton & bitmapObject,
   const string bitmapName,
   const string bitmapPath,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   bitmapObject.Create(NULL, bitmapName, this.sub_window, x1, y1, x2, y2);

   bitmapObject.BmpNames(bitmapPath, bitmapPath);

   CDialog::Add(bitmapObject);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateInput(
   const string inputName,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   createInputs = new CEdit();

   createInputs.Create(NULL, inputName, this.sub_window, x1, y1, x2, y2);

   createInputs.ReadOnly(false);
   CDialog::Add(createInputs);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateInput(
   CEdit &inputObject,
   const string inputName,
   const int x1,
   const int y1,
   const int x2 = 5,
   const int y2 = 5
)
  {

   inputObject.Create(NULL, inputName, this.sub_window, x1, y1, x2, y2);

   inputObject.ReadOnly(false);

   CDialog::Add(inputObject);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateList(
   const string listName,
   const color listBackgroundColor,
   string & listItems[],
   const int x1 = 10,
   const int y1 = 10,
   const int x2 = NULL,
   const int y2 = NULL
)
  {
   ArrayResize(this.listProperties, this.numberOfLists + 1);

   this.listProperties[this.numberOfLists].name = listName;

   createLists = new CListView();

   createLists.Create(
      NULL,
      listName,
      this.sub_window,
      x1,
      y1,
      x2 == NULL ? this.Width() - 10 : x2,
      y2 == NULL ? this.Height() - 10 : y2
   );

   createLists.ColorBackground(listBackgroundColor);

   CDialog::Add(createLists);

   ArrayResize(this.listProperties[this.numberOfLists].values, ArraySize(listItems));
   for(int i = 0; i < ArraySize(listItems); i++)
     {
      createLists.AddItem(listItems[i]);
      this.listProperties[this.numberOfLists].values[i] = listItems[i];
     }

   this.numberOfLists += 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateList(
   CListView & listObject,
   const string listName,
   const color listBackgroundColor,
   string & listItems[],
   const int x1 = 10,
   const int y1 = 10,
   const int x2 = NULL,
   const int y2 = NULL
)
  {
   ArrayResize(this.listProperties, this.numberOfLists + 1);

   this.listProperties[this.numberOfLists].name = listName;


   listObject.Create(
      NULL,
      listName,
      this.sub_window,
      x1,
      y1,
      x2 == NULL ? this.Width() - 10 : x2,
      y2 == NULL ? this.Height() - 10 : y2
   );

   listObject.ColorBackground(listBackgroundColor);

   CDialog::Add(listObject);

//listObject.Alignment(WND_ALIGN_HEIGHT,0,0,0,0);
   ArrayResize(this.listProperties[this.numberOfLists].values, ArraySize(listItems));
   for(int i = 0; i < ArraySize(listItems); i++)
     {
      listObject.AddItem(listItems[i]);
      this.listProperties[this.numberOfLists].values[i] = listItems[i];
     }

   this.numberOfLists += 1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::addItemToList(CListView & listObject, const string itemToAdd, const int listIndex = 0)
  {
// resize
   ArrayResize(this.listProperties[listIndex].values, ArraySize(this.listProperties[listIndex].values) + 1);

   listObject.AddItem(itemToAdd);
   this.listProperties[listIndex].values[ArraySize(this.listProperties[listIndex].values) - 1] = itemToAdd;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateDropdownMenu(
   const string dropdownName, // Name of Dropdown Menu
   string & dropdownItems[],  // Drop Down Items
   const int x1 = 10,          // X Position
   const int y1 = 10,          // Y Position
   const int x2 = NULL,       // X-2 Position
   const int y2 = NULL        // Y-2 Position
)
  {
   createDropdown = new CComboBox();

   createDropdown.Create(
      NULL,
      dropdownName,
      this.sub_window,
      x1,
      y1,
      x2 == NULL ? this.Width() - 10 : x2,
      y2 == NULL ? y1 + 40 : y2
   );

   CDialog::Add(createDropdown);

   createDropdown.Alignment(WND_ALIGN_HEIGHT, 0, 0, 0, 0);

   for(int i = 0; i < ArraySize(dropdownItems); i++)
     {
      createDropdown.AddItem(dropdownItems[i], i);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateDropdownMenu(
   CComboBox & dropdownObject, // CComboBox object to inhert properties
   const string dropdownName, // Name of Dropdown Menu
   string & dropdownItems[],  // Drop Down Items
   const int x1 = 10,          // X Position
   const int y1 = 10,          // Y Position
   const int x2 = NULL,       // X-2 Position
   const int y2 = NULL        // Y-2 Position
)
  {
   dropdownObject.Create(
      NULL,
      dropdownName,
      this.sub_window,
      x1,
      y1,
      x2 == NULL ? this.Width() - 10 : x2,
      y2 == NULL ? y1 + 40 : y2
   );

   CDialog::Add(dropdownObject);

   dropdownObject.Alignment(WND_ALIGN_HEIGHT, 0, 0, 0, 0);

   for(int i = 0; i < ArraySize(dropdownItems); i++)
     {
      dropdownObject.AddItem(dropdownItems[i], i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
// call chart event method of base
   CAppDialog::ChartEvent(id, lparam, dparam, sparam);
// reset clickedValue and clickedIndex
   this.clickedIndex = -1;
   this.clickedValue = "";
// check if button was pressed
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      // loop through the list properties (name, values[]);
      for(int i = 0; i < ArraySize(this.listProperties); i++)
        {
         // if sparam starts with the current property name
         if(StringSubstr(sparam, 0, StringLen(this.listProperties[i].name)) == this.listProperties[i].name)
           {
            // index is the last letter of the sparam
            // clickedValue is the value that's set at the index of the current properties values
            this.clickedIndex = int(StringSubstr(sparam, StringLen(this.listProperties[i].name + "Item"), 1));
            this.clickedValue = this.listProperties[i].values[clickedIndex];
           }
        }
     }
// check for progress bar panel drag
   if(id == CHARTEVENT_MOUSE_MOVE && this.panelBarName != "")
     {

      if(MouseLeftButtonState((uint)sparam) == "DN" && !MouseDown)
        {
         MouseDown = true;
         MouseClicked = false;
         lastX = (int)lparam;
         lastY = (int)dparam;

         // check if lastX and lastY are within the panel
         panelXposition = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_XDISTANCE);
         panelYposition = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_YDISTANCE);
         panelWidth     = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_XSIZE);
         panelHeight    = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_YSIZE);

         if(
            (int)lparam >= panelXposition - 5 && (int)lparam <= panelXposition + panelWidth + 5 &&
            (int)dparam >= panelYposition - 5 && (int)dparam <= panelYposition + panelHeight + 5
         )
           {
            ::ChartSetInteger(0, CHART_MOUSE_SCROLL, false); // disable scroll
           }
        }

      if(MouseLeftButtonState((uint)sparam) == "UP" && MouseDown)
        {
         MouseClicked = true;
         MouseDown = false;
         lastX = (int)lparam;
         lastY = (int)dparam;
         ::ChartSetInteger(0, CHART_MOUSE_SCROLL, true); // enable scroll
        }

      // if MouseDown but X/Y of mouse has changed
      // move selected object proportionality
      if(MouseDown && (int)lparam != lastX && (int)dparam != lastY)
        {
         // check if lastX and lastY are within the panel
         panelXposition = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_XDISTANCE);
         panelYposition = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_YDISTANCE);
         panelWidth     = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_XSIZE);
         panelHeight    = ::ObjectGetInteger(0, this.panelBarName, OBJPROP_YSIZE);

         if(
            (int)lparam >= panelXposition - 5 && (int)lparam <= panelXposition + panelWidth + 5 &&
            (int)dparam >= panelYposition - 5 && (int)dparam <= panelYposition + panelHeight + 5
         )
           {
            this.MoveCanvas(this.panelBarName, lastX, lastY, (int)lparam, (int)dparam);

            lastX = (int)lparam;
            lastY = (int)dparam;
           }
        }
     }


  }

//+------------------------------------------------------------------+
string CPanelDraw::OnListItemClick(ENUM_DATATYPE returnType = TYPE_STRING)
  {
   return returnType == TYPE_STRING ? this.clickedValue : string(this.clickedIndex);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CPanelDraw::CreateProgressBar(
   CColorProgressBar & progressBar,
   const string progressBarame,
   const double progressVal,
   const int x1 = 20,
   const int y1 = 100,
   const int width = 500,
   const int height = 20,
   const color goodColor = clrGreen,
   const color badColor = clrRed
)
  {
   int width_, height_;
   progressBar.CreateBar(progressBarame, x1, y1, width, height, COLOR_FORMAT_XRGB_NOALPHA, goodColor, badColor);
   progressBar.BackColor(clrIvory);
   progressBar.BorderColor(clrGray);
   progressBar.BorderWidth(1);
   progressBar.FontSet("Arial", -210);
   progressBar.TextSize(progressBarame, width_, height_);
   progressBar.TextOut(int(width / 2), int(height / 2), progressBarame, ColorToARGB(clrWhite, 255));
   progressBar.Update();

   for(int i = 0; i < width; i++)
     {
      progressBar.AddResult(i < ((progressVal / 100) * width) ? true : false);
     }

//  this.CreateBitmap("CPanelDraw " + progressBarame, "",x1,y1,width,height);
//   progressBar.Attach(0,"CPanelDraw " + progressBarame,COLOR_FORMAT_XRGB_NOALPHA);
  }
//+------------------------------------------------------------------+
void CPanelDraw::CreateProgressBar(
   const string progressBarame,
   const double progressVal,
   const int x1 = 20,
   const int y1 = 100,
   const int width = 500,
   const int height = 20,
   const color goodColor = clrGreen,
   const color badColor = clrRed
)
  {
   int width_, height_;
   const int oldPBsize = ::ArraySize(this.createProgressBars);
   ::ArrayResize(this.createProgressBars, oldPBsize + 1);
   ::ArrayResize(this.pointers, oldPBsize + 1);

   createProgressBars[oldPBsize] = new CColorProgressBar();
   pointers[oldPBsize] = GetPointer(this.createProgressBars[oldPBsize]);
   createProgressBars[oldPBsize].CreateBar(progressBarame, x1, y1, width, height, COLOR_FORMAT_XRGB_NOALPHA, goodColor, badColor);
   createProgressBars[oldPBsize].BackColor(clrIvory);
   createProgressBars[oldPBsize].BorderColor(clrGray);
   createProgressBars[oldPBsize].BorderWidth(1);
   createProgressBars[oldPBsize].FontSet("Arial", -210);
   createProgressBars[oldPBsize].TextSize(progressBarame, width_, height_);
   createProgressBars[oldPBsize].TextOut(int(width / 2), int(height / 2), progressBarame, ColorToARGB(clrWhite, 255));
   createProgressBars[oldPBsize].Update();

   for(int i = 0; i < width; i++)
     {
      createProgressBars[oldPBsize].AddResult(i < ((progressVal / 100) * width) ? true : false);
     }
//CDialog::Add(createProgressBars);
// https://www.mql5.com/en/articles/261 for more info bro
//  this.CreateBitmap("CPanelDraw " + progressBarame, "",x1,y1,width,height);
//   progressBar.Attach(0,"CPanelDraw " + progressBarame,COLOR_FORMAT_XRGB_NOALPHA);
  }
//+------------------------------------------------------------------+
void CPanelDraw::CreateProgressBarPanel(
   const string progressBarPanelName,  // delete this in OnDeInit (ObjectsDeleteAll(0, progressBarPanelName))
   ProgressBarStruct &progressBars[],
   const int x = 10,
   const int y = 100,
   const int width = 520,
   const color boxColor = clrBeige,
   const color fontColor = clrBlack,
   const color goodColor = clrGreen,
   const color badColor = clrRed,
   const ENUM_BASE_CORNER baseCorner = CORNER_LEFT_UPPER
)
  {
// CChartDraw class (chart objects)
   CChartDraw draw_;

// draw rectangle panel
   draw_.ChartBox(progressBarPanelName, x, y, width, (ArraySize(progressBars) * 30) + 50, boxColor, baseCorner, 3, 0);

   this.panelBarName = progressBarPanelName;

// draw title
   draw_.ChartLabel(progressBarPanelName + "-Title", progressBarPanelName, "Arial", 9, fontColor, x + int(width / 2.5), y + 10, baseCorner, 0);

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);

   int lastSaveY = 40;
   int biggestChar = 0;

// loop to find biggest string len
   for(int k = 0; k < ArraySize(progressBars); k++)
     {
      biggestChar = StringLen(progressBars[k].name) <= biggestChar ? biggestChar : StringLen(progressBars[k].name);
     }

   ::ArrayResize(this.createProgressBars, ArraySize(progressBars));
   ::ArrayResize(this.pointers, ArraySize(progressBars));
   ::ArrayResize(this.panelBarAddons, ArraySize(progressBars) * 3 + 2);

   int addonIteration = 0;

   this.panelBarAddons[addonIteration]    = progressBarPanelName;
   this.panelBarAddons[addonIteration + 1]    = progressBarPanelName + "-Title";
   addonIteration = 2;

// set progress bars with name and percent labels
   for(int pk = 0; pk < ArraySize(progressBars); pk++)
     {
      // draw name label
      draw_.ChartLabel(progressBarPanelName + "-" + (string)pk + "-label", progressBars[pk].name, "Arial", 5, fontColor, x + 2, y + lastSaveY, baseCorner, 0);

      // draw percent label
      draw_.ChartLabel(progressBarPanelName + "-" + (string)pk + "-value", (string)(int)progressBars[pk].percent + "%", "Arial", 5, fontColor, x + width - 28, y + lastSaveY, baseCorner, 0);

      // assign new pointer
      this.createProgressBars[pk] = new CColorProgressBar();

      this.pointers[pk] = GetPointer(this.createProgressBars[pk]);

      this.panelBarAddons[addonIteration]    = progressBarPanelName + "-" + (string)pk + "-label";
      this.panelBarAddons[addonIteration + 1]  = progressBarPanelName + "-" + (string)pk + "-value";
      this.panelBarAddons[addonIteration + 2] = progressBarPanelName + "-pBar-" + progressBars[pk].name;
      addonIteration += 3;

      // draw progress bar
      this.createProgressBars[pk].CreateProgressBar(
         progressBarPanelName + "-pBar-" + progressBars[pk].name,
         progressBars[pk].percent,
         biggestChar <= 3 ? x + 30 : biggestChar > 3 && biggestChar <= 5 ? x + 50 : x + 70,
         y + lastSaveY,
         biggestChar <= 3 ? width - 60 : biggestChar > 3 && biggestChar <= 5 ? width - 80 : width - 100,
         20,
         progressBars[pk].goodOrBad ? goodColor : badColor,
         progressBars[pk].goodOrBad ? badColor : goodColor
      );

      // increase y position by 30 for next iteration
      lastSaveY += 30;
     }
  }
//+------------------------------------------------------------------+
void CPanelDraw::UpdateProgressBarPanel(
   const string progressBarPanelName,  // delete this in OnDeInit (ObjectsDeleteAll(0, progressBarPanelName))
   ProgressBarStruct &progressBars[],
   const int x = 10,
   const int y = 100,
   const int width = 520,
   const color boxColor = clrBeige,
   const color fontColor = clrBlack,
   const color goodColor = clrGreen,
   const color badColor = clrRed,
   const ENUM_BASE_CORNER baseCorner = CORNER_LEFT_UPPER
)
  {
// CChartDraw class (chart objects)
   CChartDraw draw_;

// check if rectangle panel exists
   if(!draw_.ObjectFound(progressBarPanelName))
     {
      return;
     }

// update rectangle panel
   ::ObjectSetInteger(0, progressBarPanelName, OBJPROP_CORNER, baseCorner);
   ::ObjectSetInteger(0, progressBarPanelName, OBJPROP_XDISTANCE, x);
   ::ObjectSetInteger(0, progressBarPanelName, OBJPROP_YDISTANCE, y);
   ::ObjectSetInteger(0, progressBarPanelName, OBJPROP_XSIZE, width);
   ::ObjectSetInteger(0, progressBarPanelName, OBJPROP_YSIZE, (ArraySize(progressBars) * 30) + 50);
   ::ObjectSetInteger(0, progressBarPanelName, OBJPROP_BGCOLOR, boxColor);

// check if title label exists
   if(!draw_.ObjectFound(progressBarPanelName + "-Title"))
     {
      return;
     }

// update title
   ::ObjectSetInteger(0, progressBarPanelName + "-Title", OBJPROP_CORNER, baseCorner);
   ::ObjectSetInteger(0, progressBarPanelName + "-Title", OBJPROP_XDISTANCE,  x + int(width / 2.5));
   ::ObjectSetInteger(0, progressBarPanelName + "-Title", OBJPROP_YDISTANCE, y + 10);
   ::ObjectSetString(0, progressBarPanelName + "-Title", OBJPROP_TEXT, progressBarPanelName);
   ::ObjectSetInteger(0, progressBarPanelName + "-Title", OBJPROP_COLOR, fontColor);

   int lastSaveY = 40;
   int biggestChar = 0;

// loop to find biggest string len
   for(int ak = 0; ak < ArraySize(progressBars); ak++)
     {
      biggestChar = StringLen(progressBars[ak].name) <= biggestChar ? biggestChar : StringLen(progressBars[ak].name);
     }

// set progress bars with name and percent labels
   for(int k = 0; k < ArraySize(progressBars); k++)
     {

      // check if name label exists
      if(!draw_.ObjectFound(progressBarPanelName + "-" + (string)k + "-label"))
        {
         continue; // skip to next iteration
        }

      // update name label
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-label", OBJPROP_CORNER, baseCorner);
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-label", OBJPROP_XDISTANCE, x + 2);
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-label", OBJPROP_YDISTANCE, y + lastSaveY);
      ::ObjectSetString(0, progressBarPanelName + "-" + (string)k + "-label", OBJPROP_TEXT, progressBars[k].name);
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-label", OBJPROP_COLOR, fontColor);

      // check if percent label exists
      if(!draw_.ObjectFound(progressBarPanelName + "-" + (string)k + "-value"))
        {
         continue; // skip to next iteration
        }

      // update percent label
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-value", OBJPROP_CORNER, baseCorner);
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-value", OBJPROP_XDISTANCE, x + width - 28);
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-value", OBJPROP_YDISTANCE, y + lastSaveY);
      ::ObjectSetString(0, progressBarPanelName + "-" + (string)k + "-value", OBJPROP_TEXT, (string)(int)progressBars[k].percent + "%");
      ::ObjectSetInteger(0, progressBarPanelName + "-" + (string)k + "-value", OBJPROP_COLOR, fontColor);

      // assign new pointer
      this.createProgressBars[k] = new CColorProgressBar();

      // delete progress bar
      if(!draw_.ObjectFound(progressBarPanelName + "-pBar-" + progressBars[k].name))
        {
         continue;
        }
      else
        {
         ::ObjectDelete(0, progressBarPanelName + "-pBar-" + progressBars[k].name);
        }

      // redraw progress bar
      this.createProgressBars[k].CreateProgressBar(
         progressBarPanelName + "-pBar-" + progressBars[k].name,
         progressBars[k].percent,
         biggestChar <= 3 ? x + 30 : biggestChar > 3 && biggestChar <= 5 ? x + 50 : x + 70,
         y + lastSaveY,
         biggestChar <= 3 ? width - 60 : biggestChar > 3 && biggestChar <= 5 ? width - 80 : width - 100,
         20,
         progressBars[k].goodOrBad ? goodColor : badColor,
         progressBars[k].goodOrBad ? badColor : goodColor
      );

      // increase y position by 30 for next iteration
      lastSaveY += 30;
     }
  }
//+------------------------------------------------------------------+
