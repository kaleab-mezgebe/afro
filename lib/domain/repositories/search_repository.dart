import '../entities/provider.dart';
import '../entities/search_filter.dart';

abstract class SearchRepository {
  Future<List<Provider>> searchProviders(SearchFilter filter);
  Future<List<Provider>> getPopularProviders();
  Future<List<Provider>> getNearbyProviders(String location);
  Future<List<Provider>> getProvidersByCategory(String category);
  Future<List<Provider>> getProvidersByService(List<String> services);
}
