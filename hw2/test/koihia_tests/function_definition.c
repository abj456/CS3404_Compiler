int a()
{
    int b = a();
    b++;
    return b;
}

int *a()
{
    int b = a();
    a[2][3][4];
    b++;
    return *100;
}

char a()
{
    int b = a();
    b++;
    return '\uffff';
}