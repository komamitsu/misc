#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

typedef struct {
  char from;
  char to;
  int cost;
  int selected;
} route;

route routes[] = {
  { 'S', 'A', 5, 0 },
  { 'S', 'B', 4, 0 },
  { 'S', 'C', 2, 0 },
  { 'A', 'B', 2, 0 },
  { 'A', 'G', 6, 0 },
  { 'B', 'C', 3, 0 },
  { 'B', 'D', 2, 0 },
  { 'C', 'B', 3, 0 },
  { 'C', 'D', 6, 0 },
  { 'D', 'G', 4, 0 }
};

typedef struct trace {
  char last_pos;
  struct trace *last_trace;
  route *route;
  int cost;
} trace;

trace traces[20] = {
  { 'S', NULL, NULL, 0 }
};

int main()
{
  int i, j;
  int tmp_cost;
  trace *trace_candidate;
  route *route_candidate;
  char last_pos;

  while (1) {
    trace_candidate = NULL;
    route_candidate = NULL;
    tmp_cost = 999999;

    for (i = 0; i < sizeof(traces) / sizeof(traces[0]); i++) {
      if (traces[i].last_pos) {
        for (j = 0; j < sizeof(routes) / sizeof(routes[0]); j++) {
          if (routes[j].selected) continue;
          if (traces[i].last_pos == routes[j].from &&
              traces[i].cost + routes[j].cost < tmp_cost) {
            trace_candidate = &traces[i];
            route_candidate = &routes[j];
            tmp_cost = traces[i].cost + routes[j].cost;
          }
        }
      }
    }

    for (i = 0; i < sizeof(traces) / sizeof(traces[0]); i++) {
      if (!traces[i].last_pos) {
        traces[i].last_pos = route_candidate->to;
        traces[i].last_trace = trace_candidate;
        traces[i].route = route_candidate;
        traces[i].cost = trace_candidate->cost + route_candidate->cost;
        route_candidate->selected = 1;
        break;
      }
    }
    if (route_candidate->to == 'G') break;
  }

  last_pos = 'G';
  while (1) {
    for (i = 0; i < sizeof(traces) / sizeof(traces[0]); i++) {
      if (traces[i].route && traces[i].route->to == last_pos) break;
    }
    printf("from: %c, to: %c\n", traces[i].route->from, traces[i].route->to);
    last_pos = traces[i].route->from;
    if (last_pos == 'S') break;
  }

  return 0;
}
