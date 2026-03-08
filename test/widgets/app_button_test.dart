import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/core/widgets/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('should render primary button', (tester) async {
      // Arrange
      bool pressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              type: AppButtonType.primary,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Tap button
      await tester.tap(find.byType(AppButton));
      expect(pressed, isTrue);
    });

    testWidgets('should render secondary button', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Secondary',
              type: AppButtonType.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render outlined button', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Outlined',
              type: AppButtonType.outlined,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Outlined'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render text button', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Text',
              type: AppButtonType.text,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Text'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(text: 'Loading', isLoading: true, onPressed: () {}),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should render icon when provided', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppButton(text: 'Disabled', onPressed: null)),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should have semantic label', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test',
              semanticLabel: 'Test button label',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.bySemanticsLabel('Test button label'), findsOneWidget);
    });
  });
}
