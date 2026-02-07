# Pet Analysis Dynamic UI Protocol (2026)

## Overview
The Pet Analysis feature has been upgraded to support a **Dynamic UI** driven by the AI's response structure. Instead of hardcoded sections, the mobile app parses a structured format returned by the LLM (Large Language Model) to generate UI cards on the fly. This allows for greater flexibility and adaptability without requiring app updates for new analysis categories.

## Protocol Specification

### AI Output Format
The AI is instructed to return the analysis in a specific block format. The prompt instructions are defined in `lib/core/constants/ai_prompts.dart`.

**Format:**
```
URGENCY: [GREEN|YELLOW|RED]

[CARD_START]
TITLE: [Localized Section Title]
ICON: [IconKey]
CONTENT: [Detailed observation text]
[CARD_END]

[CARD_START]
...
[CARD_END]
```

### Supported Icons (`IconKey`)
The app maps specific string keys to `LucideIcons` in `PetAnalysisResultView`. 

| Icon Key | Icon (Lucide) | Context |
| :--- | :--- | :--- |
| `pet` | `LucideIcons.dog` | Species ID |
| `heart` | `LucideIcons.heart` | General Health |
| `coat` / `scissors` | `LucideIcons.scissors` | Coat/Fur Condition |
| `skin` / `search` | `LucideIcons.search` | Skin Health |
| `ear` | `LucideIcons.ear` | Ear Health |
| `nose` / `wind` | `LucideIcons.wind` | Nose/Breathing |
| `eye` | `LucideIcons.eye` | Eye Health |
| `body` / `scale` | `LucideIcons.scale` | Body Condition |
| `alert` / `issues` | `LucideIcons.alertTriangle` | Potential Issues |
| `summary` / `filetext` | `LucideIcons.fileText` | Analysis Summary |
| `info` (default) | `LucideIcons.info` | General Info |

### Urgency Levels
The app parses the `URGENCY:` tag to determine the status header's color and text.

*   **GREEN**: "Status: Stable" / "Healthy"
*   **YELLOW**: "Status: Monitor" / "Attention Required"
*   **RED**: "Status: Critical Attention" / "Immediate Attention"

## Source Extraction Protocol (V7 - 2026 update)

### Scientific Sourcing
To ensure verifiability (Pilar 0), the AI must now cite 3 scientific sources at the end of the analysis.
*   **Prompt Constraint**: Enforced via `PetPrompts` with a mandatory `[CARD]` structure.
*   **Token Limit**: Increased to `2500` to prevent truncation of sources.

### Robust Regex Extraction
The system employs a "Checkmate" regex extraction logic to handle variations in AI output:
```dart
final RegExp sourceRegex = RegExp(r'(Sources|References|Referências|Fontes):?', caseSensitive: false);
```
This logic is implemented in both `PetBaseAiService` (for data persistence) and `PetAnalysisResultView` (for immediate UI rendering), ensuring redundancy and reliability.

## Technical Implementation

### Key Files
*   `lib/features/pet/presentation/pet_analysis_result_view.dart`: Contains `_parseDynamicCards` and `_extractSources` logic.
*   `lib/features/pet/data/pet_constants.dart`: Stores regex patterns and keys.
*   `lib/core/constants/ai_prompts.dart`: Defines the Prompt Engineering.

### Fallback Mechanism
If the AI fails to produce the structured block format, the parser falls back to "Compatibility Mode".
If fewer than 3 sources are extracted, the system automatically injects a standard protocol fallback (e.g., Merck Manual, AAHA) to guarantee UI consistency.

## Pillar 0 Compliance
All UI strings, keys, and regex patterns are strictly decoupled.
*   **UI Text**: Managed via `AppLocalizations` (`.arb` files).
*   **Logic Keys**: Managed via `PetConstants`.

---
*Updated: 2026-02-03*
