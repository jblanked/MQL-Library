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
   
   4. OnTick/OnTimer
   
      draw.ChartRedraw(); // only neccessary if the panel texts change
   
   5. OnDeInit
   
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
//+------------------------------------------------------------------+
//| Class CPanelDraw (create a panel and add objects                 |
//+------------------------------------------------------------------+
class CPanelDraw : public CAppDialog 
{
   public:
   
   void CreateLabel(
         const string labelName,    // Name of Label
         const string labelText,    // Text to be displayed
         const color labelColor,    // Color of the Text
         const int labelFontSize,   // Fontsize of the Text
         const int x1,              // X Position
         const int y1,              // Y Position
         const int x2 = 5,          // X-2 Position
         const int y2 = 5           // Y-2 Position
    );
    
    void CreateLabel(
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
    
    void CreateLabel(
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
    
    void CreateLabel(
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
    
    void CreateButton(
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
    
    void CreateButton(
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
    
    void CreateBitmap(
         const string bitmapName,   // Name of Bitmap
         const string bitmapPath,   // Path to Bitmap (import as resource like #resource "\\Images\\jblanked.bmp"
         const int x1,              // X Position
         const int y1,              // Y Position
         const int x2 = 5,          // X-2 Position
         const int y2 = 5           // Y-2 Position 
    );
    
    void CreateBitmap(
         CBmpButton & bitmapObject,  // CBmpButton object to inherit properties
         const string bitmapName,   // Name of Bitmap
         const string bitmapPath,   // Path to Bitmap (import as resource like #resource "\\Images\\jblanked.bmp"
         const int x1,              // X Position
         const int y1,              // Y Position
         const int x2 = 5,          // X-2 Position
         const int y2 = 5           // Y-2 Position 
    );
    
    void CreateInput(
         const string inputName,    // Name of Input/Textbox
         const int x1,              // X Position
         const int y1,              // Y Position
         const int x2 = 5,          // X-2 Position
         const int y2 = 5           // Y-2 Position  
    );
    
    void CreateInput(
         CEdit & inputObject,       // CEdit object to inherit properties
         const string inputName,    // Name of Input/Textbox
         const int x1,              // X Position
         const int y1,              // Y Position
         const int x2 = 5,          // X-2 Position
         const int y2 = 5           // Y-2 Position  
    );
    
    
    
    
          // constructor
      void CPanelDraw::CPanelDraw(const string name, const int height = NULL, const int width = NULL){
      
         if(height == NULL)
         {
            chart_height = (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
         }
         else
         {
            chart_height = height;
         }
         
         if(width == NULL)
         {
            chart_width = (int)(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)/2.5);
         }
         else
         {
            chart_width = width;
         }
         
         chart_name = name;
         
         // create dialog panel
         this.Create(NULL,chart_name,0,0,0,chart_width,chart_height);
         
         
      }
      
      // deconstructor
      void CPanelDraw::~CPanelDraw(void){
         delete createLabels;
         delete createButtons;
         delete createBitmaps;
         delete createInputs;
      }
 
      // chart event handler
      void PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam,string symbol,int magicc_numberr, string orderr_comenttt);
      
      // set panel
      bool CreatePanel();
      
      
      void ChartRedraw(){ChartRedraw(0);};
   

   private:
   
      // private variables
      CScrollV m_scroll_v;
      
      // bitmap button     
      CBmpButton *createBitmaps;
      
      // labels
      CLabel *createLabels;

      // buttons
      CButton *createButtons;

      // text input
      CEdit *createInputs;
      
      int chart_height, chart_width;
      string chart_name;
      
   protected:
      //--- create dependent controls 
      bool CreateEdit(void); 
};

bool CPanelDraw::CreatePanel(){

   // run panel
   if(!this.Run()) {Print("Failed to run panel"); return false;}
    
   // refresh chart
   this.ChartRedraw();
   
   this.Maximize();
   
   return true;
}

void CPanelDraw::CreateLabel(
         const string labelName, 
         const string labelText, 
         const color labelColor, 
         const int labelFontSize,
         const int x1,
         const int y1,
         const int x2 = 5,
         const int y2 = 5 
    ){
    
    createLabels = new CLabel();

    createLabels.Create(NULL, labelName, 0, x1, y1, x2, y2);
    
    createLabels.Text(labelText);
    createLabels.Color(labelColor);
    createLabels.FontSize(labelFontSize); 
    this.Add(createLabels); 
}

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
    ){
    
    createLabels = new CLabel();

    createLabels.Create(NULL, labelName, 0, x1, y1, x2, y2);
    
    createLabels.Text(labelText);
    createLabels.Color(labelColor);
    createLabels.FontSize(labelFontSize); 
    this.Add(createLabels); 
    labelObject = createLabels;  
}

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
    ){
    
    createLabels = new CLabel();
    
    createLabels.Create(NULL, labelName, 0, x1, y1, x2, y2);

    createLabels.Text(labelText);
    createLabels.Color(labelColor);
    createLabels.ColorBackground(labelBackgroundColor);
    createLabels.FontSize(labelFontSize); 
    this.Add(createLabels); 
}

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
    ){
    
    createLabels = new CLabel();
    
    createLabels.Create(NULL, labelName, 0, x1, y1, x2, y2);

    createLabels.Text(labelText);
    createLabels.Color(labelColor);
    createLabels.ColorBackground(labelBackgroundColor);
    createLabels.FontSize(labelFontSize); 
    this.Add(createLabels); 
    labelObject = createLabels;
}


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
    ){
    
    createButtons = new CButton();

    createButtons.Create(NULL, buttonName, 0, x1, y1, x2, y2);
    
    
    createButtons.Text(buttonText); 
    createButtons.Color(buttonColor); 
    createButtons.ColorBackground(buttonBackgroundColor); 
    createButtons.FontSize(buttonFontSize); 
    this.Add(createButtons); 
}

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
    ){
    
    createButtons = new CButton();

    createButtons.Create(NULL, buttonName, 0, x1, y1, x2, y2);
    
    
    createButtons.Text(buttonText); 
    createButtons.Color(buttonColor); 
    createButtons.ColorBackground(buttonBackgroundColor); 
    createButtons.FontSize(buttonFontSize); 
    this.Add(createButtons); 
    
    buttonObject = createButtons;
}

