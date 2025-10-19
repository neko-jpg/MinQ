flutter_gemma 0.11.5 copy "flutter_gemma: ^0.11.5" to clipboard
Published 8 days ago • verified publishermobilepeople.dev
SDKFlutterPlatformAndroidiOSweb
224
Readme
Changelog
Example
Installing
Versions
Scores
# Flutter Gemma
The plugin supports not only Gemma, but also other models. Here's the full list of supported models: Gemma 2B & Gemma 7B, Gemma-2 2B, Gemma-3 1B, Gemma 3 270M, Gemma 3 Nano 2B, Gemma 3 Nano 4B, TinyLlama 1.1B, Hammer 2.1 0.5B, Llama 3.2 1B, Phi-2, Phi-3 , Phi-4, DeepSeek, Qwen2.5-1.5B-Instruct, Falcon-RW-1B, StableLM-3B.

*Note: Currently, the flutter_gemma plugin supports Gemma-3, Gemma 3 270M, Gemma 3 Nano (with multimodal vision support), TinyLlama, Hammer 2.1, Llama 3.2, Phi-4, DeepSeek and Qwen2.5.

Gemma is a family of lightweight, state-of-the art open models built from the same research and technology used to create the Gemini models

gemma_github_cover

Bring the power of Google's lightweight Gemma language models directly to your Flutter applications. With Flutter Gemma, you can seamlessly incorporate advanced AI capabilities into your iOS and Android apps, all without relying on external servers.

There is an example of using:

gemma_github_gif

Features 
Local Execution: Run Gemma models directly on user devices for enhanced privacy and offline functionality.
Platform Support: Compatible with iOS, Android, and Web platforms.
🖼️ Multimodal Support: Text + Image input with Gemma 3 Nano vision models
🛠️ Function Calling: Enable your models to call external functions and integrate with other services (supported by select models)
🧠 Thinking Mode: View the reasoning process of DeepSeek models with
🛑 Stop Generation: Cancel text generation mid-process on Android devices
⚙️ Backend Switching: Choose between CPU and GPU backends for each model individually in the example app
🔍 Advanced Model Filtering: Filter models by features (Multimodal, Function Calls, Thinking) with expandable UI
📊 Model Sorting: Sort models alphabetically, by size, or use default order in the example app
LoRA Support: Efficient fine-tuning and integration of LoRA (Low-Rank Adaptation) weights for tailored AI behavior.
📥 Enhanced Downloads: Smart retry logic and ETag handling for reliable model downloads from HuggingFace CDN
🔧 Download Reliability: Automatic resume/restart logic for interrupted downloads with exponential backoff
🔧 Model Replace Policy: Configurable model replacement system (keep/replace) with automatic model switching
📊 Text Embeddings: Generate vector embeddings from text using EmbeddingGemma and Gecko models
🔧 Unified Model Management: Single system for managing both inference and embedding models with automatic validation
Model File Types 
Flutter Gemma supports three types of model files:

.task files: MediaPipe-optimized format with built-in chat templates
.litertlm files: LiterTLM format optimized for web platform compatibility
.bin/.tflite files: Standard format requiring manual chat template formatting
The plugin automatically detects the file type and applies appropriate formatting.

Model Capabilities 
The example app offers a curated list of models, each suited for different tasks. Here's a breakdown of the models available and their capabilities:

Model Family	Best For	Function Calling	Thinking Mode	Vision	Languages	Size
Gemma 3 Nano	On-device multimodal chat and image analysis.	✅	❌	✅	Multilingual	3-6GB
DeepSeek R1	High-performance reasoning and code generation.	✅	✅	❌	Multilingual	1.7GB
Qwen 2.5	Strong multilingual chat and instruction following.	✅	❌	❌	Multilingual	1.6GB
Hammer 2.1	Lightweight action model for tool usage.	✅	❌	❌	Multilingual	0.5GB
Gemma 3 1B	Balanced and efficient text generation.	✅	❌	❌	Multilingual	0.5GB
Gemma 3 270M	Ideal for fine-tuning (LoRA) for specific tasks	❌	❌	❌	Multilingual	0.3GB
TinyLlama 1.1B	Extremely compact, general-purpose chat.	❌	❌	❌	English-focused	1.2GB
Llama 3.2 1B	Efficient instruction following	❌	❌	❌	Multilingual	1.1GB
Installation 
Add flutter_gemma to your pubspec.yaml:

