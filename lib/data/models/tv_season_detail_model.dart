import 'package:ditonton/data/models/tv_episode_model.dart';
import 'package:ditonton/domain/entities/tv_season_detail.dart';
import 'package:equatable/equatable.dart';

class TvSeasonDetailModel extends Equatable {
  TvSeasonDetailModel({
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
  final List<TvEpisodeModel> episodes;
  final String? posterPath;
  final int seasonNumber;

  factory TvSeasonDetailModel.fromJson(Map<String, dynamic> json) =>
      TvSeasonDetailModel(
        id: json["id"],
        name: json["name"] ?? "",
        overview: json["overview"] ?? "",
        episodes: List<TvEpisodeModel>.from(
            (json["episodes"] as List? ?? []).map((x) => TvEpisodeModel.fromJson(x))),
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "overview": overview,
        "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
        "poster_path": posterPath,
        "season_number": seasonNumber,
      };

  TvSeasonDetail toEntity() {
    return TvSeasonDetail(
      id: id,
      name: name,
      overview: overview,
      episodes: episodes.map((episode) => episode.toEntity()).toList(),
      posterPath: posterPath,
      seasonNumber: seasonNumber,
    );
  }

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
