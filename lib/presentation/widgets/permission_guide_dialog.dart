import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionGuideDialog extends StatefulWidget {
  final VoidCallback onUsePrivateFolder;

  const PermissionGuideDialog({
    super.key,
    required this.onUsePrivateFolder,
  });

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onUsePrivateFolder,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PermissionGuideDialog(
        onUsePrivateFolder: onUsePrivateFolder,
      ),
    );
  }

  @override
  State<PermissionGuideDialog> createState() => _PermissionGuideDialogState();
}

class _PermissionGuideDialogState extends State<PermissionGuideDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Sleek premium colors
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final cardColor = isDark ? const Color(0xFF252538) : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: backgroundColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon & Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_shared_outlined,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Acceso al Almacenamiento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Para guardar tus canciones en la carpeta pública de Música de tu dispositivo (visible por otras apps), Rmusic necesita permiso.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 20),
              
              // Device Selector Tabs
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: subtitleColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Xiaomi'),
                    Tab(text: 'Samsung'),
                    Tab(text: 'Stock'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Device Specific Instructions
              SizedBox(
                height: 140,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInstructionTab(
                      icon: Icons.phone_android,
                      title: 'MIUI / HyperOS (Xiaomi)',
                      steps: [
                        'Ve a Ajustes > Aplicaciones > Gestionar Aplicaciones.',
                        'Busca Rmusic y entra en Permisos de la aplicación.',
                        'Selecciona Archivos y contenido multimedia y cámbialo a Permitir.',
                      ],
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      primaryColor: primaryColor,
                    ),
                    _buildInstructionTab(
                      icon: Icons.phone_iphone,
                      title: 'One UI (Samsung)',
                      steps: [
                        'Abre Ajustes > Aplicaciones > Rmusic.',
                        'Toca en Accesos / Permisos.',
                        'Activa el permiso de Música y Audio o Archivos y contenido multimedia.',
                      ],
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      primaryColor: primaryColor,
                    ),
                    _buildInstructionTab(
                      icon: Icons.android_outlined,
                      title: 'Android Stock / Vanilla',
                      steps: [
                        'Ve a Ajustes > Aplicaciones > Ver todas > Rmusic.',
                        'Toca en Permisos.',
                        'Permite el acceso a Archivos y contenido multimedia.',
                      ],
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              ElevatedButton(
                onPressed: () async {
                  final status = await Permission.storage.request();
                  if (status.isGranted) {
                    if (context.mounted) Navigator.of(context).pop(true);
                  } else {
                    // Try with manageExternalStorage if on Android 11+
                    final manageStatus = await Permission.manageExternalStorage.request();
                    if (manageStatus.isGranted) {
                      if (context.mounted) Navigator.of(context).pop(true);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Permiso denegado. Intente "Abrir Ajustes".'),
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Conceder Permiso',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        openAppSettings();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Abrir Ajustes',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onUsePrivateFolder();
                        Navigator.of(context).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: textColor.withValues(alpha: 0.15)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Usar Carpeta Privada',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionTab({
    required IconData icon,
    required String title,
    required List<String> steps,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: primaryColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
