# Skill — Sửa UX `MoviePlayerPage` (Portrait-only): seekbar sát mép/panel, ambient xuống panel, tap giống YouTube, drag panel vs drag video + mini-player

> **Phạm vi:** chỉ sửa **màn hình dọc (portrait)**. Màn hình ngang (landscape) giữ nguyên.
>
> **File mục tiêu:** `MoviePlayerPage` (file đang chứa class `MoviePlayerPage` / `_MoviePlayerPageState`).

---

## 0) Guardrails để không “vỡ file” khi dùng Opencode / LLM
1. **Không rewrite cả file.** Chỉ patch các block liên quan (apply_patch / diff).
2. **Không duplicate class / import.** Đảm bảo file chỉ có **1** `MoviePlayerPage` và **1** `_MoviePlayerPageState`.
3. Sau khi sửa: chạy
   - `dart format .`
   - `flutter analyze`
   - mở app kiểm tra portrait + landscape.

---

## 1) Mục tiêu UI/UX (theo yêu cầu)
### 1.1 Seekbar
- Seekbar **nằm đúng “đường tiếp xúc” giữa video và panel** (giống YouTube).
- Seekbar **sát mép** (hai đầu chạm mép màn hình), nhưng vẫn đảm bảo thumb không bị “cụt”.
- **Thumb chỉ hiện khi người dùng chạm/drag để tua** (scrubbing). Bình thường chỉ là “thanh mảnh”.

### 1.2 Ambient blur
- Ambient blur (nền video blur + tint) **phủ xuống cả panel**, không chỉ nằm trong khu vực video/appbar.
- Panel phải nhìn thấy ambient (tức panel cần **nền bán trong suốt** hoặc **BackdropFilter**).

### 1.3 Tap/Controls (giống YouTube)
- **Tap vào video (bất kỳ chỗ nào):** chỉ để **ẩn/hiện controls**.
- **Play/Pause chỉ thực thi khi bấm đúng nút Play/Pause** (không được “tap trúng nền overlay là pause/play”).
- Double tap trái/phải: tua lùi/tiến (giữ).

### 1.4 Drag: panel để mở rộng dọc, video để “mini”
- **Kéo panel** (drag handle/panel) để thay đổi độ chiếm chỗ của panel → video **mở rộng dọc** khi panel **co lại**.
- **Kéo video** (swipe down) để vào mini-player.
- Khi video mở rộng dọc gần full: **SafeArea (top) biến mất** để video nằm “giữa màn hình”, và seekbar/controls reposition phù hợp.

---

## 2) Refactor layout portrait: đặt Ambient + Seekbar đúng layer

### 2.1 Tách “ambient layer” ra khỏi video stack
Hiện tại bạn render ambient blur *bên trong* `Container(height: _videoHeight)` nên panel không thể “hưởng” background đó.

✅ Cách làm: đưa ambient thành **Positioned.fill ở root Stack** của portrait.

**Tạo helper:**
```dart
Widget _buildAmbientBackground() {
  final vp = _videoPlayerController;
  if (vp == null || !vp.value.isInitialized) {
    return const ColoredBox(color: Colors.black);
  }

  return Positioned.fill(
    child: Opacity(
      opacity: 0.35,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: vp.value.size.width,
            height: vp.value.size.height,
            child: VideoPlayer(vp),
          ),
        ),
      ),
    ),
  );
}
```

> Lưu ý: đây chỉ là “video blur”. Bạn có thể overlay thêm 1 lớp `Container(color: Colors.black.withOpacity(...))` để tint nền.

---

### 2.2 Đưa seekbar ra “đường ranh” giữa video và panel
Hiện tại seekbar nằm `Positioned(bottom: -4)` **bên trong video container** → nhìn như “dính vào video”, không nằm đúng ranh giới.

✅ Cách làm: portrait build dùng **Stack(root)**, đặt seekbar là `Positioned` theo `top = _videoHeight - seekbarVisualHeight/2`.

**Ví dụ cấu trúc mới của `_buildPortraitPlayer()` (concept):**
```dart
Widget _buildPortraitPlayer() {
  final screenH = MediaQuery.of(context).size.height;
  final topPadding = MediaQuery.of(context).padding.top;
  final isExpanded = _videoHeight >= _maxVideoHeight - 2;

  return MediaQuery.removePadding(
    context: context,
    removeTop: isExpanded, // safearea top biến mất khi expanded
    child: Stack(
      fit: StackFit.expand,
      children: [
        _buildAmbientBackground(),

        Column(
          children: [
            SizedBox(
              height: _videoHeight,
              child: _buildPortraitVideoSurface(), // Chewie + overlays (KHÔNG đặt seekbar ở đây)
            ),

            // panel
            Expanded(
              child: _buildPortraitPanel(), // backdrop + list
            ),
          ],
        ),

        // seekbar nằm tại ranh giới video/panel
        Positioned(
          top: _videoHeight - (_seekbarVisualHeight / 2),
          left: 0,
          right: 0,
          child: _buildSeekBarOnly(),
        ),
      ],
    ),
  );
}
```

