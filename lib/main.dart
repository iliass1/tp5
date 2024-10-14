import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recherche de Films',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieSearchPage(),
    );
  }
}

class MovieSearchPage extends StatefulWidget {
  const MovieSearchPage({super.key});

  @override
  _MovieSearchPageState createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List movies = [];

  Future<void> fetchMovies(String query) async {
    const apiKey = '58ba18e4'; // Clé API OMDb
    final url = 'https://www.omdbapi.com/?s=$query&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          movies = data['Search'] ?? [];
        });
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche de Films'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Entrez un titre de film',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    fetchMovies(_controller.text);
                  },
                ),
              ),
            ),
            Expanded(
              child: movies.isNotEmpty
                  ? ListView.builder(
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return Card(
                          child: ListTile(
                            leading: Image.network(
                              movie['Poster'],
                              width: 50,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image),
                            ),
                            title: Text(movie['Title']),
                            subtitle: Text(movie['Year']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieDetailPage(movie: movie),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('Aucun film trouvé')),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieDetailPage extends StatelessWidget {
  final Map movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['Title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              movie['Poster'],
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 16),
            Text(
              'Année : ${movie['Year']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Type : ${movie['Type']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
