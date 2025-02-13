#ifndef SPLIT_STRING_H
#define SPLIT_STRING_H
#define _CRT_SECURE_NO_WARNINGS

#include <algorithm>
#include <ranges>
#include <string>
#include <vector>

std::vector<std::string> split_string(std::string &s, std::string &splitat)
{
    std::vector<std::string> result;
    auto strs{s | std::views::split(splitat)};
    size_t reserve_size{1};
    for (const auto &ref : strs)
    {
        reserve_size += ref.size();
    }
    result.reserve(reserve_size);
    for (const auto &ref : strs)
    {
        result.emplace_back(std::string{ref.begin(), ref.end()});
    }
    return result;
}
#endif
