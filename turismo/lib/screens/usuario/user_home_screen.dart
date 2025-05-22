import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  // Lista simulada de productos con colores en lugar de imágenes
  final List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'Chalina flor',
      'price': 6.87,
      'color': Colors.purple, // Color en lugar de imagen
      'description': 'Arte floral tradicional hecho a mano.',
    },
    {
      'id': '2',
      'name': 'Chalina "Luz"',
      'price': 10.0,
      'color': Colors.orange, // Color en lugar de imagen
      'description': 'Adorno textil artesanal tejido con amor.',
    },
    {
      'id': '3',
      'name': 'Chalina Toleña',
      'price': 15.0,
      'color': Colors.green, // Color en lugar de imagen
      'description': 'Plato típico decorativo hecho con técnicas ancestrales.',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bienvenido Usuario")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Descubre nuestras artesanías:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: product['color'], // Usa el color del producto
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  title: Text(product['name']),
                  subtitle: Text('\$${product['price'].toStringAsFixed(2)}'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Mostrar detalles básicos del producto en un modal
                    _showProductDetail(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Función para mostrar detalles del producto en un modal
  void _showProductDetail(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: product['color'], // Usa el mismo color para el detalle
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                product['name'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Precio: \$${product['price'].toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(product['description']),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: Navigator.of(context).pop,
                icon: Icon(Icons.close),
                label: Text('Cerrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}