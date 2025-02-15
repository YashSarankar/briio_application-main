import 'dart:convert';
import 'package:briio_application/screens/home/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../classes/wishlist.dart';
import '../../model/get_new_wishlist_product_model.dart';
import '../../utils/const.dart';
import '../../utils/globel_veriable.dart';
import '../../widgets/big_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistState();
}

class _WishlistState extends State<WishlistPage> {
  Future<GetNewWishlistProductModel> getWishList() async {
    final response = await http.post(Uri.parse(
        '${apiUrl}getWishlist?userid=${GlobalK.userId}&productid=1&productvariantid=1'));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      return GetNewWishlistProductModel.fromJson(data);
    }
    return GetNewWishlistProductModel.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        clipBehavior: Clip.none,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 1,
        title:  Text('WATCHLIST',
          style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 20),),
      ),
      // bottomNavigationBar: const BottomBars(),
      body: FutureBuilder<GetNewWishlistProductModel>(
        future: getWishList(),
        builder: (context, snapshot) => snapshot.hasData
            ? snapshot.data!.error == false
                ? ListView.builder(
                    itemCount: snapshot.data!.data!.length,
                    itemBuilder: (context, index) =>
                        wishlistCard(snapshot, index),
                  )
                : Center(
                    child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                            'https://thumbs.dreamstime.com/b/wishlist-icon-comic-style-like-document-cartoon-vector-illustration-white-isolated-background-favorite-list-splash-effect-218065056.jpg'),
                        const Text(
                          'Your Watchlist is Empty..',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ))
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Card wishlistCard(
      AsyncSnapshot<GetNewWishlistProductModel> snapshot, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: '${imgPath}products/${snapshot.data!.data![index].product!.image!.toString()}',
                  fit: BoxFit.cover,
                  memCacheWidth: 320,
                  memCacheHeight: 320,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(snapshot.data!.data![index].product!.productCode!,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  _addCartText(
                      hintText: 'Category',
                      valueText: snapshot.data!.data![index].product!.categoryName.toString()
                  ),
                  const SizedBox(height: 10),
                  _addCartText(
                      hintText: 'Gross Wt.',
                      valueText:
                          '${snapshot.data!.data![index].product!.nw} gm'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            onPressed: () async {
                              Wishlist.getDeleteWishlist(
                                product_id: snapshot.data!.data![index].productid.toString(),
                                productVarientId: snapshot.data!.data![index].productvariantid.toString()
                              ).then((value) => setState(() {}));
                              setState(() {});
                            },
                            child: const Text(
                              'REMOVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                          Expanded(
                        child: SizedBox(
                          height: 32,
                          child: TextButton(
                            onPressed: () {
                              print("ProductID: ${snapshot.data!.data![index].productid}");
                              print("Index: $index");
                              print("Data length: ${snapshot.data!.data!.length}");
                              
                              final productIdStr = snapshot.data!.data![index].productid;
                              if (productIdStr != null) {
                                try {
                                  final productId = int.parse(productIdStr.toString());
                                  print("Parsed productId: $productId");
                                  GlobalK.productId = productId.toString();
                                  GlobalK.productName = snapshot.data!.data![index].product!.productCode ?? '';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(productId: productId),
                                    ),
                                  );
                                } catch (e) {
                                  print("Error: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid product ID')),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            child: const Text(
                              'VIEW',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  _addCartText({String? hintText, String? valueText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BigText(
          text: '$hintText',
          size: 13,
        ),
        BigText(
          text: '  :  ',
          size: 13,
        ),
        BigText(
          text: '$valueText',
          size: 13,
        ),
      ],
    );
  }
}
