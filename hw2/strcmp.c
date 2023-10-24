#include<stdio.h>
#include<string.h>
int main(){
    char a1[] = "<scalar_decl>char4a=<expr>0</expr>,b=<expr>10</expr>;</scalar_decl><scalar_decl>char4c=<expr><expr><expr>a</expr>+<expr>(<expr><expr>a</expr>*<expr>b</expr></expr>)</expr></expr>-<expr>b</expr></expr>;</scalar_decl><scalar_decl>intd=<expr>c</expr>;</scalar_decl><scalar_decl>char8e=<expr>0</expr>,f=<expr>10</expr>;</scalar_decl><scalar_decl>char8g=<expr><expr><expr>(<expr><expr>e</expr>*<expr>f</expr></expr>)</expr>+<expr>e</expr></expr>-<expr>f</expr></expr>;</scalar_decl><scalar_decl>longh=<expr>g</expr>;</scalar_decl>";
    char s1[] = "<scalar_decl>char4a=<expr>0</expr>,b=<expr>10</expr>;</scalar_decl><scalar_decl>char4c=<expr><expr><expr>a</expr>+<expr>(<expr><expr>a</expr>*<expr>b</expr></expr>)</expr></expr>-<expr>b</expr></expr>;</scalar_decl><scalar_decl>intd=<expr>c</expr>;</scalar_decl><scalar_decl>char8e=<expr>0</expr>,f=<expr>10</expr>;</scalar_decl><scalar_decl>char8g=<expr><expr><expr>(<expr><expr>e</expr>*<expr>f</expr></expr>)</expr>+<expr>e</expr></expr>-<expr>f</expr></expr>;</scalar_decl><scalar_decl>longh=<expr>g</expr>;</scalar_decl>";
    printf("%d\n", strcmp(a1, s1));
    return 0;
}