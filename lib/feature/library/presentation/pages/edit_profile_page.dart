import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_app/common/components/app_toast.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';

enum _AvatarAction { camera, gallery, preview }

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  CroppedFile? _localAvatar;
  CroppedFile? _localCover;
  bool _isUpdating = false;

  Future<void> _showAvatarActions() async {
    HapticFeedback.lightImpact();
    final avatarUrl = context.read<UserLibraryCubit>().state.avatarUrl;
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .68),
      builder: (sheetContext) => _AvatarActionSheet(
        canPreview: _localAvatar != null || avatarUrl.isNotEmpty,
        onCamera: () => Navigator.pop(sheetContext, _AvatarAction.camera),
        onGallery: () => Navigator.pop(sheetContext, _AvatarAction.gallery),
        onPreview: () => Navigator.pop(sheetContext, _AvatarAction.preview),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _AvatarAction.camera:
        await _pickAndUploadAvatar(ImageSource.camera);
      case _AvatarAction.gallery:
        await _pickAndUploadAvatar(ImageSource.gallery);
      case _AvatarAction.preview:
        _openAvatarPreview(avatarUrl);
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final l10n = context.l10n;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (picked == null || !mounted) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.profileCropAvatar,
            toolbarColor: AppColor.bgApp,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColor.firstColor,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: l10n.profileCropAvatar,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            doneButtonTitle: l10n.commonDone,
            cancelButtonTitle: l10n.commonCancel,
          ),
        ],
      );
      if (cropped == null || !mounted) return;

      final previousAvatar = _localAvatar;
      setState(() {
        _localAvatar = cropped;
        _isUpdating = true;
      });

      try {
        final cubit = context.read<UserLibraryCubit>();
        final displayName = cubit.state.displayName;
        final extension = _fileExtension(cropped.path);
        final avatarUrl = await cubit.uploadAvatar(
          await cropped.readAsBytes(),
          extension: extension,
        );
        if (!mounted) return;
        await cubit.updateProfile(
          displayName: displayName,
          avatarUrl: avatarUrl,
        );
        if (!mounted) return;
        context.read<AuthSessionCubit>().refresh();
        _showMessage(l10n.profileAvatarUpdated);
      } catch (_) {
        if (!mounted) return;
        setState(() => _localAvatar = previousAvatar);
        _showMessage(l10n.profileAvatarUpdateFailed);
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(l10n.profilePhotoOpenFailed);
      }
    }
  }

  Future<void> _showCoverActions() async {
    HapticFeedback.lightImpact();
    final coverUrl = context.read<UserLibraryCubit>().state.coverUrl;
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .68),
      builder: (sheetContext) => _AvatarActionSheet(
        canPreview: _localCover != null || coverUrl.isNotEmpty,
        onCamera: () => Navigator.pop(sheetContext, _AvatarAction.camera),
        onGallery: () => Navigator.pop(sheetContext, _AvatarAction.gallery),
        onPreview: () => Navigator.pop(sheetContext, _AvatarAction.preview),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _AvatarAction.camera:
        await _pickAndUploadCover(ImageSource.camera);
      case _AvatarAction.gallery:
        await _pickAndUploadCover(ImageSource.gallery);
      case _AvatarAction.preview:
        _openCoverPreview(coverUrl);
    }
  }

  Future<void> _pickAndUploadCover(ImageSource source) async {
    final l10n = context.l10n;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2560,
        maxHeight: 1440,
      );
      if (picked == null || !mounted) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.profileCropCover,
            toolbarColor: AppColor.bgApp,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColor.firstColor,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: l10n.profileCropCover,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            doneButtonTitle: l10n.commonDone,
            cancelButtonTitle: l10n.commonCancel,
          ),
        ],
      );
      if (cropped == null || !mounted) return;

      final previousCover = _localCover;
      setState(() {
        _localCover = cropped;
        _isUpdating = true;
      });

      try {
        final cubit = context.read<UserLibraryCubit>();
        final coverUrl = await cubit.uploadCover(
          await cropped.readAsBytes(),
          extension: _fileExtension(cropped.path),
        );
        if (!mounted) return;
        await cubit.updateProfile(
          displayName: cubit.state.displayName,
          coverUrl: coverUrl,
        );
        if (!mounted) return;
        context.read<AuthSessionCubit>().refresh();
        _showMessage(l10n.profileCoverUpdated);
      } catch (_) {
        if (!mounted) return;
        setState(() => _localCover = previousCover);
        _showMessage(l10n.profileCoverUpdateFailed);
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    } catch (_) {
      if (mounted) _showMessage(l10n.profilePhotoOpenFailed);
    }
  }

  Future<void> _openNameEditor() async {
    final cubit = context.read<UserLibraryCubit>();
    final currentName = cubit.state.displayName;
    final nextName = await context.push<String>(
      AppRoutes.editDisplayName,
      extra: currentName,
    );
    if (!mounted || nextName == null || nextName == currentName) return;

    setState(() => _isUpdating = true);
    try {
      await cubit.updateProfile(displayName: nextName);
      if (!mounted) return;
      context.read<AuthSessionCubit>().refresh();
      _showMessage(context.l10n.profileNameUpdated);
    } catch (_) {
      if (mounted) {
        _showMessage(context.l10n.profileNameUpdateFailed);
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _openAvatarPreview(String avatarUrl) {
    if (_localAvatar == null && avatarUrl.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AvatarPreviewPage(
          localPath: _localAvatar?.path,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }

  void _openCoverPreview(String coverUrl) {
    if (_localCover == null && coverUrl.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _CoverPreviewPage(localPath: _localCover?.path, coverUrl: coverUrl),
      ),
    );
  }

  void _showMessage(String message) {
    AppToast.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserLibraryCubit>().state;
    final user = state.user;
    final displayName = state.displayName;
    final avatarUrl = state.avatarUrl;
    final coverUrl = state.coverUrl;
    final topContentPadding =
        MediaQuery.paddingOf(context).top + kToolbarHeight + 14;
    final coverHeight = topContentPadding + 220;

    return PopScope(
      canPop: !_isUpdating,
      child: Stack(
        children: [
          const _ProfileBackground(),
          if (_localCover != null || coverUrl.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: coverHeight,
              child: _EditProfileCover(
                localPath: _localCover?.path,
                coverUrl: coverUrl,
              ),
            ),
          Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Colors.white,
              centerTitle: true,
              title: Text(
                context.l10n.profileEdit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, topContentPadding, 20, 36),
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          Center(
                            child: _EditableAvatar(
                              localPath: _localAvatar?.path,
                              avatarUrl: avatarUrl,
                              onTap: _showAvatarActions,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton(
                              onPressed: _showAvatarActions,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColor.thirdColor,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(context.l10n.profileChangePhoto),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black26,
                          ),
                          tooltip: context.l10n.profileChangeCover,
                          onPressed: _isUpdating ? null : _showCoverActions,
                          icon: const Icon(Icons.photo_camera),
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _InfoCard(
                    children: [
                      _ProfileInfoRow(
                        label: context.l10n.profileName,
                        value: displayName,
                        onTap: _openNameEditor,
                      ),
                      const _CardDivider(),
                      _ProfileInfoRow(
                        label: context.l10n.authEmail,
                        value: user?.email ?? '',
                        trailing: const Icon(
                          Icons.lock_outline_rounded,
                          size: 19,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .055),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .08),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            context.l10n.profileEmailDescription,
                            style: const TextStyle(
                              color: Colors.white54,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUpdating)
            const Positioned.fill(child: _UpdatingProfileOverlay()),
        ],
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColor.bgApp,
          gradient: RadialGradient(
            center: const Alignment(.75, -.75),
            radius: 1.25,
            colors: [
              AppColor.firstColor.withValues(alpha: .22),
              AppColor.bgApp,
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileCover extends StatelessWidget {
  const _EditProfileCover({required this.localPath, required this.coverUrl});

  final String? localPath;
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final image = localPath != null
        ? Image.file(File(localPath!), fit: BoxFit.cover)
        : FastCachedImage(
            key: ValueKey(coverUrl),
            url: coverUrl,
            fit: BoxFit.cover,
          );

    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, .45, 1],
        ).createShader(bounds),
        child: image,
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.localPath,
    required this.avatarUrl,
    required this.onTap,
  });

  final String? localPath;
  final String avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.profileChangeAvatar,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColor.primaryColor,
              ),
              child: ClipOval(
                child: ColoredBox(
                  color: const Color(0xff292B38),
                  child: localPath != null
                      ? Image.file(File(localPath!), fit: BoxFit.cover)
                      : avatarUrl.isNotEmpty
                      ? FastCachedImage(
                          key: ValueKey(avatarUrl),
                          url: avatarUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: Colors.white70,
                          size: 62,
                        ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 3,
              child: Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: AppColor.buttonColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.bgApp, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onTap == null ? Colors.white60 : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: Colors.white54,
                ),
          ],
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 18,
      endIndent: 18,
      color: Colors.white.withValues(alpha: .08),
    );
  }
}

class _AvatarActionSheet extends StatelessWidget {
  const _AvatarActionSheet({
    required this.canPreview,
    required this.onCamera,
    required this.onGallery,
    required this.onPreview,
  });

  final bool canPreview;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 12 + 8),
      decoration: BoxDecoration(
        color: Color(0xff2F3345),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(top: 2, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          _AvatarActionRow(
            icon: Iconsax.camera_copy,
            label: context.l10n.profileTakePhoto,
            onTap: onCamera,
          ),
          const _SheetDivider(),
          _AvatarActionRow(
            icon: Iconsax.gallery_copy,
            label: context.l10n.profileUploadPhoto,
            onTap: onGallery,
          ),
          const _SheetDivider(),
          _AvatarActionRow(
            icon: Iconsax.eye_copy,
            label: context.l10n.profileViewPhoto,
            onTap: canPreview ? onPreview : null,
          ),
        ],
      ),
    );
  }
}

class _AvatarActionRow extends StatelessWidget {
  const _AvatarActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: enabled ? Colors.white : Colors.white24),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white24,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 14,
      endIndent: 14,
      color: Colors.white.withValues(alpha: .08),
    );
  }
}

class _AvatarPreviewPage extends StatelessWidget {
  const _AvatarPreviewPage({required this.localPath, required this.avatarUrl});

  final String? localPath;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text(context.l10n.profileAvatar),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: .8,
            maxScale: 4,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).width,
              child: localPath != null
                  ? Image.file(File(localPath!), fit: BoxFit.contain)
                  : FastCachedImage(
                      key: ValueKey(avatarUrl),
                      url: avatarUrl,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverPreviewPage extends StatelessWidget {
  const _CoverPreviewPage({required this.localPath, required this.coverUrl});

  final String? localPath;
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text(context.l10n.profileCover),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: .8,
            maxScale: 4,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: localPath != null
                    ? Image.file(File(localPath!), fit: BoxFit.contain)
                    : FastCachedImage(
                        key: ValueKey(coverUrl),
                        url: coverUrl,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdatingProfileOverlay extends StatelessWidget {
  const _UpdatingProfileOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: SizedBox.square(
          dimension: 32,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

String _fileExtension(String path) {
  final extension = path.split('.').last.toLowerCase();
  return extension == 'jpg' || extension == 'jpeg' || extension == 'png'
      ? extension
      : 'jpg';
}