dependencies:
  flutter_gemma: latest_version
Run flutter pub get to install.

Quick Start (Modern API) ⚡ 
Initialize Flutter Gemma 
Add to your main.dart:

import 'package:flutter_gemma/core/api/flutter_gemma.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: Initialize with HuggingFace token for gated models
  FlutterGemma.initialize(
    huggingFaceToken: const String.fromEnvironment('HUGGINGFACE_TOKEN'),
    maxDownloadRetries: 10,
  );

  runApp(MyApp());
}
Install Model 
// From network (public model)
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
  fileType: ModelFileType.task,  // Optional: defaults to .task
)
  .fromNetwork('https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma-3-270m-it-int4.task')
  .withProgress((progress) => print('Download: $progress%'))
  .install();

// From Flutter asset
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
  fileType: ModelFileType.bin,  // Optional: specify file type
)
  .fromAsset('models/gemma-2b-it.bin')
  .install();

// From bundled native resource
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
  // fileType defaults to ModelFileType.task
)
  .fromBundled('gemma-2b-it.bin')
  .install();

// From external file (mobile only)
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromFile('/path/to/model.task')
  .install();
Parameters:

modelType (required): Type of model (e.g., ModelType.gemmaIt, ModelType.deepSeek)
fileType (optional): File format - defaults to ModelFileType.task
ModelFileType.task - MediaPipe task bundles (recommended)
ModelFileType.bin - Binary model files
ModelFileType.tflite - TensorFlow Lite models
Create Model and Chat 
// Create model with runtime configuration
final inferenceModel = await FlutterGemma.getActiveModel(
  maxTokens: 2048,
  preferredBackend: PreferredBackend.gpu,
);

// Create chat
final chat = await inferenceModel.createChat();
await chat.addQueryChunk(Message.text(text: 'Hello!', isUser: true));
final response = await chat.generateChatResponse();
Next Steps:

📖 Authentication Setup - Configure tokens for gated models
📦 Model Sources - Learn about different model sources
🌐 Platform Support - Web vs Mobile differences
🔄 Migration Guide - Upgrade from Legacy API
📚 Legacy API Documentation - For backwards compatibility
HuggingFace Authentication 🔐 
Many models require authentication to download from HuggingFace. Never commit tokens to version control.

✅ Recommended: config.json Pattern 
This is the most secure way to handle tokens in development and production.

Step 1: Create config template file config.json.example:

{
  "HUGGINGFACE_TOKEN": ""
}
Step 2: Copy and add your token:

cp config.json.example config.json
# Edit config.json and add your token from https://huggingface.co/settings/tokens
Step 3: Add to .gitignore:

# Never commit tokens!
config.json
Step 4: Run with config:

flutter run --dart-define-from-file=config.json
Step 5: Access in code:

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Read from environment (populated by --dart-define-from-file)
  const token = String.fromEnvironment('HUGGINGFACE_TOKEN');

  // Initialize with token (optional if all models are public)
  FlutterGemma.initialize(
    huggingFaceToken: token.isNotEmpty ? token : null,
  );

  runApp(MyApp());
}
Alternative: Environment Variables 
export HUGGINGFACE_TOKEN=hf_your_token_here
flutter run --dart-define=HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN
Alternative: Per-Download Token 
// Pass token directly for specific downloads
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromNetwork(
    'https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-3n-E2B-it-int4.task',
    token: 'hf_your_token_here',  // ⚠️ Not recommended - use config.json
  )
  .install();
Which Models Require Authentication? 
Common gated models:

✅ Gemma 3 Nano (E2B, E4B) - google/ repos are gated
✅ Gemma 3 1B - litert-community/ requires access
✅ Gemma 3 270M - litert-community/ requires access
✅ EmbeddingGemma - litert-community/ requires access
Public models (no auth needed):

