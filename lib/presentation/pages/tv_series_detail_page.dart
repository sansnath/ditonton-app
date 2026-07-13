import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:ditonton/domain/entities/tv_series_detail.dart';
import 'package:ditonton/presentation/bloc/tv_series_detail_bloc.dart';
import 'package:ditonton/presentation/bloc/tv_season_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TvSeriesDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/detail-tv';

  final int id;
  TvSeriesDetailPage({required this.id});

  @override
  _TvSeriesDetailPageState createState() => _TvSeriesDetailPageState();
}

class _TvSeriesDetailPageState extends State<TvSeriesDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TvSeriesDetailBloc>().add(FetchTvSeriesDetail(widget.id));
      context.read<TvSeriesDetailBloc>().add(LoadWatchlistTvStatusEvent(widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TvSeriesDetailBloc, TvSeriesDetailState>(
        listenWhen: (previous, current) =>
            previous.watchlistMessage != current.watchlistMessage &&
            current.watchlistMessage.isNotEmpty,
        listener: (context, state) {
          final message = state.watchlistMessage;
          if (message == TvSeriesDetailBloc.watchlistAddSuccessMessage ||
              message == TvSeriesDetailBloc.watchlistRemoveSuccessMessage) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(message),
                  );
                });
          }
        },
        child: BlocBuilder<TvSeriesDetailBloc, TvSeriesDetailState>(
          builder: (context, state) {
            if (state.tvSeriesDetailState == RequestState.Loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state.tvSeriesDetailState == RequestState.Loaded) {
              final tvSeries = state.tvSeriesDetail!;
              return SafeArea(
                child: DetailContent(
                  tvSeries,
                  state.tvRecommendations,
                  state.isAddedToWatchlist,
                ),
              );
            } else {
              return Center(
                child: Text(state.message),
              );
            }
          },
        ),
      ),
    );
  }
}

class DetailContent extends StatefulWidget {
  final TvSeriesDetail tvSeries;
  final List<TvSeries> recommendations;
  final bool isAddedWatchlist;

  DetailContent(this.tvSeries, this.recommendations, this.isAddedWatchlist);

