import 'package:flutter/material.dart';
import 'package:turismo/screens/superadmin/services/restaurant_service.dart';
import 'RestaurantEditScreen.dart';

class RestaurantsScreen extends StatefulWidget {
  @override
  _RestaurantsScreenState createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final restaurantService = RestaurantService();
  List<dynamic> restaurants = [];
  bool isLoading = false;

  Future<void> fetchRestaurants() async {
    setState(() => isLoading = true);
    try {
      final data = await restaurantService.getRestaurants();
      setState(() => restaurants = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar restaurantes')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> _navigateToEdit({int? restaurantId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantEditScreen(restaurantId: restaurantId),
      ),
    );
    if (result == true) {
      fetchRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Restaurantes"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToEdit(),
            tooltip: "Agregar restaurante",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : restaurants.isEmpty
          ? Center(child: Text("No hay restaurantes disponibles", style: TextStyle(fontSize: 18)))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            final imageUrl = restaurant['imageUrl'] ?? '';
            return Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(15),
              shadowColor: Colors.black54,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _navigateToEdit(restaurantId: restaurant['id']),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        ),
                      )
                          : Container(
                        height: 140,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 60, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant['name'] ?? 'Sin nombre',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            restaurant['address'] ?? '',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blueAccent),
                            tooltip: 'Editar',
                            onPressed: () => _navigateToEdit(restaurantId: restaurant['id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            tooltip: 'Eliminar',
                            onPressed: () => _deleteRestaurant(restaurant['id']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteRestaurant(int id) async {
    try {
      await restaurantService.deleteRestaurant(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restaurante eliminado')),
      );
      fetchRestaurants();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar restaurante')),
      );
    }
  }
}
