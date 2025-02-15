import 'package:briio_application/screens/pages/categories/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../model/home_model.dart';
import '../../../utils/const.dart';
import '../../../utils/globel_veriable.dart';
import '../../home/api_services.dart';

class SubCategory extends StatefulWidget {
  const SubCategory(
      {super.key, required this.categoryId, required this.categoryName});

  final int categoryId;
  final String categoryName;

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  List<SubCategories> subCategory = [];

  bool isReady = false;

  _getSubCategory() async {
    isReady = true;
    final result = await ApiServices().getSubCategory(widget.categoryId);
    setState(() {
      subCategory = result;
      isReady = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSubCategory();
  }

  Widget _buildOptimizedImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 170,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 170,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 170,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Icon(Icons.error_outline),
      ),
      // Enable memory caching
      memCacheWidth: 512, // Optimize memory cache size
      memCacheHeight: 512,
      // Enable disk caching
      cacheKey: imageUrl,
      cacheManager: DefaultCacheManager(),
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
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_new,size: 18,color: Colors.grey.shade700,)),
        backgroundColor: Colors.white,
        title: Text('${widget.categoryName}',
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: isReady == true
          ? const Center(child: CircularProgressIndicator())
          : subCategory.isEmpty
              ? const Center(child: Text("No subcategories found."))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: subCategory.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          GlobalK.categoryId = widget.categoryId.toString();
                        });
                        Get.to(
                          () => ProductScreen(
                            subcategoryId: subCategory[index].id!,
                            subcategoryName: subCategory[index].subcategory!,
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildOptimizedImage(
                              "${imgPath}subcategory/${subCategory[index].image}",
                            ),
                            Text(subCategory[index].subcategory.toString())
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
