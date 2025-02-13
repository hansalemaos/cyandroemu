#ifndef TIMEOUTSTUFF_HPP
#define TIMEOUTSTUFF_HPP
#define _CRT_SECURE_NO_WARNINGS

#include <cstdint>
#include <iostream>
#include <time.h>

int64_t get_current_timestamp()
{
    return time(NULL);
}

int64_t create_timeout(int64_t timeout)
{
    return time(NULL) + timeout;
}

int64_t is_timeout(int64_t timeout)
{
    return time(NULL) > timeout;
}

#endif
