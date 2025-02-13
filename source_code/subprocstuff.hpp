#ifndef SUBPROCSTUFF_HPP
#define SUBPROCSTUFF_HPP
#define _CRT_SECURE_NO_WARNINGS

#include <cstdio>
#include <iostream>
#include <string>
#ifdef _WIN32

#define EXEC_CMD(command, mode) _popen(command, mode)
#define CLOSE_CMD(pipe) _pclose(pipe)
#else
#include <unistd.h>
#define EXEC_CMD(command, mode) popen(command, mode)
#define CLOSE_CMD(pipe) pclose(pipe)
#endif
#include <cstdlib>
std::string execute_cmd_get_stdout(std::string &cmd2execute, size_t approx_size)
{
    static constexpr size_t buffersize{32};
    char buffer[buffersize]{};
    std::string s;
    s.reserve(approx_size);
    FILE *pipe = EXEC_CMD(cmd2execute.c_str(), "r");
    if (!pipe)
    {
        std::cerr << "ERROR: failed to execute command: " << cmd2execute << '\n';
        return s;
    }
    while (fgets(buffer, buffersize, pipe) != NULL)
    {
        for (size_t i{}; i < buffersize; i++)
        {
            if (buffer[i] == '\0')
            {
                continue;
            }
            s += buffer[i];
            buffer[i] = '\0';
        }
    }
    CLOSE_CMD(pipe);
    return s;
}
void os_system(std::string &command)
{
    system(command.c_str());
}

#endif
