import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/get_tv_series_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_series_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tv_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist_tv.dart';
import 'package:ditonton/domain/usecases/save_watchlist_tv.dart';
import 'package:ditonton/presentation/bloc/tv_series_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockGetTvSeriesDetail extends Mock implements GetTvSeriesDetail {}
class MockGetTvSeriesRecommendations extends Mock implements GetTvSeriesRecommendations {}
class MockGetWatchlistTvStatus extends Mock implements GetWatchlistTvStatus {}
class MockSaveWatchlistTv extends Mock implements SaveWatchlistTv {}
class MockRemoveWatchlistTv extends Mock implements RemoveWatchlistTv {}

void main() {
  late TvSeriesDetailBloc tvSeriesDetailBloc;
  late MockGetTvSeriesDetail mockGetTvSeriesDetail;
  late MockGetTvSeriesRecommendations mockGetTvSeriesRecommendations;
  late MockGetWatchlistTvStatus mockGetWatchlistTvStatus;
  late MockSaveWatchlistTv mockSaveWatchlistTv;
  late MockRemoveWatchlistTv mockRemoveWatchlistTv;

  setUp(() {
    mockGetTvSeriesDetail = MockGetTvSeriesDetail();
    mockGetTvSeriesRecommendations = MockGetTvSeriesRecommendations();
    mockGetWatchlistTvStatus = MockGetWatchlistTvStatus();
    mockSaveWatchlistTv = MockSaveWatchlistTv();
    mockRemoveWatchlistTv = MockRemoveWatchlistTv();
    tvSeriesDetailBloc = TvSeriesDetailBloc(
      getTvSeriesDetail: mockGetTvSeriesDetail,
      getTvSeriesRecommendations: mockGetTvSeriesRecommendations,
      getWatchlistTvStatus: mockGetWatchlistTvStatus,
      saveWatchlistTv: mockSaveWatchlistTv,
      removeWatchlistTv: mockRemoveWatchlistTv,
    );
  });

  const tId = 1;
  final tTvSeriesList = <TvSeries>[testTvSeries];

  test('initial state should be initial', () {
    expect(tvSeriesDetailBloc.state, TvSeriesDetailState.initial());
  });

  group('get tv series detail', () {
    blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
      'should emit [tvSeriesDetailState: Loading, tvSeriesDetailState: Loaded, recommendationState: Loaded] when data is gotten successfully',
      build: () {
        when(() => mockGetTvSeriesDetail.execute(tId))
            .thenAnswer((_) async => Right(testTvSeriesDetail));
        when(() => mockGetTvSeriesRecommendations.execute(tId))
            .thenAnswer((_) async => Right(tTvSeriesList));
        return tvSeriesDetailBloc;
      },
      act: (bloc) => bloc.add(const FetchTvSeriesDetail(tId)),
      expect: () => [
        TvSeriesDetailState.initial().copyWith(tvSeriesDetailState: RequestState.Loading),
        TvSeriesDetailState.initial().copyWith(
          tvSeriesDetailState: RequestState.Loaded,
          tvSeriesDetail: testTvSeriesDetail,
          recommendationState: RequestState.Loading,
        ),
        TvSeriesDetailState.initial().copyWith(
          tvSeriesDetailState: RequestState.Loaded,
          tvSeriesDetail: testTvSeriesDetail,
          recommendationState: RequestState.Loaded,
          tvRecommendations: tTvSeriesList,
        ),
      ],
    );

    blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
      'should emit [tvSeriesDetailState: Loading, tvSeriesDetailState: Error] when fetching tv series detail fails',
      build: () {
        when(() => mockGetTvSeriesDetail.execute(tId))
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        when(() => mockGetTvSeriesRecommendations.execute(tId))
            .thenAnswer((_) async => Right(tTvSeriesList));
        return tvSeriesDetailBloc;
      },
      act: (bloc) => bloc.add(const FetchTvSeriesDetail(tId)),
      expect: () => [
        TvSeriesDetailState.initial().copyWith(tvSeriesDetailState: RequestState.Loading),
        TvSeriesDetailState.initial().copyWith(
          tvSeriesDetailState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );

    blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
      'should emit [tvSeriesDetailState: Loading, tvSeriesDetailState: Loaded, recommendationState: Error] when fetching recommendations fails',
      build: () {
        when(() => mockGetTvSeriesDetail.execute(tId))
            .thenAnswer((_) async => Right(testTvSeriesDetail));
        when(() => mockGetTvSeriesRecommendations.execute(tId))
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return tvSeriesDetailBloc;
      },
      act: (bloc) => bloc.add(const FetchTvSeriesDetail(tId)),
      expect: () => [
        TvSeriesDetailState.initial().copyWith(tvSeriesDetailState: RequestState.Loading),
        TvSeriesDetailState.initial().copyWith(
          tvSeriesDetailState: RequestState.Loaded,
          tvSeriesDetail: testTvSeriesDetail,
          recommendationState: RequestState.Loading,
        ),
        TvSeriesDetailState.initial().copyWith(
          tvSeriesDetailState: RequestState.Loaded,
          tvSeriesDetail: testTvSeriesDetail,
          recommendationState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );
  });

  group('watchlist tv series', () {
    blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
      'should load watchlist tv status',
      build: () {
        when(() => mockGetWatchlistTvStatus.execute(tId)).thenAnswer((_) async => true);
        return tvSeriesDetailBloc;
      },
      act: (bloc) => bloc.add(const LoadWatchlistTvStatusEvent(tId)),
      expect: () => [
        TvSeriesDetailState.initial().copyWith(isAddedToWatchlist: true),
      ],
    );

    blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
      'should emit watchlistMessage and load status when save watchlist is successful',
      build: () {
        when(() => mockSaveWatchlistTv.execute(testTvSeriesDetail))
            .thenAnswer((_) async => const Right('Added to Watchlist'));
        when(() => mockGetWatchlistTvStatus.execute(testTvSeriesDetail.id))
            .thenAnswer((_) async => true);
        return tvSeriesDetailBloc;
      },
      act: (bloc) => bloc.add(AddWatchlistTvEvent(testTvSeriesDetail)),
      expect: () => [
        TvSeriesDetailState.initial().copyWith(watchlistMessage: 'Added to Watchlist'),
        TvSeriesDetailState.initial().copyWith(
          watchlistMessage: 'Added to Watchlist',
          isAddedToWatchlist: true,
        ),
      ],
    );

    blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
      'should emit watchlistMessage and load status when remove watchlist is successful',
      build: () {
        when(() => mockRemoveWatchlistTv.execute(testTvSeriesDetail))
            .thenAnswer((_) async => const Right('Removed from Watchlist'));
        when(() => mockGetWatchlistTvStatus.execute(testTvSeriesDetail.id))
            .thenAnswer((_) async => false);
        return tvSeriesDetailBloc;
      },
      act: (bloc) => bloc.add(RemoveWatchlistTvEvent(testTvSeriesDetail)),
      expect: () => [
        TvSeriesDetailState.initial().copyWith(
          watchlistMessage: 'Removed from Watchlist',
          isAddedToWatchlist: false,
        ),
      ],
    );
  });
}
