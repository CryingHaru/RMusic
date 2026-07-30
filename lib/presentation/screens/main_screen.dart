import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rmusic/core/utils/device_profile.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'library/library_screen.dart';
import 'history/history_screen.dart';
import 'settings/settings_screen.dart';
import 'player/player_screen.dart';
import '../widgets/player_bottom_bar.dart';
import '../widgets/app_svg_icon.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  late final FocusNode _rootFocusNode;

  static const double _playerBarHeight = PlayerBottomBar.outerHeight;

  @override
  void initState() {
    super.initState();
    _rootFocusNode = FocusNode(debugLabel: 'MainScreenRoot');
    _requestAppPermissions();
  }

  Future<void> _requestAppPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await [
        Permission.notification,
        Permission.audio,
        Permission.storage,
      ].request();
    }
  }

  @override
  void dispose() {
    _rootFocusNode.dispose();
    super.dispose();
  }

  void _setIndex(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Route<void> _buildPlayerRoute() {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PlayerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 190),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      );
    }

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PlayerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    // Usar viewPadding para respetar botones/gestos del sistema aunque el
    // teclado o SafeArea modifiquen padding.
    final bottomInset = media.viewPadding.bottom;
    final featurePhone = isFeaturePhoneSize(media.size);

    Widget layout;
    if (featurePhone) {
      layout = _buildFeaturePhoneLayout(bottomInset);
    } else if (screenWidth >= 900) {
      layout = _buildDesktopLayout(bottomInset);
    } else if (screenWidth >= 600) {
      layout = _buildTabletLayout(bottomInset);
    } else {
      layout = _buildMobileLayout(bottomInset);
    }

    return _buildKeyboardNavigationScope(
      child: layout,
      enableTabCycling: featurePhone,
    );
  }

  Widget _buildKeyboardNavigationScope({
    required Widget child,
    required bool enableTabCycling,
  }) {
    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const DirectionalFocusIntent(TraversalDirection.up),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const DirectionalFocusIntent(TraversalDirection.down),
      const SingleActivator(LogicalKeyboardKey.arrowLeft):
          const DirectionalFocusIntent(TraversalDirection.left),
      const SingleActivator(LogicalKeyboardKey.arrowRight):
          const DirectionalFocusIntent(TraversalDirection.right),
      const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.numpadEnter):
          const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
      const SingleActivator(LogicalKeyboardKey.goBack): const DismissIntent(),
      const SingleActivator(LogicalKeyboardKey.browserBack):
          const DismissIntent(),
      const SingleActivator(LogicalKeyboardKey.digit5):
          const _OpenPlayerIntent(),
      const SingleActivator(LogicalKeyboardKey.numpad5):
          const _OpenPlayerIntent(),
      const SingleActivator(LogicalKeyboardKey.digit1): const _SwitchTabIntent(
        0,
      ),
      const SingleActivator(LogicalKeyboardKey.numpad1): const _SwitchTabIntent(
        0,
      ),
      const SingleActivator(LogicalKeyboardKey.digit2): const _SwitchTabIntent(
        1,
      ),
      const SingleActivator(LogicalKeyboardKey.numpad2): const _SwitchTabIntent(
        1,
      ),
      const SingleActivator(LogicalKeyboardKey.digit3): const _SwitchTabIntent(
        2,
      ),
      const SingleActivator(LogicalKeyboardKey.numpad3): const _SwitchTabIntent(
        2,
      ),
      const SingleActivator(LogicalKeyboardKey.digit4): const _SwitchTabIntent(
        3,
      ),
      const SingleActivator(LogicalKeyboardKey.numpad4): const _SwitchTabIntent(
        3,
      ),
      // Ajustes (0 o tecla MENÚ)
      const SingleActivator(LogicalKeyboardKey.digit0):
          const _OpenSettingsIntent(),
      const SingleActivator(LogicalKeyboardKey.numpad0):
          const _OpenSettingsIntent(),
      const SingleActivator(LogicalKeyboardKey.contextMenu):
          const _OpenSettingsIntent(),
      const SingleActivator(LogicalKeyboardKey.f10):
          const _OpenSettingsIntent(),
    };

    if (enableTabCycling) {
      shortcuts.addAll({
        const SingleActivator(LogicalKeyboardKey.pageUp): const _CycleTabIntent(
          -1,
        ),
        const SingleActivator(LogicalKeyboardKey.pageDown):
            const _CycleTabIntent(1),
      });
    }

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Shortcuts(
        shortcuts: shortcuts,
        child: Actions(
          actions: {
            DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
              onInvoke: (intent) {
                FocusManager.instance.primaryFocus?.focusInDirection(
                  intent.direction,
                );
                return null;
              },
            ),
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                }
                return null;
              },
            ),
            _OpenPlayerIntent: CallbackAction<_OpenPlayerIntent>(
              onInvoke: (intent) {
                Navigator.of(context).push(_buildPlayerRoute());
                return null;
              },
            ),
            _CycleTabIntent: CallbackAction<_CycleTabIntent>(
              onInvoke: (intent) {
                final next = (_selectedIndex + intent.delta) % 4;
                _setIndex(next < 0 ? next + 4 : next);
                return null;
              },
            ),
            _SwitchTabIntent: CallbackAction<_SwitchTabIntent>(
              onInvoke: (intent) {
                if (intent.index >= 0 && intent.index < 4) {
                  _setIndex(intent.index);
                }
                return null;
              },
            ),
            _OpenSettingsIntent: CallbackAction<_OpenSettingsIntent>(
              onInvoke: (intent) {
                _openSettings();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            focusNode: _rootFocusNode,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePhoneLayout(double bottomInset) {
    final contentPadding = EdgeInsets.only(
      bottom: PlayerBottomBar.compactOuterHeight + bottomInset + 4,
    );

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  HomeScreen(contentPadding: contentPadding),
                  SearchScreen(
                    contentPadding: contentPadding,
                    onBack: () => _setIndex(0),
                  ),
                  LibraryScreen(contentPadding: contentPadding),
                  HistoryScreen(contentPadding: contentPadding),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset,
              child: const PlayerBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP (≥900): sidebar + content + bottom player
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(double bottomInset) {
    const playerBarPadding = 16.0;

    return Scaffold(
      body: Row(
        children: [
          _SideNavigationBar(
            selectedIndex: _selectedIndex,
            onSelected: _setIndex,
            onSettingsTap: _openSettings,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      HomeScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      ),
                      SearchScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                        onBack: () => _setIndex(0),
                      ),
                      LibraryScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      ),
                      HistoryScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      ),
                    ],
                  ),
                ),
                // Player bar at the bottom, inside the content area
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    playerBarPadding,
                    0,
                    playerBarPadding,
                    playerBarPadding,
                  ),
                  child: const PlayerBottomBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TABLET (600–899): rail nav + content + bottom player
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTabletLayout(double bottomInset) {
    return Scaffold(
      body: Row(
        children: [
          _RailNavigation(
            selectedIndex: _selectedIndex,
            onSelected: _setIndex,
            onSettingsTap: _openSettings,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      HomeScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      ),
                      SearchScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                        onBack: () => _setIndex(0),
                      ),
                      LibraryScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      ),
                      HistoryScreen(
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: const PlayerBottomBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE (<600): bottom nav + stacked player + content
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(double bottomInset) {
    const bottomNavHeight = 56.0;
    const navGap = 6.0;
    final totalBottom =
        bottomNavHeight + navGap + bottomInset + _playerBarHeight + 4;

    final contentPadding = EdgeInsets.only(bottom: totalBottom);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(onSettingsTap: _openSettings),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      HomeScreen(contentPadding: contentPadding),
                      SearchScreen(
                        contentPadding: contentPadding,
                        onBack: () => _setIndex(0),
                      ),
                      LibraryScreen(contentPadding: contentPadding),
                      HistoryScreen(contentPadding: contentPadding),
                    ],
                  ),
                ),
              ],
            ),
            // Player bar above bottom nav
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomNavHeight + navGap + bottomInset,
              child: const PlayerBottomBar(),
            ),
            // Bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomNavigationBar(
                selectedIndex: _selectedIndex,
                onSelected: _setIndex,
                bottomInset: bottomInset,
                height: bottomNavHeight,
                extraGap: navGap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SIDEBAR NAVIGATION – Desktop (≥900)
