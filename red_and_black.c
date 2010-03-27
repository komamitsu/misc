#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define MAX_LEN 20

#define RECURSIVE 0

#if RECURSIVE

static void walk(char room[MAX_LEN][MAX_LEN], int w, int h, int x, int y, int *count)
{
    room[y][x] = ' ';
    (*count)++;
    if (x > 0 && room[y][x - 1] == '.')     walk(room, w, h, x - 1, y, count);
    if (x < w - 1 && room[y][x + 1] == '.') walk(room, w, h, x + 1, y, count);
    if (y > 0 && room[y - 1][x] == '.')     walk(room, w, h, x, y - 1, count);
    if (y < h - 1 && room[y + 1][x] == '.') walk(room, w, h, x, y + 1, count);
}

#else

#define MAX_Q 100
typedef struct {
    int i;
    int q[MAX_Q][2];
} queue_t;

static void print_queue(queue_t *q)
{
    int i;

    for (i = 0; i < q->i; i++) {
        printf("%02d: x(%d), y(%d)\n", i, q->q[i][0], q->q[i][1]);
    }
}

static void queue_init(queue_t *q)
{
    q->i = 0;
}

static void queue(queue_t *q, int x, int y)
{
    int tmp[2];

    if (q->i >= MAX_Q - 1) abort();
    tmp[0] = x; tmp[1] = y;
    memcpy(q->q[q->i], tmp, sizeof(tmp));
    (q->i)++;
}

static void dequeue(queue_t *q, int *x, int *y)
{
    if (q->i <= 0) { *x = -1; *y = -1; return; }
    *x = q->q[0][0]; *y = q->q[0][1];
    memmove(q->q[0], q->q[1], sizeof(q->q[0]) * (q->i - 1));
    (q->i)--;
}

static void walk(char room[MAX_LEN][MAX_LEN], int w, int h, int x, int y, int *count)
{
    queue_t q;
    queue_init(&q);

#define RESERVE(x, y) { \
    room[y][x] = ' '; \
    queue(&q, x, y); \
}
    while (1) {
        room[y][x] = ' ';
        (*count)++;

        if (x > 0 && room[y][x - 1] == '.')     RESERVE(x - 1, y);
        if (x < w - 1 && room[y][x + 1] == '.') RESERVE(x + 1, y);
        if (y > 0 && room[y - 1][x] == '.')     RESERVE(x, y - 1);
        if (y < h - 1 && room[y + 1][x] == '.') RESERVE(x, y + 1);

        dequeue(&q, &x, &y);
        if (x == -1 && y == -1) break;
    }
}
#endif

int main()
{
    char buf[256];
    char room[MAX_LEN][MAX_LEN];

#define RL() { if (fgets(buf, sizeof(buf), stdin) == NULL) break; }
    while (1) {
        int i;
        int count = 0;
        int w, h, x, y;

        RL();
        sscanf(buf, "%d %d", &w, &h);
        if (w == 0 && h == 0) break;

        for (i = 0; i < h; i++) {
            char *p;

            RL();
            strncpy(room[i], buf, sizeof(room[i]));
            if ((p = strchr(buf, '@')) != NULL) {
                y = i;
                x = p - buf;
            }
        }
        walk(room, w, h, x, y, &count);
        printf("%d\n", count);
    }

    /*
    int x, y;
    queue_t q;
    queue_init(&q);

    queue(&q, 1, 2);
    queue(&q, 3, 4);
    queue(&q, 5, 6);

    dequeue(&q, &x, &y);
    assert(x == 1 && y == 2);
    dequeue(&q, &x, &y);
    assert(x == 3 && y == 4);
    dequeue(&q, &x, &y);
    assert(x == 5 && y == 6);
    dequeue(&q, &x, &y);
    assert(x == -1 && y == -1);
    */

    return 0;
}
