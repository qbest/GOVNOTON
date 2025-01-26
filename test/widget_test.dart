import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_widget/main.dart';

void main() {
  testWidgets('MyApp widget test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Проверка на существование нужного текста
    expect(find.text('GOVNO TOP'), findsOneWidget);
    expect(find.text('TON GOVNO'), findsOneWidget);

    // Поскольку цена динамическая, проверим на наличие виджета с текстом в формате цены
    final priceFinder = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Text && widget.data != null && widget.data!.contains('\$'),
    );
    expect(priceFinder, findsOneWidget);
  });
}
