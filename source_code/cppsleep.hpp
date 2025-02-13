#ifndef CPPSLEEP_HPP
#define CPPSLEEP_HPP
#define _CRT_SECURE_NO_WARNINGS
#include <unistd.h>
void sleep_milliseconds(int milliseconds)
{
    usleep(milliseconds * 1000);
}

void sleepfloat(double seconds)
{
    int milliseconds{(int)(seconds * 1000)};
    sleep_milliseconds(milliseconds);
}

#endif
