#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

typedef struct {
  int numerator;
  int denominator;
} fraction;

static int greatest_common_divisor(int a, int b)
{
  int l, s;
  int mod;

  if (a > b) { l = a; s = b; }
  else       { l = b; s = a; }

  mod = l % s;
  if (mod == 0) return s;

  return greatest_common_divisor(mod, s);
}

static int least_common_multiple(int a, int b)
{
  int i;
  int gcd = greatest_common_divisor(a, b);

  if (gcd == 1) return a * b;

  return a * b / gcd;
}

static void print_fraction(fraction *f)
{
  printf("fraction => %d / %d\n", f->numerator, f->denominator);
}

static void add_fraction(fraction *a, fraction *b, fraction *result)
{
  int lcm_denominator = 
    least_common_multiple(a->denominator, b->denominator);
  int gcd, a_num, b_num;
  fraction ret;

  ret.denominator = lcm_denominator;
  ret.numerator = (lcm_denominator / a->denominator * a->numerator) + 
                  (lcm_denominator / b->denominator * b->numerator);

  gcd = greatest_common_divisor(ret.denominator, ret.numerator);
  if (gcd != 1) {
    ret.denominator /= gcd;
    ret.numerator /= gcd;
  }

  *result = ret;
}

static int compare_fraction(fraction *a, fraction *b)
{
  int lcm_denominator = 
    least_common_multiple(a->denominator, b->denominator);

  return (lcm_denominator / a->denominator * a->numerator) -
         (lcm_denominator / b->denominator * b->numerator);
}

#define MAX_NUM 7
static int process(int p, int q, int a, int n, int fnum, fraction fs[])
{
  int i, count_h, count_v, denomi_multi;
  fraction exp = { .numerator = p, .denominator = q }, acc;
  fraction fs_h[MAX_NUM], fs_v[MAX_NUM];

  denomi_multi = 1;
  for (i = 0; i < fnum; i++) {
    denomi_multi *= fs[i].denominator;
    if (denomi_multi > a) return 0;
  }

  for (i = 0; i < fnum; i++) {
    if (i == 0) acc = fs[i];
    else add_fraction(&acc, &fs[i], &acc);
  }

  memcpy(&fs_h, fs, sizeof(fs_h));
  fs_h[fnum - 1].denominator++;
  count_h = process(p, q, a, n, fnum, fs_h);

  count_v = 0;
  if (fnum < n && compare_fraction(&exp, &acc) > 0) {
    memcpy(&fs_v, fs, sizeof(fs_v));
    memcpy(&fs_v[fnum], &fs_v[fnum - 1], sizeof(fraction));
    count_v = process(p, q, a, n, fnum + 1, fs_v);
  }
  /*
printf("fs are >>> ");
for (i = 0; i < fnum; i++) printf("%d ", fs[i].denominator);
printf("\n");
// printf("exp: "); print_fraction(&exp);
// printf("acc: "); print_fraction(&acc);
// if (compare_fraction(&exp, &acc) == 0) printf("<<< matched >>>\n");
*/

  return (compare_fraction(&exp, &acc) == 0 ?  1 : 0) + count_h + count_v;
}

int main()
{
#if 0
  {
    assert(greatest_common_divisor(10, 5) == 5);
    assert(greatest_common_divisor(20, 15) == 5);
    assert(greatest_common_divisor(15, 20) == 5);
    assert(least_common_multiple(10, 5) == 10);
    assert(least_common_multiple(12, 5) == 60);
    assert(least_common_multiple(5, 12) == 60);
  }

  {
    fraction a = { .numerator = 5, .denominator = 12 }; // 25/60
    fraction b = { .numerator = 3, .denominator = 10 }; // 18/60
    fraction result;

    add_fraction(&a, &b, &result);
    assert(result.denominator == 60);
    assert(result.numerator == 43);

    assert(compare_fraction(&a, &b) > 0);
    assert(compare_fraction(&b, &a) < 0);
  }

  {
    fraction a = { .numerator = 1, .denominator = 2 }; // 3/6
    fraction b = { .numerator = 1, .denominator = 6 }; // 1/6
    fraction result;

    add_fraction(&a, &b, &result);
    assert(result.denominator == 3);
    assert(result.numerator == 2);
  }

  {
    fraction f = { .numerator = 1, .denominator = 2 };
    fraction fs[MAX_NUM] = { f };
    assert(process(2, 3, 120, 3, 1, fs) == 4);
  }
#endif

  int p, q, a, n;
  char buf[256];
  fraction f = { .numerator = 1, .denominator = 1 };
  fraction fs[MAX_NUM] = { f };

  while (1) {
    scanf("%d %d %d %d", &p, &q, &a, &n);
    if (p == 0 && q == 0 && a == 0 && n == 0) break;
    printf("%d\n", process(p, q, a, n, 1, fs));
  }

  return 0;
}
