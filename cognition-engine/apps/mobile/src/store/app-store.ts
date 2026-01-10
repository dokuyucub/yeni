import { create } from 'zustand';

interface AppState {
  isInitialized: boolean;
  isAuthenticated: boolean;
  setInitialized: (value: boolean) => void;
  setAuthenticated: (value: boolean) => void;
  reset: () => void;
}

const initialState = {
  isInitialized: false,
  isAuthenticated: false,
};

export const useAppStore = create<AppState>((set) => ({
  ...initialState,
  setInitialized: (value) => set({ isInitialized: value }),
  setAuthenticated: (value) => set({ isAuthenticated: value }),
  reset: () => set(initialState),
}));
