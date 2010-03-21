#include <stdio.h>
#include <math.h>

int main()
{
  int i;
  double num, x, x1;

  printf("please input a number: ");
  scanf("%lf", &num);

  x = 5;
  for (i = 0; i < 100; i++) {
    x1 = ((num - 1) * pow(x, 2.0) + num) / (num * x);
    if (x - x1 < 0.001) { break; }
    x = x1;
  }

  printf("ans. => %f\n", x1);

  return 0;
}
