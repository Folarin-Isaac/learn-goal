import 'package:lengoal/core/core.dart';

class ClassDetailsTabScroll extends StatelessWidget {
  const new({required this.storageKey, required this.slivers, super.key});

  factory empty({required String storageKey, required String message}) =>
      ClassDetailsTabScroll(
        storageKey: storageKey,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: _EmptyMessage(message: message)),
          ),
        ],
      );

  final String storageKey;
  final List<Widget> slivers;

  static const EdgeInsets padding = EdgeInsets.all(AppSpacing.s24);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey<String>(storageKey),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        ...slivers,
      ],
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const new({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ClassDetailsTabScroll.padding,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium,
      ),
    );
  }
}