❌ DeepSeek, Qwen2.5, TinyLlama - Public repos
Get your token: https://huggingface.co/settings/tokens

Grant access to gated repos: Visit model page → "Request Access" button

Model Sources 📦 
Flutter Gemma supports multiple model sources with different capabilities:

Source Type	Platform	Progress	Resume	Authentication	Use Case
NetworkSource	All	✅ Detailed	✅ Yes	✅ Supported	HuggingFace, CDNs, private servers
AssetSource	All	⚠️ End only	❌ No	❌ N/A	Models bundled in app assets
BundledSource	All	⚠️ End only	❌ No	❌ N/A	Native platform resources
FileSource	Mobile only	⚠️ End only	❌ No	❌ N/A	User-selected files (file picker)
NetworkSource - Internet Downloads 
Downloads models from HTTP/HTTPS URLs with full progress tracking and authentication.

Features:

✅ Progress tracking (0-100%)
✅ Resume after interruption (ETag support)
✅ HuggingFace authentication
✅ Smart retry logic with exponential backoff
✅ Background downloads on mobile
Example:

// Public model
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromNetwork('https://example.com/model.bin')
  .withProgress((progress) => print('$progress%'))
  .install();

// Private model with authentication
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromNetwork(
    'https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/model.task',
    token: 'hf_...',  // Or use FlutterGemma.initialize(huggingFaceToken: ...)
  )
  .withProgress((progress) => setState(() => _progress = progress))
  .install();
AssetSource - Flutter Assets 
Copies models from Flutter assets (declared in pubspec.yaml).

Features:

✅ No network required
✅ Fast installation (local copy)
⚠️ Increases app size significantly
✅ Works offline
Example:

// 1. Add to pubspec.yaml
// assets:
//   - models/gemma-2b-it.bin

// 2. Install from asset
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromAsset('models/gemma-2b-it.bin')
  .install();
BundledSource - Native Resources 
Production-Ready Offline Models: Include small models directly in your app bundle for instant availability without downloads.

Use Cases:

✅ Offline-first applications (works without internet from first launch)
✅ Small models (Gemma 3 270M ~300MB)
✅ Core features requiring guaranteed availability
⚠️ Not for large models (increases app size significantly)
Platform Setup:

Android (android/app/src/main/assets/models/)

# Place your model file
android/app/src/main/assets/models/gemma-3-270m-it.task
iOS (Add to Xcode project)

Drag model file into Xcode project
Check "Copy items if needed"
Add to target membership
Web (Standard Flutter assets)

# pubspec.yaml
flutter:
  assets:
    - assets/models/gemma-3-270m-it.task
Features:

✅ Zero network dependency
✅ No installation delay
✅ No storage permission needed
✅ Direct path usage (no file copying)
Example:

await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromBundled('gemma-3-270m-it.task')
  .install();
App Size Impact:

Gemma 3 270M: ~300MB
TinyLlama 1.1B: ~1.2GB
Consider hosting large models for download instead
FileSource - External Files (Mobile Only) 
References external files (e.g., user-selected via file picker).

Features:

✅ No copying (references original file)
✅ Protected from cleanup
❌ Web not supported (no local file system)
Example:

// Mobile only - after user selects file with file_picker
final path = '/data/user/0/com.app/files/model.task';
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromFile(path)
  .install();
Important: On web, FileSource only works with URLs or asset paths, not local file system paths.

Setup 
Download Model and optionally LoRA Weights: Obtain a pre-trained Gemma model (recommended: 2b or 2b-it) from Kaggle
For multimodal support, download Gemma 3 Nano models or Gemma 3 Nano in LitertLM format that support vision input
Optionally, fine-tune a model for your specific use case
If you have LoRA weights, you can use them to customize the model's behavior without retraining the entire model.
There is an article that described all approaches
Platform specific setup:
iOS

