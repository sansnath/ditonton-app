import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/usecases/get_tv_season_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late GetTvSeasonDetail usecase;
  late MockTvSeriesRepository mockTvRepository;

  setUp(() {
    mockTvRepository = MockTvSeriesRepository();
    usecase = GetTvSeasonDetail(mockTvRepository);
  });

  final tTvId = 1;
  final tSeasonNumber = 1;

  test('should get TV season detail from repository', () async {
    // arrange
    when(mockTvRepository.getTvSeasonDetail(tTvId, tSeasonNumber))
        .thenAnswer((_) async => Right(testTvSeasonDetail));
    // act
    final result = await usecase.execute(tTvId, tSeasonNumber);
    // assert
    expect(result, Right(testTvSeasonDetail));
  });
}
