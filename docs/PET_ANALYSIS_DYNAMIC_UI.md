# Pet Analysis Dynamic UI Protocol (2026)

## Overview
The Pet Analysis feature has been upgraded to support a **Dynamic UI** driven by the AI's response structure. Instead of hardcoded sections, the mobile app parses a structured format returned by the LLM (Large Language Model) to generate UI cards on the fly. This allows for greater flexibility and adaptability without requiring app updates for new analysis categories.

## Protocol Specification

### AI Output Format
The AI is instructed to return the analysis in a specific block format. The prompt instructions are defined in `lib/core/constants/ai_prompts.dart`.

**Format:**
```
URGENCY: [GREEN|YELLOW|RED]

[VISUAL_SUMMARY]
Detailed visual observation of the image.
[END_SUMMARY]

[CARD_START]
TITLE: [Localized Section Title]
ICON: [IconKey]
CONTENT: [Detailed observation text]
[CARD_END]

[CARD_START]
...
[CARD_END]

[SOURCES]
Source 1
Source 2
[END_SOURCES]
```

### Supported Icons (`IconKey`)
The app maps specific string keys to `LucideIcons` (or standard Material Icons) in `PetAnalysisResultView` and `PetAiCardsRenderer`. 

| Icon Key | Icon (Material) | Context |
| :--- | :--- | :--- |
| `pet` | `Icons.pets` | Species ID |
| `heart` | `Icons.favorite` | General Health |
| `alert` / `issues` | `Icons.warning` | Potential Issues |
| `info` (default) | `Icons.info` | General Info |
| `doc` / `filetext` | `Icons.description` | Analysis Summary |
| `visual` | `Icons.visibility` | Visual Summary |

### Urgency Levels
The app parses the `URGENCY:` tag to determine the status header's color and text.

*   **GREEN**: "Status: Stable" / "Healthy"
*   **YELLOW**: "Status: Monitor" / "Attention Required"
*   **RED**: "Status: Critical Attention" / "Immediate Attention"

## Source Extraction Protocol (V7 - 2026 update)

### Scientific Sourcing
To ensure verifiability (Pilar 0), the AI must now cite 3 scientific sources at the end of the analysis.
*   **Prompt Constraint**: Enforced via `PetPrompts` with a mandatory `[SOURCES]` structure.
*   **Token Limit**: Increased to `4000` to prevent truncation of sources.

### Robust Regex Extraction
The system employs a "Checkmate" regex extraction logic to handle variations in AI output:
```dart
final RegExp sourceRegex = RegExp(r'\[SOURCES\](.*?)\[END_SOURCES\]', dotAll: true);
```
This logic is implemented in `PetAiCardsRenderer` for immediate UI rendering in the Agenda.

## Technical Implementation

### Key Files
*   `lib/features/pet/presentation/widgets/pet_ai_cards_renderer.dart`: **[NEW]** Reusable widget for parsing and rendering analysis cards in any screen (Agenda, History, Result).
*   `lib/features/pet/presentation/pet_analysis_result_view.dart`: Original implementation (being refactored to use renderer).
*   `lib/features/pet/agenda/presentation/pet_event_detail_screen.dart`: Integrating `PetAiCardsRenderer` for rich event details.
*   `lib/features/pet/data/pet_constants.dart`: Stores regex patterns and keys.

### Fallback Mechanism
If the AI fails to produce the structured block format, the parser falls back to "Compatibility Mode".
A raw text block is displayed if no cards can be parsed.

## Pillar 0 Compliance
All UI strings, keys, and regex patterns are strictly decoupled.
*   **UI Text**: Managed via `AppLocalizations` (`.arb` files).
*   **Logic Keys**: Managed via `PetConstants`.

---
*Updated: 2026-02-13*
