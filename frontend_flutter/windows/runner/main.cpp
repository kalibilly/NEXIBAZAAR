#include "main.h"

#include <flutter/dart_project.h>
#include <flutter/flutter_window.h>

#include <windows.h>

#include "flutter_window.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t* command_line, _In_ int show_command) {
  // Attach to console when present (e.g. 'flutter run') or create a
  // new console when running with 'flutter make-host-app' for Windows.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::GetLastError() == ERROR_GEN_FAILURE) {
    CreateAndAttachConsole();
  }

  // Initialize COM on the current thread.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"NexiBazaar", origin, size)) {
    return EXIT_FAILURE;
  }

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE* unused;
    if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
      _dup2(_fileno(stdout), 1);
    }
    if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
      _dup2(_fileno(stdout), 2);
    }
    std::ios::sync_with_stdio(false);

    FlutterWindow::Point cursor_pos(0, 0);
    ::GetCursorPos(reinterpret_cast<LPPOINT>(&cursor_pos));
    ::SetConsoleCursorPosition(::GetStdHandle(STD_OUTPUT_HANDLE),
                              {0, 0});
  }
}

std::vector<std::string> GetCommandLineArguments() {
  // Convert the UTF-16 command line to UTF-8 for the Engine to use.
  int argc = 0;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  std::vector<std::string> command_line_arguments;

  // Prepare the list of command line arguments.
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(fml::WideStringToUtf8(argv[i]));
  }
  ::LocalFree(argv);

  return command_line_arguments;
}
