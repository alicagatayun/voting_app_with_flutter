part of 'room_bloc.dart';

class RoomState extends Equatable {
  const RoomState({this.rooms = const <Room>[]});

  final List<Room> rooms;

  @override
  List<Object> get props => [rooms];
}
