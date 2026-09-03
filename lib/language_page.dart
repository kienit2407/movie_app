import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/enum/language_enum.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late Language _selectedLanguage;
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = context.read<LocalizationCubit>().state;
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleScroll() {
    final isScrolled =
        _scrollController.hasClients && _scrollController.offset > 2;
    if (isScrolled == _isScrolled) return;
    setState(() => _isScrolled = isScrolled);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _selectedLanguage != context.read<LocalizationCubit>().state;

  void _save() {
    if (!_hasChanges) return;
    context.read<LocalizationCubit>().changeLanguage(_selectedLanguage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColor.bgApp,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-.7, -1),
                    radius: 1.2,
                    colors: [
                      AppColor.firstColor.withValues(alpha: .22),
                      AppColor.bgApp.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                toolbarHeight: 64,
                leadingWidth: 92,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.commonCancel,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                title: Text(
                  l10n.settingsAppLanguage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.3,
                  ),
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: _hasChanges ? _save : null,
                    child: Text(
                      l10n.commonDone,
                      style: TextStyle(
                        color: _hasChanges
                            ? AppColor.thirdColor
                            : Colors.white30,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _isScrolled ? 18 : 0,
                      sigmaY: _isScrolled ? 18 : 0,
                    ),
                    child: AnimatedContainer(
                      key: const ValueKey('language-header-surface'),
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: _isScrolled
                            ? AppColor.bgApp.withValues(alpha: .88)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: _isScrolled
                                ? Colors.white.withValues(alpha: .08)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .055),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .07),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < Language.values.length;
                          index++
                        ) ...[
                          _LanguageTile(
                            language: Language.values[index],
                            selected:
                                Language.values[index] == _selectedLanguage,
                            onTap: () {
                              setState(() {
                                _selectedLanguage = Language.values[index];
                              });
                            },
                          ),
                          if (index != Language.values.length - 1)
                            Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.white.withValues(alpha: .07),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final Language language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppColor.primaryColor : null,
                border: selected
                    ? null
                    : Border.all(color: Colors.white30, width: 2),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 17,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
