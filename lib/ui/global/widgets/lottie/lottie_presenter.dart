import 'package:lottie/lottie.dart';

class LottiePresenter {
  final String assetPath;

  const LottiePresenter({required this.assetPath});

  LottieDecoder? get decoder => _isDotLottie ? _dotLottieDecoder : null;

  bool get _isDotLottie => assetPath.toLowerCase().endsWith('.lottie');

  Future<LottieComposition?> _dotLottieDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(
      bytes,
      filePicker: (files) {
        for (final file in files) {
          final String fileName = file.name.toLowerCase();
          if (fileName.startsWith('animations/') &&
              fileName.endsWith('.json')) {
            return file;
          }
        }

        for (final file in files) {
          final String fileName = file.name.toLowerCase();
          if (fileName.startsWith('lotties/') &&
              fileName.endsWith('.json')) {
            return file;
          }
        }

        for (final file in files) {
          final String fileName = file.name.toLowerCase();
          if (fileName.endsWith('.json') &&
              fileName != 'manifest.json' &&
              !fileName.startsWith('states/')) {
            return file;
          }
        }

        return null;
      },
    );
  }
}
