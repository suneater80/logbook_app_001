import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  group('Module 3 - OnboardingView', () {
    Future<void> prepareViewport(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    }

    test(
      'TC01 - onboarding data should store first slide information correctly',
      () {
        final data = OnboardingData(
          image: 'assets/images/onboarding1.png',
          title: 'Selamat Datang',
          description:
              'Aplikasi LogBook membantu Anda mencatat setiap aktivitas dengan mudah dan rapi.',
        );

        expect(data.image, 'assets/images/onboarding1.png');
        expect(data.title, 'Selamat Datang');
        expect(
          data.description,
          'Aplikasi LogBook membantu Anda mencatat setiap aktivitas dengan mudah dan rapi.',
        );
      },
    );

    testWidgets('TC02 - onboarding first page should show welcome title', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
      await tester.pumpAndSettle();

      expect(find.text('Selamat Datang'), findsOneWidget);
    });

    testWidgets(
      'TC03 - onboarding first page should show Skip and Next buttons',
      (tester) async {
        await prepareViewport(tester);
        await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
        await tester.pumpAndSettle();

        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
      },
    );

    testWidgets('TC04 - pressing Next should move to second page', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Kelola Counter'), findsOneWidget);
    });

    testWidgets('TC05 - pressing Next again should move to third page', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Pantau Riwayat'), findsOneWidget);
    });

    testWidgets('TC06 - last page button should change to Get Started', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('TC07 - pressing Skip should jump to last page', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Pantau Riwayat'), findsOneWidget);
    });

    testWidgets('TC08 - pressing Get Started should navigate to LoginView', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('Login Gatekeeper'), findsOneWidget);
    });

    testWidgets(
      'TC09 - swiping left should move to the second onboarding page',
      (tester) async {
        await prepareViewport(tester);
        await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
        await tester.pumpAndSettle();

        await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
        await tester.pumpAndSettle();

        expect(find.text('Kelola Counter'), findsOneWidget);
      },
    );

    testWidgets('TC10 - onboarding screen should show page indicator', (
      tester,
    ) async {
      await prepareViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: OnboardingView()));
      await tester.pumpAndSettle();

      expect(find.byType(SmoothPageIndicator), findsOneWidget);
    });
  });
}
