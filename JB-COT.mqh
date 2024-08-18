//+------------------------------------------------------------------+
//|                                                       JB-COT.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#property description "class to read and parse COT data provided by cftc.gov"
#include <download.mqh>     // https://github.com/jblanked/MQL-Library/blob/main/Download.mqh
#include <jb-array.mqh>     // https://github.com/jblanked/MQL-Library/blob/main/JB-Array.mqh
//+------------------------------------------------------------------+
//|        Names and Codes for Financial Markets (COT Charts)        |
//+------------------------------------------------------------------+
enum ENUM_COT_CODES
  {
   CODE_CANADIAN_DOLLAR    = 0,  // Canadian Dollar: Code-090741
   CODE_SWISS_FRANC        = 1,  // Swiss Franc: Code-092741
   CODE_BRITISH_POUND      = 2,  // British Pound: Code-096742
   CODE_JAPANESE_YEN       = 3,  // Japanese Yen: Code-097741
   CODE_EURO_FX            = 4,  // Euro FX: Code-099741
   CODE_AUSSIE_DOLLAR      = 5,  // Australian Dollar: Code-232741
   CODE_MEXICAN_PESO       = 6,  // Mexican Peso: Code-095741
   CODE_BRAZILIAN_REAL     = 7,  // Brazilian Real: Code-102741
   CODE_NZ_DOLLAR          = 8,  // NZ Dollar: Code-112741
   CODE_SOUTH_AFRICAN_RAND = 9,  // South African Rand: Code-123741
   CODE_DJIA_CONSOLIDATED  = 10, // DJIA Consolidated: Code-12460+
   CODE_DJIA_X5            = 11, // DJIA x $5: Code-124603
   CODE_SP500_CONSOLIDATED = 12, // S&P 500 Consolidated: Code-13874+
   CODE_EMINI_SP500        = 13, // E-Mini S&P 500: Code-13874A
   CODE_EMINI_SP400        = 14, // E-Mini S&P 400 Stock Index: Code-138741
   CODE_NASDAQ_100_CONSOL  = 15, // NASDAQ-100 Consolidated: Code-20974+
   CODE_NASDAQ_MINI        = 16, // NASDAQ Mini: Code-209742
   CODE_RUSSELL_E_MINI     = 17, // Russell E-Mini: Code-239742
   CODE_MSCI_EAFE          = 18, // MSCI EAFE: Code-244603
   CODE_USD_INDEX          = 19, // USD Index: Code-098662
   CODE_BITCOIN            = 20, // Bitcoin: Code-133741
  };
//+------------------------------------------------------------------+
//|       Helper structure to hold COT data of a mini section        |
//+------------------------------------------------------------------+
struct COTDataHelper
  {
   int               longPositions;          // Current Long Positions
   int               shortPositions;         // Current Short Positions
   int               spreadingPositions;     // Current Spreading Positions

   int               longChanges;            // Change in Long Positions from the week before
   int               shortChanges;           // Change in Short Positions from the week before
   int               spreadingChanges;       // Change in Spreading Positions from the week before

   double            percentOfInterestLong;  // Percent of Open (Long) Interest Represented by Each Category of Trader
   double            percentOfInterestShort; // Percent of Open (Short) Interest Represented by Each Category of Trader
   double            percentOfInterestSpread;// Percent of Open (Spreading) Interest Represented by Each Category of Trader

   int               numberOfLongTraders;    // Number of Long Trades
   int               numberOfShortTraders;   // Number of Short Trades
   int               numberOfSpreadTraders;  // Number of Spreading Trades
  };
//+------------------------------------------------------------------+
//|        COTData structure to hold the COT data of a section       |
//+------------------------------------------------------------------+
struct COTData
  {
   ENUM_COT_CODES    code;             // CFTC code
   int               openInterest;     // Open Intrest (total volume / 100,000)
   int               totalTrades;      // Total amount of Traders in all Categories
   int               totalChange;      // Total change in positions from the week before
   COTDataHelper     dealer;           // Dealer (Intermediary) COT data
   COTDataHelper     assetManager;     // Asset Manager (Institutional) COT data
   COTDataHelper     leveragedFunds;   // Leveraged Funds COT data
   COTDataHelper     otherReportables; // Other Reportables COT data
   COTDataHelper     nonReportables;   // Nonreportable Positions COT data
  };
