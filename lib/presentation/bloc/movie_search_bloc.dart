import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';

// Event
abstract class MovieSearchEvent extends Equatable {
  const MovieSearchEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovieSearch extends MovieSearchEvent {
  final String query;

  const FetchMovieSearch(this.query);

  @override
  List<Object?> get props => [query];
}

// State
abstract class MovieSearchState extends Equatable {
  const MovieSearchState();

  @override
  List<Object?> get props => [];
}

class MovieSearchEmpty extends MovieSearchState {}

class MovieSearchLoading extends MovieSearchState {}

class MovieSearchError extends MovieSearchState {
  final String message;

  const MovieSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class MovieSearchHasData extends MovieSearchState {
  final List<Movie> result;

  const MovieSearchHasData(this.result);

  @override
  List<Object?> get props => [result];
}

// Bloc
class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  final SearchMovies searchMovies;

  MovieSearchBloc({required this.searchMovies}) : super(MovieSearchEmpty()) {
    on<FetchMovieSearch>((event, emit) async {
      emit(MovieSearchLoading());
      final result = await searchMovies.execute(event.query);
      result.fold(
        (failure) {
          emit(MovieSearchError(failure.message));
        },
        (data) {
          emit(MovieSearchHasData(data));
        },
      );
    });
  }
}
