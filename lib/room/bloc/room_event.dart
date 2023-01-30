part of 'room_bloc.dart';

abstract class RoomEvent {
  const RoomEvent();
}

class GetRoomRequested extends RoomEvent {
  const GetRoomRequested();
}
