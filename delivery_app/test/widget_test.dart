import 'package:delivery_app/main.dart';
import 'package:delivery_app/core/services/api_service.dart';
import 'package:delivery_app/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Simple mocks using mocktail — we don't need to implement all methods.
class MockStorageService extends Mock implements StorageService {}
class MockApiService extends Mock implements ApiService {}

void main() {
  // Optional: register fallback values if your ApiService methods expect custom types.
  // registerFallbackValue(MyRequestOrModel());

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // create mock instances
    final storage = MockStorageService();
    final api = MockApiService();

    // you can stub methods if your app calls them during build
    // when(() => storage.isLoggedIn()).thenReturn(false); // example

    await tester.pumpWidget(
      MyApp(
        storageService: storage,
        apiService: api,
      ),
    );

    // existing test assertions
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
