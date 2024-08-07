//+------------------------------------------------------------------+
//|                                                   Panel-Draw.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
/*
   Example:


   1. #include <panel-draw.mqh>

   2. CPanelDraw *draw;

   3. In OnInit:

      draw = new CPanelDraw("Your-Panel-Name", NULL, NULL);

      // set your labels, buttons etc
      draw.CreateLabel("TestLabel","TestLabel",clrBlue,18,5,5,1,1);

      // set panel
      if(draw.CreatePanel()) return 1;
      else return -1;

   4. In OnChartEvent

      draw.PanelChartEvent(id,lparam,dparam,sparam);

   5. In OnDeInit

      draw.Destroy(reason);

      delete draw;
*/
//+------------------------------------------------------------------+
//|                           Include                                |
//+------------------------------------------------------------------+
#include <Controls\Defines.mqh>     // import defines

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
class CPanelDraw : public CAppDialog
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

   int               Height() {return ClientAreaHeight();}
   int               Width() {return ClientAreaWidth(); }

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
         this.chart_height = (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS) - 10;
        }
      else
        {
         this.chart_height = MathAbs(y2 - y1);
        }

      if(x2 == NULL && x1 == 0)
        {
         this.chart_width = (int)(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)/2.5);
        }
      else
        {
         this.chart_width = MathAbs(x2 - x1);
        }

      this.chart_name = name;
      this.sub_window = subWindow;


      // create dialog panel
      this.Create(NULL,this.chart_name,this.sub_window,x1,y1,x2,y2);

     }

   // deconstructor
   void CPanelDraw::~CPanelDraw(void)
     {
      this.numberOfLists = 0;
      delete createLabels;
      delete createButtons;
      delete createBitmaps;
      delete createInputs;
      delete createLists;
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

   int               chart_height, chart_width, sub_window;
   string            chart_name;
   int               numberOfLists;

   string            clickedValue;
   int               clickedIndex;

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
   if(!CAppDialog::OnResize())
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
   this.Add(createLabels);
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
   this.Add(labelObject);
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
   this.Add(createLabels);
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
   this.Add(labelObject);
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
   this.Add(createButtons);
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
   this.Add(buttonObject);
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

   createBitmaps.BmpNames(bitmapPath,bitmapPath);
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

   bitmapObject.BmpNames(bitmapPath,bitmapPath);

   this.Add(bitmapObject);
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
   this.Add(createInputs);
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

   this.Add(inputObject);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateList(
   const string listName,
   const color listBackgroundColor,
   string & listItems[],
   const int x1=10,
   const int y1=10,
   const int x2=NULL,
   const int y2=NULL
)
  {
   ArrayResize(this.listProperties, this.numberOfLists+1);

   this.listProperties[this.numberOfLists].name = listName;

   createLists = new CListView();

   createLists.Create(
      NULL,
      listName,
      this.sub_window,
      x1,
      y1,
      x2 == NULL ? this.Width() - 10 : x2,
      y2 == NULL ? this.Height() - 10: y2
   );

   createLists.ColorBackground(listBackgroundColor);

   this.Add(createLists);

   ArrayResize(this.listProperties[this.numberOfLists].values,ArraySize(listItems));
   for(int i = 0; i < ArraySize(listItems); i++)
     {
      createLists.AddItem(listItems[i]);
      this.listProperties[this.numberOfLists].values[i] = listItems[i];
     }

   this.numberOfLists+=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::CreateList(
   CListView & listObject,
   const string listName,
   const color listBackgroundColor,
   string & listItems[],
   const int x1=10,
   const int y1=10,
   const int x2=NULL,
   const int y2=NULL
)
  {
   ArrayResize(this.listProperties, this.numberOfLists+1);

   this.listProperties[this.numberOfLists].name = listName;


   listObject.Create(
      NULL,
      listName,
      this.sub_window,
      x1,
      y1,
      x2 == NULL ? this.Width() - 10 : x2,
      y2 == NULL ? this.Height() - 10: y2
   );

   listObject.ColorBackground(listBackgroundColor);

   this.Add(listObject);

//listObject.Alignment(WND_ALIGN_HEIGHT,0,0,0,0);
   ArrayResize(this.listProperties[this.numberOfLists].values,ArraySize(listItems));
   for(int i = 0; i < ArraySize(listItems); i++)
     {
      listObject.AddItem(listItems[i]);
      this.listProperties[this.numberOfLists].values[i] = listItems[i];
     }

   this.numberOfLists+=1;
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

   this.Add(createDropdown);

   createDropdown.Alignment(WND_ALIGN_HEIGHT,0,0,0,0);

   for(int i = 0; i < ArraySize(dropdownItems); i++)
     {
      createDropdown.AddItem(dropdownItems[i],i);
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

   this.Add(dropdownObject);

   dropdownObject.Alignment(WND_ALIGN_HEIGHT,0,0,0,0);

   for(int i = 0; i < ArraySize(dropdownItems); i++)
     {
      dropdownObject.AddItem(dropdownItems[i],i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDraw::PanelChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// call chart event method of base
   ChartEvent(id,lparam,dparam,sparam);
// reset clickedValue and clickedIndex
   this.clickedIndex = -1;
   this.clickedValue = "";
// check if button was pressed
   if(id== CHARTEVENT_OBJECT_CLICK)
     {
      // loop through the list properties (name, values[]);
      for(int i = 0; i < ArraySize(this.listProperties); i++)
        {
         // if sparam starts with the current property name
         if(StringSubstr(sparam,0,StringLen(this.listProperties[i].name)) == this.listProperties[i].name)
           {
            // index is the last letter of the sparam
            // clickedValue is the value that's set at the index of the current properties values
            this.clickedIndex = int(StringSubstr(sparam,StringLen(this.listProperties[i].name + "Item"),1));
            this.clickedValue = this.listProperties[i].values[clickedIndex];
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
