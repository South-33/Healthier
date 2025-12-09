import 'package:flutter/foundation.dart';

/// Manages guest mode state for the application
class GuestModeManager extends ChangeNotifier {
  static final GuestModeManager _instance = GuestModeManager._internal();
  
  factory GuestModeManager() {
    return _instance;
  }
  
  GuestModeManager._internal();
  
  bool _isGuestMode = false;
  
  bool get isGuestMode => _isGuestMode;
  
  void enableGuestMode() {
    _isGuestMode = true;
    notifyListeners();
  }
  
  void disableGuestMode() {
    _isGuestMode = false;
    notifyListeners();
  }
}