Set minimum iOS version in Podfile:
platform :ios, '16.0'  # Required for MediaPipe GenAI
Enable file sharing in Info.plist:
<key>UIFileSharingEnabled</key>
<true/>
Add network access description in Info.plist (for development):
<key>NSLocalNetworkUsageDescription</key>
<string>This app requires local network access for model inference services.</string>
Enable performance optimization in Info.plist (optional):
<key>CADisableMinimumFrameDurationOnPhone</key>
<true/>
Add memory entitlements in Runner.entitlements (for large models):
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.kernel.extended-virtual-addressing</key>
	<true/>
	<key>com.apple.developer.kernel.increased-memory-limit</key>
	<true/>
	<key>com.apple.developer.kernel.increased-debugging-memory-limit</key>
	<true/>
</dict>
</plist>
Change the linking type of pods to static in Podfile:
use_frameworks! :linkage => :static
Android

If you want to use a GPU to work with the model, you need to add OpenGL support in the manifest.xml. If you plan to use only the CPU, you can skip this step.
Add to 'AndroidManifest.xml' above tag </application>

 <uses-native-library
     android:name="libOpenCL.so"
     android:required="false"/>
 <uses-native-library android:name="libOpenCL-car.so" android:required="false"/>
 <uses-native-library android:name="libOpenCL-pixel.so" android:required="false"/>
For release builds with ProGuard/R8 enabled, the plugin automatically includes necessary ProGuard rules. If you encounter issues with UnsatisfiedLinkError or missing classes in release builds, ensure your proguard-rules.pro includes:
# MediaPipe
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Protocol Buffers
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# RAG functionality
-keep class com.google.ai.edge.localagents.** { *; }
-dontwarn com.google.ai.edge.localagents.**
Web

Authentication: For gated models (Gemma 3 Nano, Gemma 3 1B/270M), you need to configure HuggingFace token. See HuggingFace Authentication section.

Web currently works only GPU backend models, CPU backend models are not supported by MediaPipe yet

Multimodal support (images) is fully supported on web platform

Model formats: Use .litertlm files for optimal web compatibility (recommended for multimodal models)

Add dependencies to index.html file in web folder

  <script type="module">
  import { FilesetResolver, LlmInference } from 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-genai@latest';
  window.FilesetResolver = FilesetResolver;
  window.LlmInference = LlmInference;
  </script>
Migration from Legacy to Modern API 🔄 
If you're upgrading from the Legacy API, here are common migration patterns:

Installing Models 
Legacy API	Modern API
// Network download
final spec = MobileModelManager.createInferenceSpec(
  name: 'model.bin',
  modelUrl: 'https://example.com/model.bin',
);

await FlutterGemmaPlugin.instance.modelManager
  .downloadModelWithProgress(spec, token: token)
  .listen((progress) {
    print('${progress.overallProgress}%');
  });
// Network download
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromNetwork(
    'https://example.com/model.bin',
    token: token,
  )
  .withProgress((progress) {
    print('$progress%');
  })
  .install();
// From assets
await modelManager.installModelFromAssetWithProgress(
  'model.bin',
  loraPath: 'lora.bin',
).listen((progress) {
  print('$progress%');
});
// From assets
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromAsset('model.bin')
  .withProgress((progress) {
    print('$progress%');
  })
  .install();

// LoRA weights can be installed with the model
await FlutterGemma.installModel(
  modelType: ModelType.gemmaIt,
)
  .fromAsset('model.bin')
  .withLoraFromAsset('lora.bin')
  .install();
Checking Model Installation 
Legacy API	Modern API
final spec = MobileModelManager.createInferenceSpec(
  name: 'model.bin',
  modelUrl: url,
);

final isInstalled = await FlutterGemmaPlugin
  .instance.modelManager
  .isModelInstalled(spec);
final isInstalled = await FlutterGemma
  .isModelInstalled('model.bin');
Key Migration Notes 
✅ Simpler imports: Use package:flutter_gemma/core/api/flutter_gemma.dart
✅ Builder pattern: Chain methods for cleaner code
✅ Callback-based progress: Simpler than streams for most cases
✅ Type-safe sources: Compile-time validation of source types
⚠️ Breaking change: Progress values are now int (0-100) instead of DownloadProgress object
⚠️ Separate files: Model and LoRA weights installed independently
Model Creation and Inference 
Modern API (Recommended):

