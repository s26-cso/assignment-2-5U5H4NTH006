#include <stdio.h>
#include <string.h>
#include <dlfcn.h>

typedef int (*func)(int, int);

int main(void)
{
    char op[6];
    int a, b;

    while (scanf("%5s %d %d", op, &a, &b) == 3) {
        char libop[20] = "./lib";
        strcat(libop, op);
        strcat(libop, ".so");
        void* library = dlopen(libop, RTLD_NOW);
        func find = (func)dlsym(library, op);
        int ans = find(a, b);
        printf("%d\n", ans);
        dlclose(library);
    }
    return 0;
}
