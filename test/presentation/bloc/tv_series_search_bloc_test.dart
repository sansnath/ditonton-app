import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/usecases/search_tv_series.dart';
import 'package:ditonton/presentation/bloc/tv_series_search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockSearchTvSeries extends Mock implements SearchTvSeries {}

void main() {
  late TvSeriesSearchBloc searchBloc;
  late MockSearchTvSeries mockSearchTvSeries;

  setUp(() {
    mockSearchTvSeries = MockSearchTvSeries();
    searchBloc = TvSeriesSearchBloc(searchTvSeries: mockSearchTvSeries);
  });

  const tQuery = 'spiderman';

  test('initial state should be empty', () {
    expect(searchBloc.state, TvSeriesSearchEmpty());
  });

  blocTest<TvSeriesSearchBloc, TvSeriesSearchState>(
    'should emit [Loading, HasData] when data is gotten successfully',
    build: () {
      when(() => mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => Right(testTvSeriesList));
      return searchBloc;
    },
    act: (bloc) => bloc.add(FetchTvSeriesSearch(tQuery)),
    expect: () => [
      TvSeriesSearchLoading(),
      TvSeriesSearchHasData(testTvSeriesList),
    ],
    verify: (bloc) {
      verify(() => mockSearchTvSeries.execute(tQuery));
    },
  );

  blocTest<TvSeriesSearchBloc, TvSeriesSearchState>(
    'should emit [Loading, Error] when data is unsuccessful',
    build: () {
      when(() => mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
      return searchBloc;
    },
    act: (bloc) => bloc.add(FetchTvSeriesSearch(tQuery)),
    expect: () => [
      TvSeriesSearchLoading(),
      TvSeriesSearchError('Server Failure'),
    ],
    verify: (bloc) {
      verify(() => mockSearchTvSeries.execute(tQuery));
    },
  );
}
