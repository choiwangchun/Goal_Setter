import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_setter/main.dart'; // Assuming _MyAppState is in main.dart or accessible
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:goal_setter/notification.dart'; // Required for NotificationService if used by _startNotificationTimer directly

// Mock NotificationService if it's directly used by startNotificationTimer and needs mocking
class MockNotificationService extends Fake implements NotificationService {
  bool initialized = false;
  @override
  Future<void> init() async {
    initialized = true;
  }

  @override
  Future<void> regular_showNotification(int id, String body, [String? title]) async {
    // Do nothing in mock
  }
}


void main() {
  // Ensure Flutter binding is initialized for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup for EasyLocalization
  setUpAll(() async {
    EasyLocalization.logger.enableBuildModes = []; // Prevent logs during tests
    // It's crucial to set mock SharedPreferences values *before* EasyLocalization.ensureInitialized()
    // if EasyLocalization itself or any part of the app's early lifecycle (like MyApp's initState)
    // might read from SharedPreferences.
    SharedPreferences.setMockInitialValues({
      'notification_interval': 8, // Default initial value for the app start
      'darkMode': false,
      'isFeatureEnabled': false,
      'enter_goal': 'My Test Goal',
      // Add any other keys that might be read during init
    });
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Notification timer restarts with new interval (direct test)', (WidgetTester tester) async {
    // 1. Initial SharedPreferences setup for this specific test run
    // This will be active when MyApp starts.
    SharedPreferences.setMockInitialValues({
      'notification_interval': 8, // Initial interval for this test
      'darkMode': false,
      'isFeatureEnabled': false,
      'enter_goal': 'My Test Goal',
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ko'), Locale('zh'), Locale('ja')],
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        child: MyApp(), // MyApp should use the SharedPreferences set above
      ),
    );
    await tester.pumpAndSettle(); // Allow MyApp's initState (which calls startNotificationTimer) to complete

    // After initial startup and initial call to startNotificationTimer,
    // MyApp.testHook_timerWasReset should be true.
    expect(MyApp.testHook_timerWasReset, isTrue, reason: "Timer should have been started (and hook set) on app init.");

    // Reset the hook before the specific action we want to test
    MyApp.testHook_timerWasReset = false;
    expect(MyApp.testHook_timerWasReset, isFalse, reason: "Test hook should be reset before action.");

    // 2. Simulate changing the interval in SharedPreferences directly
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_interval', 5); // New interval

    // Verify SharedPreferences update immediately
    expect(await prefs.getInt('notification_interval'), 5, reason: "SharedPreferences should reflect the new interval immediately.");

    // 3. Simulate the callback that restarts the timer
    // Get the state of MyApp (_MyAppState)
    // Note: Direct access to _MyAppState methods is generally for testing purposes.
    // The method `startNotificationTimer` was made public in `_MyAppState`.
    final myAppState = tester.state(find.byType(MyApp));
    
    // Cast to _MyAppState to call the method.
    // This requires _MyAppState to be exposed or a public interface on MyApp to trigger it.
    // Assuming _MyAppState is the state class for MyApp widget.
    // If _MyAppState is not directly accessible, this needs adjustment.
    // For this task, we proceed as if it's `_MyAppState`.
    // The actual class name is _MyAppState.
    (myAppState as dynamic).startNotificationTimer(); // Call the public method

    await tester.pumpAndSettle(); // Allow state changes and timer re-creation to propagate

    // 4. Assertions
    // Check if the timer restart hook was set
    expect(MyApp.testHook_timerWasReset, isTrue, reason: "_startNotificationTimer should have been called, setting the hook to true.");
    
    // Optionally, re-check SharedPreferences, though it was set by the test directly.
    // The key is that startNotificationTimer would *read* this new value.
    expect(await prefs.getInt('notification_interval'), 5, reason: "SharedPreferences should still be the new interval.");

  });
}
