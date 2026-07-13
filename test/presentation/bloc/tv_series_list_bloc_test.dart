import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tv_series.dart';
import 'package:ditonton/domain/usecases/get_popular_tv_series.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tv_series.dart';
import 'package:ditonton/presentation/bloc/tv_series_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockGetNowPlayingTvSeries extends Mock implements GetNowPlayingTvSeries {}
class MockGetPopularTvSeries extends Mock implements GetPopularTvSeries {}
class MockGetTopRatedTvSeries extends Mock implements GetTopRatedTvSeries {}

void main() {
  late TvSeriesListBloc tvSeriesListBloc;
  late MockGetNowPlayingTvSeries mockGetNowPlayingTvSeries;
  late MockGetPopularTvSeries mockGetPopularTvSeries;
  late MockGetTopRatedTvSeries mockGetTopRatedTvSeries;

  setUp(() {
    mockGetNowPlayingTvSeries = MockGetNowPlayingTvSeries();
    mockGetPopularTvSeries = MockGetPopularTvSeries();
    mockGetTopRatedTvSeries = MockGetTopRatedTvSeries();
    tvSeriesListBloc = TvSeriesListBloc(
      getNowPlayingTvSeries: mockGetNowPlayingTvSeries,
      getPopularTvSeries: mockGetPopularTvSeries,
      getTopRatedTvSeries: mockGetTopRatedTvSeries,
    );
  });

  test('initial state should be empty', () {
    expect(tvSeriesListBloc.state, TvSeriesListState.initial());
  });

  group('now playing tv series', () {
    blocTest<TvSeriesListBloc, TvSeriesListState>(
      'should emit [nowPlayingState: Loading, nowPlayingState: Loaded] when now playing is fetched successfully',
      build: () {
        when(() => mockGetNowPlayingTvSeries.execute())
            .thenAnswer((_) async => Right(testTvSeriesList));
        return tvSeriesListBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingTvSeries()),
      expect: () => [
        TvSeriesListState.initial().copyWith(nowPlayingState: RequestState.Loading),
        TvSeriesListState.initial().copyWith(
          nowPlayingState: RequestState.Loaded,
          nowPlayingTvSeries: testTvSeriesList,
        ),
      ],
    );

    blocTest<TvSeriesListBloc, TvSeriesListState>(
      'should emit [nowPlayingState: Loading, nowPlayingState: Error] when fetching fails',
      build: () {
        when(() => mockGetNowPlayingTvSeries.execute())
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return tvSeriesListBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingTvSeries()),
      expect: () => [
        TvSeriesListState.initial().copyWith(nowPlayingState: RequestState.Loading),
        TvSeriesListState.initial().copyWith(
          nowPlayingState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );
  });

  group('popular tv series', () {
    blocTest<TvSeriesListBloc, TvSeriesListState>(
      'should emit [popularState: Loading, popularState: Loaded] when popular is fetched successfully',
      build: () {
        when(() => mockGetPopularTvSeries.execute())
            .thenAnswer((_) async => Right(testTvSeriesList));
        return tvSeriesListBloc;
      },
      act: (bloc) => bloc.add(FetchPopularTvSeries()),
      expect: () => [
        TvSeriesListState.initial().copyWith(popularState: RequestState.Loading),
        TvSeriesListState.initial().copyWith(
          popularState: RequestState.Loaded,
          popularTvSeries: testTvSeriesList,
        ),
      ],
    );

    blocTest<TvSeriesListBloc, TvSeriesListState>(
      'should emit [popularState: Loading, popularState: Error] when fetching popular fails',
      build: () {
        when(() => mockGetPopularTvSeries.execute())
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return tvSeriesListBloc;
      },
      act: (bloc) => bloc.add(FetchPopularTvSeries()),
      expect: () => [
        TvSeriesListState.initial().copyWith(popularState: RequestState.Loading),
        TvSeriesListState.initial().copyWith(
          popularState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );
  });

  group('top rated tv series', () {
    blocTest<TvSeriesListBloc, TvSeriesListState>(
      'should emit [topRatedState: Loading, topRatedState: Loaded] when top rated is fetched successfully',
      build: () {
        when(() => mockGetTopRatedTvSeries.execute())
            .thenAnswer((_) async => Right(testTvSeriesList));
        return tvSeriesListBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedTvSeries()),
      expect: () => [
        TvSeriesListState.initial().copyWith(topRatedState: RequestState.Loading),
        TvSeriesListState.initial().copyWith(
          topRatedState: RequestState.Loaded,
          topRatedTvSeries: testTvSeriesList,
        ),
      ],
    );

    blocTest<TvSeriesListBloc, TvSeriesListState>(
      'should emit [topRatedState: Loading, topRatedState: Error] when fetching top rated fails',
      build: () {
        when(() => mockGetTopRatedTvSeries.execute())
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return tvSeriesListBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedTvSeries()),
      expect: () => [
        TvSeriesListState.initial().copyWith(topRatedState: RequestState.Loading),
        TvSeriesListState.initial().copyWith(
          topRatedState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );
  });
}
