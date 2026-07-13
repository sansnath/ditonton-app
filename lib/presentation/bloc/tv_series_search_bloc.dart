import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/usecases/search_tv_series.dart';

// Event
abstract class TvSeriesSearchEvent extends Equatable {
  const TvSeriesSearchEvent();

  @override
  List<Object?> get props => [];
}

class FetchTvSeriesSearch extends TvSeriesSearchEvent {
  final String query;

  const FetchTvSeriesSearch(this.query);

  @override
  List<Object?> get props => [query];
}

// State
abstract class TvSeriesSearchState extends Equatable {
  const TvSeriesSearchState();

  @override
  List<Object?> get props => [];
}

class TvSeriesSearchEmpty extends TvSeriesSearchState {}

class TvSeriesSearchLoading extends TvSeriesSearchState {}

class TvSeriesSearchError extends TvSeriesSearchState {
  final String message;

  const TvSeriesSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class TvSeriesSearchHasData extends TvSeriesSearchState {
  final List<TvSeries> result;

  const TvSeriesSearchHasData(this.result);

  @override
  List<Object?> get props => [result];
}

// Bloc
class TvSeriesSearchBloc extends Bloc<TvSeriesSearchEvent, TvSeriesSearchState> {
  final SearchTvSeries searchTvSeries;

  TvSeriesSearchBloc({required this.searchTvSeries}) : super(TvSeriesSearchEmpty()) {
    on<FetchTvSeriesSearch>((event, emit) async {
      emit(TvSeriesSearchLoading());
      final result = await searchTvSeries.execute(event.query);
      result.fold(
        (failure) {
          emit(TvSeriesSearchError(failure.message));
        },
        (data) {
          emit(TvSeriesSearchHasData(data));
        },
      );
    });
  }
}
