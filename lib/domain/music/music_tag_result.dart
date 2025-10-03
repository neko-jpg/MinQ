import 'package:equatable/equatable.dart';

class MusicTagResult extends Equatable {
  const MusicTagResult({
    required this.title,
    required this.album,
    required this.artists,
    required this.score,
    required this.genres,
  });

  final String title;
  final String album;
  final List<String> artists;
  final double score;
  final List<String> genres;

  bool get isConfident => score >= 0.6;

  @override
  List<Object?> get props => [title, album, artists, score, genres];
}
