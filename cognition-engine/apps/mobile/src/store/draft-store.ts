/**
 * Draft decision Zustand store.
 *
 * Manages the current draft being edited in the wizard.
 */

import { create } from 'zustand';
import type {
  DraftDecision,
  DecisionIntake,
  DecisionOption,
  ObjectiveWeight,
  TimeHorizons,
  DecisionConstraints,
  DecisionStakeholders,
  DecisionResources,
  DecisionRisk,
  GutPreference,
} from '@cognition-engine/shared';
import {
  createEmptyDraft,
  getDraft,
  upsertDraft,
  deleteDraft as deleteStoredDraft,
} from '@/lib/drafts';

interface DraftState {
  // Current draft
  currentDraft: DraftDecision | null;
  isLoading: boolean;
  isSaving: boolean;
  error: string | null;

  // Actions
  loadDraft: (id: string) => Promise<void>;
  createNewDraft: () => Promise<string>;
  saveDraft: () => Promise<void>;
  deleteDraft: () => Promise<void>;
  clearCurrentDraft: () => void;

  // Step navigation
  setCurrentStep: (stepIndex: number) => void;

  // Data updates
  updateBasics: (title: string, statement: string) => void;
  updateOptions: (options: DecisionOption[]) => void;
  addOption: () => void;
  removeOption: (index: number) => void;
  updateOption: (index: number, option: Partial<DecisionOption>) => void;
  updateTimeHorizons: (horizons: TimeHorizons) => void;
  updateObjectives: (objectives: ObjectiveWeight[]) => void;
  updateConstraints: (constraints: DecisionConstraints) => void;
  updateStakeholders: (stakeholders: DecisionStakeholders) => void;
  updateResources: (resources: DecisionResources) => void;
  updateRisk: (risk: DecisionRisk) => void;
  updateDealbreakers: (dealbreakers: string[]) => void;
  updateUncertainties: (uncertainties: string[]) => void;
  updateBaseline: (baseline: string) => void;
  updateSuccessDefinition: (definition: string) => void;
  updateFailureDefinition: (definition: string) => void;
  updateGutPreference: (preference: GutPreference | undefined) => void;
}

export const useDraftStore = create<DraftState>((set, get) => ({
  currentDraft: null,
  isLoading: false,
  isSaving: false,
  error: null,

  loadDraft: async (id: string) => {
    set({ isLoading: true, error: null });
    try {
      const draft = await getDraft(id);
      if (draft) {
        set({ currentDraft: draft, isLoading: false });
      } else {
        set({ error: 'Draft not found', isLoading: false });
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to load draft',
        isLoading: false,
      });
    }
  },

  createNewDraft: async () => {
    set({ isLoading: true, error: null });
    try {
      const draft = createEmptyDraft();
      await upsertDraft(draft);
      set({ currentDraft: draft, isLoading: false });
      return draft.id;
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to create draft',
        isLoading: false,
      });
      throw error;
    }
  },

  saveDraft: async () => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({ isSaving: true });
    try {
      await upsertDraft(currentDraft);
      set({ isSaving: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to save draft',
        isSaving: false,
      });
    }
  },

  deleteDraft: async () => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({ isLoading: true });
    try {
      await deleteStoredDraft(currentDraft.id);
      set({ currentDraft: null, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to delete draft',
        isLoading: false,
      });
    }
  },

  clearCurrentDraft: () => {
    set({ currentDraft: null, error: null });
  },

  setCurrentStep: (stepIndex: number) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        currentStepIndex: stepIndex,
        updatedAt: new Date().toISOString(),
      },
    });

    // Auto-save
    get().saveDraft();
  },

  updateBasics: (title: string, statement: string) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, title, statement },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateOptions: (options: DecisionOption[]) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, options },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  addOption: () => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    const options = currentDraft.data.options ?? [];
    const newOption: DecisionOption = {
      label: `O${options.length + 1}`,
      name: '',
      description: '',
    };

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, options: [...options, newOption] },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  removeOption: (index: number) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    const options = currentDraft.data.options ?? [];
    const filtered = options.filter((_, i) => i !== index);
    // Renumber labels
    const renumbered = filtered.map((opt, i) => ({ ...opt, label: `O${i + 1}` }));

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, options: renumbered },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateOption: (index: number, option: Partial<DecisionOption>) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    const options = [...(currentDraft.data.options ?? [])];
    if (index < options.length) {
      options[index] = { ...options[index], ...option };
    }

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, options },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateTimeHorizons: (horizons: TimeHorizons) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, timeHorizons: horizons },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateObjectives: (objectives: ObjectiveWeight[]) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, objectives },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateConstraints: (constraints: DecisionConstraints) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, constraints },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateStakeholders: (stakeholders: DecisionStakeholders) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, stakeholders },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateResources: (resources: DecisionResources) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, resources },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateRisk: (risk: DecisionRisk) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, risk },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateDealbreakers: (dealbreakers: string[]) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, dealbreakers },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateUncertainties: (uncertainties: string[]) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, knownUncertainties: uncertainties },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateBaseline: (baseline: string) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, baselineDoNothing: baseline },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateSuccessDefinition: (definition: string) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, successDefinition: definition },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateFailureDefinition: (definition: string) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, failureDefinition: definition },
        updatedAt: new Date().toISOString(),
      },
    });
  },

  updateGutPreference: (preference: GutPreference | undefined) => {
    const { currentDraft } = get();
    if (!currentDraft) return;

    set({
      currentDraft: {
        ...currentDraft,
        data: { ...currentDraft.data, gutPreference: preference },
        updatedAt: new Date().toISOString(),
      },
    });
  },
}));

// Selector hooks
export const useCurrentDraft = () => useDraftStore((state) => state.currentDraft);
export const useDraftData = () => useDraftStore((state) => state.currentDraft?.data);
export const useIsDraftLoading = () => useDraftStore((state) => state.isLoading);
export const useIsDraftSaving = () => useDraftStore((state) => state.isSaving);
export const useDraftError = () => useDraftStore((state) => state.error);
