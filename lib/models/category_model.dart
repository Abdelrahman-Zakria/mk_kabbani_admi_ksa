import 'dart:developer';

import 'package:html_unescape/html_unescape.dart';

class Category {
  String? id;
  String? sku;
  String? name;
  String? image;
  String? parent;
  String? slug;
  int? totalProduct;
  bool hasChildren = false;
  List<Category> subCategories = [];

  Category({
    this.id,
    this.sku,
    this.name,
    this.image,
    this.parent,
    this.slug,
    this.totalProduct,
    this.hasChildren = false,
    required this.subCategories,
  });

  Category.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson['slug'] == 'uncategorized') {
      return;
    }

    try {
      id = parsedJson['id']?.toString() ?? parsedJson['term_id'].toString();
      name = HtmlUnescape().convert(parsedJson['name']);
      parent = parsedJson['parent'].toString();
      totalProduct = parsedJson['count'];
      slug = parsedJson['slug'];
      final image = parsedJson['image'];
      if (image != null) {
        this.image = image['src'].toString();
      } else {
        this.image = 'https://trello-attachments.s3.amazonaws.com/5d64f19a7cd71013a9a418cf/640x480/1dfc14f78ab0dbb3de0e62ae7ebded0c/placeholder.jpg';
      }
      hasChildren = parsedJson['has_children'] ?? false;
    } catch (e, trace) {
      log(e.toString());
      log(trace.toString());
    }
  }

  Category copyWith({
    String? id,
    String? sku,
    String? name,
    String? image,
    String? parent,
    String? slug,
    int? totalProduct,
    bool? hasChildren,
    List<Category>? subCategories,
  }) {
    return Category(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        name: name ?? this.name,
        image: image ?? this.image,
        parent: parent ?? this.parent,
        slug: slug ?? this.slug,
        totalProduct: totalProduct ?? this.totalProduct,
        subCategories: subCategories ?? this.subCategories);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parent': parent,
    'image': {'src': image}
  };

  Category.fromJsonShopify(Map<String, dynamic> parsedJson) {
    // log(message)('fromJsonShopify id $parsedJson');

    if (parsedJson['slug'] == 'uncategorized') {
      return;
    }

    try {
      id = parsedJson['id'];
      sku = parsedJson['id'];
      name = parsedJson['title'];
      parent = '0';

      final image = parsedJson['image'];
      if (image != null) {
        this.image = image['src'].toString();
      } else {
        this.image = 'https://trello-attachments.s3.amazonaws.com/5d64f19a7cd71013a9a418cf/640x480/1dfc14f78ab0dbb3de0e62ae7ebded0c/placeholder.jpg';
      }
    } catch (e, trace) {
      log(e.toString());
      log(trace.toString());
    }
  }

  bool get isRoot => parent == '0';

  @override
  String toString() => 'Category { id: $id  name: $name}';
}
