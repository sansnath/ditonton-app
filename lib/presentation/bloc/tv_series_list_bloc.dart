import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tv_series.dart';
import 'package:ditonton/domain/usecases/get_popular_tv_series.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tv_series.dart';

// Event
abstract class TvSeriesListEvent extends Equatable {
  const TvSeriesListEvent();

  @override
  List<Object?> get props => [];
}

class FetchNowPlayingTvSeries extends TvSeriesListEvent {}
class FetchPopularTvSeries extends TvSeriesListEvent {}
class FetchTopRatedTvSeries extends TvSeriesListEvent {}

// State
class TvSeriesListState extends Equatable {
  final RequestState nowPlayingState;
  final List<TvSeries> nowPlayingTvSeries;
  final RequestState popularState;
  final List<TvSeries> popularTvSeries;
  final RequestState topRatedState;
  final List<TvSeries> topRatedTvSeries;
  final String message;

  const TvSeriesListState({
    required this.nowPlayingState,
    required this.nowPlayingTvSeries,
    required this.popularState,
    required this.popularTvSeries,
    required this.topRatedState,
    required this.topRatedTvSeries,
    required this.message,
  });

  factory TvSeriesListState.initial() {
    return const TvSeriesListState(
      nowPlayingState: RequestState.Empty,
      nowPlayingTvSeries: [],
      popularState: RequestState.Empty,
      popularTvSeries: [],
      topRatedState: RequestState.Empty,
      topRatedTvSeries: [],
      message: '',
    );
  }

  TvSeriesListState copyWith({
    RequestState? nowPlayingState,
    List<TvSeries>? nowPlayingTvSeries,
    RequestState? popularState,
    List<TvSeries>? popularTvSeries,
    RequestState? topRatedState,
    List<TvSeries>? topRatedTvSeries,
    String? message,
  }) {
    return TvSeriesListState(
      nowPlayingState: nowPlayingState ?? this.nowPlayingState,
      nowPlayingTvSeries: nowPlayingTvSeries ?? this.nowPlayingTvSeries,
      popularState: popularState ?? this.popularState,
      popularTvSeries: popularTvSeries ?? this.popularTvSeries,
      topRatedState: topRatedState ?? this.topRatedState,
      topRatedTvSeries: topRatedTvSeries ?? this.topRatedTvSeries,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        nowPlayingState,
        nowPlayingTvSeries,
        popularState,
        popularTvSeries,
        topRatedState,
        topRatedTvSeries,
        message,
      ];
}

// Bloc
class TvSeriesListBloc extends Bloc<TvSeriesListEvent, TvSeriesListState> {
  final GetNowPlayingTvSeries getNowPlayingTvSeries;
  final GetPopularTvSeries getPopularTvSeries;
  final GetTopRatedTvSeries getTopRatedTvSeries;

  TvSeriesListBloc({
    required this.getNowPlayingTvSeries,
    required this.getPopularTvSeries,
    required this.getTopRatedTvSeries,
  }) : super(TvSeriesListState.initial()) {
    on<FetchNowPlayingTvSeries>((event, emit) async {
      emit(state.copyWith(nowPlayingState: RequestState.Loading));
      final result = await getNowPlayingTvSeries.execute();
      result.fold(
        (failure) {
          emit(state.copyWith(
            nowPlayingState: RequestState.Error,
            message: failure.message,
          ));
        },
        (tvData) {
          emit(state.copyWith(
            nowPlayingState: RequestState.Loaded,
            nowPlayingTvSeries: tvData,
          ));
        },
      );
    });

    on<FetchPopularTvSeries>((event, emit) async {
      emit(state.copyWith(popularState: RequestState.Loading));
      final result = await getPopularTvSeries.execute();
      result.fold(
        (failure) {
          emit(state.copyWith(
            popularState: RequestState.Error,
            message: failure.message,
          ));
        },
        (tvData) {
          emit(state.copyWith(
            popularState: RequestState.Loaded,
            popularTvSeries: tvData,
          ));
        },
      );
    });

    on<FetchTopRatedTvSeries>((event, emit) async {
      emit(state.copyWith(topRatedState: RequestState.Loading));
      final result = await getTopRatedTvSeries.execute();
      result.fold(
        (failure) {
          emit(state.copyWith(
            topRatedState: RequestState.Error,
            message: failure.message,
          ));
        },
        (tvData) {
          emit(state.copyWith(
            topRatedState: RequestState.Loaded,
            topRatedTvSeries: tvData,
          ));
        },
      );
    });
  }
}
