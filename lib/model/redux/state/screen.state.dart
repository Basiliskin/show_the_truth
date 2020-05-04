import 'package:meta/meta.dart';

@immutable
class ScreenState {
  final Map<String, dynamic> data;

  ScreenState({@required this.data});

  factory ScreenState.initial() {
    return new ScreenState(data: null);
  }

  ScreenState copyWith({Map<String, dynamic> data}) {
    return new ScreenState(data: data ?? this.data);
  }

  screen(String language) {
    return data != null ? data[language] : null;
  }
}
