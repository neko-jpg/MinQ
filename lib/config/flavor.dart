import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Flavor {
  dev,
  stg,
  prod,
}

class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;

  FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
  });
}

final flavorProvider = FutureProvider<FlavorConfig>((ref) async {
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final flavor = Flavor.values.firstWhere((e) => e.toString().split('.').last == flavorString);

  final json = await rootBundle.loadString('env/$flavorString.json');
  final jsonMap = jsonDecode(json) as Map<String, dynamic>;

  return FlavorConfig(
    flavor: flavor,
    apiBaseUrl: jsonMap['api_base_url'] as String,
  );
});
