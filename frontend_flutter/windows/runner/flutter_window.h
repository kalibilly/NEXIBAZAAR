#ifndef FLUTTER_WINDOW_H_
#define FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>
#include <vector>

// A window that does nothing special and is intended for fluent.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow driven by the |project|,
  // hosting a Flutter view running |dart_entrypoint| in |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  void OnCreate() override;
  void OnDestroy() override;

 private:
  std::unique_ptr<flutter::FlutterEngine> engine_;
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // FLUTTER_WINDOW_H_