void CPanelDraw::CreateBitmap(
         const string bitmapName, 
         const string bitmapPath, 
         const int x1,
         const int y1,
         const int x2 = 5,
         const int y2 = 5 
    ){
    
    createBitmaps = new CBmpButton();

    createBitmaps.Create(NULL, bitmapName, 0, x1, y1, x2, y2);
    
    createBitmaps.BmpNames(bitmapPath,bitmapPath);
    this.Add(createBitmaps); 
}

void CPanelDraw::CreateBitmap(
         CBmpButton & bitmapObject,
         const string bitmapName, 
         const string bitmapPath, 
         const int x1,
         const int y1,
         const int x2 = 5,
         const int y2 = 5 
    ){
    
    createBitmaps = new CBmpButton();

    createBitmaps.Create(NULL, bitmapName, 0, x1, y1, x2, y2);
    
    createBitmaps.BmpNames(bitmapPath,bitmapPath);
    
    this.Add(createBitmaps); 
    
    bitmapObject = createBitmaps;
}

void CPanelDraw::CreateInput(
         const string inputName, 
         const int x1,
         const int y1,
         const int x2 = 5,
         const int y2 = 5 
    ){
    
    createInputs = new CEdit();

    createInputs.Create(NULL, inputName, 0, x1, y1, x2, y2);
    
    createInputs.ReadOnly(false);
    this.Add(createInputs); 
}

void CPanelDraw::CreateInput(
         CEdit &inputObject,
         const string inputName, 
         const int x1,
         const int y1,
         const int x2 = 5,
         const int y2 = 5 
    ){
    
    createInputs = new CEdit();

    createInputs.Create(NULL, inputName, 0, x1, y1, x2, y2);
    
    createInputs.ReadOnly(false); 
   
    this.Add(createInputs);  
    
    inputObject = createInputs;   
}

