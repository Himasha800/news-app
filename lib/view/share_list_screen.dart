

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app1/utils/db_helper.dart';
import 'package:news_app1/view/news_details_screen.dart';

class ShareListScreen extends StatefulWidget {
  @override
  _ShareListScreenState createState() => _ShareListScreenState();
}

class _ShareListScreenState extends State<ShareListScreen> {
  late Future<List<Map<String, dynamic>>> sharedNews;

  @override
  void initState() {
    super.initState();
    sharedNews = DBHelper().getNewsList(DBHelper().sharedNewsTable);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shared News",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 213, 196, 243), 
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10), 
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: sharedNews,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading shared news"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No shared news found"));
                  } else {
                    final newsList = snapshot.data!;
                    return ListView.builder(
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 155, 152, 152),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to details screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailsScreen(
                                    newsImage: news['image_url'] ?? '',
                                    newsTitle: news['title'] ?? 'No Title',
                                    newsDate: news['news_date'] ?? DateTime.now().toIso8601String(),
                                    author: news['author'] ?? 'Unknown Author',
                                    description: news['description']?.isNotEmpty == true
                                        ? news['description']
                                        : 'No Description Available',
                                    content: news['content'] ?? '',
                                    source: news['source'] ?? 'Unknown Source',
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: news['image_url']?.isNotEmpty == true
                                        ? news['image_url']
                                        : 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    height: height * 0.18,
                                    width: width * 0.3,
                                    placeholder: (context, url) =>
                                        const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error_outline, color: Colors.red),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title
                                        Text(
                                          news['title'] ?? 'No Title',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        // Source
                                        Text(
                                          news['source'] ?? 'Unknown Source',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        // Description
                                        Text(
                                          news['description']?.isNotEmpty == true
                                              ? news['description']
                                              : 'No Description Available',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[800],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    DBHelper().deleteNews(DBHelper().sharedNewsTable, news['id']);
                                    setState(() {
                                      sharedNews = DBHelper().getNewsList(DBHelper().sharedNewsTable);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
