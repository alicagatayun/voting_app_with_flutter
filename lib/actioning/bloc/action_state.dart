part of 'action_bloc.dart';

abstract class ActionState extends Equatable {
  const ActionState();
}

class ActionInitial extends ActionState {
  @override
  List<Object> get props => [];
}