//+------------------------------------------------------------------+
//|                          CCOT class                              |
//+------------------------------------------------------------------+
class CCOT: private CDownload
  {
public:
   //--- downloads and saves data
   bool              getData(void)
     {
      if(!this.download("https://www.cftc.gov/dea/futures/financial_lf.htm", "COT.txt") || this.emptyFile())
        {
         Print("Access to https://www.cftc.gov/ was denied. Try again at " + TimeToString(TimeLocal() + 3600));

         // if save file exists
         if(::FileIsExist("COT-Save.txt", FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN))
           {
            // duplicate the save file as COT.txt
            this.fileDuplicate(this.commonFilesFolder() + "COT-Save.txt",  this.commonFilesFolder() + "COT.txt");

            // attempt to read file
            if(!this.fileRead(false, "COT-Save.txt"))
              {
               return false;
              }

            Print("COT data for the week of " + this.getCOTDate() + "saved successfully at " + this.commonFilesFolder() + "COT.txt");
            this.fileClose();
            return true;
           }
         else // failed to download and save file doesn't exist
           {
            return false;
           }
        }

      // attempt to read COT.txt
      if(!this.fileRead(false))
        {
         return false;
        }

      this.fileDuplicate(this.commonFilesFolder() + "COT.txt",  this.commonFilesFolder() + "COT-Save.txt");
      Print("COT data for the week of " + this.getCOTDate() + "saved successfully at " + this.commonFilesFolder() + "COT.txt");

      this.fileClose();
      return true;
     }

   COTData           getCOT(const ENUM_COT_CODES cotCode)
     {
      return this.setSection(cotCode);
     }

private:
   CJBArray          cotData;
   string            cotContent[];
   string            cotTemp[];
   string            cotFile;
   int               mHandle;

   //--- checks if COT file is empty
   bool              emptyFile(void)
     {
      if(!this.fileExists())
        {
         return false;
        }
      const string stringResult = FileReadString(this.fileHandle());

      if(stringResult != "")
        {
         return false;
        }
      else
        {
         return true;
        }
     }

   //--- close file after use
   void              fileClose(void)
     {
      FileClose(this.fileHandle(true));
     }

   //--- checks if COT file exists
   bool              fileExists(const string cotFileName = "COT.txt")
     {
      if(!FileIsExist(cotFileName, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN))
        {
         Print(this.commonFilesFolder() + cotFileName + " does not exist yet");
         return false;
        }

      return true;
     }

   //--- get file handle
   int               fileHandle(const bool isSet = false, const string cotFileName = "COT.txt")
     {
      if(isSet)
        {
         return this.mHandle;
        }

      this.mHandle = FileOpen(cotFileName, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN | FILE_TXT | FILE_ANSI);

      return this.mHandle;
     }

   //--- reads file and adds each line to this.cotData[]
   bool              fileRead(const bool isNewFile = false, const string cotFileName = "COT.txt")
     {
      if(!this.fileExists())
        {
         return false;
        }

      //--- read data from the file
      const string tempFile = FileReadString(this.fileHandle(false, cotFileName));
      this.fileClose();

      if(tempFile == "")
        {
         Print(this.commonFilesFolder() + cotFileName + " is empty.");
         return false;
        }

      this.cotFile = tempFile;

      // if new file save
      if(isNewFile)
        {
         // remove html content before the actual report
         this.cotFile = StringSubstr(tempFile, StringFind(tempFile, "Traders in Financial Futures"));

         // replace file
         ::FileWriteString(this.fileHandle(false, cotFileName), this.cotFile);
         this.fileClose();
        }

      if(!this.readFileToArray())
        {
         Print("Failed to read COT data from " + this.commonFilesFolder() + cotFileName);
        }

      return true;
     }

   //--- COT date
   string            getCOTDate(void)
     {
      return StringSubstr(this.cotContent[0], 60, 16);
     }

   // sets the this.cotTemp with the section of the COT code
   bool              getSection(const ENUM_COT_CODES cotCode)
     {
      for(int s = 0; s < ArraySize(this.cotContent); s += 20)
        {
         if(this.stringToCode(this.cotContent[s + 7]) == cotCode)
           {
            for(int t = s; t < s + 20; t++)
              {
               this.cotData.Append(this.cotTemp, this.cotContent[t]);
              }
            return true;
           }
        }
      return false;
     }

   //--- sets COT data line-by-line to this.cotContent
   bool              readFileToArray(void)
     {
      return StringSplit(this.cotFile, '\n', this.cotContent) > 0;
     }

   //--- searches and subtract line to find the COT code
   ENUM_COT_CODES    stringToCode(const string strCodeLine)
     {
      const string tempCode = StringSubstr(strCodeLine, 11, 6);

      if(tempCode == "090741")
        {
         return CODE_CANADIAN_DOLLAR;
        }

      if(tempCode == "092741")
        {
         return CODE_SWISS_FRANC;
        }

      if(tempCode == "096742")
        {
         return CODE_BRITISH_POUND;
        }

      if(tempCode == "097741")
        {
         return CODE_JAPANESE_YEN;
        }

      if(tempCode == "099741")
        {
         return CODE_EURO_FX;
        }

      if(tempCode == "232741")
        {
         return CODE_AUSSIE_DOLLAR;
        }

      if(tempCode == "095741")
        {
         return CODE_MEXICAN_PESO;
        }

      if(tempCode == "102741")
        {
         return CODE_BRAZILIAN_REAL;
        }

      if(tempCode == "112741")
        {
         return CODE_NZ_DOLLAR;
        }

      if(tempCode == "123741")
        {
         return CODE_SOUTH_AFRICAN_RAND;
        }

      if(tempCode == "12460+")
        {
         return CODE_DJIA_CONSOLIDATED;
        }

      if(tempCode == "124603")
        {
         return CODE_DJIA_X5;
        }

      if(tempCode == "13874+")
        {
         return CODE_SP500_CONSOLIDATED;
        }

      if(tempCode == "13874A")
        {
         return CODE_EMINI_SP500;
        }

      if(tempCode == "138741")
        {
         return CODE_EMINI_SP400;
        }

      if(tempCode == "20974+")
        {
         return CODE_NASDAQ_100_CONSOL;
        }

      if(tempCode == "209742")
        {
         return CODE_NASDAQ_MINI;
        }

      if(tempCode == "239742")
        {
         return CODE_RUSSELL_E_MINI;
        }

      if(tempCode == "244603")
        {
         return CODE_MSCI_EAFE;
        }

      if(tempCode == "098662")
        {
         return CODE_USD_INDEX;
        }

      if(tempCode == "133741")
        {
         return CODE_BITCOIN;
        }

      return CODE_USD_INDEX;

     }

   template <typename T>
   T                 stringFix(const string wholeLine, const int startIndex = 0, const int amountOfCharacters = 11)
     {
      string tempFixStr = StringSubstr(wholeLine, startIndex, amountOfCharacters);
      StringReplace(tempFixStr, ",", "");
      StringReplace(tempFixStr, " ", "");
      return (T)tempFixStr;
     }

   COTData           setSection(const ENUM_COT_CODES cotCode)
     {
      if(!this.getSection(cotCode))
        {
         return COTData();
        }

      COTData tempy;

      tempy.code                                   = this.stringToCode(this.cotTemp[7]);
      tempy.openInterest                           = this.stringFix<int>(this.cotTemp[7], StringLen(this.cotTemp[7]) - 10, 9);
      tempy.totalChange                            = this.stringFix<int>(this.cotTemp[11], StringLen(this.cotTemp[11]) - 9, 8);
      tempy.totalTrades                            = this.stringFix<int>(this.cotTemp[17], StringLen(this.cotTemp[17]) - 5, 4);

      const string positionsLine                   = this.cotTemp[9];
      const string changesLine                     = this.cotTemp[12];
      const string interestLine                    = this.cotTemp[15];
      const string tradersLine                     = this.cotTemp[18];

      //--- dealer
      tempy.dealer.longPositions                   = this.stringFix<int>(positionsLine, 0);
      tempy.dealer.shortPositions                  = this.stringFix<int>(positionsLine, 10);
      tempy.dealer.spreadingPositions              = this.stringFix<int>(positionsLine, 21);

      tempy.dealer.longChanges                     = this.stringFix<int>(changesLine, 0);
      tempy.dealer.shortChanges                    = this.stringFix<int>(changesLine, 10);
      tempy.dealer.spreadingChanges                = this.stringFix<int>(changesLine, 21);

      tempy.dealer.percentOfInterestLong           = this.stringFix<int>(interestLine, 0);
      tempy.dealer.percentOfInterestShort          = this.stringFix<int>(interestLine, 10);
      tempy.dealer.percentOfInterestSpread         = this.stringFix<int>(interestLine, 21);

      tempy.dealer.numberOfLongTraders             = this.stringFix<int>(tradersLine, 0);
      tempy.dealer.numberOfShortTraders            = this.stringFix<int>(tradersLine, 10);
      tempy.dealer.numberOfSpreadTraders           = this.stringFix<int>(tradersLine, 21);

      //--- asset manager
      tempy.assetManager.longPositions             = this.stringFix<int>(positionsLine, 32);
      tempy.assetManager.shortPositions            = this.stringFix<int>(positionsLine, 43);
      tempy.assetManager.spreadingPositions        = this.stringFix<int>(positionsLine, 54);

      tempy.assetManager.longChanges               = this.stringFix<int>(changesLine, 32);
      tempy.assetManager.shortChanges              = this.stringFix<int>(changesLine, 43);
      tempy.assetManager.spreadingChanges          = this.stringFix<int>(changesLine, 54);

      tempy.assetManager.percentOfInterestLong     = this.stringFix<int>(interestLine, 32);
      tempy.assetManager.percentOfInterestShort    = this.stringFix<int>(interestLine, 43);
      tempy.assetManager.percentOfInterestSpread   = this.stringFix<int>(interestLine, 54);

      tempy.assetManager.numberOfLongTraders       = this.stringFix<int>(tradersLine, 32);
      tempy.assetManager.numberOfShortTraders      = this.stringFix<int>(tradersLine, 43);
      tempy.assetManager.numberOfSpreadTraders     = this.stringFix<int>(tradersLine, 54);

      //--- leverage funds
      tempy.leveragedFunds.longPositions           = this.stringFix<int>(positionsLine, 65);
      tempy.leveragedFunds.shortPositions          = this.stringFix<int>(positionsLine, 76);
      tempy.leveragedFunds.spreadingPositions      = this.stringFix<int>(positionsLine, 87);

      tempy.leveragedFunds.longChanges             = this.stringFix<int>(changesLine, 65);
      tempy.leveragedFunds.shortChanges            = this.stringFix<int>(changesLine, 76);
      tempy.leveragedFunds.spreadingChanges        = this.stringFix<int>(changesLine, 87);

      tempy.leveragedFunds.percentOfInterestLong   = this.stringFix<int>(interestLine, 65);
      tempy.leveragedFunds.percentOfInterestShort  = this.stringFix<int>(interestLine, 76);
      tempy.leveragedFunds.percentOfInterestSpread = this.stringFix<int>(interestLine, 87);

      tempy.leveragedFunds.numberOfLongTraders     = this.stringFix<int>(tradersLine, 65);
      tempy.leveragedFunds.numberOfShortTraders    = this.stringFix<int>(tradersLine, 76);
      tempy.leveragedFunds.numberOfSpreadTraders   = this.stringFix<int>(tradersLine, 87);

      //--- other reportables
      tempy.otherReportables.longPositions         = this.stringFix<int>(positionsLine, 98);
      tempy.otherReportables.shortPositions        = this.stringFix<int>(positionsLine, 109);
      tempy.otherReportables.spreadingPositions    = this.stringFix<int>(positionsLine, 120);

      tempy.otherReportables.longChanges           = this.stringFix<int>(changesLine, 98);
      tempy.otherReportables.shortChanges          = this.stringFix<int>(changesLine, 109);
      tempy.otherReportables.spreadingChanges      = this.stringFix<int>(changesLine, 120);

      tempy.otherReportables.percentOfInterestLong    = this.stringFix<int>(interestLine, 98);
      tempy.otherReportables.percentOfInterestShort   = this.stringFix<int>(interestLine, 109);
      tempy.otherReportables.percentOfInterestSpread  = this.stringFix<int>(interestLine, 120);

      tempy.otherReportables.numberOfLongTraders   = this.stringFix<int>(tradersLine, 98);
      tempy.otherReportables.numberOfShortTraders  = this.stringFix<int>(tradersLine, 109);
      tempy.otherReportables.numberOfSpreadTraders = this.stringFix<int>(tradersLine, 120);

      //--- non reportable positions
      tempy.nonReportables.longPositions           = this.stringFix<int>(positionsLine, 131);
      tempy.nonReportables.shortPositions          = this.stringFix<int>(positionsLine, 142);
      tempy.nonReportables.spreadingPositions      = 0; // empty field

      tempy.nonReportables.longChanges             = this.stringFix<int>(changesLine, 131);
      tempy.nonReportables.shortChanges            = this.stringFix<int>(changesLine, 142);
      tempy.nonReportables.spreadingChanges        = 0; // empty field

      tempy.nonReportables.percentOfInterestLong   = this.stringFix<int>(interestLine, 131);
      tempy.nonReportables.percentOfInterestShort  = this.stringFix<int>(interestLine, 142);
      tempy.nonReportables.percentOfInterestSpread = 0; // empty field

      tempy.nonReportables.numberOfLongTraders     = this.stringFix<int>(tradersLine, 131);
      tempy.nonReportables.numberOfShortTraders    = this.stringFix<int>(tradersLine, 142);
      tempy.nonReportables.numberOfSpreadTraders   = 0; // empty field

      return tempy;
     }
  };
