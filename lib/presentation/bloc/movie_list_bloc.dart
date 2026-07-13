import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';

// Event
abstract class MovieListEvent extends Equatable {
  const MovieListEvent();

  @override
  List<Object?> get props => [];
}

class FetchNowPlayingMovies extends MovieListEvent {}
class FetchPopularMovies extends MovieListEvent {}
class FetchTopRatedMovies extends MovieListEvent {}

// State
class MovieListState extends Equatable {
  final RequestState nowPlayingState;
  final List<Movie> nowPlayingMovies;
  final RequestState popularState;
  final List<Movie> popularMovies;
  final RequestState topRatedState;
  final List<Movie> topRatedMovies;
  final String message;

  const MovieListState({
    required this.nowPlayingState,
    required this.nowPlayingMovies,
    required this.popularState,
    required this.popularMovies,
    required this.topRatedState,
    required this.topRatedMovies,
    required this.message,
  });

  factory MovieListState.initial() {
    return const MovieListState(
      nowPlayingState: RequestState.Empty,
      nowPlayingMovies: [],
      popularState: RequestState.Empty,
      popularMovies: [],
      topRatedState: RequestState.Empty,
      topRatedMovies: [],
      message: '',
    );
  }

  MovieListState copyWith({
    RequestState? nowPlayingState,
    List<Movie>? nowPlayingMovies,
    RequestState? popularState,
    List<Movie>? popularMovies,
    RequestState? topRatedState,
    List<Movie>? topRatedMovies,
    String? message,
  }) {
    return MovieListState(
      nowPlayingState: nowPlayingState ?? this.nowPlayingState,
      nowPlayingMovies: nowPlayingMovies ?? this.nowPlayingMovies,
      popularState: popularState ?? this.popularState,
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedState: topRatedState ?? this.topRatedState,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        nowPlayingState,
        nowPlayingMovies,
        popularState,
        popularMovies,
        topRatedState,
        topRatedMovies,
        message,
      ];
}

// Bloc
class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final GetNowPlayingMovies getNowPlayingMovies;
  final GetPopularMovies getPopularMovies;
  final GetTopRatedMovies getTopRatedMovies;

  MovieListBloc({
    required this.getNowPlayingMovies,
    required this.getPopularMovies,
    required this.getTopRatedMovies,
  }) : super(MovieListState.initial()) {
    on<FetchNowPlayingMovies>((event, emit) async {
      emit(state.copyWith(nowPlayingState: RequestState.Loading));
      final result = await getNowPlayingMovies.execute();
      result.fold(
        (failure) {
          emit(state.copyWith(
            nowPlayingState: RequestState.Error,
            message: failure.message,
          ));
        },
        (moviesData) {
          emit(state.copyWith(
            nowPlayingState: RequestState.Loaded,
            nowPlayingMovies: moviesData,
          ));
        },
      );
    });

    on<FetchPopularMovies>((event, emit) async {
      emit(state.copyWith(popularState: RequestState.Loading));
      final result = await getPopularMovies.execute();
      result.fold(
        (failure) {
          emit(state.copyWith(
            popularState: RequestState.Error,
            message: failure.message,
          ));
        },
        (moviesData) {
          emit(state.copyWith(
            popularState: RequestState.Loaded,
            popularMovies: moviesData,
          ));
        },
      );
    });

    on<FetchTopRatedMovies>((event, emit) async {
      emit(state.copyWith(topRatedState: RequestState.Loading));
      final result = await getTopRatedMovies.execute();
      result.fold(
        (failure) {
          emit(state.copyWith(
            topRatedState: RequestState.Error,
            message: failure.message,
          ));
        },
        (moviesData) {
          emit(state.copyWith(
            topRatedState: RequestState.Loaded,
            topRatedMovies: moviesData,
          ));
        },
      );
    });
  }
}
