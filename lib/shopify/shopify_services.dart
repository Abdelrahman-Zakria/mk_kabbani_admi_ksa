import 'dart:developer';

import 'package:graphql/client.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;
import 'package:mk_kabbani_admin/shopify/shopify_query.dart';

class ShopifyService {
  ShopifyService() : super() {
    client = getClient();
  }

  late GraphQLClient client;

  GraphQLClient getClient() {
    final httpLink =
    HttpLink('https://kabbani-mk.myshopify.com//api/graphql');
    final authLink = AuthLink(
      headerKey: 'X-Shopify-Storefront-Access-Token',
      getToken: () async => 'fbb12ed06980595292f0c0b0cf234e5a',
    );
    return GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
  }

  Future<List<cat.Category>> getCategoriesByCursor(
      {List<cat.Category>? categories, String? cursor}) async {
    print("Fetch categories started");
    try {
      const nRepositories = 50;
      var variables = <String, dynamic>{
        'nRepositories': nRepositories,
      };

      log(":::: getCategoriesByCursor cursor : $cursor");

      if (cursor != null) {
        variables['cursor'] = cursor;
      }
      final options = QueryOptions(
        document: gql(ShopifyQuery.readCollections),
        variables: variables,
      );


      final result = await client.query(options) ;

      if (result.hasException) {
        log(result.exception.toString());
      }

      var list = categories ?? <cat.Category>[];
      log("From collections: ${result.data!['collections']['edges'][0]['node']}");
      list = [];
      for (var item in result.data!['collections']['edges']) {
        var category = item['node'];
        list.add(cat.Category.fromJsonShopify(category));
      }
      if (result.data?['collections']?['pageInfo']?['hasNextPage'] ?? false) {
        var lastCategory = result.data!['collections']['edges'].last;
        String? cursor = lastCategory['cursor'];
        if (cursor != null) {
          log('::::getCategories shopify by cursor $cursor');
          return await getCategoriesByCursor(categories: list, cursor: cursor);
        }
      }
      print("First category: ${list.length}");
      print("Col length: ${list.length}");
      for(var e in list){
        print("Collection ${e.isRoot.toString()}");
      }
      return list;
    } catch (e) {
      return categories ?? [];
    }
  }

}