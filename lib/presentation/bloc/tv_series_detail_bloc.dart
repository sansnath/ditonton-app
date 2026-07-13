import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_series_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_series_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tv_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist_tv.dart';
import 'package:ditonton/domain/usecases/save_watchlist_tv.dart';

// Events
abstract class TvSeriesDetailEvent extends Equatable {
  const TvSeriesDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchTvSeriesDetail extends TvSeriesDetailEvent {
  final int id;

  const FetchTvSeriesDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class AddWatchlistTvEvent extends TvSeriesDetailEvent {
  final TvSeriesDetail tvSeriesDetail;

  const AddWatchlistTvEvent(this.tvSeriesDetail);

  @override
  List<Object?> get props => [tvSeriesDetail];
}

class RemoveWatchlistTvEvent extends TvSeriesDetailEvent {
  final TvSeriesDetail tvSeriesDetail;

  const RemoveWatchlistTvEvent(this.tvSeriesDetail);

  @override
  List<Object?> get props => [tvSeriesDetail];
}

class LoadWatchlistTvStatusEvent extends TvSeriesDetailEvent {
  final int id;

  const LoadWatchlistTvStatusEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// State
class TvSeriesDetailState extends Equatable {
  final TvSeriesDetail? tvSeriesDetail;
  final RequestState tvSeriesDetailState;
  final List<TvSeries> tvRecommendations;
  final RequestState recommendationState;
  final bool isAddedToWatchlist;
  final String message;
  final String watchlistMessage;

  const TvSeriesDetailState({
    required this.tvSeriesDetail,
    required this.tvSeriesDetailState,
    required this.tvRecommendations,
    required this.recommendationState,
    required this.isAddedToWatchlist,
    required this.message,
    required this.watchlistMessage,
  });

  factory TvSeriesDetailState.initial() {
    return const TvSeriesDetailState(
      tvSeriesDetail: null,
      tvSeriesDetailState: RequestState.Empty,
      tvRecommendations: [],
      recommendationState: RequestState.Empty,
      isAddedToWatchlist: false,
      message: '',
      watchlistMessage: '',
    );
  }

  TvSeriesDetailState copyWith({
    TvSeriesDetail? tvSeriesDetail,
    RequestState? tvSeriesDetailState,
    List<TvSeries>? tvRecommendations,
    RequestState? recommendationState,
    bool? isAddedToWatchlist,
    String? message,
    String? watchlistMessage,
  }) {
    return TvSeriesDetailState(
      tvSeriesDetail: tvSeriesDetail ?? this.tvSeriesDetail,
      tvSeriesDetailState: tvSeriesDetailState ?? this.tvSeriesDetailState,
      tvRecommendations: tvRecommendations ?? this.tvRecommendations,
      recommendationState: recommendationState ?? this.recommendationState,
      isAddedToWatchlist: isAddedToWatchlist ?? this.isAddedToWatchlist,
      message: message ?? this.message,
      watchlistMessage: watchlistMessage ?? this.watchlistMessage,
    );
  }

  @override
  List<Object?> get props => [
        tvSeriesDetail,
        tvSeriesDetailState,
        tvRecommendations,
        recommendationState,
        isAddedToWatchlist,
        message,
        watchlistMessage,
      ];
}

// Bloc
class TvSeriesDetailBloc extends Bloc<TvSeriesDetailEvent, TvSeriesDetailState> {
  final GetTvSeriesDetail getTvSeriesDetail;
  final GetTvSeriesRecommendations getTvSeriesRecommendations;
  final GetWatchlistTvStatus getWatchlistTvStatus;
  final SaveWatchlistTv saveWatchlistTv;
  final RemoveWatchlistTv removeWatchlistTv;

  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  TvSeriesDetailBloc({
    required this.getTvSeriesDetail,
    required this.getTvSeriesRecommendations,
    required this.getWatchlistTvStatus,
    required this.saveWatchlistTv,
    required this.removeWatchlistTv,
  }) : super(TvSeriesDetailState.initial()) {
    on<FetchTvSeriesDetail>((event, emit) async {
      emit(state.copyWith(tvSeriesDetailState: RequestState.Loading));
      final detailResult = await getTvSeriesDetail.execute(event.id);
      final recommendationResult = await getTvSeriesRecommendations.execute(event.id);

      await detailResult.fold(
        (failure) async {
          emit(state.copyWith(
            tvSeriesDetailState: RequestState.Error,
            message: failure.message,
          ));
        },
        (tvSeries) async {
          emit(state.copyWith(
            tvSeriesDetailState: RequestState.Loaded,
            tvSeriesDetail: tvSeries,
            recommendationState: RequestState.Loading,
          ));
          await recommendationResult.fold(
            (failure) async {
              emit(state.copyWith(
                recommendationState: RequestState.Error,
                message: failure.message,
              ));
            },
            (tvs) async {
              emit(state.copyWith(
                recommendationState: RequestState.Loaded,
                tvRecommendations: tvs,
              ));
            },
          );
        },
      );
    });

    on<AddWatchlistTvEvent>((event, emit) async {
      final result = await saveWatchlistTv.execute(event.tvSeriesDetail);
      await result.fold(
        (failure) async {
          emit(state.copyWith(watchlistMessage: failure.message));
        },
        (successMessage) async {
          emit(state.copyWith(watchlistMessage: successMessage));
        },
      );
      add(LoadWatchlistTvStatusEvent(event.tvSeriesDetail.id));
    });

    on<RemoveWatchlistTvEvent>((event, emit) async {
      final result = await removeWatchlistTv.execute(event.tvSeriesDetail);
      await result.fold(
        (failure) async {
          emit(state.copyWith(watchlistMessage: failure.message));
        },
        (successMessage) async {
          emit(state.copyWith(watchlistMessage: successMessage));
        },
      );
      add(LoadWatchlistTvStatusEvent(event.tvSeriesDetail.id));
    });

    on<LoadWatchlistTvStatusEvent>((event, emit) async {
      final result = await getWatchlistTvStatus.execute(event.id);
      emit(state.copyWith(isAddedToWatchlist: result));
    });
  }
}
