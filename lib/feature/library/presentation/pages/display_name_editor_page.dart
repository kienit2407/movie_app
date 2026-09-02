import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class DisplayNameEditorPage extends StatefulWidget {
  const DisplayNameEditorPage({super.key, required this.initialName});

  final String initialName;

  @override
  State<DisplayNameEditorPage> createState() => _DisplayNameEditorPageState();
}

class _DisplayNameEditorPageState extends State<DisplayNameEditorPage> {
  static const _maxLength = 30;
  late final TextEditingController _controller;

  bool get _canSave {
    final name = _controller.text.trim();
    return name.isNotEmpty && name != widget.initialName;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName)
      ..selection = TextSelection.collapsed(offset: widget.initialName.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.bgApp,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(.75, -.75),
            radius: 1.25,
            colors: [
              AppColor.firstColor.withValues(alpha: .22),
              AppColor.bgApp,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            title: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                ),
                const Spacer(),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, _, __) => TextButton(
                    onPressed: _canSave ? _save : null,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.thirdColor,
                      disabledForegroundColor: Colors.white24,
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
              children: [
                const Text(
                  'Tên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tên này sẽ hiển thị trên hồ sơ Liquid Phim của bạn.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 26),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLength: _maxLength,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_maxLength),
                    ],
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: .075),
                      hintText: 'Nhập tên hiển thị',
                      hintStyle: const TextStyle(color: Colors.white38),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      suffixIcon: value.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Xóa tên',
                              onPressed: _controller.clear,
                              icon: const Icon(
                                Icons.cancel_rounded,
                                color: Colors.white38,
                              ),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: .08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColor.firstColor,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
