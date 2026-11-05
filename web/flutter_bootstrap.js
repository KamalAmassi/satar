{{flutter_js}}
{{flutter_build_config}}

// Load CanvasKit from the app's own origin instead of the gstatic CDN.
// If the CDN is blocked/unreachable the engine fails to boot with
// "Non-error `null` thrown by JS" during font/renderer initialization.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});
