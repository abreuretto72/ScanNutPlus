---
name: user-centric-exceptions
description: Translates technical errors into friendly human language with action-oriented messages and l10n support.
---
# User-Centric Exceptions (Ref: Skill Invariável)

This skill acts as a translator of technical errors into friendly human language, prioritizing user action over technical detail.

## Execution Rules

### 1. Interception
- **Trigger**: Whenever generating a `catch` block, `throw` statement, or `SnackBar` (especially for errors).
- **Action**: Stop and analyze the message before writing code.

### 2. Translation (The Filter)
- **BANNED TERMS**: Remove references to:
  - JSON
  - Parse
  - Null
  - Hive
  - Status Code
  - API
  - Link
  - Exception
  - Error (the word itself, unless part of a friendly phrases like "something went wrong")
  - Stack traces

### 3. Substitution (Action-Oriented)
- Use only action messages for the user.
- **Examples**:
  - ❌ "JSON Parse Error" -> ✅ "Não conseguimos processar agora." / "We couldn't process right now."
  - ❌ "Connection Timeout" -> ✅ "Verifique sua conexão." / "Check your connection."
  - ❌ "Camera permission denied" -> ✅ "Tente tirar uma foto mais clara" (Action) or "Allow camera access."

### 4. Internationalization (Iron Law)
- **Mandatory**: Use `l10n` keys for these messages.
- **Example**: `l10n.errorNetwork` instead of "Network Error".

### 5. Visual Standards
- **Negative Messages (Errors)**: Must use **Red Background** (e.g., `AppDesign.error`).
- **Positive Messages (Success)**: Must use **Green Background** (e.g., `AppDesign.success`).