  @override
  State<DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<DetailContent> {
  int _selectedSeasonNumber = 1;

  @override
  void initState() {
    super.initState();
    if (widget.tvSeries.seasons.isNotEmpty) {
      _selectedSeasonNumber = widget.tvSeries.seasons.first.seasonNumber;
      Future.microtask(() {
        context.read<TvSeasonDetailBloc>().add(FetchTvSeasonDetail(
              tvId: widget.tvSeries.id,
              seasonNumber: _selectedSeasonNumber,
            ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: 'https://image.tmdb.org/t/p/w500${widget.tvSeries.posterPath}',
          width: screenWidth,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        Container(
          margin: const EdgeInsets.only(top: 48 + 8),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: kRichBlack,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 16,
                  right: 16,
                ),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tvSeries.name,
                              style: kHeading5,
                            ),
                            FilledButton(
                              onPressed: () {
                                if (!widget.isAddedWatchlist) {
                                  context
                                      .read<TvSeriesDetailBloc>()
                                      .add(AddWatchlistTvEvent(widget.tvSeries));
                                } else {
                                  context
                                      .read<TvSeriesDetailBloc>()
                                      .add(RemoveWatchlistTvEvent(widget.tvSeries));
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  widget.isAddedWatchlist
                                      ? Icon(Icons.check)
                                      : Icon(Icons.add),
                                  Text('Watchlist'),
                                ],
                              ),
                            ),
                            Text(
                              _showGenres(widget.tvSeries.genres),
                            ),
                            Text(
                              _showDuration(widget.tvSeries.episodeRunTime),
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: widget.tvSeries.voteAverage / 2,
                                  itemCount: 5,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: kMikadoYellow,
                                  ),
                                  itemSize: 24,
                                ),
                                Text('${widget.tvSeries.voteAverage}')
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Overview',
                              style: kHeading6,
                            ),
                            Text(
                              widget.tvSeries.overview.isNotEmpty
                                  ? widget.tvSeries.overview
                                  : '-',
                            ),
                            SizedBox(height: 16),
                            if (widget.tvSeries.seasons.isNotEmpty) ...[
                              Text(
                                'Seasons',
                                style: kHeading6,
                              ),
                              Container(
                                height: 150,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.tvSeries.seasons.length,
                                  itemBuilder: (context, index) {
                                    final season = widget.tvSeries.seasons[index];
                                    final isSelected =
                                        season.seasonNumber == _selectedSeasonNumber;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedSeasonNumber = season.seasonNumber;
                                        });
                                        context.read<TvSeasonDetailBloc>().add(
                                              FetchTvSeasonDetail(
                                                tvId: widget.tvSeries.id,
                                                seasonNumber: season.seasonNumber,
                                              ),
                                            );
                                      },
                                      child: Container(
                                        width: 100,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? kMikadoYellow
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey.shade900,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: season.posterPath != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius.circular(
                                                                  6)),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            '$BASE_IMAGE_URL${season.posterPath}',
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        placeholder:
                                                            (context, url) =>
                                                                Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                        errorWidget: (context, url,
                                                                error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    )
                                                  : Icon(Icons.tv, size: 40),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text(
                                                season.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Text(
                                                '${season.episodeCount} Ep',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Episodes',
                                style: kHeading6,
                              ),
                              BlocBuilder<TvSeasonDetailBloc, TvSeasonDetailState>(
                                builder: (context, state) {
                                  if (state is TvSeasonDetailLoading) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (state is TvSeasonDetailHasData) {
                                    final episodes = state.result.episodes;
                                    if (episodes.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text('No episodes available'),
                                      );
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: episodes.length,
                                      itemBuilder: (context, index) {
                                        final episode = episodes[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: ListTile(
                                            leading: episode.stillPath != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          '$BASE_IMAGE_URL${episode.stillPath}',
                                                      width: 80,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                      errorWidget: (context, url,
                                                              error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 80,
                                                    height: 60,
                                                    color: Colors.grey.shade800,
                                                    child: Icon(Icons.movie),
                                                  ),
                                            title: Text(
                                              'Ep ${episode.episodeNumber}: ${episode.name}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              episode.overview.isNotEmpty
                                                  ? episode.overview
                                                  : 'No overview available.',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else if (state is TvSeasonDetailError) {
                                    return Text(state.message);
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                            Text(
                              'Recommendations',
                              style: kHeading6,
                            ),
                            BlocBuilder<TvSeriesDetailBloc, TvSeriesDetailState>(
                              builder: (context, state) {
                                if (state.recommendationState ==
                                    RequestState.Loading) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (state.recommendationState ==
                                    RequestState.Error) {
                                  return Text(state.message);
                                } else if (state.recommendationState ==
                                    RequestState.Loaded) {
                                  return Container(
                                    height: 150,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        final tv = widget.recommendations[index];
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pushReplacementNamed(
                                                context,
                                                TvSeriesDetailPage.ROUTE_NAME,
                                                arguments: tv.id,
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '$BASE_IMAGE_URL${tv.posterPath}',
                                                placeholder: (context, url) =>
                                                    Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: widget.recommendations.length,
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 4,
                          width: 40,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            height: 4,
                            width: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kRichBlack,
            foregroundColor: Colors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        )
      ],
    );
  }

  String _showGenres(List<Genre> genres) {
    String show = '';
    for (var genre in genres) {
      show += genre.name + ', ';
    }

    if (show.isEmpty) {
      return show;
    }

    return show.substring(0, show.length - 2);
  }

  String _showDuration(List<int> runtime) {
    if (runtime.isEmpty) return 'No Runtime info';
    return '${runtime[0]}m';
  }
}
