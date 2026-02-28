import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_analysis_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_profile_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_nutrition_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_agenda_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_walk_button.dart';

import 'package:scannutplus/features/pet/agenda/presentation/pet_agenda_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_walk_events_screen.dart';
import 'package:scannutplus/features/pet/presentation/pet_profile_view.dart';
import 'package:scannutplus/features/pet/presentation/health/pet_health_screen.dart';
import 'package:scannutplus/features/pet/presentation/pet_ai_chat_view.dart';
import 'package:scannutplus/features/pet/presentation/history/pet_history_screen.dart';
import 'package:scannutplus/features/pet/presentation/widgets/tutorial_speech_bubble.dart' as tsb; // Speech bubble


class PetCardWidget extends StatefulWidget {
  final Map<String, dynamic> pet;
  final VoidCallback onRefresh;

  const PetCardWidget({
    Key? key,
    required this.pet,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<PetCardWidget> createState() => _PetCardWidgetState();
}

class _PetCardWidgetState extends State<PetCardWidget> {
  // Tutorial Keys
  final GlobalKey _infoKey = GlobalKey();
  final GlobalKey _aiKey = GlobalKey();
  final GlobalKey _actionAnalysesKey = GlobalKey();
  final GlobalKey _actionWalkKey = GlobalKey();
  final GlobalKey _actionAgendaKey = GlobalKey();
  final GlobalKey _actionNutritionKey = GlobalKey();
  final GlobalKey _actionProfileKey = GlobalKey();
  
  late TutorialCoachMark tutorialCoachMark;

  void _showTutorial(BuildContext context, AppLocalizations appL10n) {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(appL10n),
      colorShadow: AppColors.petBackgroundDark,
      textSkip: appL10n.tutorial_skip,
      paddingFocus: 10,
      opacityShadow: 0.9,
      onFinish: () {},
      onClickTarget: (target) {},
      onSkip: () {
        return true;
      },
    )..show(context: context);
  }

  List<TargetFocus> _createTargets(AppLocalizations appL10n) {
    return [
      TargetFocus(
        identify: "Target Info",
        keyTarget: _infoKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return tsb.TutorialSpeechBubble(
                title: appL10n.tutorial_pet_info_title,
                description: appL10n.tutorial_pet_info_desc,
                align: tsb.ContentAlign.bottom,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Target AI",
        keyTarget: _aiKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return tsb.TutorialSpeechBubble(
                title: appL10n.tutorial_pet_ai_title,
                description: appL10n.tutorial_pet_ai_desc,
                align: tsb.ContentAlign.bottom,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Target Analyses",
        keyTarget: _actionAnalysesKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return tsb.TutorialSpeechBubble(
                title: appL10n.tutorial_pet_action_analyses_title,
                description: appL10n.tutorial_pet_action_analyses_desc,
                align: tsb.ContentAlign.top,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Target Walk",
        keyTarget: _actionWalkKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return tsb.TutorialSpeechBubble(
                title: appL10n.tutorial_pet_action_walk_title,
                description: appL10n.tutorial_pet_action_walk_desc,
                align: tsb.ContentAlign.top,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Target Agenda",
        keyTarget: _actionAgendaKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return tsb.TutorialSpeechBubble(
                title: appL10n.tutorial_pet_action_agenda_title,
                description: appL10n.tutorial_pet_action_agenda_desc,
                align: tsb.ContentAlign.top,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Target Nutrition",
        keyTarget: _actionNutritionKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return tsb.TutorialSpeechBubble(
                title: appL10n.tutorial_pet_action_nutrition_title,
                description: appL10n.tutorial_pet_action_nutrition_desc,
                align: tsb.ContentAlign.top,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Target Profile",
        keyTarget: _actionProfileKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return tsb.TutorialSpeechBubble(
                title: appL10n.tutorial_pet_action_profile_title,
                description: appL10n.tutorial_pet_action_profile_desc,
                align: tsb.ContentAlign.top,
                onFinish: () => tutorialCoachMark.finish(),
                finishText: appL10n.tutorial_finish,
              );
            },
          ),
        ],
      ),
    ];
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final pet = widget.pet;
    
    final String name = pet[PetConstants.fieldName] ?? appL10n.pet_unknown;
    final String breedRaw = pet[PetConstants.fieldBreed] ?? '';
    
    final bool isBreedUnknown = breedRaw.isEmpty || 
                                breedRaw == PetConstants.valueUnknown || 
                                breedRaw == PetConstants.legacyUnknownBreed ||
                                breedRaw == PetConstants.legacyUnknownBreed;
                                
    String finalBreed = breedRaw;
    if (!isBreedUnknown && finalBreed.isNotEmpty) {
       finalBreed = finalBreed[0].toUpperCase() + finalBreed.substring(1);
    }
    
    final String displayBreed = isBreedUnknown ? appL10n.pet_breed_unknown : finalBreed;
    final String imagePath = pet[PetConstants.fieldImagePath] ?? '';
    final String uuid = pet[PetConstants.fieldUuid] ?? '';

    return Card(
      color: AppColors.petPrimary, 
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.petText, width: 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(
            context, 
            '/pet_dashboard', 
            arguments: {
              PetConstants.argUuid: uuid,
              PetConstants.argName: name,
              PetConstants.argBreed: displayBreed, 
              PetConstants.argImagePath: imagePath,
            },
          ).then((_) => widget.onRefresh());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    key: _infoKey,
                    child: Row(
                      children: [
                        Hero(
                          tag: 'pet_image_$uuid',
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.white, 
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.petText, width: 1.5),
                              image: imagePath.isNotEmpty 
                                ? DecorationImage(
                                    image: ResizeImage(FileImage(File(imagePath)), width: 150),
                                    fit: BoxFit.cover,
                                  ) 
                                : null,
                            ),
                            child: imagePath.isEmpty 
                              ? const Icon(Icons.pets, size: 32, color: Colors.black54) 
                              : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.petText,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayBreed,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isBreedUnknown ? Colors.black54 : AppColors.petText.withValues(alpha: 0.8),
                                  fontStyle: isBreedUnknown ? FontStyle.italic : FontStyle.normal,
                                  fontWeight: isBreedUnknown ? FontWeight.normal : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (pet[PetConstants.fieldCreatedAt] != null) ...[
                                Text(
                                  '${appL10n.pet_created_at_label} ${_formatDate(pet[PetConstants.fieldCreatedAt])}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    key: _aiKey,
                    icon: const Icon(Icons.auto_awesome, color: AppColors.petIconAction),
                    tooltip: appL10n.ai_assistant_title(name),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetAiChatView(petUuid: uuid, petName: name),
                        ),
                      );
                    },
                  ),
                  
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: AppColors.petIconAction),
                    tooltip: 'Ajuda',
                    onPressed: () {
                        _showTutorial(context, appL10n);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              Divider(color: AppColors.petText.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Expanded(
                       key: _actionAnalysesKey,
                       child: PetAnalysisButton(
                         label: appL10n.pet_action_analyses,
                         onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetHistoryScreen(
                                  petUuid: uuid,
                                  petName: name,
                                  petBreed: displayBreed,
                                  petImagePath: imagePath,
                                ),
                              ),
                            ).then((_) => widget.onRefresh()); 
                         }
                       ),
                     ),
                     
                      Expanded(
                        key: _actionWalkKey,
                        child: PetWalkButton(
                          label: appL10n.pet_action_walk,
                          onTap: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => PetWalkEventsScreen(
                                   petId: uuid,
                                   petName: name,
                                 ),
                               ),
                             ).then((_) => widget.onRefresh()); 
                          }
                        ),
                      ),

                      Expanded(
                        key: _actionAgendaKey,
                        child: PetAgendaButton(
                          label: appL10n.pet_action_agenda,
                          onTap: () {
                             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetAgendaScreen(
                                    petId: uuid, 
                                    petName: name,
                                  ),
                                )
                             ).then((_) => widget.onRefresh());
                          }
                        ),
                      ),

                     Expanded(
                       key: _actionNutritionKey,
                       child: PetNutritionButton(
                         label: appL10n.pet_action_nutrition,
                         onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetHealthScreen(petUuid: uuid, petName: name),
                              ),
                            ).then((_) => widget.onRefresh());
                         }
                       ),
                     ),
                     
                     Expanded(
                       key: _actionProfileKey,
                       child: PetProfileButton(
                         label: appL10n.pet_action_profile_short, 
                         onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetProfileView(petUuid: uuid),
                              ),
                            ).then((_) => widget.onRefresh());
                         },
                       ),
                     ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
