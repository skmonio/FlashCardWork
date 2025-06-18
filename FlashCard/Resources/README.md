# Resources Directory

This directory contains audio and other resource files for the FlashCard app.

## Audio Files

### Begin.wav
- **Purpose**: Played when the splash screen fades away and transitions to the main app
- **Location**: Place your `Begin.wav` file in the **root directory** of the project (not in Resources)
- **Format**: WAV audio file
- **Usage**: Automatically played by `SoundManager.shared.playBeginSound()` during app launch

### Game.wav
- **Purpose**: Played when user presses "Start <game name>" button
- **Location**: Place your `Game.wav` file in the **root directory** of the project (same level as Begin.wav)
- **Format**: WAV audio file
- **Usage**: Automatically played by `SoundManager.shared.playGameStartSound()` when starting any game
- **Fallback**: If file not found, falls back to system tap sound

### Complete.wav
- **Purpose**: Played when user completes a game (replaces old success sound)
- **Location**: Place your `Complete.wav` file in the **root directory** of the project (same level as Begin.wav)
- **Format**: WAV audio file
- **Usage**: Automatically played by `SoundManager.shared.playCompleteSound()` when games are completed
- **Fallback**: If file not found, falls back to system success sound

### Correct.wav
- **Purpose**: Played when user answers correctly in all games (Test, True/False, Writing, Word Scramble, Look Cover Check, Multiple Choice, Memory Game)
- **Location**: Place your `Correct.wav` file in the **root directory** of the project (same level as Begin.wav)
- **Format**: WAV audio file
- **Usage**: Automatically played by `SoundManager.shared.playTestCorrectSound()` when user answers correctly in games
- **Note**: Study mode ("Study Your Cards") uses system sounds, not custom sounds
- **Fallback**: If file not found, falls back to system correct sound

### Wrong.wav
- **Purpose**: Played when user answers incorrectly in all games (Test, True/False, Writing, Word Scramble, Look Cover Check, Multiple Choice, Memory Game)
- **Location**: Place your `Wrong.wav` file in the **root directory** of the project (same level as Begin.wav)
- **Format**: WAV audio file
- **Usage**: Automatically played by `SoundManager.shared.playTestWrongSound()` when user answers incorrectly in games
- **Note**: Study mode ("Study Your Cards") uses system sounds, not custom sounds
- **Fallback**: If file not found, falls back to system incorrect sound

## Adding the Audio Files

1. Place your audio files (`Begin.wav`, `Game.wav`, `Complete.wav`, `Correct.wav`, `Wrong.wav`) in the **root directory** of the project (same level as FlashCard.xcodeproj)
2. In Xcode, right-click on the FlashCard project in the navigator
3. Select "Add Files to 'FlashCard'"
4. Navigate to and select the audio files
5. Make sure "Add to target" is checked for FlashCard

The audio files will automatically play during appropriate game events and respect the user's sound settings.

**Note**: All audio files should be in the project root, not in the Resources folder, so that Bundle.main can find them directly. If any audio file is missing, the app will gracefully fall back to system sounds. 