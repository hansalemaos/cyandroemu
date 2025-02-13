#ifndef TAKESCREENSHOT_HPP
#define TAKESCREENSHOT_HPP

#define _CRT_SECURE_NO_WARNINGS
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <iostream>
#include <string>
#include <unistd.h>
#include <vector>
std::vector<uint8_t> convert_screencap_c(std::string &cmd, int width, int height)
{
    std::vector<uint8_t> image_vector;
    FILE *f = popen(cmd.c_str(), "r");
    if (!f)
    {
        std::cerr << "Error opening pipe" << std::endl;
        return image_vector;
    }
    size_t size_my_buffer = (size_t)width * height * 4 + 17;
    image_vector.reserve((size_t)width * height * 3 + 16);
    char *buffer{new char[size_my_buffer]};
    fread(buffer, size_my_buffer, 1, f);
    for (size_t j{}; j < size_my_buffer - 1; j++)
    {
        if (((j + 1) % 4 == 0) || (j < 16))
        {
            continue;
        }
        image_vector.emplace_back((uint8_t)buffer[j]);
    }
    pclose(f);
    delete[] buffer;
    return image_vector;
}
#endif
