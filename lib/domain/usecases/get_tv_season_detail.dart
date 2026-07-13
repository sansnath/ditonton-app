import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/entities/tv_season_detail.dart';
import 'package:ditonton/domain/repositories/tv_series_repository.dart';
import 'package:ditonton/common/failure.dart';

class GetTvSeasonDetail {
  final TvSeriesRepository repository;

  GetTvSeasonDetail(this.repository);

  Future<Either<Failure, TvSeasonDetail>> execute(int tvId, int seasonNumber) {
    return repository.getTvSeasonDetail(tvId, seasonNumber);
  }
}
