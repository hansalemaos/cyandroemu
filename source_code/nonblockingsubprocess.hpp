#ifndef SHELL_PROCESS_MANAGER_H
#define SHELL_PROCESS_MANAGER_H
#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <istream>
#include <mutex>
#include <ostream>
#include <stdio.h>
#include <string>
#include <thread>
#include <vector>

#include <fcntl.h>
#include <pthread.h>

#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/wait.h>
#include <unistd.h>

static const char *On_IRed{"\033[0;101m"}; // Red
static const char *Color_Off{"\033[0m"};   // Text Reset
static const char *IYellow{"\033[0;93m"};  // Yellow

static bool isspace_or_empty(std::string &str)
{
    if (str.size() == 0)
    {
        return true;
    }
    for (size_t i{}; i < str.size(); i++)
    {
        if (!::isspace(str[i]))
        {
            return false;
        }
    }
    return true;
}

static void print_red(std::string &msg)
{
    if (isspace_or_empty(msg))
    {
        return;
    }
    puts(On_IRed);
    puts(msg.c_str());
    puts(Color_Off);
}
static void print_yellow(std::string &msg)
{
    if (isspace_or_empty(msg))
    {
        return;
    }
    fputs(IYellow, stderr);
    fputs(msg.c_str(), stderr);
    fputs(Color_Off, stderr);
}

void sleepcp(int milliseconds);

void sleepcp(int milliseconds)
{
#ifdef _WIN32
    Sleep(milliseconds);
#else
    usleep(milliseconds * 1000);
#endif // _WIN32
}
void sleepcp(int milliseconds);

class ShellProcessManager
{
  public:
    ShellProcessManager(std::string shell_command, size_t buffer_size = 4096, size_t stdout_max_len = 4096,
                        size_t stderr_max_len = 4096, std::string exit_command = "exit", int print_stdout = 1,
                        int print_stderr = 1)
        : continue_reading_stdout(true), continue_reading_stderr(true), shell_command(shell_command),
          buffer_size(buffer_size), stdout_max_len(stdout_max_len), stderr_max_len(stderr_max_len),
          exit_command(exit_command), print_stdout((bool)print_stdout), print_stderr((bool)print_stderr)
    {
    }

    ~ShellProcessManager()
    {
        stop_shell();
    }

    bool start_shell()
    {
        pipe(pip0);
        pipe(pip1);
        pipe(pip2);
        PID = fork();
        if (PID < 0)
        {
            throw std::runtime_error("Failed to fork process");
        }
        if (PID == 0)
        {
            child_process();
        }
        else
        {
            parent_process();
        }
        return true;
    }

    void stdin_write(std::string command)
    {
        std::string mycommand = command + "\n";
        fputs(mycommand.c_str(), pXFile);
        fflush(pXFile);
    }

    std::string get_stdout()
    {
        std::string results;
        results.reserve(4096);
        my_mutex_lock.lock();
        if (!strmap_out.empty())
        {
            try
            {
                for (auto &pair : strmap_out)
                {
                    results.append(pair);
                }
                strmap_out.clear();
            }
            catch (...)
            {
            }
        }
        my_mutex_lock.unlock();
        return results;
    }
    std::string get_stderr()
    {
        std::string results;
        results.reserve(4096);
        my_mutex_lock.lock();
        if (!strmap_out.empty())
        {
            try
            {
                for (auto &pair : strmap_err)
                {
                    results.append(pair);
                }
                strmap_err.clear();
            }
            catch (...)
            {
            }
        }
        my_mutex_lock.unlock();
        return results;
    }

    void clear_stdout()
    {
        my_mutex_lock.lock();
        try
        {
            if (!strmap_out.empty())
            {
                strmap_out.clear();
            }
        }
        catch (...)
        {
        }
        my_mutex_lock.unlock();
    }
    void clear_stderr()
    {
        my_mutex_lock.lock();
        try
        {
            if (!strmap_err.empty())
            {
                strmap_err.clear();
            }
        }
        catch (...)
        {
        }
        my_mutex_lock.unlock();
    }

