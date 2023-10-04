import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final searchController = TextEditingController();
  List<String> allDogImages = [];
  List<String> displayedDogImages = [];
  Map<String, List<String>> dogBreeds = {};
  String? searchValue;
  int currentPage = 1;
  int imagesPerPage = 30;

  @override
  void initState() {
    super.initState();
    // Initially, fetch a large number of dog images
    fetchDogImages(currentPage);
    // Fetch the list of dog breeds
    fetchDogBreeds();
  }

  Future<void> fetchDogImages(int page) async {
    var dogUrl = 'https://dog.ceo/api/breeds/image/random/$imagesPerPage';
    var response = await http.get(Uri.parse(dogUrl));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var dogImages = jsonResponse['message'] as List<dynamic>;

      setState(() {
        allDogImages.addAll(dogImages.map((dynamic obj) => obj.toString()));
        displayedDogImages = allDogImages;
      });
    } else {
      throw Exception("Status code --> ${response.statusCode}");
    }
  }

  Future<void> fetchDogBreeds() async {
    var breedUrl = 'https://dog.ceo/api/breeds/list/all';
    var response = await http.get(Uri.parse(breedUrl));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var breedsMap = jsonResponse['message'] as Map<String, dynamic>;

      setState(() {
        dogBreeds = breedsMap.map((key, value) {
          var subBreeds = (value as List).cast<String>();
          return MapEntry(key, subBreeds);
        });
      });
    } else {
      throw Exception("Status code --> ${response.statusCode}");
    }
  }

  void searchImages(String query) {
    setState(() {
      displayedDogImages = allDogImages.where((image) {
        var dogName = getDogNameFromUrl(image);
        return dogName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  String getDogNameFromUrl(String url) {
    var parts = url.split('/');
    if (parts.length >= 6) {
      var breed = parts[4];
      var subBreed = parts[5].split('.')[0];
      var breedName = subBreed.isNotEmpty ? '$subBreed $breed' : breed;
      return breedName;
    }
    return 'Unknown Dog';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pet",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500)),
            Text("Finder",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: TextFormField(
                controller: searchController,
                onChanged: (value) {
                  searchImages(value);
                },
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  prefixIcon: Icon(CupertinoIcons.search),
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent) {
                  currentPage++;
                  fetchDogImages(currentPage);
                }
                return true;
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200.0 / 350.0,
                ),
                itemCount: displayedDogImages.length,
                itemBuilder: (context, index) {
                  var dogName = getDogNameFromUrl(displayedDogImages[index]);
                  return Column(
                    children: [
                      Card(
                        child: Image.network(
                          displayedDogImages[index],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        dogName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
