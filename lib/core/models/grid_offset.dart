import 'package:equatable/equatable.dart';

class GridOffset extends Equatable {
  final int row;
  final int col;

  const GridOffset(this.row, this.col);

  @override
  List<Object> get props => [row, col];

  @override
  String toString() => '$row,$col';
}