    bool continue_reading_stdout;
    bool continue_reading_stderr;

  private:
    std::string shell_command;
    int pip0[2], pip1[2], pip2[2];
    int FDChildStdin, FDChildStdout, FDChildStderr;
    pid_t PID;
    FILE *pXFile;
    std::vector<std::string> strmap_out;
    std::vector<std::string> strmap_err;
    std::thread t1;
    std::thread t2;
    size_t buffer_size;
    size_t stdout_max_len;
    size_t stderr_max_len;
    std::string exit_command;
    std::mutex my_mutex_lock;
    bool print_stdout;
    bool print_stderr;

    void child_process()
    {
        close(pip0[1]);
        close(pip1[0]);
        close(pip2[0]);
        dup2(pip2[1], 2);
        dup2(pip1[1], 1);
        dup2(pip0[0], 0);
        close(pip0[0]);
        close(pip1[1]);
        close(pip2[1]);
        char *argv[1] = {};
        char *envp[1] = {};
        execve(shell_command.c_str(), argv, envp);
        exit(-1);
    }

    void parent_process()
    {
        FDChildStdin = pip0[1];
        FDChildStdout = pip1[0];
        FDChildStderr = pip2[0];
        pXFile = fdopen(FDChildStdin, "w");

        t1 = std::thread(&ShellProcessManager::read_from_stdout, this);
        t2 = std::thread(&ShellProcessManager::read_from_stderr, this);
    }

    void read_from_stdout()
    {
        std::vector<char> buff;
        buff.resize(buffer_size);
        while (continue_reading_stdout)
        {
            int iret = read(FDChildStdout, buff.data(), buffer_size);
            if (!continue_reading_stdout)
            {
                break;
            }
            if (iret == 0)
            {
                continue;
            }
            strmap_out.emplace_back(std::string{buff.begin(), buff.begin() + iret});
            if (print_stdout)
            {
                print_yellow(strmap_out.back());
            }
            if (strmap_out.size() >= stdout_max_len)
            {
                strmap_out.erase(strmap_out.begin());
            }
            buff.clear();
            buff.resize(buffer_size);
        }
    }

    void read_from_stderr()
    {
        std::vector<char> bufferr;
        bufferr.resize(buffer_size);
        while (continue_reading_stderr)
        {
            int iret = read(FDChildStderr, bufferr.data(), buffer_size);
            if (!continue_reading_stderr)
            {
                break;
            }
            if (iret == 0)
            {
                continue;
            }
            strmap_err.emplace_back(std::string{bufferr.begin(), bufferr.begin() + iret});
            if (print_stderr)
            {
                print_red(strmap_err.back());
            }
            if (strmap_err.size() >= stderr_max_len)
            {
                strmap_err.erase(strmap_err.begin());
            }
            bufferr.clear();
            bufferr.resize(buffer_size);
        }
    }

  public:
    void stop_shell()
    {
        if (!continue_reading_stdout && !continue_reading_stderr)
        {
            return;
        }
        continue_reading_stdout = false;
        continue_reading_stderr = false;
        stdin_write(">&2 echo done stderr\n");
        stdin_write("echo done stdout\n");
        stdin_write(exit_command);
        stdin_write(exit_command);
        stdin_write(exit_command);
        stdin_write(exit_command);
        stdin_write(exit_command);
        fclose(pXFile);
        close(FDChildStdin);
        close(FDChildStdout);
        close(FDChildStderr);
        // pthread_cancel(t1.native_handle());
        // pthread_cancel(t2.native_handle());
        try
        {
            if (t1.joinable())
            {
                t1.join();
            }
        }
        catch (...)
        {
        }
        try
        {
            if (t2.joinable())
            {
                t2.join();
            }
        }
        catch (...)
        {
        };
    }
};
#endif // SHELL_PROCESS_MANAGER_H
