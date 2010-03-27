#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

static int is_same(int len_a, int a[][2], int len_b, int b[][2])
{
  int r, d, i;

  for (d = 0; d < 2; d++) {
    for (r = 0; r < 4; r++) {
      int di_x, di_y;

      for (i = 0; i < len_b; i++) {
        int ib;
        int bx, by;

        if (d == 0) ib = i;
        else        ib = len_b - 1 - i;

        switch (r) {
          case 0:
            bx =   b[ib][0]; by =   b[ib][1]; break;
          case 1:
            bx =   b[ib][1]; by = - b[ib][0]; break;
          case 2:
            bx = - b[ib][0]; by = - b[ib][1]; break;
          case 3:
            bx = - b[ib][1]; by =   b[ib][0]; break;
          default:
            abort();
        }

        if (i == 0) {
          di_x = bx - a[i][0];
          di_y = by - a[i][1];
        }
        else {
          if (bx - a[i][0] != di_x || by - a[i][1] != di_y) break;
        }
      }

      if (i >= len_b) return 1;
    }
  }

  return 0;
}

#define MAX_LINE 10
int main()
{
#if 0
  {
    /*
    4aa
    3a
    2a bbb
    1    b
    012345

    4aa
    3a b
    2a b
    1 bb
    012345

    4aa
    3a 
    2ab
    1 bbb
    012345
    */
    int a[10][2] = { {1, 2}, {1, 3}, {1, 4}, {2, 4} };
    // int b[10][2] = { {3, 2}, {4, 2}, {5, 2}, {5, 1} };
    // int b[10][2] = { {3, 3}, {3, 2}, {3, 1}, {2, 1} };
    // int b[10][2] = { {4, 1}, {3, 1}, {2, 1}, {2, 2} };

    // int b[10][2] = { {2, 4}, {1, 4}, {1, 3}, {1, 2} };
    // int b[10][2] = { {5, 1}, {5, 2}, {4, 2}, {3, 2} };
    // int b[10][2] = { {2, 1}, {3, 1}, {3, 2}, {3, 3} };
    int b[10][2] = { {2, 2}, {2, 1}, {3, 1}, {4, 1} };
    assert(is_same(4, a, 4, b) == 1);
  }
#endif

  int i, j, total, num_of_point;
  int orig[MAX_LINE][2], other[MAX_LINE][2];
  char buf[256];

#define RL() { if (fgets(buf, sizeof(buf), stdin) == NULL) break; }
  while (1) {
    RL(); sscanf(buf, "%d", &total);
    if (total == 0) break;

    RL(); sscanf(buf, "%d", &num_of_point);
    for (j = 0; j < num_of_point; j++) {
      RL(); sscanf(buf, "%d %d", &orig[j][0], &orig[j][1]);
    }

    for (i = 0; i < total; i++) {
      RL(); sscanf(buf, "%d", &num_of_point);

      for (j = 0; j < num_of_point; j++) {
        RL(); sscanf(buf, "%d %d", &other[j][0], &other[j][1]);
      }

      if (is_same(num_of_point, orig, num_of_point, other) == 1)
        printf("%d\n", i + 1);
    }
    printf("+++++\n");
  }

  return 0;
}

