// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_slide_puzzle/dashatar/dashatar.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/timer/timer.dart';

import '../../helpers/helpers.dart';

void main() {
  group('DashatarCountdown', () {
    late DashatarPuzzleBloc dashatarPuzzleBloc;
    late DashatarThemeBloc dashatarThemeBloc;

    setUp(() {
      dashatarPuzzleBloc = MockDashatarPuzzleBloc();
      final dashatarPuzzleState = DashatarPuzzleState(secondsToBegin: 3);
      whenListen(
        dashatarPuzzleBloc,
        Stream.value(dashatarPuzzleState),
        initialState: dashatarPuzzleState,
      );

      dashatarThemeBloc = MockDashatarThemeBloc();
      final themes = [GreenDashatarTheme()];
      final dashatarThemeState = DashatarThemeState(themes: themes);
      whenListen(
        dashatarThemeBloc,
        Stream.value(dashatarThemeState),
        initialState: dashatarThemeState,
      );
    });

    testWidgets(
        'adds TimerStarted to TimerBloc '
        'when isCountdownRunning is true and '
        'secondsToBegin is equal to 0', (tester) async {
      final timerBloc = MockTimerBloc();

      final state = DashatarPuzzleState(
        isCountdownRunning: true,
        secondsToBegin: 0,
      );

      whenListen(
        dashatarPuzzleBloc,
        Stream.value(state),
        initialState: state,
      );

      await tester.pumpApp(
        DashatarCountdown(),
        dashatarPuzzleBloc: dashatarPuzzleBloc,
        dashatarThemeBloc: dashatarThemeBloc,
        timerBloc: timerBloc,
      );

      verify(() => timerBloc.add(TimerStarted())).called(1);
    });

    testWidgets(
        'adds PuzzleReset to PuzzleBloc '
        'when isCountdownRunning is true and '
        'secondsToBegin is between 1 and 3 (inclusive)', (tester) async {
      final puzzleBloc = MockPuzzleBloc();

      final state = DashatarPuzzleState(
        isCountdownRunning: true,
        secondsToBegin: 4,
      );

      final streamController = StreamController<DashatarPuzzleState>();

      whenListen(
        dashatarPuzzleBloc,
        streamController.stream,
      );

      streamController
        ..add(state)
        ..add(state.copyWith(secondsToBegin: 3))
        ..add(state.copyWith(secondsToBegin: 2))
        ..add(state.copyWith(secondsToBegin: 1))
        ..add(state.copyWith(secondsToBegin: 0))
        ..add(state.copyWith(isCountdownRunning: false));

      await tester.pumpApp(
        DashatarCountdown(),
        dashatarPuzzleBloc: dashatarPuzzleBloc,
        dashatarThemeBloc: dashatarThemeBloc,
        puzzleBloc: puzzleBloc,
      );

      verify(() => puzzleBloc.add(PuzzleReset())).called(3);
    });

    group('on a large display', () {
      testWidgets(
          'renders DashatarCountdownSecondsToBegin '
          'if isCountdownRunning is true and '
          'secondsToBegin is greater than 0', (tester) async {
        tester.setLargeDisplaySize();

        final state = DashatarPuzzleState(
          isCountdownRunning: true,
          secondsToBegin: 3,
        );

        whenListen(
          dashatarPuzzleBloc,
          Stream.value(state),
          initialState: state,
        );

        await tester.pumpApp(
          DashatarCountdown(),
          dashatarPuzzleBloc: dashatarPuzzleBloc,
          dashatarThemeBloc: dashatarThemeBloc,
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DashatarCountdownSecondsToBegin &&
                widget.secondsToBegin == state.secondsToBegin,
          ),
          findsOneWidget,
        );

        expect(find.byType(DashatarCountdownGo), findsNothing);
      });

      testWidgets(
          'renders DashatarCountdownGo '
          'if isCountdownRunning is true and '
          'secondsToBegin is equal to 0', (tester) async {
        tester.setLargeDisplaySize();

        final state = DashatarPuzzleState(
          isCountdownRunning: true,
          secondsToBegin: 0,
        );

        whenListen(
          dashatarPuzzleBloc,
          Stream.value(state),
          initialState: state,
        );

        await tester.pumpApp(
          DashatarCountdown(),
          dashatarPuzzleBloc: dashatarPuzzleBloc,
          dashatarThemeBloc: dashatarThemeBloc,
        );

        expect(find.byType(DashatarCountdownSecondsToBegin), findsNothing);
        expect(find.byType(DashatarCountdownGo), findsOneWidget);
      });

      testWidgets(
          'renders SizedBox '
          'if isCountdownRunning is false', (tester) async {
        tester.setLargeDisplaySize();

        final state = DashatarPuzzleState(
          isCountdownRunning: false,
          secondsToBegin: 3,
        );

        whenListen(
          dashatarPuzzleBloc,
          Stream.value(state),
          initialState: state,
        );

        await tester.pumpApp(
          DashatarCountdown(),
          dashatarPuzzleBloc: dashatarPuzzleBloc,
          dashatarThemeBloc: dashatarThemeBloc,
        );

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(DashatarCountdownSecondsToBegin), findsNothing);
        expect(find.byType(DashatarCountdownGo), findsNothing);
      });

      testWidgets(
          'renders SizedBox '
          'if secondsToBegin is greater than 3', (tester) async {
        tester.setLargeDisplaySize();

        final state = DashatarPuzzleState(
          isCountdownRunning: true,
          secondsToBegin: 4,
        );

        whenListen(
          dashatarPuzzleBloc,
          Stream.value(state),
          initialState: state,
        );

        await tester.pumpApp(
          DashatarCountdown(),
          dashatarPuzzleBloc: dashatarPuzzleBloc,
          dashatarThemeBloc: dashatarThemeBloc,
        );

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(DashatarCountdownSecondsToBegin), findsNothing);
        expect(find.byType(DashatarCountdownGo), findsNothing);
      });
    });

    testWidgets('renders SizedBox on a medium display', (tester) async {
      tester.setMediumDisplaySize();

      await tester.pumpApp(
        DashatarCountdown(),
        dashatarPuzzleBloc: dashatarPuzzleBloc,
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(DashatarCountdownSecondsToBegin), findsNothing);
      expect(find.byType(DashatarCountdownGo), findsNothing);
    });

    testWidgets('renders SizedBox on a small display', (tester) async {
      tester.setSmallDisplaySize();

      await tester.pumpApp(
        DashatarCountdown(),
        dashatarPuzzleBloc: dashatarPuzzleBloc,
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(DashatarCountdownSecondsToBegin), findsNothing);
      expect(find.byType(DashatarCountdownGo), findsNothing);
    });
  });

  group('DashatarCountdownSecondsToBegin', () {
    late DashatarThemeBloc dashatarThemeBloc;
    late DashatarTheme dashatarTheme;

    setUp(() {
      dashatarThemeBloc = MockDashatarThemeBloc();
      dashatarTheme = MockDashatarTheme();
      final dashatarThemeState = DashatarThemeState(
        themes: [dashatarTheme],
        theme: dashatarTheme,
      );

      when(() => dashatarTheme.defaultColor).thenReturn(Colors.black);
      when(() => dashatarTheme.countdownColor).thenReturn(Colors.black);
      when(() => dashatarThemeBloc.state).thenReturn(dashatarThemeState);
    });

    testWidgets(
        'renders secondsToBegin '
        'using DashatarTheme.countdownColor as text color', (tester) async {
      const countdownColor = Colors.green;
      when(() => dashatarTheme.countdownColor).thenReturn(countdownColor);

      await tester.pumpApp(
        DashatarCountdownSecondsToBegin(
          secondsToBegin: 3,
        ),
        dashatarThemeBloc: dashatarThemeBloc,
      );

      final text = tester.widget<Text>(find.text('3'));

      expect(text.style?.color, equals(countdownColor));
    });
  });

  group('DashatarCountdownGo', () {
    late DashatarThemeBloc dashatarThemeBloc;
    late DashatarTheme dashatarTheme;

    setUp(() {
      dashatarThemeBloc = MockDashatarThemeBloc();
      dashatarTheme = MockDashatarTheme();
      final themeState = DashatarThemeState(
        themes: [dashatarTheme],
        theme: dashatarTheme,
      );

      when(() => dashatarTheme.defaultColor).thenReturn(Colors.black);
      when(() => dashatarTheme.countdownColor).thenReturn(Colors.black);
      when(() => dashatarThemeBloc.state).thenReturn(themeState);
    });

    testWidgets(
        'renders text '
        'using DashatarTheme.defaultColor as text color', (tester) async {
      const defaultColor = Colors.orange;
      when(() => dashatarTheme.defaultColor).thenReturn(defaultColor);

      await tester.pumpApp(
        DashatarCountdownGo(),
        dashatarThemeBloc: dashatarThemeBloc,
      );

      final text = tester.widget<Text>(find.byType(Text));

      expect(text.style?.color, equals(defaultColor));
    });
  });
}
