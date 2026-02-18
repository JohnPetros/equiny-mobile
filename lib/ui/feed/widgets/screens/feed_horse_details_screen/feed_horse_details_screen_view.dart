import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_horse_details_screen/bottom_action_button/index.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_horse_details_screen/feed_horse_details_screen_presenter.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_horse_details_screen/image_dots/index.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_horse_details_screen/info_tile/index.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_horse_details_screen/top_icon_button/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FeedHorseDetailsScreenView extends StatefulWidget {
  final FeedHorseDto horse;
  final FileStorageDriver? fileStorageDriver;

  const FeedHorseDetailsScreenView({
    required this.horse,
    this.fileStorageDriver,
    super.key,
  });

  @override
  State<FeedHorseDetailsScreenView> createState() =>
      _FeedHorseDetailsScreenViewState();
}

class _FeedHorseDetailsScreenViewState
    extends State<FeedHorseDetailsScreenView> {
  late final FeedHorseDetailsScreenPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = FeedHorseDetailsScreenPresenter(
      widget.horse,
      fileStorageDriver: widget.fileStorageDriver,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.5;

    return Material(
      color: AppThemeColors.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Watch((BuildContext context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: imageHeight,
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: _presenter.currentImageUrl.value == null
                                ? Container(
                                    color: AppThemeColors.backgroundAlt,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  )
                                : Image.network(
                                    _presenter.currentImageUrl.value!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            color: AppThemeColors.backgroundAlt,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                  ),
                          ),
                          Positioned.fill(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: _presenter.previousImage,
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: _presenter.nextImage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 16,
                            child: TopIconButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: ImageDots(
                              count: widget.horse.imageUrls.isEmpty
                                  ? 1
                                  : widget.horse.imageUrls.length,
                              currentIndex: _presenter.currentImageIndex.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                        decoration: const BoxDecoration(
                          color: AppThemeColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                width: 56,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              '${widget.horse.name}, ${_presenter.horseAgeLabel.value}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                height: 0.98,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Color(0xFF89A4C4),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Proprietario Verificado',
                                  style: TextStyle(
                                    color: const Color(0xFFC6D5E6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.62,
                              children: <Widget>[
                                InfoTile(
                                  icon: Icons.female,
                                  label: 'SEXO',
                                  value: _presenter.sexLabel.value,
                                ),
                                InfoTile(
                                  icon: Icons.pets,
                                  label: 'RACA',
                                  value: _presenter.breedLabel.value,
                                ),
                                InfoTile(
                                  icon: Icons.height,
                                  label: 'ALTURA',
                                  value: _presenter.heightLabel.value,
                                ),
                                InfoTile(
                                  icon: Icons.location_on,
                                  label: 'LOCALIZACAO',
                                  value: _presenter.locationLabel.value,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Sobre ${widget.horse.name}',
                              style: TextStyle(
                                fontSize: 24,
                                color: const Color(0xFF5D6878),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.horse.description.trim().isEmpty
                                  ? '${widget.horse.name} e uma egua promissora pronta para bons encontros no Equiny.'
                                  : widget.horse.description,
                              style: TextStyle(
                                fontSize: 15,
                                color: const Color(0xFFD4DBE5),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  BottomActionButton(
                    icon: Icons.close,
                    iconColor: const Color(0xFFFF4E78),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Column(
                    children: <Widget>[
                      BottomActionButton(
                        icon: Icons.keyboard_arrow_up,
                        iconColor: Color(0xFF8CA2B6),
                        size: 54,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'DETALHES',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0x99FFFFFF),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  const BottomActionButton(
                    icon: Icons.favorite,
                    iconColor: Color(0xFF1EE5A8),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