// Create model with runtime configuration
final inferenceModel = await FlutterGemma.getActiveModel(
  maxTokens: 2048,
  preferredBackend: PreferredBackend.gpu,
);

final chat = await inferenceModel.createChat();
await chat.addQueryChunk(Message.text(text: 'Hello!', isUser: true));
final response = await chat.generateChatResponse();
Legacy API (Still supported):

// Works with both Legacy and Modern installation methods
final inferenceModel = await FlutterGemmaPlugin.instance.createModel(
  modelType: ModelType.gemmaIt,
  preferredBackend: PreferredBackend.gpu,
  maxTokens: 2048,
);

final chat = await inferenceModel.createChat();
await chat.addQueryChunk(Message.text(text: 'Hello!', isUser: true));
final response = await chat.generateChatResponse();
Usage (Legacy API) 
⚠️ Click to expand Legacy API documentation (for backwards compatibility)
🖼️ Message Types 
The plugin now supports different types of messages:

// Text only
final textMessage = Message.text(text: "Hello!", isUser: true);

// Text + Image
final multimodalMessage = Message.withImage(
  text: "What's in this image?",
  imageBytes: imageBytes,
  isUser: true,
);

// Image only
final imageMessage = Message.imageOnly(imageBytes: imageBytes, isUser: true);

// Tool response (for function calling)
final toolMessage = Message.toolResponse(
  toolName: 'change_background_color',
  response: {'status': 'success', 'color': 'blue'},
);

// System information message
final systemMessage = Message.systemInfo(text: "Function completed successfully");

// Thinking content (for DeepSeek models)
final thinkingMessage = Message.thinking(text: "Let me analyze this problem...");

// Check if message contains image
if (message.hasImage) {
  print('This message contains an image');
}

// Create a copy of message
final copiedMessage = message.copyWith(text: "Updated text");
💬 Response Types 
The model can return different types of responses depending on capabilities:

// Handle different response types
chat.generateChatResponseAsync().listen((response) {
  if (response is TextResponse) {
    // Regular text token from the model
    print('Text token: ${response.token}');
    // Use response.token to update your UI incrementally
    
  } else if (response is FunctionCallResponse) {
    // Model wants to call a function (Gemma 3 Nano, DeepSeek, Qwen2.5)
    print('Function: ${response.name}');
    print('Arguments: ${response.args}');
    
    // Execute the function and send response back
    _handleFunctionCall(response);
  } else if (response is ThinkingResponse) {
    // Model's reasoning process (DeepSeek models only)
    print('Thinking: ${response.content}');
    
    // Show thinking process in UI
    _showThinkingBubble(response.content);
  }
});
Response Types:

TextResponse: Contains a text token (response.token) for regular model output
FunctionCallResponse: Contains function name (response.name) and arguments (response.args) when the model wants to call a function
ThinkingResponse: Contains the model's reasoning process (response.content) for DeepSeek models with thinking mode enabled
🎯 Supported Models 
Text-Only Models 
Gemma 2B & Gemma 7B
Gemma-2 2B
Gemma-3 1B
Gemma 3 270M - Ultra-compact model
TinyLlama 1.1B - Lightweight chat model
Hammer 2.1 0.5B - Action model with function calling
Llama 3.2 1B - Instruction-tuned model
Phi-4
DeepSeek
Phi-2, Phi-3, Falcon-RW-1B, StableLM-3B
🖼️ Multimodal Models (Vision + Text) 
Gemma 3 Nano E2B - 2B parameters with vision support
Gemma 3 Nano E4B - 4B parameters with vision support
Gemma 3 Nano E2B LitertLM - 2B parameters with vision support
Gemma 3 Nano E4B LitertLM - 4B parameters with vision support
📊 Text Embedding Models 
EmbeddingGemma 256 - 300M parameters, 256 dimensions (179MB)
EmbeddingGemma 512 - 300M parameters, 512 dimensions (179MB)
EmbeddingGemma 1024 - 300M parameters, 1024 dimensions (183MB)
EmbeddingGemma 2048 - 300M parameters, 2048 dimensions (196MB)
Gecko 256 - 110M parameters, 256 dimensions (114MB)
🛠️ Model Function Calling Support 
Function calling is currently supported by the following models:

