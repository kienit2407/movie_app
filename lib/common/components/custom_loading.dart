import 'package:flutter/material.dart';

class CustomLoading extends StatefulWidget {
  const CustomLoading({
    super.key,
    this.size = 100
    });

  final double size;

  @override
  State<CustomLoading> createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading> with SingleTickerProviderStateMixin {

  late AnimationController _controller; //<- khởi tạo trễ một controller để đièu khiển tốc độ và thời giàn xoay
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this, //<- sử dụng this để dồng bộ nguồn ticker để đòng bộ với màn hình
      duration: const Duration(seconds: 1),
    )..repeat();
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller); //<- xác định phạm vi xoay và kết nói vơi sbooj điều khiển 
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _animation,
        child: Image.asset(
          'assets/images/loading.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
        ),
        
      ),
    );
  }
}