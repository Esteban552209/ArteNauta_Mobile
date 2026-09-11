import 'package:flutter_test/flutter_test.dart';
import 'package:artenauta/main.dart';

void main() {
  testWidgets('Prueba de carga inicial de Artenauta', (WidgetTester tester) async {
    // Carga la aplicación en el entorno de pruebas
    await tester.pumpWidget(const ArtenautaApp());

    // Verifica que existan los textos principales de la pantalla
    expect(find.text('©2026 ArteNauta'), findsOneWidget);
  });
}