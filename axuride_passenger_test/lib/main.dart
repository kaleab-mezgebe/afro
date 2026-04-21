import 'package:flutter/material.dart';
import 'presentation/simulator_page.dart';

void main() => runApp(const AxuRidePassengerSimulator());

class AxuRidePassengerSimulator extends StatelessWidget {
  const AxuRidePassengerSimulator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AxuRide Passenger Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFFFD700),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: const SimulatorPage(),
    );
  }
}
