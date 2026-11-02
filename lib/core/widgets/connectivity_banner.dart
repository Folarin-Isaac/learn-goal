import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/motion/app_motion.dart';
import 'package:lengoal/core/network/connectivity_cubit.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/utils/extensions/context_extensions.dart';
import 'package:lengoal/l10n/l10n.dart';

class ConnectivityBanner extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        final visible =
            status == ConnectivityStatus.offline ||
            status == ConnectivityStatus.restored;
        return Column(
          children: [
            AnimatedSize(
              duration: AppMotion.reduced(context)
                  ? Duration.zero
                  : AppMotion.base,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: visible
                  ? _Bar(isOffline: status == ConnectivityStatus.offline)
                  : const SizedBox(width: double.infinity),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: visible,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const new({required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final color = isOffline ? const Color(0xFFB42318) : const Color(0xFF0E8C43);
    final label = isOffline
        ? context.l10n.connectivityOffline
        : context.l10n.connectivityBackOnline;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: color,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s16,
            MediaQuery.paddingOf(context).top + AppSpacing.s4,
            AppSpacing.s16,
            6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
