import 'dart:js_interop';

@JS('track60CanInstall')
external bool _jsCanInstall();

@JS('track60PromptInstall')
external JSPromise<JSBoolean> _jsPromptInstall();

class PwaInstallHelper {
  static bool canInstallDirectly() {
    try {
      return _jsCanInstall();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> promptInstall() async {
    try {
      final res = await _jsPromptInstall().toDart;
      return res.toDart;
    } catch (_) {
      return false;
    }
  }
}

