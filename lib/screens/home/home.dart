// ignore_for_file: unnecessary_null_comparison, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:briio_application/screens/pages/notifiction_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/shimmer_loading.dart';

import '../../classes/categories.dart';
import '../../model/catogries_model.dart';
import '../../model/home_model.dart';
import '../../utils/colors.dart';
import '../../utils/const.dart';
import '../../utils/globel_veriable.dart';
import '../pages/categories/subCategory.dart';
import '../pages/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _imageUrls = [];
  bool _isLoading = true;

  Future<Home2Model> getData() async {
    String? uri = '${apiUrl}HomeData';
    var response = await http.post(Uri.parse(uri));
    var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      return Home2Model.fromJson(data);
    }
    return Home2Model.fromJson(data);
  }

  bool isLoader = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    getData();
    Future.delayed(const Duration(milliseconds: 2000), () {});
  }

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _fetchImages() async {
    try {
      var request =
          http.Request('POST', Uri.parse('https://briio.in/api/home-slide'));
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);

        if (data['error'] == false && data['data'] is List) {
          setState(() {
            _imageUrls = (data['data'] as List)
                .map((item) =>
                    "https://briio.in/uploads/homesliders/${item['image']}")
                .toList();
            _isLoading = false;
          });
        } else {
          // Handle case where data is not a list or there's an error
        }
      } else {}
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.grey.shade100,
        child: _buildUi(),
      ),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        title: 
          Image.asset(
            'assets/blg.png',
            height: 28,
            fit: BoxFit.contain,
          ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SearchPage()));
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const NotificationPage()));
            },
          ),
        ],
      ),
      body: FutureBuilder<Home2Model>(
        future: getData(),
        builder: (context, snapshot) => snapshot.hasData
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          CarouselSlider.builder(
                            itemCount: snapshot.data!.banner!.length,
                            itemBuilder: (context, index, realIndex) =>
                                Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: "${imgPath}homesliders/${snapshot.data!.banner![index].image.toString()}",
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const ShimmerLoading(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                            options: CarouselOptions(
                              height: 190.0,
                              autoPlay: true,
                              viewportFraction: 1,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          snapshot.data!.banner!.length,
                          (index) => Container(
                                margin:
                                    const EdgeInsets.only(top: 10, right: 8),
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == index
                                        ? AppColors.logo2
                                        : Colors.grey),
                              )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          GridView.count(
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (final category in snapshot.data!.categorie!)
                                Builder(builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        GlobalK.categoryId =
                                            category.id.toString();
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SubCategory(
                                            categoryId: category.id!,
                                            categoryName: category.name!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: '${imgPath}category/${category.bgImage!.toString()}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const ShimmerLoading(),
                                            errorWidget: (context, url, error) => Container(),
                                          ),
                                          CachedNetworkImage(
                                            imageUrl: '${imgPath}category/${category.image!.toString()}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const ShimmerLoading(),
                                            errorWidget: (context, url, error) => Container(),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 0),
                                              child: Text(category.name!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          )
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 220,
                    //   width: double.infinity,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //       image: const DecorationImage(
                    //         image: AssetImage('assets/briio.gif'),
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),
                    //     margin: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                    //     // height: 30,
                    //     width: 300,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _imageUrls.isNotEmpty
                            ? CarouselSlider(
                                items: _imageUrls.map((imageUrl) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            memCacheWidth: 300,
                                            memCacheHeight: 300,
                                            placeholder: (context, url) => const ShimmerLoading(),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                  height: 200,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 1,
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  reverse: false,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enlargeCenterPage: true,
                                  scrollDirection: Axis.horizontal,
                                ),
                              )
                            : const Center(child: Text('No images found')),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      width: double.infinity,
                      color: Colors.white,
                      child: Text(' WHY BRIIO',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    const WhyBrllo(
                      text: '100% Certified Jewellery',
                      image:
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-Nc0UXZd5WM0WrEi4YX7kH5LwUhYg9l1ey3Ra67o&s',
                    ),
                    const WhyBrllo(
                      text: 'Value for Money',
                      image:
                          'https://www.shutterstock.com/image-vector/pay-vector-thin-line-icon-260nw-1799803231.jpg',
                    ),
                    const WhyBrllo(
                      text: "Easily Exchange within 24 hours",
                      image:
                          'https://st2.depositphotos.com/13981182/50896/v/600/depositphotos_508968392-stock-illustration-rupees-chargeback-vector-icon-simple.jpg',
                    ),
                    const WhyBrllo(
                      text: 'Free Shipping & Insurance',
                      image:
                          'https://www.shutterstock.com/image-vector/shipping-free-delivery-van-icon-260nw-1253868556.jpg',
                    ),
                    const WhyBrllo(
                        text: 'Explore 1000+ designs on your finger tips',
                        image:
                            'https://static.thenounproject.com/png/1306779-200.png'),
                    Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 15),
                              margin:
                                  const EdgeInsets.only(top: 15, bottom: 10),
                              child: Text('Follow us on',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    // letterSpacing: 1.2,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 0, top: 15, bottom: 20),
                              color: Colors.white,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.facebook,
                                      size: 40,
                                    ),
                                    onPressed: () => _launchURL('https://www.facebook.com/people/BRIIO/61555871942867/'),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.linkedin,
                                      size: 40,
                                    ),
                                    onPressed: () => _launchURL('https://www.linkedin.com/company/brij-ornaments-pvt-ltd'),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.squareInstagram,
                                      size: 40,
                                    ),
                                    onPressed: () => _launchURL('https://www.instagram.com/briio.in/'),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.twitter,
                                      size: 40,
                                    ),
                                    onPressed: () => _launchURL('https://twitter.com/BRIIO_IN'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Container(
                      height: 60,
                    )
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      // bottomNavigationBar: const BottomBars(),
    );
  }

  evluction2() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.greenAccent,
                backgroundImage: AssetImage(
                  'assets/logo_bg.png',
                ),
              ),
              title: Text('Evolution of Group',
                  style: GoogleFonts.lato(
                      height: 1, fontSize: 18, fontWeight: FontWeight.w800)),
              trailing: const Icon(
                Icons.keyboard_arrow_up_outlined,
                size: 35,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: const Text(
                'Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type .'),
          )
        ],
      ),
    );
  }

  Widget _buildUi() {
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Category',
              style: GoogleFonts.lato(
                  height: 1, fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
              height: 550,
              width: double.infinity,
              child: FutureBuilder<CatogriesModel>(
                future: CategoriesView.getPro(),
                builder: (context, snapshot) => ListView.builder(
                  itemCount: snapshot.data!.data!.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      GlobalK.categoryId =
                          snapshot.data!.data![index].id!.toString();
                      Get.to(() => SubCategory(
                        categoryId: int.parse(snapshot.data!.data![index].id!.toString()),
                        categoryName: snapshot.data!.data![index].name!.toString(),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        minTileHeight: 0,
                        tileColor: Colors.white,
                        minVerticalPadding: 4,
                        title: Text(
                            snapshot.data!.data![index].name!.toString(),
                            style: GoogleFonts.lato(
                                height: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)
                        ),
                        trailing: const Icon(
                          Icons.keyboard_arrow_right,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              )),
          // SizedBox(
          //   height: 28,
          // ),
          // Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     ListTile(
          //       dense: true,
          //       title: const Text(
          //         textAlign: TextAlign.center,
          //         'Powered by Act T Connect',
          //         style: TextStyle(fontSize: 15, color: Colors.black),
          //       ),
          //       onTap: () {
          //         launch("https://www.acttconnect.com/", forceWebView: true);
          //       },
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Shimmer getShimmerLodaing() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: const Center(
          child: CircularProgressIndicator(),
        ));
  }
}

class WhyBrllo extends StatefulWidget {
  const WhyBrllo({Key? key, this.text, this.image}) : super(key: key);
  final String? text;
  final String? image;

  @override
  State<WhyBrllo> createState() => _WhyBrlloState();
}

class _WhyBrlloState extends State<WhyBrllo> {
  bool _obscureText = false;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: GestureDetector(
        onTap: _toggle,
        child: ListTile(
          tileColor: Colors.white,
          title: Text(
            "${widget.text}",
            style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
          ),
          // trailing: _obscureText == true
          //     ? const Icon(Icons.keyboard_arrow_down)
          //     : const Icon(Icons.keyboard_arrow_up),
          leading: CachedNetworkImage(
            imageUrl: '${widget.image}',
            width: 40,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

//success on sharing project on git hub
//success on sharing project on git hub
//success on sharing project on git hub
//success on sharing project on git hub
