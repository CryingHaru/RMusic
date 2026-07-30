import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../data/database/daos/music_dao.dart';
import '../../providers/playback_flow_providers.dart';
import '../../widgets/app_svg_icon.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _sections = [
    _SettingsSectionData('Apariencia', Icons.palette_outlined),
    _SettingsSectionData('Calidad y fuentes', Icons.library_music_outlined),
    _SettingsSectionData('Reproducción', Icons.graphic_eq),
    _SettingsSectionData('Cuenta y datos', Icons.account_circle_outlined),
    _SettingsSectionData('Acerca de', Icons.info_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStateProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Ajustes'),
            floating: true,
            pinned: true,
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < _sections.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: _buildSectionCard(
                            context,
                            title: _sections[i].title,
                            icon: _sections[i].icon,
                            children: _getSectionChildren(context, ref, settings, i),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: colorScheme.surfaceContainer,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _withTileSeparators(children, colorScheme),
          ),
        ),
      ],
    );
  }

  List<Widget> _withTileSeparators(List<Widget> children, ColorScheme colorScheme) {
    if (children.isEmpty) return const [];
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        );
      }
    }
    return result;
  }

  List<Widget> _getSectionChildren(
    BuildContext context,
    WidgetRef ref,
    AppPreferences settings,
    int sectionIndex,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.read(settingsStateProvider.notifier);

    Widget buildTile({
      required String title,
      String? subtitle,
      required VoidCallback onTap,
      bool enabled = true,
    }) {
      return ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: AppSvgIcon(assetName: 'chevron_forward', size: 18, color: colorScheme.onSurfaceVariant),
        enabled: enabled,
        onTap: onTap,
      );
    }

    switch (sectionIndex) {
      case 0: // Apariencia
        return [
          buildTile(
            title: 'Tema',
            subtitle: _themeLabel(settings.themeMode),
            onTap: () => _showRadioDialog<String>(
              context: context,
              title: 'Tema',
              currentValue: settings.themeMode,
              items: const ['system', 'light', 'dark'],
              titleBuilder: _themeLabel,
              onSelected: notifier.setThemeMode,
            ),
          ),
          SwitchListTile(
            title: const Text('Color dinámico (Material You)'),
            subtitle: const Text('Usar paleta de colores del sistema'),
            value: settings.dynamicColor,
            onChanged: notifier.toggleDynamicColor,
          ),
          SwitchListTile(
            title: const Text('Colorear con portada'),
            subtitle: const Text('Adaptar la interfaz a la portada actual'),
            value: settings.useCoverArtColors,
            onChanged: notifier.toggleUseCoverArtColors,
          ),
          SwitchListTile(
            title: const Text('Negro puro'),
            subtitle: const Text('Fondo negro absoluto para pantallas OLED'),
            value: settings.pureBlack,
            onChanged: notifier.togglePureBlack,
          ),
        ];

      case 1: // Calidad y fuentes
        return [
          buildTile(
            title: 'Calidad de audio',
            subtitle: _qualitySummary(settings.quality),
            onTap: () => _showRadioDialog<String>(
              context: context,
              title: 'Calidad de audio',
              currentValue: settings.quality,
              items: const ['High', 'Medium', 'Low'],
              titleBuilder: (val) => switch (val) {
                'High' => 'Alta (AAC ~256kbps)',
                'Medium' => 'Media (AAC ~128kbps)',
                _ => 'Baja (Ahorro de datos)',
              },
              onSelected: notifier.setQuality,
            ),
          ),
          buildTile(
            title: 'Proveedor de letras',
            subtitle: _lyricsProviderLabel(settings.lyricsProvider),
            onTap: () => _showRadioDialog<String>(
              context: context,
              title: 'Proveedor de letras',
              currentValue: settings.lyricsProvider.trim().toLowerCase(),
              items: const ['lrclib', 'musixmatch', 'apple_music'],
              titleBuilder: (val) => switch (val) {
                'musixmatch' => 'Musixmatch',
                'apple_music' => 'Apple Music',
                _ => 'LRCLib (Sincronizadas)',
              },
              onSelected: notifier.setLyricsProvider,
            ),
          ),
          SwitchListTile(
            title: const Text('SponsorBlock'),
            subtitle: const Text('Saltar segmentos de intro, sponsor u offtopic'),
            value: settings.sponsorBlockEnabled,
            onChanged: notifier.toggleSponsorBlock,
          ),
          buildTile(
            title: 'Categorías de SponsorBlock',
            subtitle: '${settings.sponsorBlockCategories.length} seleccionadas',
            enabled: settings.sponsorBlockEnabled,
            onTap: () => _showSponsorBlockDialog(context, ref, settings),
          ),
        ];

      case 2: // Reproducción
        return [
          SwitchListTile(
            title: const Text('Auto-radio'),
            subtitle: const Text('Añadir canciones similares automáticamente al terminar la cola'),
            value: settings.autoRadio,
            onChanged: notifier.toggleAutoRadio,
          ),
          SwitchListTile(
            title: const Text('Pausar al desconectar auriculares'),
            subtitle: const Text('Pausar si se desconectan auriculares o bluetooth'),
            value: settings.pauseOnHeadsetUnplug,
            onChanged: notifier.togglePauseOnHeadsetUnplug,
          ),
          SwitchListTile(
            title: const Text('Normalización de volumen'),
            subtitle: const Text('Mantener un nivel de volumen uniforme'),
            value: settings.normalizeLoudness,
            onChanged: (v) {
              notifier.toggleNormalizeLoudness(v);
              _applyPlaybackPreferences(ref);
            },
          ),
          SwitchListTile(
            title: const Text('Omitir silencios'),
            subtitle: const Text('Saltar pausas de silencio en las canciones'),
            value: settings.skipSilence,
            onChanged: (v) {
              notifier.toggleSkipSilence(v);
              _applyPlaybackPreferences(ref);
            },
          ),
          buildTile(
            title: 'Velocidad de reproducción',
            subtitle: '${settings.playbackSpeed.toStringAsFixed(2)}x',
            onTap: () => _showSliderDialog(
              context: context,
              title: 'Velocidad de reproducción',
              initialValue: settings.playbackSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              labelBuilder: (v) => '${v.toStringAsFixed(2)}x',
              onSave: (v) {
                notifier.setPlaybackSpeed(v);
                _applyPlaybackPreferences(ref);
              },
            ),
          ),
        ];

      case 3: // Cuenta y datos
        return [
          SwitchListTile(
            title: const Text('Guardar historial'),
            subtitle: const Text('Registrar canciones escuchadas localmente'),
            value: settings.saveHistory,
            onChanged: notifier.toggleSaveHistory,
          ),
          buildTile(
            title: 'Borrar historial',
            subtitle: 'Eliminar el registro local de reproducción',
            onTap: () => _confirmClearHistory(context),
          ),
          buildTile(
            title: 'Restablecer ajustes',
            subtitle: 'Volver a los valores por defecto',
            onTap: () => _confirmResetSettings(context, ref),
          ),
        ];

      case 4: // Acerca de
      default:
        return [
          const ListTile(
            title: Text('Rmusic'),
            subtitle: Text('Versión 1.0.0'),
          ),
          const ListTile(
            title: Text('Desarrollador'),
            subtitle: Text('CryingHaru'),
          ),
          buildTile(
            title: 'Licencias de terceros',
            subtitle: 'Bibliotecas open-source utilizadas',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Rmusic',
              applicationVersion: '1.0.0',
            ),
          ),
        ];
    }
  }

  // ===========================================================================
  // HELPERS Y DIÁLOGOS
  // ===========================================================================

  void _showRadioDialog<T>({
    required BuildContext context,
    required String title,
    required T currentValue,
    required List<T> items,
    required String Function(T) titleBuilder,
    required void Function(T) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: RadioGroup<T>(
            groupValue: currentValue,
            onChanged: (value) {
              if (value != null) {
                onSelected(value);
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items
                  .map((item) => RadioListTile<T>(
                        value: item,
                        title: Text(titleBuilder(item)),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showSliderDialog({
    required BuildContext context,
    required String title,
    required double initialValue,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) labelBuilder,
    required void Function(double) onSave,
  }) {
    double temp = initialValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(labelBuilder(temp), style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: temp,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: (val) => setState(() => temp = val),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              onSave(temp);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showSponsorBlockDialog(BuildContext context, WidgetRef ref, AppPreferences preferences) {
    final selected = preferences.sponsorBlockCategories.toSet();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Categorías a omitir'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ('sponsor', 'Patrocinios'),
                ('selfPromotion', 'Autopromoción'),
                ('interaction', 'Interacción'),
                ('intro', 'Intro'),
                ('outro', 'Outro'),
                ('filler', 'Relleno'),
              ].map((opt) => CheckboxListTile(
                value: selected.contains(opt.$1),
                title: Text(opt.$2),
                onChanged: (val) => setState(() => val == true ? selected.add(opt.$1) : selected.remove(opt.$1)),
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              ref.read(settingsStateProvider.notifier).setSponsorBlockCategories(selected.toList());
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirm = await _showConfirmDialog(context, 'Borrar historial', '¿Quieres eliminar el historial local?', 'Borrar');
    if (confirm && context.mounted) {
      await getIt<MusicDao>().clearHistory();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historial eliminado')));
    }
  }

  Future<void> _confirmResetSettings(BuildContext context, WidgetRef ref) async {
    final confirm = await _showConfirmDialog(context, 'Restablecer ajustes', '¿Quieres restablecer todos los ajustes por defecto?', 'Restablecer');
    if (confirm && context.mounted) {
      ref.read(settingsStateProvider.notifier).resetAll();
      _applyPlaybackPreferences(ref);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajustes restablecidos')));
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context, String title, String content, String confirmText) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmText)),
            ],
          ),
        ) ??
        false;
  }

  void _applyPlaybackPreferences(WidgetRef ref) {
    final latest = ref.read(settingsStateProvider);
    ref.read(playbackControllerProvider).applyPlaybackPreferences(latest);
  }

  String _themeLabel(String mode) => switch (mode.trim().toLowerCase()) {
        'light' => 'Claro',
        'dark' => 'Oscuro',
        _ => 'Sistema',
      };

  String _qualitySummary(String quality) => switch (quality.trim().toLowerCase()) {
        'low' => 'Baja (Ahorro de datos)',
        'medium' => 'Media (Balanceada)',
        _ => 'Alta (AAC ~256kbps)',
      };

  String _lyricsProviderLabel(String value) => switch (value.trim().toLowerCase()) {
        'musixmatch' => 'Musixmatch',
        'apple_music' => 'Apple Music',
        _ => 'LRCLib',
      };
}

class _SettingsSectionData {
  final String title;
  final IconData icon;
  const _SettingsSectionData(this.title, this.icon);
}
