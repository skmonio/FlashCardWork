#!/usr/bin/env python3
"""
Swift to JSON Converter for Dutch Vocabulary Packs

This script helps convert the DutchVocabularyPacks.swift file to JSON format.
It parses the Swift data structures and creates a JSON file with the same information.
"""

import json
import re
from typing import Dict, List, Any
from datetime import datetime

class SwiftToJsonConverter:
    def __init__(self):
        self.levels = [
            {"id": "A1", "name": "Beginner", "description": "Basic everyday words"},
            {"id": "A2", "name": "Elementary", "description": "Expanding vocabulary"},
            {"id": "B1", "name": "Intermediate", "description": "Complex concepts"}
        ]
        
        self.categories = [
            {"id": "family", "name": "Family", "dutchName": "Familie"},
            {"id": "food", "name": "Food and Drink", "dutchName": "Eten en Drinken"},
            {"id": "home", "name": "House and Living", "dutchName": "Huis en Wonen"},
            {"id": "work", "name": "Work and Professions", "dutchName": "Werk en Beroepen"},
            {"id": "travel", "name": "Travel and Transport", "dutchName": "Reizen en Transport"},
            {"id": "time", "name": "Time and Date", "dutchName": "Tijd en Datum"},
            {"id": "weather", "name": "Weather and Seasons", "dutchName": "Weer en Seizoenen"},
            {"id": "body", "name": "Body and Health", "dutchName": "Lichaam en Gezondheid"},
            {"id": "clothing", "name": "Clothing", "dutchName": "Kleding"},
            {"id": "animals", "name": "Animals", "dutchName": "Dieren"},
            {"id": "colors", "name": "Colors", "dutchName": "Kleuren"},
            {"id": "numbers", "name": "Numbers", "dutchName": "Getallen"},
            {"id": "verbs", "name": "Verbs", "dutchName": "Werkwoorden"},
            {"id": "adjectives", "name": "Adjectives", "dutchName": "Bijvoeglijke Naamwoorden"},
            {"id": "emotions", "name": "Emotions and Feelings", "dutchName": "Emoties en Gevoelens"},
            {"id": "education", "name": "Education", "dutchName": "Onderwijs"},
            {"id": "technology", "name": "Technology", "dutchName": "Technologie"},
            {"id": "sports", "name": "Sports and Hobbies", "dutchName": "Sport en Hobby's"},
            {"id": "shopping", "name": "Shopping", "dutchName": "Winkelen"},
            {"id": "nature", "name": "Nature", "dutchName": "Natuur"},
            {"id": "business", "name": "Business and Office", "dutchName": "Zakelijk en Kantoor"},
            {"id": "medical", "name": "Medical and Health", "dutchName": "Medisch en Gezondheid"},
            {"id": "politics", "name": "Politics and Society", "dutchName": "Politiek en Maatschappij"},
            {"id": "culture", "name": "Culture and Art", "dutchName": "Cultuur en Kunst"},
            {"id": "media", "name": "Media and Communication", "dutchName": "Media en Communicatie"},
            {"id": "science", "name": "Science and Research", "dutchName": "Wetenschap en Onderzoek"},
            {"id": "environment", "name": "Environment and Sustainability", "dutchName": "Milieu en Duurzaamheid"},
            {"id": "finance", "name": "Finance and Money", "dutchName": "Financiën en Geld"},
            {"id": "relationships", "name": "Relationships and Friendship", "dutchName": "Relaties en Vriendschap"},
            {"id": "personality", "name": "Personality and Character", "dutchName": "Persoonlijkheid en Karakter"},
            {"id": "cooking", "name": "Cooking and Recipes", "dutchName": "Koken en Recepten"},
            {"id": "transportation", "name": "Transport and Traffic", "dutchName": "Vervoer en Transport"},
            {"id": "entertainment", "name": "Entertainment and Leisure", "dutchName": "Entertainment en Vrije Tijd"},
            {"id": "law", "name": "Law and Legal", "dutchName": "Recht en Juridisch"}
        ]
        
        self.word_types = [
            {"id": "noun", "name": "Noun", "dutchName": "Zelfstandig naamwoord"},
            {"id": "verb", "name": "Verb", "dutchName": "Werkwoord"},
            {"id": "adjective", "name": "Adjective", "dutchName": "Bijvoeglijk naamwoord"},
            {"id": "adverb", "name": "Adverb", "dutchName": "Bijwoord"},
            {"id": "preposition", "name": "Preposition", "dutchName": "Voorzetsel"},
            {"id": "conjunction", "name": "Conjunction", "dutchName": "Voegwoord"},
            {"id": "pronoun", "name": "Pronoun", "dutchName": "Voornaamwoord"},
            {"id": "interjection", "name": "Interjection", "dutchName": "Tussenwerpsel"}
        ]

    def parse_dutch_word(self, word_text: str) -> Dict[str, Any]:
        """Parse a DutchWord structure from Swift text"""
        word_data = {}
        
        # Extract word properties using regex patterns
        patterns = {
            'word': r'word:\s*"([^"]*)"',
            'article': r'article:\s*"([^"]*)"',
            'definition': r'definition:\s*"([^"]*)"',
            'example': r'example:\s*"([^"]*)"',
            'plural': r'plural:\s*"([^"]*)"',
            'pastTense': r'pastTense:\s*"([^"]*)"',
            'futureTense': r'futureTense:\s*"([^"]*)"',
            'pastParticiple': r'pastParticiple:\s*"([^"]*)"',
            'wordType': r'wordType:\s*\.(\w+)',
            'level': r'level:\s*\.(\w+)',
            'category': r'category:\s*\.(\w+)'
        }
        
        for key, pattern in patterns.items():
            match = re.search(pattern, word_text)
            if match:
                value = match.group(1)
                # Convert Swift enum values to string
                if key in ['level']:
                    value = value.upper()
                word_data[key] = value
            else:
                word_data[key] = ""
        
        return word_data

    def parse_vocabulary_pack(self, pack_text: str) -> Dict[str, Any]:
        """Parse a DutchVocabularyPack from Swift text"""
        pack_data = {}
        
        # Extract pack properties with more flexible patterns
        name_match = re.search(r'name:\s*"([^"]*)"', pack_text, re.MULTILINE)
        if name_match:
            pack_data['name'] = name_match.group(1)
            pack_data['id'] = self.generate_id_from_name(pack_data['name'])
        
        level_match = re.search(r'level:\s*\.(\w+)', pack_text, re.MULTILINE)
        if level_match:
            pack_data['level'] = level_match.group(1).upper()
        
        category_match = re.search(r'category:\s*\.(\w+)', pack_text, re.MULTILINE)
        if category_match:
            pack_data['category'] = category_match.group(1)
        
        description_match = re.search(r'description:\s*"([^"]*)"', pack_text, re.MULTILINE)
        if description_match:
            pack_data['description'] = description_match.group(1)
        
        # Extract words array - more robust pattern
        words_match = re.search(r'words:\s*\[(.*?)\](?=\s*,\s*description)', pack_text, re.DOTALL)
        if words_match:
            words_text = words_match.group(1)
            # Find all DutchWord instances
            word_pattern = r'DutchWord\s*\((.*?)\s*\)(?=\s*(?:,\s*DutchWord|\s*\]|$))'
            word_matches = re.findall(word_pattern, words_text, re.DOTALL)
            
            pack_data['words'] = []
            for word_match in word_matches:
                word_data = self.parse_dutch_word(word_match)
                if word_data.get('word'):  # Only add if word is not empty
                    pack_data['words'].append(word_data)
        else:
            pack_data['words'] = []
        
        return pack_data

    def generate_id_from_name(self, name: str) -> str:
        """Generate a consistent ID from a vocabulary pack name"""
        # Remove (A1), (A2), (B1) and convert to lowercase with underscores
        clean_name = re.sub(r'\s*\([A-B][0-9]\)\s*', '', name)
        clean_name = re.sub(r'[^\w\s]', '', clean_name)  # Remove special chars
        clean_name = re.sub(r'\s+', '_', clean_name.strip())  # Replace spaces with underscores
        return clean_name.lower()

    def convert_swift_file(self, swift_file_path: str, output_file_path: str):
        """Convert Swift file to JSON"""
        try:
            with open(swift_file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            print(f"File size: {len(content)} characters")
            
            # Find all lazy var vocabulary pack definitions - improved pattern
            pack_pattern = r'lazy\s+var\s+\w+\s*=\s*DutchVocabularyPack\s*\((.*?)\)(?=\s*(?:lazy\s+var|\s*}\s*(?://|$)|\s*//|\s*$))'
            pack_matches = re.findall(pack_pattern, content, re.DOTALL)
            
            print(f"Found {len(pack_matches)} potential vocabulary pack matches")
            
            vocabulary_packs = []
            for i, pack_match in enumerate(pack_matches):
                print(f"Processing pack {i+1}...")
                pack_data = self.parse_vocabulary_pack(pack_match)
                if pack_data.get('name'):  # Only add if pack has a name
                    vocabulary_packs.append(pack_data)
                    print(f"  Successfully parsed: {pack_data['name']} ({len(pack_data.get('words', []))} words)")
                else:
                    print(f"  Failed to parse pack {i+1}")
            
            # Create the complete JSON structure
            json_data = {
                "metadata": {
                    "version": "1.0.0",
                    "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
                    "language": "Dutch",
                    "targetLanguage": "English"
                },
                "levels": self.levels,
                "categories": self.categories,
                "wordTypes": self.word_types,
                "vocabularyPacks": vocabulary_packs
            }
            
            # Write to JSON file
            with open(output_file_path, 'w', encoding='utf-8') as file:
                json.dump(json_data, file, indent=2, ensure_ascii=False)
            
            print(f"Successfully converted {len(vocabulary_packs)} vocabulary packs to {output_file_path}")
            print(f"Total words converted: {sum(len(pack.get('words', [])) for pack in vocabulary_packs)}")
            
        except FileNotFoundError:
            print(f"Error: Swift file not found at {swift_file_path}")
        except Exception as e:
            print(f"Error during conversion: {e}")
            import traceback
            traceback.print_exc()

    def validate_json(self, json_file_path: str) -> bool:
        """Validate the generated JSON file"""
        try:
            with open(json_file_path, 'r', encoding='utf-8') as file:
                data = json.load(file)
            
            # Basic validation
            required_keys = ['metadata', 'levels', 'categories', 'wordTypes', 'vocabularyPacks']
            for key in required_keys:
                if key not in data:
                    print(f"Validation error: Missing required key '{key}'")
                    return False
            
            # Validate vocabulary packs
            for pack in data['vocabularyPacks']:
                if not all(key in pack for key in ['id', 'name', 'level', 'category', 'words']):
                    print(f"Validation error: Vocabulary pack missing required fields")
                    return False
                
                for word in pack['words']:
                    if not all(key in word for key in ['word', 'definition', 'wordType']):
                        print(f"Validation error: Word missing required fields in pack '{pack['name']}'")
                        return False
            
            print("JSON validation successful!")
            return True
            
        except json.JSONDecodeError as e:
            print(f"JSON validation error: {e}")
            return False
        except Exception as e:
            print(f"Validation error: {e}")
            return False

def main():
    """Main conversion function"""
    converter = SwiftToJsonConverter()
    
    # File paths
    swift_file = "FlashCard/Data/DutchVocabularyPacks.swift"
    json_file = "dutch_vocabulary_complete.json"
    
    print("Converting DutchVocabularyPacks.swift to JSON...")
    converter.convert_swift_file(swift_file, json_file)
    
    print("\nValidating generated JSON...")
    converter.validate_json(json_file)
    
    print(f"\nConversion complete! Check {json_file} for the results.")

if __name__ == "__main__":
    main() 