//+------------------------------------------------------------------+
/* ------------Example report----------
Traders in Financial Futures - Futures Only Positions as of August 13, 2024
-----------------------------------------------------------------------------------------------------------------------------------------------------------
              Dealer            :           Asset Manager/       :            Leveraged           :              Other             :     Nonreportable    :
           Intermediary         :           Institutional        :              Funds             :           Reportables          :       Positions      :
    Long  :   Short  : Spreading:    Long  :   Short  : Spreading:    Long  :   Short  : Spreading:    Long  :   Short  : Spreading:    Long  :   Short   :
-----------------------------------------------------------------------------------------------------------------------------------------------------------
CANADIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE   (CONTRACTS OF CAD 100,000)
CFTC Code #090741                                                    Open Interest is   323,167
Positions
   229,662      3,435      1,404     26,260    158,263      4,533      9,546    112,680      5,851     14,674      4,417         74     31,163     32,510

Changes from:       August 6, 2024                                   Total Change is:   -11,953
    -4,961       -723       -355     -1,160     -9,427       -247       -468      1,997     -1,597     -2,865      1,158         -3       -297     -2,756

Percent of Open Interest Represented by Each Category of Trader
      71.1        1.1        0.4        8.1       49.0        1.4        3.0       34.9        1.8        4.5        1.4        0.0        9.6       10.1

Number of Traders in Each Category                                    Total Traders:       128
        11          .          .          9         37         10         13         42          9          6          7          .
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Traders in Financial Futures - Futures Only Positions as of August 13, 2024
-----------------------------------------------------------------------------------------------------------------------------------------------------------
              Dealer            :           Asset Manager/       :            Leveraged           :              Other             :     Nonreportable    :
           Intermediary         :           Institutional        :              Funds             :           Reportables          :       Positions      :
    Long  :   Short  : Spreading:    Long  :   Short  : Spreading:    Long  :   Short  : Spreading:    Long  :   Short  : Spreading:    Long  :   Short   :
-----------------------------------------------------------------------------------------------------------------------------------------------------------
E-MINI S&P 500 - CHICAGO MERCANTILE EXCHANGE   ($50 X S&P 500 INDEX)
CFTC Code #13874A                                                    Open Interest is 2,033,008
Positions
   152,829    875,051     29,345  1,132,115    183,179    117,412    175,193    451,647     56,202    116,269    137,498      2,743    250,900    179,931

Changes from:       August 6, 2024                                   Total Change is:     7,174
    12,368    -17,065      4,771     23,843    -37,012    -15,011    -50,396     16,299     17,802     18,121     28,098     -4,397         73     13,689

Percent of Open Interest Represented by Each Category of Trader
       7.5       43.0        1.4       55.7        9.0        5.8        8.6       22.2        2.8        5.7        6.8        0.1       12.3        8.9

Number of Traders in Each Category                                    Total Traders:       462
        22         38         23        170         45         95         65         78         58         25         18          6
*/
//+------------------------------------------------------------------+
