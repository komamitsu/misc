#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    char buf[4096];
    int table[100];
    char *token, *saveptr;

    while (1) {
        int i;
        int member, qurorum;
        int record_day = 0, record = -1;

        /* header */
        if (fgets(buf, sizeof(buf), stdin) == NULL) break;
        sscanf(buf, "%d %d", &member, &qurorum);

        if (!member && !qurorum) break;

        memset(table, 0, sizeof(table));

        /* body */
        for (i = 0; i < member; i++) {
            int j;
            int conv_days;

            if (fgets(buf, sizeof(buf), stdin) == NULL) break;

            token = strtok_r(buf, " ", &saveptr);
            conv_days = atoi(token);

            for (j = 0; j < conv_days; j++) {
                int conv_day;

                token = strtok_r(NULL, " ", &saveptr);
                conv_day = atoi(token);

                table[conv_day]++;
            }
        }

        for (i = 0; i < sizeof(table) / sizeof(table[0]); i++) {
            if (table[i] >= qurorum && table[i] > record) {
                record = table[i];
                record_day = i;
            }
        }
        printf("%d\n", record_day);
    }

    return 0;
}
