#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

#define MAX_LEN 10000

static int is_prime(int n)
{
  int i;
  for (i = 2; i < n / 2; i++) if (n % i == 0) break;
  return i >= n / 2 ? 1 : 0;
}

static void sieve(int *list_len, int list[],
    int primes[], 
    int *primes_index /* on first call, should be set -1 */)
{
  int i;
  int work_index, work[MAX_LEN];

  for (i = 0; i < *list_len; i++) {
    if (is_prime(list[i])) {
      primes[++(*primes_index)] = list[i];
      break;
    }
  }
  assert(*primes_index >= 0);
 
  work_index = -1;
  for (i = 0; i < *list_len; i++)
    if (list[i] % primes[*primes_index] != 0) work[++work_index] = list[i];
  assert(work_index >= 0);

  *list_len = work_index + 1;
  memcpy(list, work, sizeof(work[0]) * *list_len);
  if (primes[*primes_index] > sqrt(work[work_index])) return;

  sieve(list_len, list, primes, primes_index);
}

int main()
{
  int i;
  int list[MAX_LEN];
  int list_len = MAX_LEN - 2;
  int primes[MAX_LEN];
  int primes_index = -1;

  for (i = 2; i < MAX_LEN; i++) list[i - 2] = i;

  sieve(&list_len, list, primes, &primes_index);

  for (i = 0; i <= primes_index; i++) {
    printf("%d ", primes[i]);
  }
  for (i = 0; i < list_len; i++) {
    printf("%d ", list[i]);
  }
  printf("\n");

  return 0;
}
