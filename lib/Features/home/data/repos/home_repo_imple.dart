import 'dart:developer';

import 'package:bookly/Features/home/data/data_sources/home_local_data_sources.dart';
import 'package:bookly/Features/home/data/data_sources/home_remote_data_sources.dart';
import 'package:bookly/Features/home/domain/entities/book_entity.dart';
import 'package:bookly/Features/home/domain/repos/home_repo.dart';
import 'package:bookly/core/errors/failure.dart';
import 'package:bookly/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class HomeRepoImple extends HomeRepo {
  final HomeLocalDataSources homeLocalDataSources;
  final HomeRemoteDataSources homeRemoteDataSources;
  final NetworkInfo networkInfo;

  HomeRepoImple(
      {required this.networkInfo,
      required this.homeLocalDataSources,
      required this.homeRemoteDataSources});
  @override
  Future<Either<Failure, List<BookEntity>>> fetchFeaturedBooks(
      {int page = 0}) async {
    try {
      List<BookEntity> books;
      books = homeLocalDataSources.fetchNewestBooks();
      if (books.isNotEmpty && !(await networkInfo.isConneced)) {
        log("No Internet Connection");
        // return right(books);
      }
      books = await homeRemoteDataSources.fetchFeaturedBooks(page: page);
      return right(books);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> fetchNewestBooks(
      {int page = 0}) async {
    try {
      List<BookEntity> books;
      // books = homeLocalDataSources.fetchNewestBooks();
      // if (books.isNotEmpty && !(await networkInfo.isConneced)) {
      //   log("No Internet Connection");
      //   return right(books);
      // }
      books = await homeRemoteDataSources.fetchNewestBooks(page: page);
      return right(books);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: 'error'));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> fetchSimilarBooks(
      {required String category}) async {
    try {
      List<BookEntity> books;
      books = await homeRemoteDataSources.fetchSimilarBooks(category: category);
      return right(books);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: 'error'));
    }
  }
}
