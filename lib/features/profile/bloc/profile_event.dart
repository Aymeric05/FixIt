import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class UpdateNicknameRequested extends ProfileEvent {
  final String newNickname;
  const UpdateNicknameRequested(this.newNickname);

  @override
  List<Object> get props => [newNickname];
}

class UpdateAvatarRequested extends ProfileEvent {
  final String imagePath;
  const UpdateAvatarRequested(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
