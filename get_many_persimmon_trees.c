#include <stdio.h>
#include <assert.h>

#define MAX_LEN 100
#define MAX_PT 500

static int process(int pt_len, char pt[][2],
                   int max_width, int max_height, int width, int height)
{
  int ipt, ix, iy;
  int count, result = 0;

// printf("mw(%d) mh(%d) w(%d) h(%d) \n", max_width, max_height, width, height);
  for (iy = 1; iy <= max_height - height + 1; iy++) {
    for (ix = 1; ix <= max_width - width + 1; ix++) {
// printf("================================================== \n");
      for (ipt = 0, count = 0; ipt < pt_len; ipt++) {
        int pt_x = pt[ipt][0];
        int pt_y = pt[ipt][1];
        if (pt_y >= iy && pt_y <= iy + height - 1 &&  
            pt_x >= ix && pt_x <= ix + width - 1) {
// printf("iy(%d), ix(%d), ipt(%d), pt_y(%d), pt_x(%d)#1 \n", iy, ix, ipt, pt_y, pt_x);
          count++;
// printf("bingo! %d\n", count);
        }
      }
      if (count > result) result = count;
    }
  }

  return result;
}

int main()
{
  /*
   123456
  1 *  **
  2 *
  3*   *
  4 *  *
  5   **

  char pt[MAX_PT][2] = {
    {1, 2}, {1, 5}, {1, 6}, {2, 2}, {3, 1}, {3, 5},
    {4, 2}, {4, 5}, {5, 4}, {5, 5}
  };
  assert(process(10, pt, 6, 5, 2, 3) == 4);

  char pt[MAX_PT][2] = {
    {1, 2},
    {2, 1},
    {2, 4},
    {3, 4},
    {4, 2},
    {5, 3},
    {6, 1},
    {6, 2},
  };
  assert(process(8, pt, 6, 4, 3, 2) == 3);
  */

  char pt[MAX_PT][2];
  char buf[256];
  int i, pt_num, max_width, max_height, pt_x, pt_y, width, height;

  while (1) {
#define READLINE() {if (fgets(buf, sizeof(buf), stdin) == NULL) break;}
    READLINE();
    sscanf(buf, "%d", &pt_num);
    if (pt_num == 0) break;
    READLINE();
    sscanf(buf, "%d %d", &max_width, &max_height);
    for (i = 0; i < pt_num; i++) {
      READLINE();
      sscanf(buf, "%d %d", &pt_x, &pt_y);
      pt[i][0] = pt_x;
      pt[i][1] = pt_y;
    }
    READLINE();
    sscanf(buf, "%d %d", &width, &height);

    printf("%d\n", process(pt_num, pt, max_width, max_height, width, height));
  }

  return 0;
}
