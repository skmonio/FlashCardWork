#!/usr/bin/env python3
"""
Vocabulary Analysis Script

This script analyzes the converted Dutch vocabulary JSON file and provides statistics.
"""

import json
from collections import defaultdict, Counter

def analyze_vocabulary(json_file_path: str):
    """Analyze the vocabulary JSON file and print statistics"""
    
    try:
        with open(json_file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
        
        print("=" * 60)
        print("DUTCH VOCABULARY ANALYSIS")
        print("=" * 60)
        
        # Basic metadata
        metadata = data.get('metadata', {})
        print(f"Version: {metadata.get('version', 'Unknown')}")
        print(f"Last Updated: {metadata.get('lastUpdated', 'Unknown')}")
        print(f"Language: {metadata.get('language', 'Unknown')} → {metadata.get('targetLanguage', 'Unknown')}")
        print()
        
        # Vocabulary packs statistics
        packs = data.get('vocabularyPacks', [])
        print(f"📚 VOCABULARY PACKS: {len(packs)}")
        print("-" * 40)
        
        # Count by level
        level_counts = defaultdict(int)
        level_words = defaultdict(int)
        category_counts = defaultdict(int)
        word_type_counts = defaultdict(int)
        
        total_words = 0
        
        for pack in packs:
            level = pack.get('level', 'Unknown')
            category = pack.get('category', 'Unknown')
            words = pack.get('words', [])
            
            level_counts[level] += 1
            level_words[level] += len(words)
            category_counts[category] += len(words)
            total_words += len(words)
            
            # Count word types
            for word in words:
                word_type = word.get('wordType', 'Unknown')
                word_type_counts[word_type] += 1
        
        print(f"Total Words: {total_words}")
        print()
        
        # Level distribution
        print("📊 BY LEVEL:")
        for level in ['A1', 'A2', 'B1']:
            packs_count = level_counts.get(level, 0)
            words_count = level_words.get(level, 0)
            print(f"  {level}: {packs_count} packs, {words_count} words")
        print()
        
        # Top categories
        print("🏷️  TOP CATEGORIES:")
        sorted_categories = sorted(category_counts.items(), key=lambda x: x[1], reverse=True)
        for category, count in sorted_categories[:10]:
            print(f"  {category}: {count} words")
        print()
        
        # Word types distribution
        print("📝 WORD TYPES:")
        sorted_types = sorted(word_type_counts.items(), key=lambda x: x[1], reverse=True)
        for word_type, count in sorted_types:
            percentage = (count / total_words) * 100
            print(f"  {word_type}: {count} words ({percentage:.1f}%)")
        print()
        
        # Sample vocabulary packs
        print("📋 SAMPLE VOCABULARY PACKS:")
        print("-" * 40)
        for i, pack in enumerate(packs[:5]):
            words_count = len(pack.get('words', []))
            print(f"{i+1}. {pack.get('name', 'Unknown')} ({pack.get('level', '?')}) - {words_count} words")
            print(f"   Category: {pack.get('category', 'Unknown')}")
            print(f"   Description: {pack.get('description', 'No description')}")
            
            # Show first few words
            words = pack.get('words', [])[:3]
            if words:
                print("   Sample words:")
                for word in words:
                    article = word.get('article', '')
                    article_text = f" ({article})" if article else ""
                    print(f"     • {word.get('word', '')}{article_text} - {word.get('definition', '')}")
            print()
        
        # Data quality checks
        print("✅ DATA QUALITY CHECKS:")
        print("-" * 40)
        
        # Check for missing data
        missing_definitions = 0
        missing_examples = 0
        missing_articles = 0
        
        for pack in packs:
            for word in pack.get('words', []):
                if not word.get('definition', '').strip():
                    missing_definitions += 1
                if not word.get('example', '').strip():
                    missing_examples += 1
                if word.get('wordType') == 'noun' and not word.get('article', '').strip():
                    missing_articles += 1
        
        print(f"Missing definitions: {missing_definitions}")
        print(f"Missing examples: {missing_examples}")
        print(f"Missing articles (nouns): {missing_articles}")
        
        # Calculate completeness
        completeness = ((total_words - missing_definitions) / total_words) * 100 if total_words > 0 else 0
        print(f"Definition completeness: {completeness:.1f}%")
        
        # File size info
        import os
        file_size = os.path.getsize(json_file_path)
        print(f"File size: {file_size:,} bytes ({file_size / 1024 / 1024:.1f} MB)")
        
        print()
        print("=" * 60)
        print("CONVERSION SUCCESSFUL! 🎉")
        print("=" * 60)
        print("Your Dutch vocabulary data has been successfully converted to JSON format.")
        print("The data is now portable and can be used across different platforms and applications.")
        
    except FileNotFoundError:
        print(f"Error: JSON file not found at {json_file_path}")
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON format - {e}")
    except Exception as e:
        print(f"Error analyzing vocabulary: {e}")

def main():
    """Main analysis function"""
    json_file = "dutch_vocabulary_complete.json"
    analyze_vocabulary(json_file)

if __name__ == "__main__":
    main() 