//diff <(./parser < ./test.c) <(golden_parser < ./test.c)
/* need to test start*/
//?:
//
/* need to test end */

// int nul = NULL;
// int a = ++i;
// char a1, b1;
// unsigned int *a3, b3, *c3;
// const float a4 = 123.0, b4 = 45.6;
// int a5 = 1 * ( 0 + 3 ) + 2 * 5, b5 = 3 * 4;
// float *a9, *b9 = &c9, d9 = 3.14159, e9 = *a9;
// const double e2[3][4], f2[5];
// int a6 = (((a1 + b2) == 3));
// int a7[2][3] = {{0, 1, 2}, {3, 4, 5}};
// int b10[2][2][3];
// int b11[3][2][3] = {{{0, 1, 2}, {3, 4, 5}}, {{6, 7, 8}, {9, 10, 11}}, {{12, 13, 14}, {15, 16, 17}}};
// int a15 = (int)'\n';

// int foo(int a, int *b){
//     return a + b;
// }
// int boo(int a, int b){
//     return a - b;
// }
// int main(char *argv, int arg){
//     int i;
//     for(i = 0; i < 5; i++){
//         a = i;
//     }
// 	int b = a;
//     return 0;
// }
int main(){int b=3; int c=0;}
// int b[2][2][3] = {{{0, 1, 2}, {3, 4, 5}}, {{6, 7, 8}, {9, 10, 11}}};
// int arr1[2][2], arr2[3], arr3[4][5][6];
/*upper is checked code */
// char s[1000];
// int counter, len, index;
// int i, j;//loop counters
// int main()
// {
// 	while(scanf("%s", s) != EOF) 
//     {
// 		len = strlen(s);
//         counter=0;
// 		for( i = 1; i < len -1 ; i++)//odd
// 		{
// 			index=1;
// 			while((i-index)>=0&&(i+index)<len)
// 			{
// 				if(s[i-index] == s[i+index]){
//                     counter++; 
//                     index++;
//                 }
// 				else {break;}
// 			}
// 		}
// 		// for(i=0, j=1; i<len-1 && j<len ;i++, j++)//even
// 		// {
// 			index=0;
// 			while((i-index)>=0&&(j+index)<len)
// 			{
// 				if(s[i-index]==s[j+index]){
//                     counter++;
//                     index++;
//                 }
// 				else {break;}
// 			}
// 		// }
// 		printf("%d\n", counter);
// 	}
// 	return 0;
// }