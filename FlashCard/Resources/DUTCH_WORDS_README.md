# 🇳🇱 Dutch Words - Custom Word Exercise System

## Overview

The **Dutch Words** feature allows users to create, import, and practice custom exercises for specific Dutch words they're struggling with. This is perfect for targeted learning when you encounter difficult words in your studies.

## 🎯 Key Features

### **Create Custom Exercises**
- Build personalized exercises for any Dutch word
- Choose from 10 different exercise types
- Set difficulty levels (Easy, Medium, Hard)
- Add hints and detailed explanations
- Categorize words by topic

### **Multiple Exercise Types**
1. **Fill in the Blank** - Complete sentences with the target word
2. **Sentence Building** - Arrange words to form correct Dutch sentences
3. **Multiple Choice** - Choose the correct meaning or usage
4. **Translation** - Translate between Dutch and English
5. **Word Order** - Practice Dutch word order rules
6. **Context Clue** - Understand word usage in context
7. **Pronunciation** - Learn correct pronunciation
8. **Verb Conjugation** - Practice verb forms
9. **Article Practice** - Master Dutch articles (de/het)
10. **Synonym/Antonym** - Learn related words

### **Import & Export**
- **Import JSON files** with custom exercise sets
- **Export your exercises** to share with others
- **Sample file included** for testing
- **Excel support** coming soon

### **Smart Organization**
- **20 categories** (Business, Academic, Casual, etc.)
- **Search and filter** by word, translation, or category
- **Difficulty tracking** with color-coded indicators
- **Statistics and progress** tracking

## 📱 How to Use

### **Accessing Dutch Words**
1. Open the app and go to **Resources**
2. Tap **"Dutch Words"** (green text icon)
3. You'll see the main dashboard with statistics and options

### **Creating Your First Exercise**
1. Tap **"Create"** button
2. Enter the Dutch word and English translation
3. Choose category and difficulty level
4. Tap **"Add Exercise"** to create questions
5. Select exercise type and fill in details
6. Save your word exercise

### **Importing Exercises**
1. Tap **"Import"** button
2. Choose a JSON file from your device
3. The app will import all exercises automatically
4. View imported exercises in the main list

### **Practicing Exercises**
1. Tap on any word exercise card
2. Answer questions one by one
3. Get immediate feedback and explanations
4. View your final score and results
5. Review all questions and answers

## 📊 Exercise Types Explained

### **Fill in the Blank**
```
Prompt: "De straf was _____ voor wat hij had gedaan."
Options: ["terecht", "onterecht", "recht", "rechtstreeks"]
Correct: "terecht"
```

### **Sentence Building**
```
Prompt: "Arrange the words to form a correct Dutch sentence:"
Options: ["De", "kritiek", "was", "terecht", "en", "nuttig"]
Correct: "De kritiek was terecht en nuttig"
```

### **Multiple Choice**
```
Prompt: "What does 'terecht' mean in English?"
Options: ["Wrong", "Justified", "Direct", "Correct"]
Correct: "Justified"
```

### **Translation**
```
Prompt: "Translate 'The complaint was justified' to Dutch:"
Options: ["De klacht was terecht", "De klacht was onterecht", ...]
Correct: "De klacht was terecht"
```

## 📁 Import/Export Format

### **JSON Structure**
```json
{
  "exercises": [
    {
      "targetWord": "terecht",
      "wordTranslation": "justified",
      "exercises": [
        {
          "type": "fillInBlank",
          "prompt": "De straf was _____ voor wat hij had gedaan.",
          "options": ["terecht", "onterecht", "recht", "rechtstreeks"],
          "correctAnswer": "terecht",
          "explanation": "'Terecht' means 'justified' or 'deserved'.",
          "hint": "Think about whether the punishment was deserved",
          "difficulty": "medium"
        }
      ],
      "difficulty": "medium",
      "category": "general"
    }
  ],
  "metadata": {
    "source": "Custom Import",
    "version": "1.0",
    "importedAt": "2024-01-01T00:00:00Z",
    "totalExercises": 1,
    "categories": ["general"]
  }
}
```

## 🎨 Categories Available

- **General** - Everyday vocabulary
- **Business** - Professional and work terms
- **Academic** - Educational and scholarly words
- **Casual** - Informal and conversational
- **Formal** - Official and formal language
- **Technical** - Technical and specialized terms
- **Medical** - Health and medical vocabulary
- **Legal** - Legal and judicial terms
- **Travel** - Tourism and travel words
- **Food** - Culinary and dining vocabulary
- **Family** - Family and relationship terms
- **Emotions** - Feelings and emotional states
- **Weather** - Weather and climate terms
- **Time** - Time-related vocabulary
- **Numbers** - Numerical expressions
- **Colors** - Color vocabulary
- **Animals** - Animal names and terms
- **Sports** - Sports and athletic terms
- **Music** - Musical vocabulary
- **Art** - Artistic and creative terms

## 📈 Statistics & Progress

The system tracks:
- **Total word exercises** created
- **Total questions** across all exercises
- **User-created vs imported** exercises
- **Category breakdown** with percentages
- **Difficulty level** distribution
- **Recent activity** timeline
- **Average questions per word**

## 💡 Tips for Effective Learning

### **Creating Good Exercises**
1. **Mix exercise types** - Use different question formats
2. **Include context** - Add real-world usage examples
3. **Provide hints** - Help learners when they're stuck
4. **Vary difficulty** - Include easy, medium, and hard questions
5. **Use clear explanations** - Explain why answers are correct

### **Practicing Effectively**
1. **Start with easy exercises** to build confidence
2. **Review explanations** even for correct answers
3. **Practice regularly** with the same words
4. **Use the search function** to find specific words
5. **Export and share** exercises with study partners

## 🔧 Technical Details

### **Supported Formats**
- **Import**: JSON files (.json)
- **Export**: JSON files with metadata
- **Future**: Excel files (.xlsx, .xls)

### **Data Storage**
- Exercises are saved locally on your device
- No internet connection required
- Data persists between app sessions
- Automatic backup with device settings

### **Performance**
- Fast loading and smooth navigation
- Efficient search and filtering
- Optimized for large exercise sets
- Minimal memory usage

## 🆘 Troubleshooting

### **Import Issues**
- Ensure JSON file is properly formatted
- Check that all required fields are present
- Verify file extension is .json
- Try the sample file first

### **Exercise Creation**
- All required fields must be filled
- Correct answer must be one of the options
- At least 2 options are required
- Exercise type must be selected

### **Performance**
- Large exercise sets may take time to load
- Consider breaking large imports into smaller files
- Restart app if experiencing slowdowns

## 📞 Support

If you encounter any issues or have suggestions:
1. Check this documentation first
2. Try the sample import file
3. Ensure your JSON format matches the example
4. Contact support with specific error messages

## 🎉 Getting Started

1. **Try the sample file** - Import `sample_dutch_words.json` to see the system in action
2. **Create your first exercise** - Start with a word you find challenging
3. **Practice regularly** - Use the exercises to reinforce learning
4. **Share with others** - Export and share your custom exercises

The Dutch Words system is designed to make learning difficult Dutch vocabulary more engaging and effective. Create personalized exercises, import existing sets, and track your progress as you master the Dutch language! 🇳🇱 