✅ Models with Function Calling Support 
Gemma 3 Nano models (E2B, E4B) - Full function calling support
Hammer 2.1 0.5B - Action model with strong function calling capabilities
DeepSeek models - Function calling + thinking mode support
Qwen models - Full function calling support
❌ Models WITHOUT Function Calling Support 
Gemma 3 1B models - Text generation only
Gemma 3 270M - Text generation only
TinyLlama 1.1B - Text generation only
Llama 3.2 1B - Text generation only
Phi models - Text generation only
Important Notes:

When using unsupported models with tools, the plugin will log a warning and ignore the tools
Models will work normally for text generation even if function calling is not supported
Check the supportsFunctionCalls property in your model configuration
Platform Support Details 🌐 
Feature Comparison 
Feature	Android	iOS	Web	Notes
Text Generation	✅ Full	✅ Full	✅ Full	All models supported
Image Input (Multimodal)	✅ Full	✅ Full	✅ Full	Gemma 3 Nano models
Function Calling	✅ Full	✅ Full	✅ Full	Select models only
Thinking Mode	✅ Full	✅ Full	✅ Full	DeepSeek models
GPU Acceleration	✅ Full	✅ Full	✅ Full	Recommended
CPU Backend	✅ Full	✅ Full	❌ Not supported	MediaPipe limitation
Streaming Responses	✅ Full	✅ Full	✅ Full	Real-time generation
LoRA Support	✅ Full	✅ Full	✅ Full	Fine-tuned weights
Text Embeddings	✅ Full	✅ Full	✅ Full	EmbeddingGemma, Gecko
File Downloads	✅ Background	✅ Background	✅ In-memory	Platform-specific
Asset Loading	✅ Full	✅ Full	✅ Full	All source types
Bundled Resources	✅ Full	✅ Full	✅ Full	Native bundles
External Files (FileSource)	✅ Full	✅ Full	❌ Not supported	No local FS on web
Web Platform Specifics 
Authentication
Required for gated models: Gemma 3 Nano, Gemma 3 1B/270M, EmbeddingGemma
Configuration: Use FlutterGemma.initialize(huggingFaceToken: '...') or pass token per-download
Storage: Tokens stored in browser memory (not localStorage)
File Handling
Downloads: Creates blob URLs in browser memory (no actual files)
Storage: IndexedDB via WebFileSystemService
FileSource: Only works with HTTP/HTTPS URLs or assets/ paths
Local file paths: ❌ Not supported (browser security restriction)
Backend Support
GPU only: Web platform requires GPU backend (MediaPipe limitation)
CPU models: ❌ Will fail to initialize on web
CORS Configuration
Required for custom servers: Enable CORS headers on your model hosting server
Firebase Storage: See CORS configuration docs
HuggingFace: CORS already configured correctly
Memory Limitations
Large models: May hit browser memory limits (2GB typical)
Recommended: Use smaller models (1B-2B) for web platform
Best models for web:
Gemma 3 270M (300MB)
Gemma 3 1B (500MB-1GB)
Gemma 3 Nano E2B (3GB) - requires 6GB+ device RAM
Mobile Platform Specifics 
Android
GPU Support: Requires OpenGL libraries in AndroidManifest.xml
ProGuard: Automatic rules included for release builds
Storage: Local file system in app documents directory
iOS
Minimum version: iOS 16.0 required for MediaPipe GenAI
Memory entitlements: Required for large models (see Setup section)
Linking: Static linking required (use_frameworks! :linkage => :static)
Storage: Local file system in app documents directory
The full and complete example you can find in example folder

