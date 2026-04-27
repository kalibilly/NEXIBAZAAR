#ifndef RUNNER_MAIN_H_
#define RUNNER_MAIN_H_

#include <vector>
#include <string>

// Creates and attaches a console to the current process if it is not already
// attached. If a console is already attached, does nothing.
void CreateAndAttachConsole();

// Takes the list of command line arguments, and returns a vector of UTF-8
// encoded arguments suitable for passing to the Flutter Engine.
std::vector<std::string> GetCommandLineArguments();

#endif  // RUNNER_MAIN_H_
