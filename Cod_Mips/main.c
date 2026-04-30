#include <stdio.h>

int main(void) {

    int n = 15;
    int s = 0;
    int i = 1;

    while (i <= n) {

        int rest = n;
        while (rest >= i) {
            rest = rest - i;
        }

        if (rest == 0) {
            s = s + i;
        }

        i = i + 1;
    }

    printf("%d\n", s);

    return 0;
}