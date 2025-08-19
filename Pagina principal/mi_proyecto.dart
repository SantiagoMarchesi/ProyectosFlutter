import 'package:flutter/material.dart';

class MiProyecto extends StatelessWidget {
  const MiProyecto({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.work, size: 80),
          SizedBox(height: 20),
          Text(
            'Aquí van los detalles de tu proyecto',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}