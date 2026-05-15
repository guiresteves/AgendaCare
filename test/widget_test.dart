import 'package:agendacare/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts and shows welcome screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('AgendaCare'), findsOneWidget);
    expect(find.text('Comecar agora'), findsOneWidget);
    expect(find.text('Ja tenho conta'), findsOneWidget);
  });
}