---

## 3) Seekbar “sát mép” + thumb chỉ hiện khi scrubbing

### 3.1 Tách seekbar khỏi control bar
Hiện `_buildControlBar()` đang chứa cả time row + fullscreen button + slider.  
Để đặt slider đúng ranh giới, hãy tách thành 2 phần:

- `_buildSeekBarOnly()` → chỉ slider/progress (luôn render)
- `_buildTopControlsRow()` → time + fullscreen (chỉ render khi `_showControls`)

**Seekbar-only** nên có “hit area” dày (dễ kéo), nhưng “track” nằm sát mép.

```dart
static const double _seekbarHitHeight = 24;     // vùng chạm
static const double _seekbarVisualHeight = 8;   // chiều cao render
static const double _thumbRadius = 6;
```

Trong SliderTheme:
- `trackHeight`: bình thường 2, khi `_isScrubbing` thì 4
- `thumbShape`: invisible khi không scrubbing, visible khi scrubbing

Bạn đang làm đúng ý này; chỉ cần đảm bảo seekbar **luôn xuất hiện** và “flush edge”.

---

### 3.2 Track “flush edge” (hai đầu chạm mép màn hình)
Material Slider tính toán vị trí thumb dựa trên `trackRect`. Muốn thumb chạm mép mà không bị cắt, hãy offset rect theo bán kính thumb.

✅ Sửa `BufferedSliderTrackShape.getPreferredRect`:
```dart
@override
Rect getPreferredRect({
  required RenderBox parentBox,
  Offset offset = Offset.zero,
  required SliderThemeData sliderTheme,
  bool isEnabled = false,
  bool isDiscrete = false,
}) {
  final trackHeight = sliderTheme.trackHeight ?? 2;
  const thumbRadius = _thumbRadius; // đồng bộ với thumb shape

  // track bắt đầu tại thumbRadius để khi thumb ở min, mép thumb = 0
  final left = offset.dx + thumbRadius;
  final width = parentBox.size.width - (2 * thumbRadius);

  // đặt track sát đáy của widget seekbar
  final top = offset.dy + parentBox.size.height - trackHeight;

  return Rect.fromLTWH(left, top, width, trackHeight);
}
```

> Nếu bạn đặt seekbar ở ranh giới video/panel, nhớ để seekbar widget “Clip.none” để thumb không bị panel clip.

---

## 4) Ambient xuống panel: panel phải “hưởng” background
Vì ambient layer đã là `Positioned.fill`, panel chỉ cần:
- nền “semi-transparent”
- hoặc `BackdropFilter` để blur nhẹ + tint

**Gợi ý `_buildPortraitPanel()` wrapper:**
```dart
Widget _buildPortraitPanel() {
  return ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        color: Colors.black.withOpacity(0.35), // quan trọng để nhìn thấy ambient
        child: ... // content panel hiện tại (title + episode list)
      ),
    ),
  );
}
```

---

## 5) Tap/Controls giống YouTube: chỉ nút play/pause mới pause/play

### 5.1 Không để overlay “ăn” tap toàn màn hình
Hiện `_buildPlayPauseOverlay()` đang:
- wrap cả màn hình bằng `GestureDetector(onTap: _togglePlayPause)`  
→ người dùng tap bất kỳ chỗ nào cũng pause/play (không đúng yêu cầu).

✅ Sửa: chỉ button ở giữa là tappable.
```dart
Widget _buildPlayPauseOverlay() {
  if (_chewieController == null) return const SizedBox.shrink();

  return Center(
    child: AnimatedOpacity(
      opacity: _showControls ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: _togglePlayPause, // CHỈ button mới toggle
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 80),
            child: _chewieController!.isPlaying
              ? Icon(Iconsax.pause_copy, key: const ValueKey('pause'), color: Colors.white, size: 30)
              : Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Icon(Iconsax.play_copy, key: const ValueKey('play'), color: Colors.white, size: 30),
                ),
          ),
        ),
      ),
    ),
  );
}
```

### 5.2 Center double tap không được toggle play/pause
Hiện `_handleDoubleTap()` có nhánh “center” gọi `_togglePlayPause()`.

✅ Sửa nhánh center:
- hoặc `_toggleControls()`
- hoặc `_showControlsWithAutoHide()`

