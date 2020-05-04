import 'package:meta/meta.dart';

const prefsVersion = '1.0.1.1';
const prefsName = "smttState_$prefsVersion";
const defaultTile = 'Show me the truth';

const Map<String, dynamic> defaultConfig = {
  'title': defaultTile,
  'version': "Default - $prefsVersion"
};

@immutable
class ConfigState {
  final Map<String, bool> filter;
  final int isLoading;
  final String errorMessage;
  final Map<String, dynamic> data;
  final String language;
  final Map<String, Map<String, bool>> knesset;
  final Map<String, Map<String, bool>> knessetYears;
  final Map<String, Map<String, bool>> faction;

  ConfigState(
      {@required this.isLoading,
      @required this.errorMessage,
      @required this.data,
      @required this.language,
      @required this.filter,
      @required this.knesset,
      @required this.knessetYears,
      @required this.faction});

  factory ConfigState.initial() {
    return new ConfigState(
        isLoading: 1,
        errorMessage: "",
        data: null,
        language: "he",
        filter: {},
        knesset: null,
        knessetYears: null,
        faction: null);
  }

  ConfigState copyWith(
      {int isLoading,
      String errorMessage,
      Map<String, dynamic> data,
      String language,
      Map<String, bool> filter,
      Map<String, Map<String, bool>> knesset,
      Map<String, Map<String, bool>> knessetYears,
      Map<String, Map<String, bool>> faction}) {
    return new ConfigState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        data: data ?? this.data,
        language: language ?? this.language,
        filter: filter ?? this.filter,
        knesset: knesset ?? this.knesset,
        knessetYears: knessetYears ?? this.knessetYears,
        faction: faction ?? this.faction);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          language == other.language &&
          data == other.data;

  @override
  int get hashCode => isLoading.hashCode ^ data.hashCode;

  List<dynamic> languages() => data["languages"];
  Map<String, dynamic> screens(String name) =>
      data["screens"] && data["screens"].containsKey(name)
          ? data["screens"][name]
          : {};
}
