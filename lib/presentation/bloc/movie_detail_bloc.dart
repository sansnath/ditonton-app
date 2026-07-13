import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';

// Events
abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovieDetail extends MovieDetailEvent {
  final int id;

  const FetchMovieDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class AddWatchlistEvent extends MovieDetailEvent {
  final MovieDetail movieDetail;

  const AddWatchlistEvent(this.movieDetail);

  @override
  List<Object?> get props => [movieDetail];
}

class RemoveWatchlistEvent extends MovieDetailEvent {
  final MovieDetail movieDetail;

  const RemoveWatchlistEvent(this.movieDetail);

  @override
  List<Object?> get props => [movieDetail];
}

class LoadWatchlistStatusEvent extends MovieDetailEvent {
  final int id;

  const LoadWatchlistStatusEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// State
class MovieDetailState extends Equatable {
  final MovieDetail? movieDetail;
  final RequestState movieDetailState;
  final List<Movie> movieRecommendations;
  final RequestState recommendationState;
  final bool isAddedToWatchlist;
  final String message;
  final String watchlistMessage;

  const MovieDetailState({
    required this.movieDetail,
    required this.movieDetailState,
    required this.movieRecommendations,
    required this.recommendationState,
    required this.isAddedToWatchlist,
    required this.message,
    required this.watchlistMessage,
  });

  factory MovieDetailState.initial() {
    return const MovieDetailState(
      movieDetail: null,
      movieDetailState: RequestState.Empty,
      movieRecommendations: [],
      recommendationState: RequestState.Empty,
      isAddedToWatchlist: false,
      message: '',
      watchlistMessage: '',
    );
  }

  MovieDetailState copyWith({
    MovieDetail? movieDetail,
    RequestState? movieDetailState,
    List<Movie>? movieRecommendations,
    RequestState? recommendationState,
    bool? isAddedToWatchlist,
    String? message,
    String? watchlistMessage,
  }) {
    return MovieDetailState(
      movieDetail: movieDetail ?? this.movieDetail,
      movieDetailState: movieDetailState ?? this.movieDetailState,
      movieRecommendations: movieRecommendations ?? this.movieRecommendations,
      recommendationState: recommendationState ?? this.recommendationState,
      isAddedToWatchlist: isAddedToWatchlist ?? this.isAddedToWatchlist,
      message: message ?? this.message,
      watchlistMessage: watchlistMessage ?? this.watchlistMessage,
    );
  }

  @override
  List<Object?> get props => [
        movieDetail,
        movieDetailState,
        movieRecommendations,
        recommendationState,
        isAddedToWatchlist,
        message,
        watchlistMessage,
      ];
}

// Bloc
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final GetMovieDetail getMovieDetail;
  final GetMovieRecommendations getMovieRecommendations;
  final GetWatchListStatus getWatchListStatus;
  final SaveWatchlist saveWatchlist;
  final RemoveWatchlist removeWatchlist;

  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  MovieDetailBloc({
    required this.getMovieDetail,
    required this.getMovieRecommendations,
    required this.getWatchListStatus,
    required this.saveWatchlist,
    required this.removeWatchlist,
  }) : super(MovieDetailState.initial()) {
    on<FetchMovieDetail>((event, emit) async {
      emit(state.copyWith(movieDetailState: RequestState.Loading));
      final detailResult = await getMovieDetail.execute(event.id);
      final recommendationResult = await getMovieRecommendations.execute(event.id);

      await detailResult.fold(
        (failure) async {
          emit(state.copyWith(
            movieDetailState: RequestState.Error,
            message: failure.message,
          ));
        },
        (movie) async {
          emit(state.copyWith(
            movieDetailState: RequestState.Loaded,
            movieDetail: movie,
            recommendationState: RequestState.Loading,
          ));
          await recommendationResult.fold(
            (failure) async {
              emit(state.copyWith(
                recommendationState: RequestState.Error,
                message: failure.message,
              ));
            },
            (movies) async {
              emit(state.copyWith(
                recommendationState: RequestState.Loaded,
                movieRecommendations: movies,
              ));
            },
          );
        },
      );
    });

    on<AddWatchlistEvent>((event, emit) async {
      final result = await saveWatchlist.execute(event.movieDetail);
      await result.fold(
        (failure) async {
          emit(state.copyWith(watchlistMessage: failure.message));
        },
        (successMessage) async {
          emit(state.copyWith(watchlistMessage: successMessage));
        },
      );
      add(LoadWatchlistStatusEvent(event.movieDetail.id));
    });

    on<RemoveWatchlistEvent>((event, emit) async {
      final result = await removeWatchlist.execute(event.movieDetail);
      await result.fold(
        (failure) async {
          emit(state.copyWith(watchlistMessage: failure.message));
        },
        (successMessage) async {
          emit(state.copyWith(watchlistMessage: successMessage));
        },
      );
      add(LoadWatchlistStatusEvent(event.movieDetail.id));
    });

    on<LoadWatchlistStatusEvent>((event, emit) async {
      final result = await getWatchListStatus.execute(event.id);
      emit(state.copyWith(isAddedToWatchlist: result));
    });
  }
}
