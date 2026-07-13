import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:ditonton/presentation/bloc/movie_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNowPlayingMovies extends Mock implements GetNowPlayingMovies {}
class MockGetPopularMovies extends Mock implements GetPopularMovies {}
class MockGetTopRatedMovies extends Mock implements GetTopRatedMovies {}

void main() {
  late MovieListBloc movieListBloc;
  late MockGetNowPlayingMovies mockGetNowPlayingMovies;
  late MockGetPopularMovies mockGetPopularMovies;
  late MockGetTopRatedMovies mockGetTopRatedMovies;

  setUp(() {
    mockGetNowPlayingMovies = MockGetNowPlayingMovies();
    mockGetPopularMovies = MockGetPopularMovies();
    mockGetTopRatedMovies = MockGetTopRatedMovies();
    movieListBloc = MovieListBloc(
      getNowPlayingMovies: mockGetNowPlayingMovies,
      getPopularMovies: mockGetPopularMovies,
      getTopRatedMovies: mockGetTopRatedMovies,
    );
  });

  final tMovie = Movie(
    adult: false,
    backdropPath: 'backdropPath',
    genreIds: [1, 2, 3],
    id: 1,
    originalTitle: 'originalTitle',
    overview: 'overview',
    popularity: 1,
    posterPath: 'posterPath',
    releaseDate: 'releaseDate',
    title: 'title',
    video: false,
    voteAverage: 1,
    voteCount: 1,
  );
  final tMovieList = <Movie>[tMovie];

  test('initial state should be empty', () {
    expect(movieListBloc.state, MovieListState.initial());
  });

  group('now playing movies', () {
    blocTest<MovieListBloc, MovieListState>(
      'should emit [nowPlayingState: Loading, nowPlayingState: Loaded] when now playing is fetched successfully',
      build: () {
        when(() => mockGetNowPlayingMovies.execute())
            .thenAnswer((_) async => Right(tMovieList));
        return movieListBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingMovies()),
      expect: () => [
        MovieListState.initial().copyWith(nowPlayingState: RequestState.Loading),
        MovieListState.initial().copyWith(
          nowPlayingState: RequestState.Loaded,
          nowPlayingMovies: tMovieList,
        ),
      ],
    );

    blocTest<MovieListBloc, MovieListState>(
      'should emit [nowPlayingState: Loading, nowPlayingState: Error] when fetching fails',
      build: () {
        when(() => mockGetNowPlayingMovies.execute())
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return movieListBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingMovies()),
      expect: () => [
        MovieListState.initial().copyWith(nowPlayingState: RequestState.Loading),
        MovieListState.initial().copyWith(
          nowPlayingState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );
  });

  group('popular movies', () {
    blocTest<MovieListBloc, MovieListState>(
      'should emit [popularState: Loading, popularState: Loaded] when popular is fetched successfully',
      build: () {
        when(() => mockGetPopularMovies.execute())
            .thenAnswer((_) async => Right(tMovieList));
        return movieListBloc;
      },
      act: (bloc) => bloc.add(FetchPopularMovies()),
      expect: () => [
        MovieListState.initial().copyWith(popularState: RequestState.Loading),
        MovieListState.initial().copyWith(
          popularState: RequestState.Loaded,
          popularMovies: tMovieList,
        ),
      ],
    );

    blocTest<MovieListBloc, MovieListState>(
      'should emit [popularState: Loading, popularState: Error] when fetching popular fails',
      build: () {
        when(() => mockGetPopularMovies.execute())
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return movieListBloc;
      },
      act: (bloc) => bloc.add(FetchPopularMovies()),
      expect: () => [
        MovieListState.initial().copyWith(popularState: RequestState.Loading),
        MovieListState.initial().copyWith(
          popularState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );
  });

  group('top rated movies', () {
    blocTest<MovieListBloc, MovieListState>(
      'should emit [topRatedState: Loading, topRatedState: Loaded] when top rated is fetched successfully',
      build: () {
        when(() => mockGetTopRatedMovies.execute())
            .thenAnswer((_) async => Right(tMovieList));
        return movieListBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedMovies()),
      expect: () => [
        MovieListState.initial().copyWith(topRatedState: RequestState.Loading),
        MovieListState.initial().copyWith(
          topRatedState: RequestState.Loaded,
          topRatedMovies: tMovieList,
        ),
      ],
    );

    blocTest<MovieListBloc, MovieListState>(
      'should emit [topRatedState: Loading, topRatedState: Error] when fetching top rated fails',
      build: () {
        when(() => mockGetTopRatedMovies.execute())
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return movieListBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedMovies()),
      expect: () => [
        MovieListState.initial().copyWith(topRatedState: RequestState.Loading),
        MovieListState.initial().copyWith(
          topRatedState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );
  });
}
