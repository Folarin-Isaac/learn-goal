import 'dart:io';

import 'package:lengoal/core/core.dart';

class ProfileAvatar extends StatelessWidget {
  const new({
    super.key,
    this.localPath,
    this.imageUrl,
    this.size = 100,
    this.onEdit,
    this.isBusy = false,
  });

  final String? localPath;
  final String? imageUrl;
  final double size;
  final VoidCallback? onEdit;
  final bool isBusy;

  ImageProvider? get _provider {
    if (localPath != null && localPath!.isNotEmpty) {
      return FileImage(File(localPath!));
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipOval(
            child: provider == null
                ? Assets.images.profileAvatarIllustration.image(
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : Image(
                    image: provider,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Assets
                        .images
                        .profileAvatarIllustration
                        .image(width: size, height: size, fit: BoxFit.cover),
                  ),
          ),
          if (isBusy)
            Positioned.fill(
              child: ClipOval(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (onEdit != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Pressable(
                child: GestureDetector(
                  onTap: isBusy ? null : onEdit,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Assets.icons.editIconBlue.svg(width: 16, height: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
