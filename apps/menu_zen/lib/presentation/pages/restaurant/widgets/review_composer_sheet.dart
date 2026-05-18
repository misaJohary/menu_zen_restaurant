import 'package:design_system/design_system.dart';
import 'package:domain/entities/review_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/dependencies_injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../bloc/customer_review/customer_review_cubit.dart';

/// Outcome surfaced to the caller via `Navigator.pop` so the host screen can
/// reload its data without having to read the cubit's state.
class ReviewComposerResult {
  final ReviewEntity? saved;
  final int? deletedId;

  const ReviewComposerResult.saved(this.saved) : deletedId = null;
  const ReviewComposerResult.deleted(this.deletedId) : saved = null;
}

class ReviewComposerSheet extends StatelessWidget {
  final int restaurantId;
  final String restaurantName;
  final ReviewEntity? existing;

  const ReviewComposerSheet({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CustomerReviewCubit>(),
      child: _ReviewComposerView(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        existing: existing,
      ),
    );
  }
}

class _ReviewComposerView extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;
  final ReviewEntity? existing;

  const _ReviewComposerView({
    required this.restaurantId,
    required this.restaurantName,
    this.existing,
  });

  @override
  State<_ReviewComposerView> createState() => _ReviewComposerViewState();
}

class _ReviewComposerViewState extends State<_ReviewComposerView> {
  late int _rating;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existing?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  void _submit() {
    final cubit = context.read<CustomerReviewCubit>();
    final raw = _commentController.text.trim();
    final comment = raw.isEmpty ? null : raw;
    if (_isEditing) {
      cubit.update(
        reviewId: widget.existing!.id,
        rating: _rating,
        comment: comment,
      );
    } else {
      cubit.submit(
        restaurantId: widget.restaurantId,
        rating: _rating,
        comment: comment,
      );
    }
  }

  Future<void> _confirmDelete() async {
    final review = widget.existing;
    if (review == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reviewDeleteDialogTitle),
        content: Text(l10n.reviewDeleteDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonKeep),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    context.read<CustomerReviewCubit>().delete(review.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<CustomerReviewCubit, CustomerReviewState>(
      listener: (context, state) {
        if (state is CustomerReviewSubmitted) {
          Navigator.of(context).pop(ReviewComposerResult.saved(state.review));
        } else if (state is CustomerReviewDeleted) {
          Navigator.of(
            context,
          ).pop(ReviewComposerResult.deleted(state.reviewId));
        } else if (state is CustomerReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isBusy = state is CustomerReviewSubmitting;
        final canSubmit = _rating >= 1 && !isBusy;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.xl),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s,
                      ),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.m,
                          AppSpacing.s,
                          AppSpacing.m,
                          AppSpacing.m,
                        ),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isEditing
                                          ? l10n.reviewComposerEditTitle
                                          : l10n.reviewComposerCreateTitle,
                                      style: textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      widget.restaurantName,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isEditing)
                                IconButton(
                                  tooltip: l10n.commonDelete,
                                  onPressed: isBusy ? null : _confirmDelete,
                                  icon: const Icon(PhosphorIconsRegular.trash),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.l),
                          _StarPicker(
                            rating: _rating,
                            onChanged: isBusy
                                ? null
                                : (value) => setState(() => _rating = value),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Center(
                            child: Text(
                              _ratingLabel(context, _rating),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          TextField(
                            controller: _commentController,
                            enabled: !isBusy,
                            maxLines: 6,
                            maxLength: 2000,
                            decoration: InputDecoration(
                              labelText: l10n.reviewCommentLabel,
                              hintText: l10n.reviewCommentHint,
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                                borderSide: BorderSide(
                                  color: scheme.outlineVariant,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                                borderSide: BorderSide(
                                  color: scheme.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.m,
                          AppSpacing.s,
                          AppSpacing.m,
                          AppSpacing.m,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isBusy
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: Text(l10n.commonCancel),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: canSubmit ? _submit : null,
                                child: isBusy
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isEditing
                                            ? l10n.reviewSaveChanges
                                            : l10n.reviewPostReview,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _ratingLabel(BuildContext context, int rating) {
    final l10n = AppLocalizations.of(context);
    return switch (rating) {
      1 => l10n.reviewRating1,
      2 => l10n.reviewRating2,
      3 => l10n.reviewRating3,
      4 => l10n.reviewRating4,
      5 => l10n.reviewRating5,
      _ => l10n.reviewRatingNone,
    };
  }
}

class _StarPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;

  const _StarPicker({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        final filled = value <= rating;
        return Semantics(
          label: l10n.reviewStarSemantic(value),
          button: true,
          selected: filled,
          child: IconButton(
            iconSize: 36,
            onPressed: onChanged == null ? null : () => onChanged!(value),
            icon: Icon(
              filled ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
              color: filled ? AppColors.warning : null,
            ),
          ),
        );
      }),
    );
  }
}
