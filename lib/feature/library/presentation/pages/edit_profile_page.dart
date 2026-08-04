import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  CroppedFile? _croppedAvatar;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserLibraryCubit>().state.user;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    _nameController = TextEditingController(
      text: _firstNonEmpty([
        metadata['full_name'],
        metadata['name'],
        user?.email?.split('@').first,
      ]),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
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
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Cắt ảnh đại diện',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped != null && mounted) setState(() => _croppedAvatar = cropped);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Tên không được để trống.');
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      String? avatarUrl;
      final cropped = _croppedAvatar;
      if (cropped != null) {
        final extension = cropped.path.split('.').last;
        avatarUrl = await context.read<UserLibraryCubit>().uploadAvatar(
          await cropped.readAsBytes(),
          extension: extension,
        );
      }
      if (!mounted) return;
      await context.read<UserLibraryCubit>().updateProfile(
        displayName: name,
        avatarUrl: avatarUrl,
      );
      if (!mounted) return;
      context.read<AuthSessionCubit>().refresh();
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _errorMessage = 'Không thể cập nhật hồ sơ. Hãy thử lại.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserLibraryCubit>().state.user;
    final currentAvatar = _firstNonEmpty([
      user?.userMetadata?['avatar_url'],
      user?.userMetadata?['picture'],
    ]);
    return Scaffold(
      backgroundColor: AppColor.bgApp,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: AppColor.bgApp,
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _saving,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: _croppedAvatar != null
                            ? Image.file(
                                File(_croppedAvatar!.path),
                                fit: BoxFit.cover,
                              )
                            : currentAvatar.isNotEmpty
                            ? FastCachedImage(
                                url: currentAvatar,
                                fit: BoxFit.cover,
                              )
                            : const ColoredBox(
                                color: Color(0xff292B38),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 58,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton.filled(
                        tooltip: 'Chọn ảnh',
                        onPressed: _pickAvatar,
                        icon: const Icon(Icons.photo_library_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                maxLength: 80,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: user?.email ?? '',
                readOnly: true,
                style: const TextStyle(color: Colors.white70),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _firstNonEmpty(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}
