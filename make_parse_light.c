#include <stdio.h>
#include <assert.h>

#define MAX_COIN 20

typedef struct {
  int y10;
  int y50;
  int y100;
  int y500;
} coins;

static void print_coins(coins *c)
{
  printf("coins y500(%d) y100(%d) y50(%d) y10(%d)\n", c->y500, c->y100, c->y50, c->y10);
}

static int total(coins *payment)
{
  return (
    payment->y500 * 500 + payment->y100 * 100 +
    payment->y50 * 50 + payment->y10 * 10
  );
}

static int total_weight(coins *payment)
{
  return (
    payment->y500 + payment->y100 + payment->y50 + payment->y10
  );
}

static void exchange(int price, coins *change)
{
  change->y500 = price / 500;
  price %= 500;
  change->y100 = price / 100;
  price %= 100;
  change->y50 = price / 50;
  price %= 50;
  change->y10 = price / 10;
  price %= 10;
}

static int pay(int price, coins *saving, coins *payment)
{
  coins change;
  int total_pay = total(payment);

  if (total_pay < price) return -1;

  exchange(total_pay - price, &change);

  saving->y500 -= payment->y500 - change.y500;
  saving->y100 -= payment->y100 - change.y100;
  saving->y50 -= payment->y50 - change.y50;
  saving->y10 -= payment->y10 - change.y10;

  return 0;
}

static int calc(coins *saving, int price, coins *payment)
{
  int total;
  int i500, i100, i50, i10;
  coins payment_work, saving_work, record = 
    { MAX_COIN, MAX_COIN, MAX_COIN, MAX_COIN };

  for (i500 = 0; i500 <= saving->y500; i500++) {
    for (i100 = 0; i100 <= saving->y100; i100++) {
      for (i50 = 0; i50 <= saving->y50; i50++) {
        for (i10 = 0; i10 <= saving->y10; i10++) {
          payment_work.y500 = i500;
          payment_work.y100 = i100;
          payment_work.y50 = i50;
          payment_work.y10 = i10;
          saving_work = *saving;
          if (!pay(price, &saving_work, &payment_work)) {
            if (total_weight(&record) > 
                total_weight(&saving_work)) {
              *payment = payment_work;
              record = saving_work;
            }
          }
        }
      }
    }
  }

  return 0;
}

int main()
{
  coins saving, payment;

  saving.y500 = 0;
  saving.y100 = 2;
  saving.y50 = 1;
  saving.y10 = 1;
  calc(&saving, 160, &payment);
  assert(payment.y10 == 1);
  assert(payment.y50 == 1);
  assert(payment.y100 == 1);
  assert(payment.y500 == 0);

  saving.y500 = 4;
  saving.y100 = 3;
  saving.y50 = 2;
  saving.y10 = 1;
  assert(total(&saving) == 2410);

  exchange(2380, &saving);
  assert(saving.y500 == 4);
  assert(saving.y100 == 3);
  assert(saving.y50 == 1);
  assert(saving.y10 == 3);

  payment.y500 = 1;
  payment.y100 = 0;
  payment.y50 = 0;
  payment.y10 = 0;
  assert(pay(490, &saving, &payment) == 0);
  assert(saving.y500 == 3);
  assert(saving.y100 == 3);
  assert(saving.y50 == 1);
  assert(saving.y10 == 4);

  return 0;
}
