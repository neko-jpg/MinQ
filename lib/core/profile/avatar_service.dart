import 'dart:math' as math;

/// Service for avatar generation and management
class AvatarService {
  static const String _baseUrl = 'https://api.dicebear.com/7.x/avataaars/svg';
  
  /// Generate avatar URL from seed
  static String getAvatarUrl(String seed) {
    return '$_baseUrl?seed=$seed';
  }
  
  /// Generate a random avatar seed
  static String generateRandomSeed() {
    final random = math.Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = random.nextInt(999999);
    return 'seed-$timestamp-$randomValue';
  }
  
  /// Get predefined avatar seeds for selection
  static List<String> getPredefinedSeeds() {
    return [
      'seed-adventurer',
      'seed-explorer',
      'seed-creator',
      'seed-dreamer',
      'seed-achiever',
      'seed-builder',
      'seed-thinker',
      'seed-innovator',
      'seed-leader',
      'seed-artist',
      'seed-scholar',
      'seed-warrior',
      'seed-sage',
      'seed-pioneer',
      'seed-visionary',
    ];
  }
  
  /// Generate avatar seed based on user preferences
  static String generatePersonalizedSeed({
    String? displayName,
    List<String>? focusTags,
  }) {
    final random = math.Random();
    
    // Use display name as base if available
    String baseSeed = displayName?.toLowerCase().replaceAll(' ', '-') ?? 'user';
    
    // Add focus tag influence
    if (focusTags != null && focusTags.isNotEmpty) {
      final primaryTag = focusTags.first.toLowerCase();
      baseSeed = '$baseSeed-$primaryTag';
    }
    
    // Add randomness to ensure uniqueness
    final randomSuffix = random.nextInt(9999);
    return '$baseSeed-$randomSuffix';
  }
  
  /// Get avatar style options
  static Map<String, List<String>> getAvatarStyleOptions() {
    return {
      'style': ['adventurer', 'avataaars', 'big-ears', 'big-smile', 'croodles'],
      'mood': ['happy', 'sad', 'surprised', 'wink'],
      'accessories': ['glasses', 'sunglasses', 'none'],
      'hair': ['short', 'long', 'curly', 'straight', 'bald'],
      'clothing': ['casual', 'formal', 'hoodie', 'sweater'],
    };
  }
  
  /// Generate custom avatar URL with options
  static String getCustomAvatarUrl(
    String seed, {
    String style = 'avataaars',
    String? mood,
    String? accessories,
    String? hair,
    String? clothing,
    String? backgroundColor,
  }) {
    final params = <String, String>{
      'seed': seed,
    };
    
    if (mood != null) params['mood'] = mood;
    if (accessories != null) params['accessories'] = accessories;
    if (hair != null) params['hair'] = hair;
    if (clothing != null) params['clothing'] = clothing;
    if (backgroundColor != null) params['backgroundColor'] = backgroundColor;
    
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return 'https://api.dicebear.com/7.x/$style/svg?$queryString';
  }
  
  /// Get fallback avatar initials
  static String getInitials(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    
    final words = trimmed.split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList();
    
    if (words.isEmpty) {
      return 'U';
    }
    
    return words
        .map((word) => word.characters.first.toUpperCase())
        .join();
  }
  
  /// Generate color for initials avatar
  static int getInitialsColor(String seed) {
    final colors = [
      0xFF4F46E5, // Indigo
      0xFF8B5CF6, // Purple
      0xFF14B8A6, // Teal
      0xFF10B981, // Emerald
      0xFFF59E0B, // Amber
      0xFFEF4444, // Red
      0xFF3B82F6, // Blue
      0xFF8B5A2B, // Brown
      0xFF6B7280, // Gray
      0xFFEC4899, // Pink
    ];
    
    final index = seed.hashCode.abs() % colors.length;
    return colors[index];
  }
  
  /// Check if avatar URL is accessible (for offline fallback)
  static bool isAvatarAccessible() {
    // In a real implementation, this would check network connectivity
    // For now, we'll assume it's accessible if we have internet
    return true; // This should be replaced with actual network check
  }
  
  /// Get offline fallback avatar data
  static Map<String, dynamic> getOfflineFallback(String seed, String displayName) {
    return {
      'type': 'initials',
      'initials': getInitials(displayName),
      'color': getInitialsColor(seed),
      'seed': seed,
    };
  }
}