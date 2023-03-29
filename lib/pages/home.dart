import 'package:flutter/material.dart';
import 'markers_page.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Mile 2 Park"),
        centerTitle: true,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: SearchField());
              },
              icon: const Icon(Icons.search)),
        ],
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.green.withOpacity(0.001),
            Colors.green.withOpacity(0.3),
            Colors.green.withOpacity(0.9)
          ], stops: [
            0.0,
            0.3,
            0.7
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
        ),
        elevation: 20,
        shadowColor: Colors.green.withOpacity(1),
      ),
      body: MapApp(),
    );
    throw UnimplementedError();
  }
}

class MapApp extends StatelessWidget {
  const MapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MarkersPage();
  }
}

class SearchField extends SearchDelegate {
  List<String> searchResults = ['Main Parking', 'MBA Gate Parking'];
  @override
  List<Widget>? buildActions(BuildContext context) {
    IconButton(
        onPressed: () {
          if (query.isEmpty == true)
            close(context, null);
          else
            query = "";
        },
        icon: Icon(Icons.clear));
    return null;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    Center(
      child: Text(
        query,
        style: TextStyle(fontSize: 64),
      ),
    );
    return Text("Search");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults.where((searchResult) {
      final result = searchResult.toLowerCase();
      return result.contains(query);
    }).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}
