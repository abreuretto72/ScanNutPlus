# Implementation Plan - Pet RAG Architecture V2 (Protocol 2026)

## 🎯 Goal
Implement a robust Retrieval-Augmented Generation (RAG) architecture for the Pet module to enable long-term data tracking and comparative analysis (evolutionary memory). Eliminate hardcoded strings (Pilar 0) and ensure type safety.

## 🛠️ Implementation Details

### 1. Data Model (`pet_history_entry.dart`)
- **Action**: Updated `PetHistoryEntry` class and Hive Adapter.
- **New Fields**:
  - `tags` (List<String>): For searchable keywords (Severity, Symptom, etc).
  - `severityIndex` (int): 1-10 scaling.
  - `trendAnalysis` (String): Evolutionary context (Improvement/Worsening).
- **Status**: ✅ Implemented (Manual Adapter updated).

### 2. Constants & Configuration (`pet_constants.dart`)
- **Action**: Unified all RAG constants, including Keys, Values, and System Prompts.
- **Compliance**: STRICT Pilar 0 (All strings extracted to `static const`).
- **Updates**:
  - `promptRagMaster`: The "Brain" of the RAG system.
  - Keys: `pet_rag_tags`, `pet_rag_severity`, etc.
  - UI Configs: Colors and Padding for SM A256E.
- **Status**: ✅ Implemented & Harmonized.

### 3. Logic & Persistence (`pet_repository.dart`)
- **Action**: Enhanced `saveAnalysis` to parse the "Invisible Metadata Block" (`[RAG_METADATA]`) from AI responses.
- **Logic**: Automatically extracts JSON metadata and populates the new Hive fields.
- **Status**: ✅ Implemented with JSON Parsing and Logging.

### 4. AI Service (`pet_base_ai_service.dart`)
- **Action**: Updated prompt construction (`_buildSystemPrompt`).
- **Logic**: Injects `promptRagMaster` + `[CONTEXT/HISTORY]` block to enable AI memory.
- **Status**: ✅ Implemented.

## ⚠️ Known Issues
- **Build Failure**: `Gradle task assembleDebug failed with exit code 1`.
  - **Context**: Persistent environmental error (likely Native Lib/MultiDex/JDK).
  - **Mitigation**: MultiDex enabled, Java 17 verified. Requires deeper native debugging.

## 🚀 Next Steps
1. Resolve Native Build environment (Reset Android Studio caches?).
2. Verify RAG Metadata indexing (using `PetRagDebugView`).
3. Implement "Timeline" visualization using `severityIndex`.
