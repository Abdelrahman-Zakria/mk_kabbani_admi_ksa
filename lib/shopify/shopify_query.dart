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
}