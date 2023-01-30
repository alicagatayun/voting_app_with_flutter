import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'action_event.dart';
part 'action_state.dart';

class ActionBloc extends Bloc<ActionEvent, ActionState> {
  ActionBloc() : super(ActionInitial()) {
    on<ActionEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
/*
Future<List<BookingList>> getAllData() async {
    print("Active Users");
    var val = await fireStore
        .collection("booking")
        .getDocuments();
    var documents = val.documents;
    print("Documents ${documents.length}");
    if (documents.length > 0) {
      try {
        print("Active ${documents.length}");
        return documents.map((document) {
          BookingList bookingList = BookingList.fromJson(Map<String, dynamic>.from(document.data));

          return bookingList;
        }).toList();
      } catch (e) {
        print("Exception $e");
        return [];
      }
    }
    return [];
  }
 */