import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:customer_app/features/search/views/search_page.dart';

void main() {
  group('SearchPage Map View Tests', () {
    testWidgets('SearchPage should display toggle buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: SearchPage()));

      // Verify that toggle buttons are present
      expect(find.text('List View'), findsOneWidget);
      expect(find.text('Map View'), findsOneWidget);
    });

    testWidgets('Should switch to map view when map toggle is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: SearchPage()));

      // Tap on Map View button
      await tester.tap(find.text('Map View'));
      await tester.pump();

      // Verify GoogleMap widget is displayed
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('Should switch back to list view when list toggle is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: SearchPage()));

      // First switch to map view
      await tester.tap(find.text('Map View'));
      await tester.pump();

      // Then switch back to list view
      await tester.tap(find.text('List View'));
      await tester.pump();

      // Verify ListView is displayed (check for provider items)
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Afro Cuts Salon'), findsOneWidget);
      expect(find.text('Barber Joe'), findsOneWidget);
    });

    testWidgets('List view should display all mock providers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: SearchPage()));

      // Verify all providers are displayed in list view
      expect(find.text('Afro Cuts Salon'), findsOneWidget);
      expect(find.text('Barber Joe'), findsOneWidget);
      expect(find.text('Style Studio'), findsOneWidget);
      expect(find.text('Gentle Cuts'), findsOneWidget);
      expect(find.text('Urban Styles'), findsOneWidget);

      // Verify ratings are displayed
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('4.9'), findsWidgets);
      expect(find.text('4.7'), findsOneWidget);
      expect(find.text('4.6'), findsOneWidget);
    });
  });
}