// ═══════════════════════════════════════════════════════════════════════════════

class _SideNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSettingsTap;

  const _SideNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = const [
      _NavItem(assetName: 'sparkles', label: 'Inicio'),
      _NavItem(assetName: 'search', label: 'Buscar'),
      _NavItem(assetName: 'library', label: 'Biblioteca'),
      _NavItem(assetName: 'history', label: 'Historial'),
    ];

    return SizedBox(
      width: 220,
      child: Material(
        color: colorScheme.surface,
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Rmusic',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Nav items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = selectedIndex == index;
                  return _buildNavTile(
                    context: context,
                    item: item,
                    selected: selected,
                    colorScheme: colorScheme,
                    onTap: () => onSelected(index),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                onTap: onSettingsTap,
                leading: AppSvgIcon(
                  assetName: 'settings',
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  'Ajustes',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                dense: true,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required _NavItem item,
    required bool selected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: AppSvgIcon(
        assetName: item.assetName,
        size: 22,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.35),
      dense: true,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RAIL NAVIGATION – Tablet (600–899)
// ═══════════════════════════════════════════════════════════════════════════════

class _RailNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSettingsTap;

  const _RailNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationRail(
      selectedIndex: _selectedIndex(selectedIndex),
      onDestinationSelected: (index) {
        if (index < 4) {
          onSelected(index);
        }
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      leading: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AppSvgIcon(
            assetName: 'sparkles',
            size: 22,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              onPressed: onSettingsTap,
              icon: AppSvgIcon(
                assetName: 'settings',
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Ajustes',
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: AppSvgIcon(assetName: 'sparkles', size: 22),
          label: Text('Inicio'),
        ),
        NavigationRailDestination(
          icon: AppSvgIcon(assetName: 'search', size: 22),
          label: Text('Buscar'),
        ),
        NavigationRailDestination(
          icon: AppSvgIcon(assetName: 'library', size: 22),
          label: Text('Biblioteca'),
        ),
        NavigationRailDestination(
          icon: AppSvgIcon(assetName: 'history', size: 22),
          label: Text('Historial'),
        ),
      ],
    );
  }

  int _selectedIndex(int index) => index.clamp(0, 3);
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP BAR – Mobile
// ═══════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _TopBar({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Rmusic',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            onPressed: onSettingsTap,
            icon: AppSvgIcon(
              assetName: 'settings',
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM NAVIGATION BAR – Mobile
// ═══════════════════════════════════════════════════════════════════════════════

class _BottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double bottomInset;
  final double height;
  final double extraGap;

  const _BottomNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.bottomInset,
    required this.height,
    required this.extraGap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = const [
      _NavItem(assetName: 'sparkles', label: 'Inicio'),
      _NavItem(assetName: 'search', label: 'Buscar'),
      _NavItem(assetName: 'library', label: 'Biblioteca'),
      _NavItem(assetName: 'history', label: 'Historial'),
    ];

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: height + extraGap,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = selectedIndex == index;

            return Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppSvgIcon(
                        assetName: item.assetName,
                        size: 22,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String assetName;
  final String label;

  const _NavItem({required this.assetName, required this.label});
}

class _CycleTabIntent extends Intent {
  final int delta;

  const _CycleTabIntent(this.delta);
}

class _OpenPlayerIntent extends Intent {
  const _OpenPlayerIntent();
}

class _SwitchTabIntent extends Intent {
  final int index;
  const _SwitchTabIntent(this.index);
}

class _OpenSettingsIntent extends Intent {
  const _OpenSettingsIntent();
}
