import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/usecases/get_tv_season_detail.dart';
import 'package:ditonton/presentation/bloc/tv_season_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockGetTvSeasonDetail extends Mock implements GetTvSeasonDetail {}

void main() {
  late TvSeasonDetailBloc tvSeasonDetailBloc;
  late MockGetTvSeasonDetail mockGetTvSeasonDetail;

  setUp(() {
    mockGetTvSeasonDetail = MockGetTvSeasonDetail();
    tvSeasonDetailBloc = TvSeasonDetailBloc(getTvSeasonDetail: mockGetTvSeasonDetail);
  });

  const tTvId = 1;
  const tSeasonNumber = 1;

  test('initial state should be empty', () {
    expect(tvSeasonDetailBloc.state, TvSeasonDetailEmpty());
  });

  blocTest<TvSeasonDetailBloc, TvSeasonDetailState>(
    'should emit [Loading, HasData] when data is gotten successfully',
    build: () {
      when(() => mockGetTvSeasonDetail.execute(tTvId, tSeasonNumber))
          .thenAnswer((_) async => Right(testTvSeasonDetail));
      return tvSeasonDetailBloc;
    },
    act: (bloc) => bloc.add(const FetchTvSeasonDetail(tvId: tTvId, seasonNumber: tSeasonNumber)),
    expect: () => [
      TvSeasonDetailLoading(),
      TvSeasonDetailHasData(testTvSeasonDetail),
    ],
    verify: (bloc) {
      verify(() => mockGetTvSeasonDetail.execute(tTvId, tSeasonNumber));
    },
  );

  blocTest<TvSeasonDetailBloc, TvSeasonDetailState>(
    'should emit [Loading, Error] when data is unsuccessful',
    build: () {
      when(() => mockGetTvSeasonDetail.execute(tTvId, tSeasonNumber))
          .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
      return tvSeasonDetailBloc;
    },
    act: (bloc) => bloc.add(const FetchTvSeasonDetail(tvId: tTvId, seasonNumber: tSeasonNumber)),
    expect: () => [
      TvSeasonDetailLoading(),
      TvSeasonDetailError('Server Failure'),
    ],
    verify: (bloc) {
      verify(() => mockGetTvSeasonDetail.execute(tTvId, tSeasonNumber));
    },
  );
}
