import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/presentation/pages/tv_series_detail_page.dart';
import 'package:ditonton/presentation/bloc/tv_series_detail_bloc.dart';
import 'package:ditonton/presentation/bloc/tv_season_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockTvSeriesDetailBloc
    extends MockBloc<TvSeriesDetailEvent, TvSeriesDetailState>
    implements TvSeriesDetailBloc {}

class MockTvSeasonDetailBloc
    extends MockBloc<TvSeasonDetailEvent, TvSeasonDetailState>
    implements TvSeasonDetailBloc {}

void main() {
  late MockTvSeriesDetailBloc mockDetailBloc;
  late MockTvSeasonDetailBloc mockSeasonBloc;

  setUpAll(() {
    registerFallbackValue(TvSeriesDetailState.initial());
    registerFallbackValue(const FetchTvSeriesDetail(1));
    registerFallbackValue(TvSeasonDetailEmpty());
    registerFallbackValue(const FetchTvSeasonDetail(tvId: 1, seasonNumber: 1));
  });

  setUp(() {
    mockDetailBloc = MockTvSeriesDetailBloc();
    mockSeasonBloc = MockTvSeasonDetailBloc();
  });

  Widget _makeTestableWidget(Widget body) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TvSeriesDetailBloc>.value(value: mockDetailBloc),
        BlocProvider<TvSeasonDetailBloc>.value(value: mockSeasonBloc),
      ],
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets(
      'Watchlist button should display add icon when tv series not added to watchlist',
      (WidgetTester tester) async {
    when(() => mockDetailBloc.state).thenReturn(TvSeriesDetailState.initial().copyWith(
      tvSeriesDetailState: RequestState.Loaded,
      tvSeriesDetail: testTvSeriesDetail,
      recommendationState: RequestState.Loaded,
      tvRecommendations: <TvSeries>[],
      isAddedToWatchlist: false,
    ));
    when(() => mockSeasonBloc.state).thenReturn(TvSeasonDetailHasData(testTvSeasonDetail));

    final watchlistButtonIcon = find.byIcon(Icons.add);

    await tester.pumpWidget(_makeTestableWidget(TvSeriesDetailPage(id: 1)));

    expect(watchlistButtonIcon, findsOneWidget);
  });

  testWidgets(
      'Watchlist button should display check icon when tv series is added to watchlist',
      (WidgetTester tester) async {
    when(() => mockDetailBloc.state).thenReturn(TvSeriesDetailState.initial().copyWith(
      tvSeriesDetailState: RequestState.Loaded,
      tvSeriesDetail: testTvSeriesDetail,
      recommendationState: RequestState.Loaded,
      tvRecommendations: <TvSeries>[],
      isAddedToWatchlist: true,
    ));
    when(() => mockSeasonBloc.state).thenReturn(TvSeasonDetailHasData(testTvSeasonDetail));

    final watchlistButtonIcon = find.byIcon(Icons.check);

    await tester.pumpWidget(_makeTestableWidget(TvSeriesDetailPage(id: 1)));

    expect(watchlistButtonIcon, findsOneWidget);
  });

  testWidgets(
      'Watchlist button should display Snackbar when added to watchlist',
      (WidgetTester tester) async {
    when(() => mockDetailBloc.state).thenReturn(TvSeriesDetailState.initial().copyWith(
      tvSeriesDetailState: RequestState.Loaded,
      tvSeriesDetail: testTvSeriesDetail,
      recommendationState: RequestState.Loaded,
      tvRecommendations: <TvSeries>[],
      isAddedToWatchlist: false,
    ));
    when(() => mockSeasonBloc.state).thenReturn(TvSeasonDetailHasData(testTvSeasonDetail));

    whenListen(
      mockDetailBloc,
      Stream.fromIterable([
        TvSeriesDetailState.initial().copyWith(
          tvSeriesDetailState: RequestState.Loaded,
          tvSeriesDetail: testTvSeriesDetail,
          recommendationState: RequestState.Loaded,
          tvRecommendations: <TvSeries>[],
          isAddedToWatchlist: false,
          watchlistMessage: 'Added to Watchlist',
        ),
      ]),
    );

    final watchlistButton = find.byType(FilledButton);

    await tester.pumpWidget(_makeTestableWidget(TvSeriesDetailPage(id: 1)));

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(watchlistButton, warnIfMissed: false);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Added to Watchlist'), findsOneWidget);
  });

  testWidgets(
      'Watchlist button should display AlertDialog when add to watchlist failed',
      (WidgetTester tester) async {
    when(() => mockDetailBloc.state).thenReturn(TvSeriesDetailState.initial().copyWith(
      tvSeriesDetailState: RequestState.Loaded,
      tvSeriesDetail: testTvSeriesDetail,
      recommendationState: RequestState.Loaded,
      tvRecommendations: <TvSeries>[],
      isAddedToWatchlist: false,
    ));
    when(() => mockSeasonBloc.state).thenReturn(TvSeasonDetailHasData(testTvSeasonDetail));

    whenListen(
      mockDetailBloc,
      Stream.fromIterable([
        TvSeriesDetailState.initial().copyWith(
          tvSeriesDetailState: RequestState.Loaded,
          tvSeriesDetail: testTvSeriesDetail,
          recommendationState: RequestState.Loaded,
          tvRecommendations: <TvSeries>[],
          isAddedToWatchlist: false,
          watchlistMessage: 'Failed',
        ),
      ]),
    );

    final watchlistButton = find.byType(FilledButton);

    await tester.pumpWidget(_makeTestableWidget(TvSeriesDetailPage(id: 1)));

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(watchlistButton, warnIfMissed: false);
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });
}
