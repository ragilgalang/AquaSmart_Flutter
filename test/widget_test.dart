import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aquasmart_app/main.dart';
import 'package:aquasmart_app/providers/auth_provider.dart';
import 'package:aquasmart_app/services/api_service.dart';

void main() {
  testWidgets('AquaSmartApp smoke test', (WidgetTester tester) async {
    final api = ApiService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: api),
          ChangeNotifierProvider(create: (_) => AuthProvider(api)),
        ],
        child: const AquaSmartApp(),
      ),
    );
    expect(find.byType(AquaSmartApp), findsOneWidget);
  });
}
