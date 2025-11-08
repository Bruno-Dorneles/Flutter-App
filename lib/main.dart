import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dev.Mobile Fase2',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
    );
  }
}

// Tela principal com navegação inferior
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Controla a aba selecionada

  final List<Widget> _pages = [
    Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    UserListPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuários'),
        ],
      ),
    );
  }
}

// Página que lista os usuários com barra de busca
class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _showSearch = false;
  TextEditingController _searchController = TextEditingController();

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    final data = json.decode(response.body);
    setState(() {
      _users = data.map((user) => {
        'id': user['id'],
        'name': user['name'],
        'email': user['email']
      }).toList();
      _filteredUsers = _users;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users
          .where((user) => user['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _filteredUsers = _users;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : Center(
                child: Text(
                  'Lista de usuários',
                  style: TextStyle(color: Colors.white),
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _filteredUsers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (_, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=${(index % 70) + 1}'),
                  ),
                  title: Text(user['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(
                          user: user,
                          avatarIndex: (index % 70) + 1,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// Página de perfil do usuário
class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final int avatarIndex;

  ProfilePage({required this.user, required this.avatarIndex});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> albums = [];
  List<dynamic> photos = [];

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  void fetchAlbums() async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/albums?userId=${widget.user['id']}'));
    final data = json.decode(response.body);
    setState(() {
      albums = data;
    });
    if (albums.isNotEmpty) {
      fetchPhotos(albums[0]['id']);
    }
  }

  void fetchPhotos(int albumId) async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/photos?albumId=$albumId'));
    final data = json.decode(response.body);
    setState(() {
      photos = data;
    });
  }

  void openPhoto(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenPhoto(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(widget.user['name'], style: TextStyle(color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?img=${widget.avatarIndex}'),
            ),
            SizedBox(height: 8),
            Text(widget.user['email'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: albums.length,
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () => fetchPhotos(albums[index]['id']),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/id/${(albums[index]['id'] + 50) % 100}/200'),
                        ),
                        SizedBox(height: 4),
                        Text('Story ${index + 1}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemCount: photos.length,
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () => openPhoto(
                      context, photos[index]['url'], photos[index]['title']),
                  child: Image.network(
                    photos[index]['thumbnailUrl'],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Tela para visualizar imagem ampliada
class FullscreenPhoto extends StatelessWidget {
  final String url;
  final String title;

  FullscreenPhoto({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title, style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Image.network(url),
      ),
    );
  }
}
