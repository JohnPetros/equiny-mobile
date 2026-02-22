import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/feed_horse_card/feed_horse_card_gallery/index.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/feed_horse_card/feed_horse_card_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FeedHorseCardView extends StatefulWidget {
  final FeedHorseDto horse;
  final FileStorageDriver fileStorageDriver;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onDetails;

  const FeedHorseCardView({
    required this.horse,
    required this.fileStorageDriver,
    required this.onLike,
    required this.onDislike,
    required this.onDetails,
    super.key,
  });

  @override
  State<FeedHorseCardView> createState() => _FeedHorseCardViewState();
}

class _FeedHorseCardViewState extends State<FeedHorseCardView> {
  late FeedHorseCardPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = FeedHorseCardPresenter(widget.horse, widget.fileStorageDriver);
  }

  @override
  void didUpdateWidget(covariant FeedHorseCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.horse != widget.horse ||
        oldWidget.fileStorageDriver != widget.fileStorageDriver) {
      _presenter = FeedHorseCardPresenter(
        widget.horse,
        widget.fileStorageDriver,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((BuildContext context) {
      final int age = _horseAge();
      final String ageLabel = age <= 0 ? '--' : age.toString();

      return Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeColors.surface,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(36),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: FeedHorseCardGallery(
                      imageUrl: _presenter.currentImageUrl.value,
                      imageUrls: _horseImageUrls(),
                      imageCount: widget.horse.imageUrls.length,
                      currentImageIndex: _presenter.currentImageIndex.value,
                      onNextImage: _presenter.nextImage,
                      onPreviousImage: _presenter.previousImage,
                    ),
                  ),
                  Positioned.fill(child: IgnorePointer()),
                  Positioned(
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppThemeColors.surface.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${widget.horse.name}, $ageLabel',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                height: 0.95,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${_sexLabel(widget.horse.sex)} • ${_locationLabel()}',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withValues(alpha: 0.86),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: 350,
                              child: Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: <Widget>[
                                  _StatPill(
                                    icon: Icons.event_outlined,
                                    label: '$ageLabel anos',
                                  ),
                                  _StatPill(
                                    icon: Icons.location_on_outlined,
                                    label: _locationLabel(),
                                  ),
                                  _StatPill(
                                    icon: Icons.straighten,
                                    label:
                                        '${widget.horse.height.toStringAsFixed(2)}m',
                                  ),
                                  _StatPill(
                                    icon: Icons.pets_outlined,
                                    label: widget.horse.breed,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _ActionCircleButton(
                icon: Icons.close,
                iconColor: const Color(0xFFFF4E78),
                onTap: widget.onDislike,
              ),
              Column(
                children: <Widget>[
                  _ActionCircleButton(
                    icon: Icons.keyboard_arrow_up,
                    iconColor: const Color(0xFF8CA2B6),
                    onTap: widget.onDetails,
                    size: 52,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'DETALHES',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              _ActionCircleButton(
                icon: Icons.favorite,
                iconColor: const Color(0xFF1EE5A8),
                onTap: widget.onLike,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      );
    });
  }

  int _horseAge() {
    final int year = widget.horse.birthYear;
    if (year <= 0) {
      return 0;
    }

    final DateTime now = DateTime.now();
    final int month = widget.horse.birthMonth.clamp(1, 12);
    int age = now.year - year;

    if (now.month < month) {
      age -= 1;
    }

    return age < 0 ? 0 : age;
  }

  String _locationLabel() {
    return '${widget.horse.location.city}, ${widget.horse.location.state}';
  }

  String _sexLabel(String sex) {
    final String normalized = sex.trim().toLowerCase();
    if (normalized == 'female' || normalized == 'femea') {
      return 'Égua';
    }
    if (normalized == 'male' || normalized == 'macho') {
      return 'Garanhão';
    }
    return sex;
  }

  List<String> _horseImageUrls() {
    return widget.horse.imageUrls
        .map(_presenter.getFileUrl)
        .where((String url) => url.trim().isNotEmpty)
        .toList(growable: false);
  }
}

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final double size;

  const _ActionCircleButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF273247)),
          color: const Color(0xFF0B1018).withValues(alpha: 0.88),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
