template <typename T>
struct TestCacheRecord
{
  T Result;
  uchar OptBuffer[];
  uchar Genetic[];

  void operator =( const T &Value )
  {
    this.Result = Value;

    return;
  }
};