```dart
void _handleDoubleTap(TapDownDetails details) {
  final screenWidth = MediaQuery.of(context).size.width;
  final tapX = details.globalPosition.dx;

  if (tapX < screenWidth * 0.4) {
    _handleYoutubeSeek(SeekDirection.backward);
  } else if (tapX > screenWidth * 0.6) {
    _handleYoutubeSeek(SeekDirection.forward);
  } else {
    _toggleControls(); // thay vì play/pause
  }
}
```

---

## 6) Drag behavior: panel mở rộng dọc, video swipe-down để mini

### 6.1 Panel drag điều khiển `_videoHeight`
Hiện bạn đang drag trực tiếp trên video để đổi `_videoHeight`. Theo yêu cầu mới:
- video drag: ưu tiên mini (swipe down)
- panel drag: điều khiển độ mở rộng dọc

✅ Giải pháp gợi ý (khuyến nghị): dùng `DraggableScrollableSheet` cho panel và map `extent -> _videoHeight`.

**State vars:**
```dart
final DraggableScrollableController _panelCtrl = DraggableScrollableController();
static const double _panelMin = 0.18; // panel co lại
static const double _panelMax = 0.65; // panel mở
```

**Trong build portrait:**
```dart
Expanded(
  child: NotificationListener<DraggableScrollableNotification>(
    onNotification: (n) {
      final t = ((n.extent - _panelMin) / (_panelMax - _panelMin)).clamp(0.0, 1.0);

      // panel càng mở (t -> 1) => video càng nhỏ
      final newH = lerpDouble(_maxVideoHeight, _minVideoHeight, t)!;

      if (mounted) setState(() => _videoHeight = newH);
      return false;
    },
    child: DraggableScrollableSheet(
      minChildSize: _panelMin,
      maxChildSize: _panelMax,
      initialChildSize: _panelMax,
      builder: (context, scrollCtrl) {
        return _buildPortraitPanelWithScroll(scrollCtrl);
      },
    ),
  ),
),
```

> Nếu bạn muốn panel “ẩn hẳn” khi expanded video: đặt `_panelMin = 0.01` và khi extent <= 0.02 thì bỏ rounded/top divider.

### 6.2 Video swipe-down để mini player
Giữ gesture trên video nhưng **chỉ dùng để mini**:
- Detect drag xuống đủ xa / velocity đủ lớn
- Chỉ trigger khi video đang ở trạng thái “compact” (gần `_minVideoHeight`) hoặc theo logic bạn muốn.

Ví dụ:
```dart
double _dragDy = 0;

onVerticalDragStart: (d) { _dragDy = 0; },
onVerticalDragUpdate: (d) { _dragDy += d.delta.dy; },
onVerticalDragEnd: (d) {
  final isDownFast = (d.primaryVelocity ?? 0) > 900;
  final atCompact = (_videoHeight - _minVideoHeight).abs() < 8;

  if (atCompact && (isDownFast || _dragDy > 120)) {
    _enterMiniPlayer();
  } else {
    _dragDy = 0;
  }
},
```

---

## 7) SafeArea khi video “expanded portrait”
Yêu cầu: khi mở rộng dọc (video gần full), safearea top biến mất để video nằm “giữa”.

✅ Cách đơn giản:
- `MediaQuery.removePadding(removeTop: isExpanded)`
- hoặc `SafeArea(top: !isExpanded, bottom: false, ...)`

Ngoài ra:
- Nếu cần tránh “đụng” status bar cho controls (appbar overlay), hãy add padding thủ công cho nút ở top:
  - `final topInset = MediaQuery.of(context).padding.top;`
  - `Positioned(top: isExpanded ? topInset : 8, ...)`

---

## 8) Checklist nghiệm thu (Portrait)
1. Seekbar đúng ranh giới video/panel, sát mép trái/phải.
2. Thumb chỉ hiện khi chạm kéo, bình thường chỉ là thanh mảnh.
3. Panel thấy rõ ambient (blur/tint) phía sau.
4. Tap video: chỉ ẩn/hiện controls.
5. Tap play/pause button: mới pause/play.
6. Double tap trái/phải tua, center double tap không pause/play.
7. Drag panel co lại → video mở rộng dọc; drag panel mở → video thu.
8. Swipe down trên video (đúng điều kiện) → mini-player.

---

## 9) Gợi ý tối ưu hiệu năng (optional)
- Ambient render `VideoPlayer` 2 lần (1 blur background + 1 foreground). Nếu thấy lag:
  - Giảm `sigmaX/Y` xuống 16–20
  - hoặc chỉ render ambient khi `_showControls == true` / panel mở
  - hoặc dùng `RepaintBoundary` cho layer blur.

