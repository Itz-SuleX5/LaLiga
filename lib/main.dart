import 'package:flutter/material.dart';
import 'models/team.dart';
import 'screens/team_details_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Liga',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'SamsungSans-Bold',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w700),
          displayMedium: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w700),
          displaySmall: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w500),
          headlineSmall: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w500),
          titleLarge: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w500),
          titleMedium: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w400),
          labelMedium: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w400),
          labelSmall: TextStyle(fontFamily: 'SamsungSans-Bold', fontWeight: FontWeight.w400),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Team> teams = [];
  List<Team> filteredTeams = [];
  bool isLoading = true;
  bool isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTeams();
    _searchController.addListener(_filterTeams);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTeams() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTeams = teams.where((team) => 
        team.name.toLowerCase().contains(query)
      ).toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (!isSearchVisible) {
        _searchController.clear();
        filteredTeams = teams;
      }
    });
  }

  Future<void> loadTeams() async {
    setState(() => isLoading = true);
    try {
      final loadedTeams = [
        Team(
          name: 'Atlético de Madrid',
          imageUrl: 'https://drop-assets.ea.com/images/1G7tZQxjdWA8GRHM7rrQC3/18b30a6bf5682e269861aea29eb66712/Atl_tico_de_Madrid.png',
          id: '240',
          league: 'La Liga',
        ),
        Team(
          name: 'FC Barcelona',
          imageUrl: 'https://drop-assets.ea.com/images/78IsnlfAiYOFM2UtAN8n05/1227e7142f5590b6a92c4e1d37d05dba/FC_Barcelona.png',
          id: '241',
          league: 'La Liga',
        ),
        Team(
          name: 'Real Madrid',
          imageUrl: 'https://drop-assets.ea.com/images/3X9LsZRgy03pchwhQacpwY/f6a0a73d564f4e5653e88427c0b4a02c/Real_Madrid.png',
          id: '243',
          league: 'La Liga',
        ),
        Team(
          name: 'Athletic Club',
          imageUrl: 'https://drop-assets.ea.com/images/5GO9rQv8OkrFWl5MAi0efY/9a9406ee5e762e4e4c8e809625f91912/Athletic_Club.png',
          id: '448',
          league: 'La Liga',
        ),
        Team(
          name: 'Real Betis',
          imageUrl: 'https://drop-assets.ea.com/images/6fnpWS1bJpN0wb4pZx5473/6509730841d69ceea2d149c7afe2d3b7/Real_Betis.png',
          id: '449',
          league: 'La Liga',
        ),
        Team(
          name: 'RC Celta',
          imageUrl: 'https://drop-assets.ea.com/images/8rx9iFGpgrzwYQ2qPvUg7/660c5c784ce2dac485e83cb70f4d1653/RC_Celta.png',
          id: '450',
          league: 'La Liga',
        ),
        Team(
          name: 'RCD Espanyol',
          imageUrl: 'https://drop-assets.ea.com/images/1KMtUvQZaOslJHDgn86Tux/ccec131bee4ed7b8f1081b396982444f/RCD_Espanyol.png',
          id: '452',
          league: 'La Liga',
        ),
        Team(
          name: 'RCD Mallorca',
          imageUrl: 'https://drop-assets.ea.com/images/6sIc8Ru1qFrbp7r1kdZvfh/45f4b05ed9c79abbf56961087a8bd951/RCD_Mallorca.png',
          id: '453',
          league: 'La Liga',
        ),
        Team(
          name: 'Real Sociedad',
          imageUrl: 'https://drop-assets.ea.com/images/vszpDziddcNj3RtOw0hRF/9601cae70ef7bb01670af59da64219db/Real_Sociedad.png',
          id: '457',
          league: 'La Liga',
        ),
        Team(
          name: 'Valencia CF',
          imageUrl: 'https://drop-assets.ea.com/images/QEVnS03rU9SRA9JD3X1Hb/0469c1fbd530177f0a5cd1a17580c2a9/Valencia_CF.png',
          id: '461',
          league: 'La Liga',
        ),
        Team(
          name: 'R. Valladolid CF',
          imageUrl: 'https://drop-assets.ea.com/images/6A0S4MdOE5mGMjMv6OpP8F/3733c8c46ba1e686451bec0aace1d609/R._Valladolid_CF.png',
          id: '462',
          league: 'La Liga',
        ),
        Team(
          name: 'D. Alavés',
          imageUrl: 'https://drop-assets.ea.com/images/o2UzLznMeSaTKQXIDBJ9K/9604a07fac457def6567acbac80d92e6/D._Alav_s.png',
          id: '463',
          league: 'La Liga',
        ),
        Team(
          name: 'UD Las Palmas',
          imageUrl: 'https://drop-assets.ea.com/images/N9dCopwg6b7K5GQ4etImq/608133deafa6c1183961225ead33ca50/UD_Las_Palmas.png',
          id: '472',
          league: 'La Liga',
        ),
        Team(
          name: 'CA Osasuna',
          imageUrl: 'https://drop-assets.ea.com/images/1t8E9D3XfqaQuiljOJZYuE/30c307dcb1b29e2743f831728eb1fe1a/CA_Osasuna.png',
          id: '479',
          league: 'La Liga',
        ),
        Team(
          name: 'Rayo Vallecano',
          imageUrl: 'https://drop-assets.ea.com/images/5jOx2OahPZf21DoHuOcbPe/c26d6434244353095f48924d23de36ac/Rayo_Vallecano.png',
          id: '480',
          league: 'La Liga',
        ),
        Team(
          name: 'Sevilla FC',
          imageUrl: 'https://drop-assets.ea.com/images/7Ao2AjWPOnUpRCmlDUTyqW/4f653d09d69769ee8e701062ea47f308/Sevilla_FC.png',
          id: '481',
          league: 'La Liga',
        ),
        Team(
          name: 'Villarreal CF',
          imageUrl: 'https://drop-assets.ea.com/images/4QzWJu03fZ3bm6pQxkD7Kj/a95a158969e6fb298ffff79939c6b018/Villarreal_CF.png',
          id: '483',
          league: 'La Liga',
        ),
        Team(
          name: 'Getafe CF',
          imageUrl: 'https://drop-assets.ea.com/images/1YIX79X2MDZotpGUS7COps/59ea02334874c4dded5750ff55fd2122/Getafe_CF.png',
          id: '1860',
          league: 'La Liga',
        ),
        Team(
          name: 'CD Leganés',
          imageUrl: 'https://drop-assets.ea.com/images/2IksQdjNxKq3TYuP1pw2nt/3651f0847639e43ffb3c29424e9478d8/CD_Legan_s.png',
          id: '100888',
          league: 'La Liga',
        ),
        Team(
          name: 'Girona FC',
          imageUrl: 'https://drop-assets.ea.com/images/3zk1UEgfoZF9Gw4EC5CEU8/b082cf070a2327d0453d11d15dfa116a/Girona_FC.png',
          id: '110062',
          league: 'La Liga',
        ),
      ];
      setState(() {
        teams = loadedTeams;
        filteredTeams = loadedTeams;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar equipos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'La Liga',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'SamsungSans-Bold',
                color: Color(0xFF1E293B),
              ),
            ),
            if (isSearchVisible)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar equipo',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterTeams();
                              },
                            )
                          : const Icon(Icons.mic),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTeams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron equipos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredTeams.length,
                          itemBuilder: (context, index) {
                            final team = filteredTeams[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeamDetailsScreen(
                                      team: team,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      team.imageUrl,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 100,
                                          width: 100,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.sports_soccer,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        team.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'SamsungSans-Bold',
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, 'Inicio', !isSearchVisible),
                    _buildNavItem(Icons.search, 'Buscar', isSearchVisible, onTap: _toggleSearch),
                    _buildNavItem(Icons.favorite_border, 'Favoritos', false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
