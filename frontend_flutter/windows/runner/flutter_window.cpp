#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(std::make_unique<flutter::DartProject>(project)),
      view_properties_(fml::RefPtr<FlutterWindowProperties>(
          new FlutterWindowProperties())) {}

FlutterWindow::~FlutterWindow() {}

void FlutterWindow::OnCreate() {
  if (!View()) {
    std::cerr << "view not found" << std::endl;
    return;
  }

  auto bounds = GetPhysicalWindowBounds();
  SetPhysicalWindowBounds(bounds);

  flutter::DartExecutor::CreateDartProject create_dart_project;
  create_dart_project.data_directory = project_->data_directory();
  create_dart_project.assets_path = project_->assets_path();
  create_dart_project.dart_entrypoint = project_->dart_entrypoint();
  create_dart_project.dart_entrypoint_args = project_->dart_entrypoint_args();

  engine_ = std::make_unique<flutter::FlutterEngine>(
      std::make_unique<flutter::DartProject>(project_->snapshot_path()),
      true);

  if (!engine_->Start()) {
    std::cerr << "Failed to start Flutter engine" << std::endl;
    return;
  }

  flutter_controller_ =
      std::make_unique<flutter::FlutterViewController>(bounds.width, bounds.height, engine_.get());
  
  if (!flutter_controller_->attached()) {
    std::cerr << "Failed to attach Flutter view" << std::endl;
    return;
  }

  RegisterPlugins(flutter_controller_->engine());

  SetChildContent(flutter_controller_->view());
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }
  if (engine_) {
    engine_ = nullptr;
  }
}
