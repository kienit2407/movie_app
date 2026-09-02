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
            toolbarTitle: 'Cắt ảnh đại diện',
            toolbarColor: AppColor.bgApp,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColor.firstColor,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Cắt ảnh đại diện',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            doneButtonTitle: 'Xong',
            cancelButtonTitle: 'Hủy',
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
        _showMessage('Đã cập nhật ảnh đại diện.');
      } catch (_) {
        if (!mounted) return;
        setState(() => _localAvatar = previousAvatar);
        _showMessage('Không thể cập nhật ảnh đại diện. Hãy thử lại.');
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể mở ảnh. Hãy kiểm tra quyền truy cập.');
      }
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
      _showMessage('Đã cập nhật tên hiển thị.');
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể cập nhật tên. Hãy thử lại.');
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

  void _showMessage(String message) {
    AppToast.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserLibraryCubit>().state;
    final user = state.user;
    final displayName = state.displayName;
    final avatarUrl = state.avatarUrl;

    return PopScope(
      canPop: !_isUpdating,
      child: Stack(
        children: [
          const _ProfileBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Colors.white,
              centerTitle: true,
              title: const Text(
                'Sửa hồ sơ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
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
                      child: const Text('Thay đổi ảnh'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _InfoCard(
                    children: [
                      _ProfileInfoRow(
                        label: 'Tên',
                        value: displayName,
                        onTap: _openNameEditor,
                      ),
                      const _CardDivider(),
                      _ProfileInfoRow(
                        label: 'Email',
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
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Colors.white54,
                        ),
                        SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'Email được liên kết với tài khoản và chỉ hiển thị tại đây.',
                            style: TextStyle(
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
      label: 'Thay đổi ảnh đại diện',
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
            label: 'Chụp ảnh',
            onTap: onCamera,
          ),
          const _SheetDivider(),
          _AvatarActionRow(
            icon: Iconsax.gallery_copy,
            label: 'Tải ảnh lên',
            onTap: onGallery,
          ),
          const _SheetDivider(),
          _AvatarActionRow(
            icon: Iconsax.eye_copy,
            label: 'Xem ảnh',
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
          title: const Text('Ảnh đại diện'),
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
