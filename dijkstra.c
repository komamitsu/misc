#include <stdio.h>

#define MAX_BRANCH 10
typedef struct {
  char id;
  char next_ids[MAX_BRANCH];
  int next_costs[MAX_BRANCH];
  int cost;
  char from;
} route;

route routes[] = {
  { 'S', {'A', 'B', 'C'}, {5, 4, 2}, 0 },
  { 'A', {'B', 'G'}, {2, 6}, -1 },
  { 'B', {'C', 'D'}, {3, 2}, -1 },
  { 'C', {'B', 'D'}, {3, 6}, -1 },
  { 'D', {'G'}, {4}, -1 },
  { 'G', {}, {}, -1 }
};

const int routes_len = sizeof(routes) / sizeof(routes[0]);

static route *find_route(char id)
{
  int i;
  for (i = 0; i < routes_len; i++) {
    if (routes[i].id == id) return &routes[i];
  }
  return NULL;
}

int main()
{
  int i, j;
  char from, to;
  route *next_route;

  while (1) {
    for (i = 0; i < routes_len; i++) {
      if (routes[i].cost >= 0) {
        for (j = 0; j < sizeof(routes[i].next_ids) / 
                        sizeof(routes[i].next_ids[0]); j++) {

          if (!routes[i].next_ids[j]) break;

          next_route = find_route(routes[i].next_ids[j]);

          if (routes[i].cost + routes[i].next_costs[j] < next_route->cost ||
              next_route->cost < 0) {
            next_route->cost = routes[i].cost + routes[i].next_costs[j];
            next_route->from = routes[i].id;
          }
        }
      }
    }

    for (i = 0; i < routes_len; i++) {
      if (routes[i].cost < 0) break;
    }
    if (i >= routes_len) break;
  }

  for (i = 0; i < routes_len; i++) {
    printf("id(%c) from(%c) cost(%d)\n", routes[i].id, routes[i].from, routes[i].cost);
  }

  return 0;
}

