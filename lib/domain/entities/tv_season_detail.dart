import 'package:ditonton/domain/entities/tv_episode.dart';
import 'package:equatable/equatable.dart';

class TvSeasonDetail extends Equatable {
  TvSeasonDetail({
    required this.id,
    required this.name,
    required this.overview,
    required this.episodes,
    required this.posterPath,
    required this.seasonNumber,
  });

  final int id;
  final String name;
  final String overview;
  final List<TvEpisode> episodes;
  final String? posterPath;
  final int seasonNumber;

  @override
  List<Object?> get props => [
        id,
        name,
        overview,
        episodes,
        posterPath,
        seasonNumber,
      ];
}
