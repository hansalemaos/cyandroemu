#ifndef STRIPSTRING_HPP
#define STRIPSTRING_HPP

#include <string>

void lstrip_spaces_inplace(std::string &s)
{
    if (s.size() == 0)
    {
        return;
    }
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) { return !std::isspace(ch); }));
}

void rstrip_spaces_inplace(std::string &s)
{
    if (s.size() == 0)
    {
        return;
    }
    s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch) { return !std::isspace(ch); }).base(), s.end());
}
void strip_spaces_inplace(std::string &s)
{
    if (s.size() == 0)
    {
        return;
    }
    lstrip_spaces_inplace(s);
    rstrip_spaces_inplace(s);
}

void lstrip_charset_inplace(std::string &s, std::string &char_set)
{
    if (s.size() == 0 || char_set.size() == 0)
    {
        return;
    }
    size_t newsize{};
    size_t oldsize = s.size();
    while (newsize < oldsize)
    {
        newsize = s.size();
        oldsize = newsize;
        for (auto c : char_set)
        {
            s.erase(s.begin(), std::find_if(s.begin(), s.end(), [c = c](char ch) { return ch != c; }));
        }
        newsize = s.size();
    }
}
void rstrip_charset_inplace(std::string &s, std::string &char_set)
{
    if (s.size() == 0 || char_set.size() == 0)
    {
        return;
    }
    size_t newsize{};
    size_t oldsize = s.size();
    while (newsize < oldsize)
    {
        newsize = s.size();
        oldsize = newsize;
        for (auto c : char_set)
        {
            s.erase(std::find_if(s.rbegin(), s.rend(), [c = c](char ch) { return ch != c; }).base(), s.end());
        }
        newsize = s.size();
    }
}
void strip_charset_inplace(std::string &s, std::string &char_set)
{
    if (s.size() == 0 || char_set.size() == 0)
    {
        return;
    }
    lstrip_charset_inplace(s, char_set);
    rstrip_charset_inplace(s, char_set);
}

#endif
