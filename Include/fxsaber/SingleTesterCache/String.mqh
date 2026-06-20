#ifndef __STRING__

#define __STRING__

#define NULL_CHAR (short)0xFFFF

#define DEFINE_STRING(A)                        \
  struct STRING##A                              \
  {                                             \
  public :                                      \
    short Array[A];                             \
                                                \
  public:                                       \
    void operator =( const string &Str )        \
    {                                           \
      ::ArrayInitialize(Array, 0);              \
      this.Array[0] = NULL_CHAR;                \
      ::StringToShortArray(Str, this.Array);    \
                                                \
      return;                                   \
    }                                           \
                                                \
    template <typename T>                       \
    void operator =( const T &Str )             \
    {                                           \
      const string StrTmp = Str[];              \
      this = StrTmp;                            \
                                                \
      return;                                   \
    }                                           \
                                                \
    string operator []( const int = 0 ) const   \
    {                                           \
      return((this.Array[0] == NULL_CHAR)       \
              ? NULL :                          \
             ::ShortArrayToString(this.Array)); \
    }                                           \
  };

DEFINE_STRING(16)
DEFINE_STRING(32)
DEFINE_STRING(64)
DEFINE_STRING(128)
DEFINE_STRING(80)

#undef DEFINE_STRING

#undef NULL_CHAR

#endif // __STRING__