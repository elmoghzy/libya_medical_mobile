import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/app_localizations.dart';
import '../localization/locale_cubit.dart';
import '../theme/app_colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showNotification = true,
    this.showAvatar = true,
    this.showLanguageToggle = true,
    this.onNotificationTap,
    this.avatarUrl,
  });

  final String? title;
  final bool showBackButton;
  final bool showNotification;
  final bool showAvatar;
  final bool showLanguageToggle;
  final VoidCallback? onNotificationTap;
  final String? avatarUrl;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resolvedTitle = title ?? l10n.tr('appName');

    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            else if (showAvatar)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 20,
                      )
                    : null,
              ),
            const SizedBox(width: 12),
            Text(
              resolvedTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            if (showLanguageToggle)
              PopupMenuButton<String>(
                tooltip: l10n.tr('language'),
                initialValue: l10n.locale.languageCode,
                onSelected: (languageCode) {
                  context.read<LocaleCubit>().setLocale(Locale(languageCode));
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'ar',
                    child: _LanguageMenuItem(
                      label: 'العربية',
                      isSelected: l10n.locale.languageCode == 'ar',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'en',
                    child: _LanguageMenuItem(
                      label: 'English',
                      isSelected: l10n.locale.languageCode == 'en',
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.translate,
                  color: AppColors.textSecondary,
                ),
              ),
            if (showNotification)
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: onNotificationTap,
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 20),
        Icon(
          isSelected ? Icons.check : Icons.circle_outlined,
          size: 18,
          color: isSelected ? AppColors.primary : AppColors.outline,
        ),
      ],
    );
  }
}
