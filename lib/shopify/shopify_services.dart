import 'dart:developer';

import 'package:graphql/client.dart';
import 'package:mk_kabbani_admin/models/category_model.dart' as cat;
import 'package:mk_kabbani_admin/shopify/shopify_query.dart';

import '../models/product_model.dart' as product_model;
import 'shopify_storage.dart';




class ShopifyService {
  ShopifyService() : super() {
    client = getClient();
  }

  late GraphQLClient client;
  ShopifyStorage shopifyStorage = ShopifyStorage();


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


  Future<List<product_model.Product>> getAllProduct({
    categoryId,
    tagId,
    page = 1,
    minPrice,
    maxPrice,
    orderBy,
    lang,
    order,
    attribute,
    attributeTerm,
    featured,
    onSale,
    listingLocation,
    userId,
    nextCursor,
    String? include,
    String? search,
    limit,
    sortKey,
    reverse,
    color,
    query,
  }) async {
    List<product_model.Product> productList = [];
    bool hasNextPage = true;
    String? cursor;

    while (hasNextPage) {
      try {
        log('::::request fetchProductsByCategory with category id $categoryId search:$search');
        log('::::request fetchProductsByCategory with cursor $cursor');

        final options = QueryOptions(
          document: gql(ShopifyQuery.getProducts),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: <String, dynamic>{
            'pageSize': limit ?? 100,
            'color': color,
            'lang': "EN",
            if (sortKey != "" && sortKey != null) 'sortKey': sortKey ?? "",
            'reverse': reverse,
            'query': query,
            'cursor': cursor,
          },
        );

        final result = await client.query(options);

        if (result.hasException) {
          log(result.exception.toString());
          break;
        }

        var node = result.data?['products'];

        if (node != null) {
          var productResp = node;
          var pageInfo = productResp['pageInfo'];
          hasNextPage = pageInfo['hasNextPage'];
          var edges = productResp['edges'];

          if (edges.isNotEmpty) {
            cursor = edges.last['cursor'];

            for (var item in edges) {
              var product = item['node'];
              product['categoryId'] = categoryId;
              productList.add(product_model.Product.fromShopify(product));
            }
          }
        } else {
          hasNextPage = false;
        }
      } catch (e) {
        log('::::fetchProductsByCategory shopify error $e');
        log(e.toString());
        rethrow;
      }
    }

    log("Total products fetched: ${productList.length}");
    return productList;
  }


}