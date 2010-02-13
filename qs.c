#include <stdio.h>

#define SWAP(a, b) { \
  int tmp; \
  tmp = a; a = b; b = tmp; \
}

static int avg(int elms[], int left, int right)
{
  int i, sum = 0;

  for (i = left; i <= right; i++)
    sum += elms[i];

  return (sum / (right - left + 1));
}

static void print_list(int elms[], int left, int right)
{
  int i;
  for (i = left; i <= right; i++)
    printf("%d ", elms[i]);

  printf("\n");
}

static void qs(int elms[], int left, int right)
{
  int l, r;
  int pivot = avg(elms, left, right);

  for (l = left, r = right; l < r; l++, r--) {
    for (; elms[l] < pivot; l++);
    for (; elms[r] > pivot; r--);

    if (r < l) break;

    SWAP(elms[l], elms[r]);
  }

  if (left < l - 1)
    qs(elms, left, l - 1);

  if (l < right)
    qs(elms, l, right);
}

int main(void)
{
  int len;
  int elms[] = { 7, 2, 5, 9, 6, 1, 3, 8, 4 };

  len = sizeof(elms) / sizeof(elms[0]);

  qs(elms, 0, len - 1);

  print_list(elms, 0, len - 1);

  return 0;
}

