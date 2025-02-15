// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../classes/design_upload.dart';
import '../../utils/colors.dart';
import '../../utils/const.dart';
import '../../widgets/big_text.dart';

class UploadImageD extends StatefulWidget {
  const UploadImageD({Key? key}) : super(key: key);

  @override
  State<UploadImageD> createState() => _UploadImageDState();
}

class _UploadImageDState extends State<UploadImageD> {
  GlobalKey globalKey = GlobalKey<FormState>();
  TextEditingController caratController = TextEditingController();
  TextEditingController gramController = TextEditingController();
  TextEditingController produtDesecController = TextEditingController();
  TextEditingController bangleSizeController = TextEditingController();
  File? image;
  List<XFile> images = [];
  bool showSpinner = false;
  final _picker = ImagePicker();

  // List of available bangle sizes for dropdown
  List<String> bangleSizes = [
    '2/2',
    '2/3',
    '2/4',
    '2/5',
    '2/6',
    '2/7',
    '2/8',
    '2/9',
    '2-10',
    '2/11',
    '2/12',
    '2/13',
    '2/14',
    '2/15',
    '2/16',
  ];

  String? selectedBangleSize;

  // Add this to the class variables at the top
  List<String> goldPurity = [
    '18K',
    '22K',
    '24K',
  ];
  String? selectedGoldPurity;

  Future getImageCamera() async {
    final pickFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickFile != null) {
      image = File(pickFile.path);
      setState(() {});
    } else {}
  }

  Future<void> pickMultipleImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      images = selectedImages;
      setState(() {});
    }
  }

  Future getImageGallery() async {
    final pickFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickFile != null) {
      image = File(pickFile.path);
      setState(() {});
    } else {}
  }

  Future getUpload() async {
    setState(() {
      showSpinner = true;
    });
    var strem = http.ByteStream(image!.openRead());
    strem.cast();
    var length = await image!.length();
    var uri = Uri.parse(
        '${apiUrl}imagepicker?cid=1&imagepicker=22-03-23-1224117867.jpg');
    var request = http.MultipartRequest('POST', uri);
    request.fields["description"] = "$produtDesecController";
    var multiport = http.MultipartFile('imagepicker', strem, length);
    request.files.add(multiport);
    var response = await request.send();
    if (response.statusCode == 200) {
      showSpinner = false;
      Fluttertoast.showToast(msg: 'Successfully uploaded image');
      Navigator.pop(context);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'CUSTOM ORDER',
          style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
              uIForm(),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Container buildButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  if (images.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please Upload Image');
                  } else if (selectedBangleSize == null ||
                      selectedGoldPurity == null ||
                      gramController.text.isEmpty ||
                      produtDesecController.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please fill in all details');
                  } else {
                    _uploadImage(
                        allImage: images,
                        gram: gramController.text,
                        descp: produtDesecController.text,
                        carat: selectedGoldPurity!,
                        bangleSize: selectedBangleSize!
                        );
                  }
                },
                color: AppColors.logo2,
                child: const Center(
                  child: Text(
                    'Order',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  uIForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: images.isEmpty
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text('Select Image Source'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.camera_alt),
                                            title: const Text('Camera'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _pickImageFromCamera();
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.photo_library),
                                            title: const Text('Gallery'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              pickMultipleImages();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                height: 60,
                                width: 80,
                                child: const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: BigText(
                            text: 'Select image',
                            color: Colors.black54,
                            size: 18,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: GridView.builder(
                              itemCount: images.length,
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) => Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(images[index].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: -10,
                                      top: -10,
                                      child: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            images.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: FloatingActionButton(
                              mini: true,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text('Select Image Source'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.camera_alt),
                                            title: const Text('Camera'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _pickImageFromCamera();
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.photo_library),
                                            title: const Text('Gallery'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              pickMultipleImages();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Icon(Icons.add_photo_alternate),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(
              height: 10,
            ),
            BigText(
              text: 'Bangle Size',
              size: 14,
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedBangleSize,
              style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.smart_button),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'Select Bangle Size',
              ),
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  selectedBangleSize = newValue!;
                });
              },
              items: bangleSizes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 15,
            ),
            BigText(
              text: 'Gold Purity',
              size: 14,
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedGoldPurity,
              style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.smart_button),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'Select Gold Purity',
              ),
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  selectedGoldPurity = newValue!;
                });
              },
              items: goldPurity.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 15,
            ),
            BigText(
              text: 'Weight',
              size: 14,
            ),
            const SizedBox(height: 5),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: gramController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.g_mobiledata_outlined),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'In Grams',
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            BigText(
              text: 'Remarks',
              size: 14,
            ),
            const SizedBox(height: 5),
            TextFormField(
              keyboardType: TextInputType.text,
              controller: produtDesecController,
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                 prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 90), // Adjust icon position
                  child: Icon(Icons.text_fields),
                ),
               focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'Description about product in brief',
              ),
            ),
          ],
        ),
      ),
    );
  }

  _uploadImage(
      {required List<XFile> allImage,
      required String gram,
      required String descp,
      required String carat,
      required String bangleSize}) async {
    if (globalKey.currentState.isNull) {
      await UploadDesingImageUser.getUploadDesign(
              images: allImage,
              gram: gram,
              descp: descp,
              carat: selectedGoldPurity ?? '',
              bangleSize: bangleSize)
          .then(
        (value) => setState(
          () {
            bangleSizeController.clear();
            selectedGoldPurity = null;
            gramController.clear();
            produtDesecController.clear();
            images = [];
          },
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        images.add(photo);
      });
    }
  }
}
