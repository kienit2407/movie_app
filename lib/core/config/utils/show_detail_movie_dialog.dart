import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/presentation/bloc/detail_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/detail_movie_state.dart';

class ShowDetailMovieDialog extends StatefulWidget {
  const ShowDetailMovieDialog({super.key, required this.slug});
  final String slug;
  @override
  State<ShowDetailMovieDialog> createState() => _ShowDetailMovieDialogState();
}

class _ShowDetailMovieDialogState extends State<ShowDetailMovieDialog> {
  @override
  void initState() {
    context.read<DetailMovieCubit>().getDetailMovie(widget.slug);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BlocBuilder<DetailMovieCubit, DetailMovieState>(
        builder: (context, state) {
          if(state is DetailMovieSuccessed) {
            return _buidlDialog(state);
          }
          return _buildLoading();
        },
      ),
    );
  }
Widget _buildLoading() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          height: 200,
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white60.withOpacity(0.3),
                Colors.white10.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white60),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
  Widget _buidlDialog(DetailMovieSuccessed data) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          height: 600,
          width: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white60.withOpacity(.3),
                Colors.white10.withOpacity(.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white60),
          ),
          child: Text(data.detailMovieModel.movie.content),
        ),
      ),
    );
  }
}
