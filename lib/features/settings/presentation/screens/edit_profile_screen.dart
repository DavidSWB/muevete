import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/profile/domain/entities/biological_sex.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/services/personal_info_validator.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/widgets/biological_sex_selector.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/screens/error_screen.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';
import 'package:muevete/shared/widgets/my_textinputfield.dart';

/// Lets the user change the personal fields they entered at sign-up.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  BiologicalSex? _sex;

  bool _initialized = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  /// Fills the form once, so a profile refresh never discards what the user
  /// is typing.
  void _initFields(UserModel user) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = user.username;
    _ageController.text = user.age?.toString() ?? '';
    _weightController.text = _formatNumber(user.weight);
    _heightController.text = _formatNumber(user.height);
    _medicalConditionsController.text =
        user.medicalConditions?.join(', ') ?? '';
    _sex = BiologicalSex.fromStored(user.sex);
  }

  static String _formatNumber(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  /// Returns the validated fields, or sets [_errorMessage] and returns null.
  PersonalInfo? _validate(AppLocalizations l10n) {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();
    final weightText = _weightController.text.trim();
    final heightText = _heightController.text.trim();

    String? error;
    final age = PersonalInfoValidator.parseAge(ageText);
    final weight = PersonalInfoValidator.parseWeightKg(weightText);
    final height = PersonalInfoValidator.parseHeightCm(heightText);

    if (name.isEmpty ||
        ageText.isEmpty ||
        weightText.isEmpty ||
        heightText.isEmpty) {
      error = l10n.valMandatoryFields;
    } else if (age == null) {
      error = l10n.valInvalidAge;
    } else if (weight == null) {
      error = l10n.valInvalidWeight;
    } else if (height == null) {
      error = l10n.valInvalidHeight;
    } else if (_sex == null) {
      error = l10n.valSelectSex;
    }

    if (error != null) {
      setState(() => _errorMessage = error);
      return null;
    }

    final medicalConditions = _medicalConditionsController.text.trim();
    return PersonalInfo(
      username: name,
      age: age!,
      weight: weight!,
      height: height!,
      sex: _sex!,
      medicalConditions: medicalConditions.isNotEmpty
          ? [medicalConditions]
          : null,
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    final info = _validate(l10n);
    if (info == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref.read(profileProvider.notifier).updatePersonalInfo(info);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editProfileSaved),
          backgroundColor: AppColors.success,
        ),
      );
      if (context.canPop()) context.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = l10n.editProfileSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsEditProfile)),
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorScreen(
          l10n.homeCouldNotLoadProfile,
          onRetry: () => ref.read(profileProvider.notifier).refresh(),
          retryLabel: l10n.notifRetry,
        ),
        data: (user) {
          _initFields(user);
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      key: const ValueKey('edit-profile-error'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                MyTextinputfield(
                  controller: _nameController,
                  hintText: l10n.authFullNameHint,
                  prefixIcon: Icons.person_outline_rounded,
                  obscureText: false,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                if (user.email.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                l10n.editProfileEmailReadOnly,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                MyTextinputfield(
                  controller: _ageController,
                  hintText: l10n.authAgeHint,
                  prefixIcon: Icons.cake_outlined,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 14),
                MyTextinputfield(
                  controller: _weightController,
                  hintText: l10n.authWeightHint,
                  prefixIcon: Icons.monitor_weight_outlined,
                  obscureText: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                MyTextinputfield(
                  controller: _heightController,
                  hintText: l10n.authHeightHint,
                  prefixIcon: Icons.height_rounded,
                  obscureText: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                BiologicalSexSelector(
                  value: _sex,
                  enabled: !_isSaving,
                  onChanged: (sex) => setState(() => _sex = sex),
                ),
                const SizedBox(height: 14),
                MyTextinputfield(
                  controller: _medicalConditionsController,
                  hintText: l10n.authMedicalConditionsHint,
                  prefixIcon: Icons.medical_information_outlined,
                  obscureText: false,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                MyButton(
                  key: const ValueKey('edit-profile-save'),
                  text: l10n.editProfileSave,
                  onTap: _save,
                  isLoading: _isSaving,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
