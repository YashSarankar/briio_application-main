import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../classes/wishlist.dart';
import '../../../model/get_category_id_by_product_model.dart';
import '../../../utils/const.dart';
import '../../../utils/globel_veriable.dart';
import '../../home/api_services.dart';
import '../../home/product_detail_page.dart';
import 'filter_page.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen(
      {super.key, required this.subcategoryId, required this.subcategoryName, required this.categoryId});

  final int subcategoryId;
  final String subcategoryName;
  final int categoryId;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  List<Product> allProducts = [];
  late Filters filters;
  bool isLoading = false;
  bool isLoader = false;
  Set<int> wishlistedProducts = {};
  bool isReady = false;
  String sortOrder = 'none';

  _getProducts() async {
    isReady = true;
    final result = await ApiServices().getProducts(widget.subcategoryId, widget.categoryId);
    print(result.length);
    print(widget.categoryId);
    print(widget.subcategoryId);
    setState(() {
      products = result;
      allProducts = result;
      isReady = false;
    });
  }

  void filterProducts() {
    setState(() {
      products = List.from(allProducts);
      
      products = products.where((product) {
        final weight = product.gw ?? 0;
        return weight >= filters.weightFrom && weight <= filters.weightTo;
      }).toList();

      if (sortOrder == 'lowToHigh') {
        products.sort((a, b) => (a.gw ?? 0).compareTo(b.gw ?? 0));
      } else if (sortOrder == 'highToLow') {
        products.sort((a, b) => (b.gw ?? 0).compareTo(a.gw ?? 0));
      }
    });
  }

  void sortProducts(String order) {
    setState(() {
      sortOrder = order;
      if (order == 'lowToHigh') {
        products.sort((a, b) => (a.gw ?? 0).compareTo(b.gw ?? 0));
      } else if (order == 'highToLow') {
        products.sort((a, b) => (b.gw ?? 0).compareTo(a.gw ?? 0));
      }
    });
  }

  Future<void> _loadWishlistedProducts() async {
    final wishlistData = await Wishlist.getWishlist();
    setState(() {
      wishlistedProducts = wishlistData.data
          ?.map((item) => int.parse(item.productid.toString()))
          .toSet() ?? {};
    });
  }

  @override
  void initState() {
    super.initState();
    filters = Filters();
    _getProducts();
    _loadWishlistedProducts();
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        isLoading = false;
        isLoader = true;
      });
    });
  }

  Widget _buildImageWithShimmer(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 160,
          width: double.infinity,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        clipBehavior: Clip.none,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey.shade700,
            size: 18,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${widget.subcategoryName.toUpperCase()}',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child:   Row(
            children: [
              PopupMenuButton<String>(
                clipBehavior: Clip.none,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Sort', style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.sort, size: 20),
                    ],
                  ),
                ),
                onSelected: sortProducts,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'lowToHigh',
                    child: Text('Weight: Low to High'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'highToLow',
                    child: Text('Weight: High to Low'),
                  ),
                ],
              ),
              const Spacer(),
                TextButton.icon(
                onPressed: () async {
                  final result = await Get.to<Filters>(
                    () => FilterPage(filters: filters),
                  );
                  if (result != null) {
                    setState(() {
                      filters = result;
                      filterProducts();
                    });
                  }
                },
                icon: const Text('Filter', style: TextStyle(color: Colors.black87)),
                label: const Icon(Icons.filter_list, color: Colors.black87),
              ),
            ],
          ),
        ),
          Expanded(
            child: isReady == true
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty 
                    ? const Center(child: Text("No Products found."))
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    GlobalK.productId =
                                        '${products[index].id!.toString()} ';
                                    GlobalK.productName =
                                        '${products[index].name!.toString()} ';
                                  });
                                  Get.to(() => ProductDetailsPage(
                                        productId: products[index].id!,
                                      ));
                                },
                                child: Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildImageWithShimmer("${imgPath}products/${products[index].image}"),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              products[index].name.toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              "Gross wt: ${products[index].gw!.toString()}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () async {
                                    final productId = products[index].id.toString();
                                    if (wishlistedProducts.contains(products[index].id)) {
                                      await Wishlist.getDeleteWishlist(
                                        product_id: productId,
                                        productVarientId: '6',
                                      );
                                      setState(() {
                                        wishlistedProducts.remove(products[index].id);
                                      });
                                    } else {
                                      await Wishlist.getAddWishlist(
                                        product_id: productId,
                                        productVarientId: '6',
                                      );
                                      setState(() {
                                        wishlistedProducts.add(products[index].id!);
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      wishlistedProducts.contains(products[index].id)
                                          ? Icons.favorite
                                          : Icons.favorite_border_outlined,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
