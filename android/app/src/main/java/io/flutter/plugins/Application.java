package com.example.get_fit_native;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import com.tekartik.sqflite.SqflitePlugin;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
  @Override
  public void registerWith(PluginRegistry registry) {
    System.out.println("Application.java");
  }
}