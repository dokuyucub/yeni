/**
 * Draft storage using AsyncStorage.
 *
 * Uses an index + per-draft keys approach for robustness.
 * Index key: "cognition_draft_index" -> string[] of draft IDs
 * Draft key: "cognition_draft_{id}" -> DraftDecision JSON
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import type { DraftDecision, DraftListItem, DecisionIntake } from '@cognition-engine/shared';

const DRAFT_INDEX_KEY = 'cognition_draft_index';
const DRAFT_PREFIX = 'cognition_draft_';

/**
 * Generate a unique draft ID.
 */
export function generateDraftId(): string {
  return `draft_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

/**
 * Get the storage key for a draft.
 */
function getDraftKey(id: string): string {
  return `${DRAFT_PREFIX}${id}`;
}

/**
 * Get the list of draft IDs from the index.
 */
async function getDraftIndex(): Promise<string[]> {
  try {
    const indexJson = await AsyncStorage.getItem(DRAFT_INDEX_KEY);
    if (!indexJson) return [];
    return JSON.parse(indexJson);
  } catch (error) {
    console.error('Failed to get draft index:', error);
    return [];
  }
}

/**
 * Update the draft index.
 */
async function setDraftIndex(ids: string[]): Promise<void> {
  await AsyncStorage.setItem(DRAFT_INDEX_KEY, JSON.stringify(ids));
}

/**
 * Create a new empty draft.
 */
export function createEmptyDraft(): DraftDecision {
  const now = new Date().toISOString();
  return {
    id: generateDraftId(),
    currentStepIndex: 0,
    createdAt: now,
    updatedAt: now,
    data: {
      title: '',
      statement: '',
      options: [
        { label: 'O1', name: '', description: '' },
        { label: 'O2', name: '', description: '' },
      ],
      timeHorizons: { short: false, mid: true, long: false },
      objectives: [],
      constraints: {},
      stakeholders: {},
      baselineDoNothing: '',
      resources: {},
      risk: { tolerance: 'medium' },
      dealbreakers: [],
      knownUncertainties: [],
      successDefinition: '',
      failureDefinition: '',
    },
  };
}

/**
 * Get all drafts sorted by updatedAt descending.
 */
export async function listDrafts(): Promise<DraftDecision[]> {
  const ids = await getDraftIndex();
  const drafts: DraftDecision[] = [];

  for (const id of ids) {
    const draft = await getDraft(id);
    if (draft) {
      drafts.push(draft);
    }
  }

  // Sort by updatedAt descending
  return drafts.sort(
    (a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
  );
}

/**
 * Get draft list items for display (lighter weight).
 */
export async function listDraftItems(): Promise<DraftListItem[]> {
  const drafts = await listDrafts();
  return drafts.map((draft) => ({
    id: draft.id,
    title: draft.data.title || 'Untitled Decision',
    currentStepIndex: draft.currentStepIndex,
    updatedAt: draft.updatedAt,
    optionCount: draft.data.options?.length ?? 0,
  }));
}

/**
 * Get a single draft by ID.
 */
export async function getDraft(id: string): Promise<DraftDecision | null> {
  try {
    const draftJson = await AsyncStorage.getItem(getDraftKey(id));
    if (!draftJson) return null;
    return JSON.parse(draftJson);
  } catch (error) {
    console.error(`Failed to get draft ${id}:`, error);
    return null;
  }
}

/**
 * Save or update a draft.
 */
export async function upsertDraft(draft: DraftDecision): Promise<void> {
  const ids = await getDraftIndex();

  // Update timestamp
  draft.updatedAt = new Date().toISOString();

  // Save the draft
  await AsyncStorage.setItem(getDraftKey(draft.id), JSON.stringify(draft));

  // Add to index if new
  if (!ids.includes(draft.id)) {
    ids.push(draft.id);
    await setDraftIndex(ids);
  }
}

/**
 * Update draft data partially.
 */
export async function updateDraftData(
  id: string,
  data: Partial<DecisionIntake>,
  stepIndex?: number
): Promise<DraftDecision | null> {
  const draft = await getDraft(id);
  if (!draft) return null;

  draft.data = { ...draft.data, ...data };
  if (stepIndex !== undefined) {
    draft.currentStepIndex = stepIndex;
  }

  await upsertDraft(draft);
  return draft;
}

/**
 * Delete a draft.
 */
export async function deleteDraft(id: string): Promise<void> {
  const ids = await getDraftIndex();

  // Remove from storage
  await AsyncStorage.removeItem(getDraftKey(id));

  // Remove from index
  const newIds = ids.filter((draftId) => draftId !== id);
  await setDraftIndex(newIds);
}

/**
 * Delete all drafts (dev/debug only).
 */
export async function resetAllDrafts(): Promise<void> {
  const ids = await getDraftIndex();

  // Remove all draft items
  for (const id of ids) {
    await AsyncStorage.removeItem(getDraftKey(id));
  }

  // Clear index
  await AsyncStorage.removeItem(DRAFT_INDEX_KEY);
}

/**
 * Check if there are any drafts.
 */
export async function hasDrafts(): Promise<boolean> {
  const ids = await getDraftIndex();
  return ids.length > 0;
}

/**
 * Get the count of drafts.
 */
export async function getDraftCount(): Promise<number> {
  const ids = await getDraftIndex();
  return ids.length;
}
