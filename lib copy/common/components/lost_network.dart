import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class LostNetworkPage extends StatelessWidget {
  const LostNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Lottie.asset('assets/icons/notConnectInternet.json'),
    );
  }
}