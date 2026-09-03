import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/app_toast.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/feature/auth/data/saved_account_store.dart';
import 'package:movie_app/feature/auth/presentation/session/saved_accounts_cubit.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/pages/sign_in.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _finishAccountChange() async {
    context.read<AuthSessionCubit>().refresh();
    await context.read<UserLibraryCubit>().refresh();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Future<void> _openAccountSwitcher() async {
    final accountsCubit = context.read<SavedAccountsCubit>();
    await accountsCubit.rememberCurrentSession();
    if (!mounted) return;

    final result = await showModalBottomSheet<_AccountSheetResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .68),
      builder: (_) => BlocProvider.value(
        value: accountsCubit,
        child: const _AccountSwitcherSheet(),
      ),
    );
    if (result == null || !mounted) return;

    if (result.addAccount) {
      final signedIn = await SignInPage.showSheet(
        context,
        forceGoogleAccountPicker: true,
      );
      if (signedIn) {
        await accountsCubit.rememberCurrentSession();
        if (!mounted) return;
        await _finishAccountChange();
      }
      return;
    }

    final userId = result.userId;
    if (userId == null) return;
    final switched = await accountsCubit.switchAccount(userId);
    if (!mounted) return;
    if (switched) {
      await _finishAccountChange();
    } else {
      AppToast.show(context, context.l10n.settingsAccountSwitchFailed);
    }
  }

  Future<void> _signOut() async {
    final l10n = context.l10n;
    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      dialog: AppAlertDialog(
        title: l10n.librarySignOutTitle,
        content: l10n.librarySignOutConfirmation,
        buttonTitle: l10n.librarySignOut,
        cancelButtonTitle: l10n.commonCancel,
        isDestructive: true,
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await context.read<SavedAccountsCubit>().signOutCurrent();
    if (!mounted) return;
    if (!success) {
      AppToast.show(context, context.l10n.settingsSignOutFailed);
      return;
    }

    if (Supabase.instance.client.auth.currentUser == null) {
      context.go(AppRoutes.home);
    } else {
      await context.read<UserLibraryCubit>().refresh();
    }
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
                    center: const Alignment(.8, -1),
                    radius: 1.1,
                    colors: [
                      AppColor.firstColor.withValues(alpha: .18),
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
                toolbarHeight: 64,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                leading: IconButton(
                  tooltip: l10n.commonBack,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
                ),
                title: Text(
                  l10n.settingsTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _isScrolled ? 18 : 0,
                      sigmaY: _isScrolled ? 18 : 0,
                    ),
                    child: AnimatedContainer(
                      key: const ValueKey('settings-header-surface'),
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
              BlocBuilder<SavedAccountsCubit, SavedAccountsState>(
                builder: (context, accountsState) {
                  return SliverSafeArea(
                    top: false,
                    sliver: SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
                      sliver: SliverList.list(
                        children: [
                          _SectionTitle(l10n.settingsGeneralSection),
                          const SizedBox(height: 9),
                          _SettingsCard(
                            children: [
                              _SettingsTile(
                                icon: Iconsax.language_square_copy,
                                title: l10n.settingsAppLanguage,
                                subtitle: context
                                    .watch<LocalizationCubit>()
                                    .state
                                    .displayName,
                                onTap: () => context.push(AppRoutes.language),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          _SectionTitle(l10n.settingsAccountSection),
                          const SizedBox(height: 9),
                          _SettingsCard(
                            children: [
                              _SettingsTile(
                                icon: Iconsax.arrow_swap_horizontal_copy,
                                title: l10n.settingsSwitchAccount,
                                trailing: _AccountAvatar(
                                  url:
                                      accountsState.currentAccount?.avatarUrl ??
                                      '',
                                  size: 34,
                                ),
                                onTap: accountsState.busyUserId == null
                                    ? _openAccountSwitcher
                                    : null,
                              ),
                              _SettingsTile(
                                icon: Iconsax.logout_1_copy,
                                title: l10n.librarySignOut,
                                destructive: true,
                                showDivider: false,
                                trailing: accountsState.busyUserId == null
                                    ? null
                                    : const SizedBox.square(
                                        dimension: 22,
                                        child:
                                            CircularProgressIndicator.adaptive(
                                              strokeWidth: 2,
                                            ),
                                      ),
                                onTap: accountsState.busyUserId == null
                                    ? _signOut
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .5),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive ? const Color(0xffFF7789) : Colors.white;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: destructive
                        ? const Color(0xffFF6B81).withValues(alpha: .12)
                        : Colors.white.withValues(alpha: .075),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: foreground.withValues(alpha: .82),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 10), trailing!],
                if (!destructive) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white30,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 67,
            endIndent: 16,
            color: Colors.white.withValues(alpha: .07),
          ),
      ],
    );
  }
}

class _AccountSwitcherSheet extends StatelessWidget {
  const _AccountSwitcherSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: const Color(0xff20212C),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(
                height: 62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      l10n.settingsSwitchAccount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: l10n.commonClose,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: BlocBuilder<SavedAccountsCubit, SavedAccountsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.accounts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(36),
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                      children: [
                        for (final account in state.accounts)
                          _AccountTile(
                            account: account,
                            isCurrent: account.userId == state.currentUserId,
                            isBusy: account.userId == state.busyUserId,
                            onTap: () => Navigator.of(
                              context,
                            ).pop(_AccountSheetResult.switchTo(account.userId)),
                          ),
                        _AddAccountTile(
                          onTap: () => Navigator.of(
                            context,
                          ).pop(const _AccountSheetResult.add()),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.isCurrent,
    required this.isBusy,
    required this.onTap,
  });

  final SavedAccount account;
  final bool isCurrent;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = account.displayName.isNotEmpty
        ? account.displayName
        : account.email;
    return InkWell(
      onTap: isBusy ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            _AccountAvatar(url: account.avatarUrl, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (account.email.isNotEmpty && account.email != title) ...[
                    const SizedBox(height: 3),
                    Text(
                      account.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isBusy)
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            else if (isCurrent)
              Container(
                width: 27,
                height: 27,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColor.primaryColor,
                ),
                child: const Icon(Icons.check_rounded, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddAccountTile extends StatelessWidget {
  const _AddAccountTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
              ),
              child: const Icon(Iconsax.user_add_copy, color: Colors.white70),
            ),
            const SizedBox(width: 14),
            Text(
              context.l10n.settingsAddAccount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: url.isEmpty
            ? const ColoredBox(
                color: Color(0xff30313D),
                child: Icon(Icons.person_rounded, color: Colors.white54),
              )
            : FastCachedImage(url: url, fit: BoxFit.cover),
      ),
    );
  }
}

class _AccountSheetResult {
  const _AccountSheetResult.add() : addAccount = true, userId = null;
  const _AccountSheetResult.switchTo(this.userId) : addAccount = false;

  final bool addAccount;
  final String? userId;
}
