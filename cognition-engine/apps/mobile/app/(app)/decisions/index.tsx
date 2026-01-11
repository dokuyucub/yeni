/**
 * Decisions list screen.
 *
 * Shows list of draft decisions and allows creating new ones.
 */

import { useCallback, useEffect, useState } from 'react';
import {
  FlatList,
  Pressable,
  StyleSheet,
  Text,
  View,
  RefreshControl,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useFocusEffect } from 'expo-router';

import type { DraftListItem } from '@cognition-engine/shared';
import { listDraftItems, deleteDraft } from '@/lib/drafts';
import { useDraftStore } from '@/store/draft-store';
import { Loading } from '@/components';

export default function DecisionsListScreen() {
  const [drafts, setDrafts] = useState<DraftListItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const createNewDraft = useDraftStore((s) => s.createNewDraft);
  const loadDraft = useDraftStore((s) => s.loadDraft);

  const fetchDrafts = useCallback(async () => {
    try {
      const items = await listDraftItems();
      // Sort by updatedAt descending
      items.sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
      setDrafts(items);
    } catch (error) {
      console.error('Failed to load drafts:', error);
    }
  }, []);

  // Initial load
  useEffect(() => {
    fetchDrafts().finally(() => setIsLoading(false));
  }, [fetchDrafts]);

  // Refresh on focus
  useFocusEffect(
    useCallback(() => {
      fetchDrafts();
    }, [fetchDrafts])
  );

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await fetchDrafts();
    setIsRefreshing(false);
  };

  const handleCreateNew = async () => {
    try {
      const draftId = await createNewDraft();
      router.push(`/(app)/decisions/wizard/${draftId}`);
    } catch (error) {
      Alert.alert('Error', 'Failed to create new decision');
    }
  };

  const handleContinueDraft = async (draftId: string) => {
    await loadDraft(draftId);
    router.push(`/(app)/decisions/wizard/${draftId}`);
  };

  const handleDeleteDraft = (draftId: string, title: string) => {
    Alert.alert(
      'Delete Draft',
      `Are you sure you want to delete "${title || 'Untitled'}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteDraft(draftId);
              await fetchDrafts();
            } catch (error) {
              Alert.alert('Error', 'Failed to delete draft');
            }
          },
        },
      ]
    );
  };

  const formatDate = (isoString: string) => {
    const date = new Date(isoString);
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
    });
  };

  if (isLoading) {
    return <Loading />;
  }

  return (
    <SafeAreaView style={styles.container} edges={['bottom']}>
      <FlatList
        data={drafts}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={handleRefresh}
            tintColor="#e94560"
          />
        }
        ListHeaderComponent={
          <View style={styles.header}>
            <Text style={styles.subtitle}>
              {drafts.length === 0
                ? 'Start by creating your first decision'
                : `${drafts.length} draft${drafts.length !== 1 ? 's' : ''} in progress`}
            </Text>
          </View>
        }
        ListEmptyComponent={
          <View style={styles.emptyState}>
            <Text style={styles.emptyIcon}>🎯</Text>
            <Text style={styles.emptyTitle}>No decisions yet</Text>
            <Text style={styles.emptyText}>
              Create a new decision to get started with the structured
              decision-making process
            </Text>
          </View>
        }
        renderItem={({ item }) => (
          <Pressable
            style={styles.draftCard}
            onPress={() => handleContinueDraft(item.id)}
            onLongPress={() => handleDeleteDraft(item.id, item.title)}
          >
            <View style={styles.draftHeader}>
              <Text style={styles.draftTitle} numberOfLines={1}>
                {item.title || 'Untitled Decision'}
              </Text>
              <Text style={styles.draftStep}>
                Step {item.currentStepIndex + 1}/7
              </Text>
            </View>
            <View style={styles.draftProgress}>
              <View style={styles.progressBar}>
                <View
                  style={[
                    styles.progressFill,
                    { width: `${((item.currentStepIndex + 1) / 7) * 100}%` },
                  ]}
                />
              </View>
            </View>
            <Text style={styles.draftDate}>
              Last edited {formatDate(item.updatedAt)}
            </Text>
          </Pressable>
        )}
      />

      <View style={styles.footer}>
        <Pressable style={styles.createButton} onPress={handleCreateNew}>
          <Text style={styles.createButtonText}>+ New Decision</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#16213e',
  },
  listContent: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 100,
    flexGrow: 1,
  },
  header: {
    marginBottom: 20,
  },
  subtitle: {
    color: '#808080',
    fontSize: 14,
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
    paddingHorizontal: 32,
  },
  emptyIcon: {
    fontSize: 48,
    marginBottom: 16,
  },
  emptyTitle: {
    color: '#ffffff',
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  emptyText: {
    color: '#808080',
    fontSize: 14,
    textAlign: 'center',
    lineHeight: 20,
  },
  draftCard: {
    backgroundColor: '#1a1a2e',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#2a2a4e',
  },
  draftHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  draftTitle: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
    flex: 1,
    marginRight: 12,
  },
  draftStep: {
    color: '#e94560',
    fontSize: 12,
    fontWeight: '600',
  },
  draftProgress: {
    marginBottom: 8,
  },
  progressBar: {
    height: 4,
    backgroundColor: '#2a2a4e',
    borderRadius: 2,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#e94560',
    borderRadius: 2,
  },
  draftDate: {
    color: '#606080',
    fontSize: 12,
  },
  footer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    paddingHorizontal: 20,
    paddingVertical: 20,
    backgroundColor: '#16213e',
    borderTopWidth: 1,
    borderTopColor: '#2a2a4e',
  },
  createButton: {
    backgroundColor: '#e94560',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  createButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '700',
  },
});
