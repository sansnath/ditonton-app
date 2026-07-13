import 'package:ditonton/domain/repositories/tv_series_repository.dart';

class GetWatchlistTvStatus {
  final TvSeriesRepository repository;

  GetWatchlistTvStatus(this.repository);

  Future<bool> execute(int id) {
    return repository.isAddedToWatchlist(id);
  }
}
