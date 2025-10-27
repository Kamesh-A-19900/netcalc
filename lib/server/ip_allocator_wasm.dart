// ip_allocator_wasm.dart
import 'dart:async';
import 'dart:js';
import 'dart:js_util' as js_util;


class IpAllocatorWasm {
  static dynamic _module;
  static Future<void>? _initFuture;

  /// ensure module is initialized
  static Future<void> _ensureInitialized() {
    _initFuture ??= _init();
    return _initFuture!;
  }

  static Future<void> _init() async {
    // try existing global instance
    _module = js_util.getProperty(globalThis, 'IpAllocatorModule') ??
              js_util.getProperty(globalThis, 'IpAllocator') ?? // fallback name
              js_util.getProperty(globalThis, 'createIpAllocatorModule'); // unlikely

    // if factory function exists, call it (createIpAllocatorModule)
    final createFn = js_util.getProperty(globalThis, 'createIpAllocatorModule');
    if (_module == null && createFn != null) {
      final jsResult = js_util.callMethod(globalThis, 'createIpAllocatorModule', []);
      try {
        _module = await js_util.promiseToFuture(jsResult);
      } catch (_) {
        // not a promise, maybe returned immediate module
        _module = jsResult;
      }
      js_util.setProperty(globalThis, 'IpAllocatorModule', _module);
    }

    // fallback: short polling
    if (_module == null) {
      const int attempts = 20;
      const Duration delay = Duration(milliseconds: 100);
      for (var i = 0; i < attempts; i++) {
        _module = js_util.getProperty(globalThis, 'IpAllocatorModule');
        if (_module != null) break;
        await Future.delayed(delay);
      }
    }

    if (_module == null) {
      throw Exception('WASM ip allocator module not found. Ensure ip_allocation.js is loaded.');
    }

    // sanity: ensure cwrap & UTF8ToString exist
    final cwrap = js_util.getProperty(_module, 'cwrap');
    final utf8 = js_util.getProperty(_module, 'UTF8ToString');
    if (cwrap == null || utf8 == null) {
      throw Exception('WASM module missing required runtime methods (cwrap/UTF8ToString).');
    }
  }

  /// Allocates IPs by calling allocate_ip_groups(cidr, jsonInput).
  /// Returns the JSON string produced by the C module.
  static Future<String> allocate(String cidr, String jsonInput) async {
    await _ensureInitialized();

    // build cwrap wrapper (no leading underscore in name)
    final jsWrapper = js_util.callMethod(
      _module,
      'cwrap',
      ['allocate_ip_groups', 'number', ['string', 'string']],
    );

    if (jsWrapper == null) {
      throw Exception('Failed to create cwrap wrapper for allocate_ip_groups.');
    }

    // call wrapper and get pointer (number)
    final ptr = js_util.callMethod(jsWrapper, 'call', [null, cidr, jsonInput]);

    if (ptr == null) {
      throw Exception('WASM allocation returned null pointer.');
    }

    // decode pointer to JS string
    final decoded = js_util.callMethod(_module, 'UTF8ToString', [ptr]);
    return decoded?.toString() ?? '';
  }
}

/// safe globalThis accessor
dynamic get globalThis {
  try {
    return js_util.globalThis;
  } catch (_) {
    return context;
  }
}
