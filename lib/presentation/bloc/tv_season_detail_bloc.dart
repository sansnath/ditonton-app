import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ditonton/domain/entities/tv_season_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_season_detail.dart';

// Event
abstract class TvSeasonDetailEvent extends Equatable {
  const TvSeasonDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchTvSeasonDetail extends TvSeasonDetailEvent {
  final int tvId;
  final int seasonNumber;

  const FetchTvSeasonDetail({required this.tvId, required this.seasonNumber});

  @override
  List<Object?> get props => [tvId, seasonNumber];
}

// State
abstract class TvSeasonDetailState extends Equatable {
  const TvSeasonDetailState();

  @override
  List<Object?> get props => [];
}

class TvSeasonDetailEmpty extends TvSeasonDetailState {}

class TvSeasonDetailLoading extends TvSeasonDetailState {}

class TvSeasonDetailError extends TvSeasonDetailState {
  final String message;

  const TvSeasonDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class TvSeasonDetailHasData extends TvSeasonDetailState {
  final TvSeasonDetail result;

  const TvSeasonDetailHasData(this.result);

  @override
  List<Object?> get props => [result];
}

// Bloc
class TvSeasonDetailBloc extends Bloc<TvSeasonDetailEvent, TvSeasonDetailState> {
  final GetTvSeasonDetail getTvSeasonDetail;

  TvSeasonDetailBloc({required this.getTvSeasonDetail}) : super(TvSeasonDetailEmpty()) {
    on<FetchTvSeasonDetail>((event, emit) async {
      emit(TvSeasonDetailLoading());
      final result = await getTvSeasonDetail.execute(event.tvId, event.seasonNumber);
      result.fold(
        (failure) {
          emit(TvSeasonDetailError(failure.message));
        },
        (data) {
          emit(TvSeasonDetailHasData(data));
        },
      );
    });
  }
}
