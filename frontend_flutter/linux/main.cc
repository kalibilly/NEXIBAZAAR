#include <gtk/gtk.h>
#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugins.h"

static void* on_exit(gpointer user_data) {
  gtk_main_quit();
  return nullptr;
}

int main(int argc, char* argv[]) {
  gtk_init(&argc, &argv);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, fl_get_command_line_args(&argc, &argv, nullptr));

  g_autoptr(FlApplication) app = fl_application_new(project);
  g_autoptr(GError) error = nullptr;
  if (!fl_application_start(app, &error)) {
    g_warning("Failed to start application: %s", error->message);
    g_error_free(error);
    return EXIT_FAILURE;
  }

  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_engine_get_binary_messenger(fl_application_get_engine(app)),
                            "com.nexibazaar.nexi_bazaar/native",
                            FL_METHOD_CODEC_METHOD_CALL_FORMAT);

  g_signal_connect(app, "startup", G_CALLBACK(on_exit), nullptr);

  int result = g_application_run(G_APPLICATION(app), argc, argv);

  return result;
}
