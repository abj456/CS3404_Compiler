int a = (-5);
const int b = +9;
float c , f = -.5 , k = +87;
const double d = +0., *f = &d;
const char k = 'l';
void func(int a, char   * b);
int main()
{

    func(a,&b);
    func(foo()+5,func(func(a,&b),&b));
    int d = (int) c, *e = &b ;
    int arr[2][3] = {{1,2,3}, {1,2,3}};
    a = (int) c;
    void *ptr = (void*) e ; 
    arr[0][1] = arr[0][0];
    return a;
}

void func(int a, char * b)
{
    return foo();
}


void foo()
{
    return a = a+b;
}
