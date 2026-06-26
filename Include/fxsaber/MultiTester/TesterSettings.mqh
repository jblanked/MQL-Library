#include "Settings.mqh"

typedef bool (*INITDEINIT)( void );

class TESTER_SETTINGS
{
private:
  SETTINGS Settings[];

  INITDEINIT iInit[];
  INITDEINIT iDeinit[];

public:
  TESTER_SETTINGS( const string FileName = __FILE__ )
  {
    if (this.Load(FileName))
      for (int i = ::ArrayResize(this.iDeinit, ::ArrayResize(this.iInit, this.GetSize())) - 1; i >= 0; i--)
      {
        this.iInit[i] = NULL;
        this.iDeinit[i] = NULL;
      }
  }

  void Free( void )
  {
    ::ArrayFree(this.Settings);
    ::ArrayFree(this.iInit);
    ::ArrayFree(this.iDeinit);

    return;
  }

  bool Load( const string FileName = __FILE__ )
  {
    const int handle = ::FileOpen(FileName, FILE_READ | FILE_BIN);
    const bool Res = (handle != INVALID_HANDLE);

    if (Res)
    {
      this.Free();

      ::FileReadArray(handle, this.Settings);

      ::FileClose(handle);
    }

    return(Res);
  }

  bool Save( const int Pos, const string FileName = __FILE__ ) const
  {
    const int handle = (Pos < this.GetSize()) ? ::FileOpen(FileName, FILE_WRITE | FILE_BIN) : INVALID_HANDLE;
    const bool Res = (handle != INVALID_HANDLE);

    if (Res)
    {
      ::FileWriteArray(handle, this.Settings, Pos);

      ::FileClose(handle);
    }

    return(Res);
  }

  bool Finish( const string FileName = __FILE__ ) const
  {
    return(::FileDelete(FileName));
  }

  bool Add( const string ExpertName = NULL,
            const string Symb = NULL,
            const ENUM_TIMEFRAMES period = PERIOD_CURRENT,
            const datetime BeginTime = 0,
            const datetime EndTime = 0,
            const INITDEINIT fInit = NULL,
            const INITDEINIT fDeinit = NULL )
  {
    const bool Res = ::SymbolInfoInteger(Symb, SYMBOL_VISIBLE);

    if (Res)
    {
      const int Size = ::ArrayResize(this.Settings, this.GetSize() + 1);

      ::ArrayResize(this.iInit, Size);
      ::ArrayResize(this.iDeinit, Size);

      this.Settings[Size - 1].Set(ExpertName, Symb, period, BeginTime, EndTime);
      this.iInit[Size - 1] = fInit;
      this.iDeinit[Size - 1] = fDeinit;
    }

    return(Res);
  }

  bool Run( const int Pos ) const
  {
    return(this.Settings[Pos].Run() && (this.Save(Pos) || true));
  }

  bool Init( const int Pos ) const
  {
    bool Res = true;

    if (this.GetSize() && this.iInit[Pos])
    {
      const INITDEINIT Ptr = this.iInit[Pos]; // https://www.mql5.com/ru/forum/324536/page23#comment_13868048

      Res = Ptr();
    }

    return(Res);
  }

  bool Deinit( const int Pos ) const
  {
    bool Res = true;

    if (this.GetSize() && this.iDeinit[Pos])
    {
      const INITDEINIT Ptr = this.iDeinit[Pos]; // https://www.mql5.com/ru/forum/324536/page23#comment_13868048

      Res = Ptr();
    }

    return(Res);
  }

  int GetSize( void ) const
  {
    return(::ArraySize(this.Settings));
  }

  string ToString( const int Pos ) const
  {
    return(this.Settings[Pos].ToString() + " (" + (string)(Pos + 1) + "/" + (string)this.GetSize() + ")");
  }
};