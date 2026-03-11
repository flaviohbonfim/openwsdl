import 'package:flutter/material.dart';

/// Barra de status inferior
/// Exibe informações como: versão SOAP, status de conexão, tema ativo
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF007ACC) // Azul VS Code
            : const Color(0xFF007ACC),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Status do SOAP
          _buildStatusItem(
            context,
            icon: Icons.cloud_outlined,
            label: 'Pronto',
          ),
          
          const Spacer(),
          
          // Versão SOAP
          _buildStatusItem(
            context,
            icon: Icons.info_outline,
            label: 'SOAP 1.2',
          ),
          
          const SizedBox(width: 16),
          
          // Tema ativo
          _buildStatusItem(
            context,
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            label: isDark ? 'Dark' : 'Light',
          ),
          
          const SizedBox(width: 16),
          
          // Versão do App
          const Text(
            'v1.0.0',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),

        ],
      ),
    );
  }
  
  Widget _buildStatusItem(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
