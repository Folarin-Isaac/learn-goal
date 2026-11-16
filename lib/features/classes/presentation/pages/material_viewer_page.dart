import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:pdfrx/pdfrx.dart';

class MaterialViewerPage extends StatelessWidget {
  const new({required this.material, super.key});

  final ClassMaterial material;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      material.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: context.colors.surfaceContainerHighest,
                child: PdfViewer.uri(
                  Uri.parse(material.url),
                  params: PdfViewerParams(
                    textSelectionParams: const PdfTextSelectionParams(
                      enabled: false,
                    ),
                    loadingBannerBuilder: (context, downloaded, total) =>
                        Center(
                          child: CircularProgressIndicator(
                            value: total == null || total == 0
                                ? null
                                : downloaded / total,
                          ),
                        ),
                    errorBannerBuilder: (context, error, stackTrace, ref) =>
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.s24),
                            child: Text(
                              context.l10n.materialViewerLoadFailed,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
