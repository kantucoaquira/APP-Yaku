import 'package:flutter/material.dart';
import 'package:turismoapp/screens/admin/menu_edit_screen.dart';
import 'package:turismoapp/screens/admin/services/menu_service.dart';
import 'admin_drawer.dart'; // o el drawer que uses

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final menuService = MenuService();
  List<dynamic> menus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() => isLoading = true);
    try {
      final data = await menuService.getMyMenus();
      setState(() => menus = data);
    } catch (e) {
      print('Error al cargar menús: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar menús: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteMenu(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar menú?'),
        content: Text('¿Estás seguro de que deseas eliminar este menú?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await menuService.deleteMenu(id);
      _loadMenus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar menú')),
      );
    }
  }

  Future<void> _navigateToEdit({int? menuId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuEditScreen(menuId: menuId),
      ),
    );

    if (result == true) {
      _loadMenus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(), // o tu drawer personalizado
      appBar: AppBar(
        title: Text('Menús'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : menus.isEmpty
          ? Center(child: Text('No hay menús registrados'))
          : RefreshIndicator(
        onRefresh: _loadMenus,
        child: ListView.builder(
          itemCount: menus.length,
          itemBuilder: (context, index) {
            final menu = menus[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: menu['imageUrl'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    menu['imageUrl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(Icons.fastfood, size: 40),
                title: Text(menu['name']),
                subtitle: Text('${menu['description'] ?? ''}\nPrecio: \$${menu['price']}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEdit(menuId: menu['id']);
                    } else if (value == 'delete') {
                      _deleteMenu(menu['id']);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        child: Icon(Icons.add),
        tooltip: 'Crear nuevo menú',
      ),
    );
  }
}
