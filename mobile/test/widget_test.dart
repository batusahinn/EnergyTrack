import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:energy_track_mobile/main.dart';
import 'package:energy_track_mobile/services/api_service.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider(
        create: (_) => ApiService(),
        child: const EnergyTrackApp(),
      ),
    );
    expect(find.text('EnergyTrack'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
