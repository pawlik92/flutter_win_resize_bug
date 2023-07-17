import 'dart:ffi';
import 'dart:ui';

import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

class WinApiHelper {
  static int? _hwnd;

  static setBounds(Rect bounds) {
    final hwnd = _getMainWindowHwnd();
    if (hwnd == null) {
      print('HWND is null');
      return;
    }

    var flags = _getFlags();
    SetWindowPos(
      hwnd,
      0,
      bounds.left.toInt(),
      bounds.top.toInt(),
      bounds.width.toInt(),
      bounds.height.toInt(),
      flags,
    );
  }

  static Rect getBounds() {
    final hwnd = _getMainWindowHwnd();
    if (hwnd == null) {
      print('HWND is null');
      return Rect.zero;
    }

    final winRect = calloc<RECT>();
    GetWindowRect(hwnd, winRect);

    double x = winRect.ref.left.toDouble();
    double y = winRect.ref.top.toDouble();
    double width = (winRect.ref.right - winRect.ref.left).toDouble();
    double height = (winRect.ref.bottom - winRect.ref.top).toDouble();

    free(winRect);

    return Rect.fromLTWH(x, y, width, height);
  }

  static int _getFlags() {
    return SWP_NOZORDER | SWP_NOACTIVATE | SWP_NOOWNERZORDER;
  }

  static int? _getMainWindowHwnd() {
    if (_hwnd == null) {
      final wndProc =
          Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
      EnumWindows(wndProc, 0);
    }

    return _hwnd;
  }

  static int _enumWindowsProc(int hWnd, int lParam) {
    var currentProcId = GetCurrentProcessId();

    final pId = calloc<Uint32>();
    GetWindowThreadProcessId(hWnd, pId);
    int windowPID = pId.value;
    free(pId);

    if (windowPID == currentProcId) {
      _hwnd = hWnd;
      return FALSE;
    }

    return TRUE;
  }
}
