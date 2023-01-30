import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../actioning/model/rooms.dart';

part 'room_event.dart';

part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc() : super(const RoomState()) {
    on<GetRoomRequested>(_onGetRoomRequested);
    //ADD MORE here
  }

  void _onGetRoomRequested(GetRoomRequested event, Emitter<RoomState> emit) {

  }
}
