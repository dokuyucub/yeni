/// AppStrings - String resources for Day app
/// Contains all user-facing text organized by feature area
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  /// Bottom navigation: Today tab
  static const String navToday = 'Today';

  /// Bottom navigation: Gallery tab
  static const String navGallery = 'Gallery';

  /// Bottom navigation: Journal tab
  static const String navJournal = 'Journal';

  /// Bottom navigation: Profile tab
  static const String navProfile = 'Profile';

  // ============================================================================
  // HOME SCREEN
  // ============================================================================

  /// Greeting displayed in the morning (5 AM - 11:59 AM)
  static const String homeGreetingMorning = 'Good morning';

  /// Greeting displayed in the afternoon (12 PM - 4:59 PM)
  static const String homeGreetingAfternoon = 'Good afternoon';

  /// Greeting displayed in the evening (5 PM - 8:59 PM)
  static const String homeGreetingEvening = 'Good evening';

  /// Greeting displayed at night (9 PM - 4:59 AM)
  static const String homeGreetingNight = 'Good night';

  /// Main question prompt on home screen
  static const String homeQuestion = 'How are you feeling?';

  /// Instructions for color selection
  static const String homeSelectColor = 'Choose a color that matches your mood';

  /// Streak counter label (plural)
  static const String homeStreak = 'day streak';

  /// Streak counter label (singular)
  static const String homeStreakSingular = 'day';

  /// This week section header
  static const String homeThisWeek = 'This Week';

  /// Today section header
  static const String homeToday = 'Today';

  /// Message when no entry exists for today
  static const String homeNoEntry = 'No entry yet';

  // ============================================================================
  // GALLERY
  // ============================================================================

  /// Gallery screen title
  static const String galleryTitle = 'Gallery';

  /// Empty state message for gallery
  static const String galleryEmpty = 'Your gallery is empty';

  /// Empty state description for gallery
  static const String galleryEmptyDesc = 'Start logging your mood to create beautiful artworks';

  /// Favorites section header
  static const String galleryFavorites = 'Favorites';

  /// All artworks section header
  static const String galleryAllArtworks = 'All Artworks';

  /// Monthly view filter
  static const String galleryMonthly = 'Monthly';

  /// Weekly view filter
  static const String galleryWeekly = 'Weekly';

  // ============================================================================
  // JOURNAL
  // ============================================================================

  /// Journal screen title
  static const String journalTitle = 'Journal';

  /// New journal entry button
  static const String journalNew = 'New Entry';

  /// Empty state message for journal
  static const String journalEmpty = 'No entries yet';

  /// Empty state description for journal
  static const String journalEmptyDesc = 'Write your first thought';

  /// Default journal prompt
  static const String journalPromptDefault = 'What made you choose this color?';

  /// Confirmation message when journal entry is saved
  static const String journalSaved = 'Entry saved';

  // ============================================================================
  // PROFILE
  // ============================================================================

  /// Profile screen title
  static const String profileTitle = 'Profile';

  /// Settings section/button
  static const String profileSettings = 'Settings';

  /// Premium upgrade section/button
  static const String profilePremium = 'Day Premium';

  /// Statistics section header
  static const String profileStats = 'Statistics';

  /// Current streak statistic label
  static const String profileCurrentStreak = 'Current Streak';

  /// Longest streak statistic label
  static const String profileLongestStreak = 'Longest Streak';

  /// Total entries statistic label
  static const String profileTotalEntries = 'Total Entries';

  /// Total artworks statistic label
  static const String profileTotalArtworks = 'Artworks Created';

  /// Member since date label
  static const String profileMemberSince = 'Member since';

  // ============================================================================
  // COMMON ACTIONS
  // ============================================================================

  /// Save button text
  static const String actionSave = 'Save';

  /// Cancel button text
  static const String actionCancel = 'Cancel';

  /// Delete button text
  static const String actionDelete = 'Delete';

  /// Edit button text
  static const String actionEdit = 'Edit';

  /// Done button text
  static const String actionDone = 'Done';

  /// Skip button text
  static const String actionSkip = 'Skip';

  /// Next button text
  static const String actionNext = 'Next';

  /// Back button text
  static const String actionBack = 'Back';

  /// Continue button text
  static const String actionContinue = 'Continue';

  /// Try again button text
  static const String actionTryAgain = 'Try Again';

  /// OK button text
  static const String actionOk = 'OK';

  /// Yes button text
  static const String actionYes = 'Yes';

  /// No button text
  static const String actionNo = 'No';

  // ============================================================================
  // STATES
  // ============================================================================

  /// Loading state message
  static const String stateLoading = 'Loading...';

  /// Saving state message
  static const String stateSaving = 'Saving...';

  /// Empty state message
  static const String stateEmpty = 'Nothing here';

  // ============================================================================
  // ERRORS
  // ============================================================================

  /// Generic error message
  static const String errorGeneric = 'Something went wrong';

  /// Network error message
  static const String errorNetwork = 'No internet connection';

  /// Error recovery prompt
  static const String errorTryAgain = 'Please try again';

  /// Failed to load error
  static const String errorLoadFailed = 'Failed to load';

  /// Failed to save error
  static const String errorSaveFailed = 'Failed to save';
}
