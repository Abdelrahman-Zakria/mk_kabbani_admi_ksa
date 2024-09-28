class ShopifyQuery{
  static String readCollections = '''
    query(\$cursor: String , ) @inContext(language: EN){
       collections(first: 250, after: \$cursor){
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              title
              description
              image() {
                id
                src
              }
            }
          }
        }
      }
    ''';


  static String getProducts = '''
    query(\$cursor: String, \$lang: LanguageCode, \$pageSize: Int, \$query: String, \$reverse : Boolean, \$sortKey: ProductSortKeys, ) @inContext(language: \$lang){
     products(first: \$pageSize, after: \$cursor, sortKey: \$sortKey, query: \$query, reverse: \$reverse) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
              cursor
              node {
                id
                title
                vendor
                description
                descriptionHtml
                totalInventory
                availableForSale
                productType
                onlineStoreUrl
                collections(first: 1) {
                  pageInfo {
                    hasNextPage
                    hasPreviousPage
                  }
                  edges {
                    node {
                      id
                    }
                  }
                }
                options {
                  id
                  name
                  values
                }
                variants(first: 250) {
                  pageInfo {
                    hasNextPage
                    hasPreviousPage
                  }
                  edges {
                    node {
                      id
                      title
                      availableForSale
                      quantityAvailable
                      selectedOptions {
                        name
                        value
                      }
                      image() {
                        src
                      }
                      priceV2 {
                        amount
                        currencyCode
                      }
                      compareAtPriceV2 {
                        amount
                        currencyCode
                      }
                    }
                  }
                }
                images(first: 250) {
                  edges {
                    node {
                      src
                    }
                  }
                }
              }
          }
      }
    }
  ''';

}