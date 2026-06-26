template <typename T>
struct TestInputRange
{
  T Start;
  T Step;
  T Stop;

#define TOSTRING(A) #A + " = " + (string)(A) + "\n"
  string ToString( void ) const
  {
    return(TOSTRING(Start) + TOSTRING(Step) + TOSTRING(Stop));
  }
#undef TOSTRING
};