Important Considerations 
Model Size: Larger models (such as 7b and 7b-it) might be too resource-intensive for on-device inference.
Function Calling Support: Gemma 3 Nano and DeepSeek models support function calling. Other models will ignore tools and show a warning.
Thinking Mode: Only DeepSeek models support thinking mode. Enable with isThinking: true and modelType: ModelType.deepSeek.
Multimodal Models: Gemma 3 Nano models with vision support require more memory and are recommended for devices with 8GB+ RAM.
iOS Memory Requirements: Large models require memory entitlements in Runner.entitlements and minimum iOS 16.0.
LoRA Weights: They provide efficient customization without the need for full model retraining.
Development vs. Production: For production apps, do not embed the model or LoRA weights within your assets. Instead, load them once and store them securely on the device or via a network drive.
Web Models: Currently, Web support is available only for GPU backend models. Multimodal support is fully implemented.
Image Formats: The plugin automatically handles common image formats (JPEG, PNG, etc.) when using Message.withImage().
🛟 Troubleshooting 
Multimodal Issues:

Ensure you're using a multimodal model (Gemma 3 Nano E2B/E4B)
Set supportImage: true when creating model and chat
Check device memory - multimodal models require more RAM
Performance:

Use GPU backend for better performance with multimodal models
Consider using CPU backend for text-only models on lower-end devices
Memory Issues:

iOS: Ensure Runner.entitlements contains memory entitlements (see iOS setup)
iOS: Set minimum platform to iOS 16.0 in Podfile
Reduce maxTokens if experiencing memory issues
Use smaller models (1B-2B parameters) for devices with <6GB RAM
Close sessions and models when not needed
Monitor token usage with sizeInTokens()
iOS Build Issues:

Ensure minimum iOS version is set to 16.0 in Podfile
Use static linking: use_frameworks! :linkage => :static
Clean and reinstall pods: cd ios && pod install --repo-update
Check that all required entitlements are in Runner.entitlements
Advanced Usage 
ModelThinkingFilter (Advanced) 
For advanced users who need to manually process model responses, the ModelThinkingFilter class provides utilities for cleaning model outputs:

import 'package:flutter_gemma/core/extensions.dart';

// Clean response based on model type
String cleanedResponse = ModelThinkingFilter.cleanResponse(
  rawResponse, 
  ModelType.deepSeek
);

// The filter automatically removes model-specific tokens like:
// - <end_of_turn> tags (Gemma models)
// - Special DeepSeek tokens
// - Extra whitespace and formatting
This is automatically handled by the chat API, but can be useful for custom inference implementations.

🚀 What's New 
✅ 📊 Text Embeddings - Generate vector embeddings with EmbeddingGemma and Gecko models for semantic search applications ✅ 🔧 Unified Model Management - Single system for managing both inference and embedding models with automatic validation ✅ 🛠️ Advanced Function Calling - Enable your models to call external functions and integrate with other services (Gemma 3 Nano, Hammer 2.1, DeepSeek, and Qwen2.5 models) ✅ 🧠 Thinking Mode - View the reasoning process of DeepSeek models with interactive thinking bubbles ✅ 💬 Enhanced Response Types - New TextResponse, FunctionCallResponse, and ThinkingResponse types for better handling ✅ 🖼️ Multimodal Support - Text + Image input with Gemma 3 Nano models ✅ 📨 Enhanced Message API - Support for different message types including tool responses ✅ ⚙️ Backend Switching - Choose between CPU and GPU backends individually for each model in the example app ✅ 🔍 Advanced Model Filtering - Filter models by features (Multimodal, Function Calls, Thinking) with expandable UI ✅ 📊 Model Sorting - Sort models alphabetically, by size, or use default order ✅ 🚀 New Models - Added Gemma 3 270M, TinyLlama 1.1B, Hammer 2.1 0.5B, and Llama 3.2 1B support ✅ 🌐 Cross-Platform - Works on Android, iOS, and Web (including multimodal) ✅ 💾 Memory Optimization - Better resource management for multimodal models

Coming Soon:

On-Device RAG Pipelines
Desktop Support (macOS, Windows, Linux)
Audio & Video Input
Audio Output (Text-to-Speech)