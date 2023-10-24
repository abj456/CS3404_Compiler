/* Jump 0 */
// void codegen();

// void codegen() {
//   int input_data[17];
//   int i;
//   for (i = 0; i < 17; i = i + 1) {
//     input_data[i] = i ;
//   }
//   int end = 0;
//   int data[17];

//   for (i = 0; i < 17; i = i + 1) {
//     int *id = input_data + i;    
//     // int slot = end;
//     // int cont = slot != 0;
//     // while (cont) {
//     //   const int parent = (slot - 1) / 2;
//     //   if (data[parent] < *id) {
//     //     *(data + slot) = *(data + parent);
//     //     slot = parent;
//     //   } else {
//     //     cont = 0;
//     //   }
//     //   if (slot == 0) {
//     //     cont = 0;
//     //   }
//     // }
//     // data[slot] = *id;
//     end = end + 1;
//     // end = *id;
//   }
//   digitalWrite(26, HIGH);
//   delay(input_data[5] * 1000); /* data[0] - data[2] = 3 */
//   digitalWrite(26, LOW);
//   delay(input_data[1] * 1000);
//   // digitalWrite(26, HIGH);
//   // delay((data[0] - data[2]) * 1000); /* data[0] - data[2] = 3 */
//   // digitalWrite(26, LOW);
//   // delay((end - data[0]) * 1000); /* end - data[0] = 1 */
// }

/* bonus */
void codegen();
void codegen()
{
  char4 a = 65280; // a = 00000000_00000000_11111111_00000000
  char4 b = 259;   // b = 00000000_00000000_00000001_00000011
  int c = a + b;   // c = 3  
  digitalWrite(26, HIGH);
  delay(c * 1000); // delay 3 seconds
  digitalWrite(26, LOW);
  delay(c * 1000); // delay 3 seconds
}


/* Pointer 1 */
// void codegen();

// void codegen() {
//   int a = 58 / 17; /* a = 3 */
//   int b = a * 2 + 10; /* b = 16 */
//   int *c = &a; /* *c = 3 */
//   *c = *c + 1; /* *c = 4, a = 4 */
//   c = &b; /* *c = 16 */
//   *c = b / a; /* *c = 4, b = 4 */
//   digitalWrite(29, HIGH);
//   delay(a * 1000 + 1000); /* 5 seconds */
//   digitalWrite(29, LOW);
//   delay(b * 1000 - 250 * 8); /* 2 seconds */
// }

/* Pointer 0 */
// void codegen();

// void codegen() {
//   int a = 42 - 53 * 2; /* a = -64 */
//   int *b = &a; /* *b = -64 */
//   *b = -a / 8; /* a = 8, *b = 8 */
//   a = *b - 4; /* a = 4, *b = 4 */
//   digitalWrite(28, HIGH);
//   delay(a * 1000);
//   digitalWrite(28, LOW);
//   delay(*b * 1000);
// }

/* Arithmetic Expression 1*/
// void codegen();
// void codegen()
// {
//   int a = 4; // a = 4
//   int b = (a - 2) * (a - 1); // b = 6
//   digitalWrite(27, HIGH);
//   delay(a * 1000); // delay 4 seconds
//   digitalWrite(27, LOW);
//   delay(b * 1000); // delay 6 seconds
// }

/* Arithmetic Expression 0 */
// void codegen();
// void codegen()
// {
//   int a = 1 + 2 * 1; // a = 3
//   int b = (a + 3) / 2; // b = 3
//   digitalWrite(26, HIGH);
//   delay(a * 1000); // delay 3 seconds
//   digitalWrite(26, LOW);
//   delay(b * 1000); // delay 3 seconds
// }

/* Basic */
// void codegen();
// void codegen()
// {
//   digitalWrite(26, HIGH);
//   delay(1000);
//   digitalWrite(26, 0);
//   delay(1000);
// }
