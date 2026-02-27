import 'package:customer_app/domain/entities/provider.dart';
import 'package:customer_app/domain/entities/search_filter.dart';
import 'package:customer_app/domain/repositories/search_repository.dart';

class SearchProviders {
  final SearchRepository repository;

  SearchProviders(this.repository);

  Future<List<Provider>> call(SearchFilter filter) {
    return repository.searchProviders(filter);
  }
}
