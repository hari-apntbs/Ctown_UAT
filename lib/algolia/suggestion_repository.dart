import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:ctown/algolia/query_suggestion.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants/general.dart';
import 'credentials.dart';

/// Query suggestions data repository.
class SuggestionRepository {

  late HitsSearcher _suggestionsSearcher;

  SuggestionRepository({required String initialIndexName}) {
    _suggestionsSearcher = HitsSearcher(
      applicationID: Credentials.applicationID,
      apiKey: Credentials.searchOnlyKey,
      indexName: initialIndexName,
    );
  }

  /// Set the index name dynamically.
  void setIndexName(String newIndexName) {
    _suggestionsSearcher.dispose(); // Dispose the existing searcher
    _suggestionsSearcher = HitsSearcher(
      applicationID: Credentials.applicationID,
      apiKey: Credentials.searchOnlyKey,
      indexName: newIndexName,
    );
  }

  /// Hits Searcher for suggestions index
  // final _suggestionsSearcher = HitsSearcher(
  //   applicationID: Credentials.applicationID,
  //   apiKey: Credentials.searchOnlyKey,
  //   indexName: "Abdali_en_67",
  // );

  /// Get query suggestions for a given query string.
  void query(String query) {
    _suggestionsSearcher.query(query);
  }

  /// Get query suggestions stream
  late final Stream<List<QuerySuggestion>> suggestions = _suggestionsSearcher
      .responses
      .map((response) => response.hits.map(QuerySuggestion.fromJson).toList());

  /// In-memory store of submitted queries.
  final BehaviorSubject<List<String>> _history =
  BehaviorSubject.seeded(['Apple']);

  /// Stream of previously submitted queries.
  Stream<List<String>> get history => _history;

  /// Add a query to queries history store.
  void addToHistory(String query) {
    if (query.isEmpty) return;
    final _current = _history.value;
    _current.removeWhere((element) => element == query);
    _current.add(query);
    _history.sink.add(_current);
  }

  Future<void> saveKeywords(List<String> keywords) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kLocalKey["recentSearches"]!, keywords);
      _history.sink.add(keywords);
    } catch (_) {
      printLog(_.toString());
    }
  }

  void getKeywords(String query) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? list = prefs.getStringList(kLocalKey["recentSearches"]!);
      if (list != null && list.isNotEmpty) {
        list.removeWhere((element) => element == query);
        list.add(query);
        _history.sink.add(list);
      }
    } catch (_) {}
  }

  /// Remove a query from queries history store.
  void removeFromHistory(String query) {
    final _current = _history.value;
    _current.removeWhere((element) => element == query);
    _history.sink.add(_current);
  }

  /// Clear everything from queries history store.
  void clearHistory() {
    _history.sink.add([]);
  }

  /// Dispose of underlying resources.
  void dispose() {
    _suggestionsSearcher.dispose();
  }
}
