// tcp_udp_wasm.dart
import 'dart:async';
import 'dart:js';
import 'dart:js_util' as js_util;

class IpAnalyzerWasm {
  static dynamic _module;
  static Future<void>? _initFuture;

  /// Ensure the WASM module is initialized (only once).
  static Future<void> _ensureInitialized() {
    _initFuture ??= _init();
    return _initFuture!;
  }

  static Future<void> _init() async {
    // Try to find the module already loaded on window
    _module = js_util.getProperty(globalThis, 'IpAnalyzerModule');
    if (_module != null) return;

    // Try to create it manually if factory function exists
    final createFn = js_util.getProperty(globalThis, 'createIpAnalyzerModule');
    if (createFn != null) {
      final jsResult = js_util.callMethod(globalThis, 'createIpAnalyzerModule', []);
      try {
        _module = await js_util.promiseToFuture(jsResult);
      } catch (_) {
        _module = jsResult;
      }
      js_util.setProperty(globalThis, 'IpAnalyzerModule', _module);
      return;
    }

    // Fallback: short polling loop
    const int maxAttempts = 20;
    const Duration delay = Duration(milliseconds: 100);
    for (var i = 0; i < maxAttempts; ++i) {
      _module = js_util.getProperty(globalThis, 'IpAnalyzerModule');
      if (_module != null) return;
      await Future.delayed(delay);
    }

    throw Exception('WASM module not found. Make sure ip_analyzer.js is loaded.');
  }

  /// Analyze a TCP/UDP header given as hex string.
  static Future<String> analyze(String headerHex) async {
    await _ensureInitialized();
    if (_module == null) {
      throw Exception('WASM module not initialized.');
    }

    // Use Emscripten cwrap for automatic string marshalling.
    final cwrap = js_util.getProperty(_module, 'cwrap');
    if (cwrap == null) {
      throw Exception('cwrap not exported by WASM module.');
    }

    // Wrap the C function (no underscore — cwrap adds it internally)
    final jsWrapper = js_util.callMethod(
      _module,
      'cwrap',
      ['analyze_ip_cidr', 'number', ['string']],
    );

    // Call wrapper and get pointer
    final ptr = js_util.callMethod(jsWrapper, 'call', [null, headerHex]);

    // Decode pointer to string via UTF8ToString
    final utf8ToString = js_util.getProperty(_module, 'UTF8ToString');
    if (utf8ToString == null) {
      throw Exception('UTF8ToString not found in WASM module.');
    }

    final decoded = js_util.callMethod(_module, 'UTF8ToString', [ptr]);
    return decoded?.toString() ?? '';
  }
}

/// Helper to access globalThis safely in Dart/JS interop.
dynamic get globalThis {
  try {
    return js_util.globalThis;
  } catch (_) {
    return context; // Fallback for older Dart versions
  }
}
