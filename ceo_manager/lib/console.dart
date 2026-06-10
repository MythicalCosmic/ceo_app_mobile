import 'package:flutter/material.dart';
import 'theme.dart';
import 'data.dart';
import 'screens.dart';

/// The role console: a bottom-tab shell that swaps the active screen.
class Console extends StatefulWidget {
  final RoleConfig cfg;
  final VoidCallback onSwitchRole;
  const Console({super.key, required this.cfg, required this.onSwitchRole});

  @override
  State<Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  String tab = 'dash';

  @override
  void didUpdateWidget(Console old) {
    super.didUpdateWidget(old);
    if (old.cfg.role != widget.cfg.role) tab = 'dash';
  }

  Widget _screen() {
    switch (tab) {
      case 'students':
        return const StudentsScreen();
      case 'anomalies':
        return const AnomaliesScreen();
      case 'approvals':
        return const ApprovalsScreen();
      case 'branches':
        return const BranchesScreen();
      case 'cases':
        return const CasesScreen();
      case 'ai':
        return AiScreen(cfg: widget.cfg);
      case 'messages':
        return const MessagesScreen();
      case 'me':
        return ProfileScreen(cfg: widget.cfg, onSwitchRole: widget.onSwitchRole);
      default:
        return DashboardScreen(cfg: widget.cfg, go: (t) => setState(() => tab = t));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cfg.colors;
    return SfTheme(
      colors: c,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.025),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(key: ValueKey(tab), child: _screen()),
                  ),
                ),
              ),
              _TabBar(
                cfg: widget.cfg,
                colors: c,
                current: tab,
                onTap: (t) => setState(() => tab = t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final RoleConfig cfg;
  final SfColors colors;
  final String current;
  final ValueChanged<String> onTap;
  const _TabBar({required this.cfg, required this.colors, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = cfg.accent(colors);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: EdgeInsets.fromLTRB(4, 8, 4, 8 + MediaQuery.of(context).padding.bottom * 0.4),
      child: Row(
        children: [
          for (final t in cfg.tabs)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(t.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: current == t.id ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutBack,
                          scale: current == t.id ? 1.0 : 0.92,
                          child: Icon(t.icon,
                              size: 21, color: current == t.id ? Colors.white : colors.muted),
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 260),
                        style: TextStyle(
                            fontFamily: SfType.ui,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: current == t.id ? accent : colors.muted),
                        child: Text(t.label),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
