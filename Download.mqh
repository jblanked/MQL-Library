//+------------------------------------------------------------------+
//|                                                     Download.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"



// Import ShellExecuteW from shell32.dll
#import "shell32.dll"
int ShellExecuteW(int hWnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
int ShellExecuteA(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import



#import "Wininet.dll"
int InternetOpenW(string name, int config, string, string, int);
int InternetOpenUrlW(int, string, string, int, int, int);
bool InternetReadFile(int, uchar &sBuffer[], int, int &OneInt);
bool InternetCloseHandle(int);
bool HttpAddRequestHeadersW(int, string, int, int);
int HttpOpenRequestW(int, string, string, string, string, string, int, int);
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, char &lpOptional[], int dwOptionalLength);
bool InternetWriteFile(int, uchar &[], int, int &);
bool InternetQueryDataAvailable(int, int &);
bool InternetSetOptionW(int, int, int &, int);
int InternetConnectW(int, string, int, string, string, int, int, int);
int InternetReadFile(int, string, int, int& OneInt[]);


#import

#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10
#define SW_FORCEMINIMIZE    11
#define SW_MAX              11

#include <Zip\Zip.mqh>
CZip Zip;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct CDownload
  {
private:
   string            commonDataPath;
   string            savePath;
   string            curlCommand,psCommand;
   int               result;
   string            cmdParameters;
   string            deleteCmdParameters;
   int               eaNameLength;
   int               fullpathLength;
   string            Expertsfolder;
   string            downloadedFileLocation;
   string            targetFileLocation;
   string            command;
   int               fileHandle, hInternet, hUrl, fileHand;
   int               bytesRead;
   string            headers;
   uchar             buffer[1024];
   int               filehandle;
   string            strCurrentFile;
   string            strNewName;
   string            renameCommand;
   string            binName;
   string            cname;
   string            tname;
   string            editedName;


public:

   void              createBatchFile(void)
     {
      const string batfile =
         "@echo off\n"
         "rem RestartTerminal.bat\n"
         "set /a initialCount=0\n"
         "for /f \"usebackq delims==\" %%F in (`tasklist ^| findstr \"terminal.exe\"`) do (\n"
         "    set/a initialCount+=1\n"
         ")\n"
         ":loop\n"
         "    ping -n 6 localhost >nul& rem Sleep 5 seconds\n"
         "    set /a newCount=0\n"
         "    for /f \"usebackq delims==\" %%F in (`tasklist ^| findstr \"terminal.exe\"`) do (\n"
         "        set/a newCount+=1\n"
         "    )\n"
         "    if %newCount% == %initialCount% goto loop\n"
         "start \"terminal\" \"%~dp0terminal.exe\"";

      if(::FileIsExist("RestartTerminal.txt", FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_TXT))
        {
         ::FileDelete("RestartTerminal.txt", FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_TXT | FILE_IS_BINARY);
        }

      this.fileHand = FileOpen("RestartTerminal.txt", FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_TXT);
      if(this.fileHand == INVALID_HANDLE)
        {
         ::Print("file handle is invalid");
        }
      else
        {

         ::FileWriteString(this.fileHand, batfile);
         ::FileClose(this.fileHand);

         // Get the path to the common data directory
         commonDataPath = TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\";

         if(!FileIsExist("RestartTerminal.txt",FILE_COMMON))
           {
            Print("RestartTerminal.txt does not exist in ",commonDataPath);
            return;
           }

         // Command to rename the file

         // works
         //renameCommand = "/C rename \"" + commonDataPath + "RestartTerminal.txt" + "\" \"" + "newtest.txt" + "\"";

         // doesnt work
         renameCommand = "/C rename \"" + commonDataPath + "RestartTerminal.txt" + "\" \"" + "RestartTerminal.bat" + "\"";


         // Execute the renaming command
         ShellExecuteW(0, "open", "cmd.exe", renameCommand, NULL, SW_HIDE);

        }

     }


   void              restartTerminal(void)
     {
      // Execute the batch file

      // ShellExecuteW(NULL,"open","c:\\users\\route206\\desktop\\test.bat",NULL,NULL,1);
      //ShellExecuteW(0, "open", "/C " + TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\RestartTerminal.bat", "", "", 1);

      //ShellExecuteA(0, "open", "/C " + TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\RestartTerminal.bat", "", "", SW_HIDE);
      //ShellExecuteW(0, "open", "cmd.exe", "/C " + TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\RestartTerminal.bat", NULL, 0);
     }

   // downloads the file and saves it to the Experts folder
   bool              download(const string downloadLink, const string filenameToSave, bool zipFile=true)
     {

      tname = TerminalInfoString(TERMINAL_NAME);
      bytesRead = 0;
      headers = "Content-Type: application/json";
      // Initialize WinHTTP
      hInternet = InternetOpenW("MyApp", 1, NULL, NULL, 0);
      if(hInternet)
        {
         // Open a URL
         hUrl = InternetOpenUrlW(hInternet, downloadLink, NULL, 0, 0, 0);
         if(hUrl)
           {
            // Send the request headers
            if(HttpSendRequestW(hUrl, headers, StringLen(headers), buffer, 0))
              {
               fileHandle = FileOpen(filenameToSave, FILE_WRITE|FILE_BIN|FILE_COMMON); // Open the file in binary write mode
               if(fileHandle != INVALID_HANDLE)
                 {
                  // Read the response and write directly to file
                  while(InternetReadFile(hUrl, buffer, ArraySize(buffer), bytesRead) && bytesRead > 0)
                    {
                     FileWriteArray(fileHandle, buffer, 0, bytesRead); // Write the data to the file
                    }

                  FileClose(fileHandle); // Close the file
                 }
               else
                 {
                  Print("Error opening file for writing.");
                  return false;
                 }
              }
            InternetCloseHandle(hUrl); // Close the request handle
           }
         InternetCloseHandle(hInternet); // Close the WinHTTP handle
        }

      // Corrected definitions for paths
      eaNameLength = StringLen(MQLInfoString(MQL_PROGRAM_NAME)) + 4;
      fullpathLength = StringLen(MQLInfoString(MQL_PROGRAM_PATH));
      Expertsfolder = StringSubstr(MQLInfoString(MQL_PROGRAM_PATH), 0, (fullpathLength - eaNameLength));
      downloadedFileLocation = TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\" + "Files" + "\\" + filenameToSave;
      targetFileLocation = Expertsfolder + "\\" +  filenameToSave;

      Sleep(5000);

      if(zipFile)
        {
         // Load the ZIP file
         if(!FileIsExist(filenameToSave,FILE_COMMON)||!Zip.LoadZipFromFile(filenameToSave, FILE_COMMON))
           {
            Print("Failed to load ZIP file: ", filenameToSave);
            return false;
           }
         else
           {
            // unzip the file
            for(int i = 0; i < Zip.TotalElements(); i++)
              {
               uchar file_content[];                  // local var to hold file contents
               CZipFile* content = Zip.ElementAt(i);  // set CZipFileContent
               content.GetUnpackFile(file_content);   // unzip file contents into array
               delete content;                        // delete pointer after use

               cname = Zip.ElementAt(i).Name();       // name of zip file (without .zip)
               binName = cname+".bin";                // name of zip file (without .zip) + .bin extension

               // create file with file_content
               filehandle = FileOpen(binName,FILE_READ | FILE_WRITE | FILE_BIN | FILE_COMMON);
               FileWriteArray(filehandle,file_content);
               FileClose(filehandle);

               // Prepare for renaming by removing the .bin extension
               strCurrentFile = TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\" + "Files" + "\\" + binName;
               strNewName = StringSubstr(strCurrentFile, 0, StringLen(strCurrentFile) - 4); // Remove last 4 characters, ".bin"

               // Command to rename the file
               renameCommand = "/C rename \"" + strCurrentFile + "\" \"" + cname + "\"";

               // Execute the renaming command
               ShellExecuteW(0, "open", "cmd.exe", renameCommand, NULL, SW_HIDE);

               Sleep(1000);

               // Move the file to the Experts folder from the downloadedFileLocation using ShellExecuteW to call cmd.exe with move command
               cmdParameters = "/C move \"" + strNewName + "\" \"" + Expertsfolder + "\\" + cname + "\"";
               ShellExecuteW(0, "open", "cmd.exe", cmdParameters, NULL, SW_HIDE); // SW_HIDE to hide the command window

               Sleep(1000);

              }

            // ShellExecuteW to call cmd.exe to delete the file at zip file
            deleteCmdParameters = "/C if exist \"" + targetFileLocation + "\" del \"" + targetFileLocation + "\"";

            ShellExecuteW(0, "open", "cmd.exe", deleteCmdParameters, NULL, SW_HIDE); // SW_HIDE to hide the command window

            Sleep(1000);

#ifdef __MQL5__
            editedName = Expertsfolder + "\\" + StringSubstr(filenameToSave, 0, StringLen(filenameToSave) - 4) + ".ex4";
#else
            editedName = Expertsfolder + "\\" + StringSubstr(filenameToSave, 0, StringLen(filenameToSave) - 4) + ".ex5";
#endif
            // ShellExecuteW to call cmd.exe to delete the file at ex4 file
            deleteCmdParameters = "/C if exist \"" + editedName  + "\" del \"" + editedName + "\"";

            ShellExecuteW(0, "open", "cmd.exe", deleteCmdParameters, NULL, SW_HIDE); // SW_HIDE to hide the command window
           }

        }
      else
        {
         // Move the file to the Experts folder from the downloadedFileLocation using ShellExecuteW to call cmd.exe with move command
         cmdParameters = "/C move \"" + downloadedFileLocation + "\" \"" + targetFileLocation + "\"";
         ShellExecuteW(0, "open", "cmd.exe", cmdParameters, NULL, SW_HIDE); // SW_HIDE to hide the command window
        }


      Alert(filenameToSave + " successfully downloaded! Restart your terminal.");

      return true;

     }

   bool              MessageBox(const string message) {return MessageBox(message, "Alert", MB_YESNO | MB_ICONQUESTION) == 6 ? true : false;}


  };
//+------------------------------------------------------------------+
