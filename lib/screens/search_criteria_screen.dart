import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'schools_screen.dart';
import 'thematic_map_screen.dart';

class SearchCriteriaScreen extends StatefulWidget {
  const SearchCriteriaScreen({super.key});

  @override
  State<SearchCriteriaScreen> createState() => _SearchCriteriaScreenState();
}

class _SearchCriteriaScreenState extends State<SearchCriteriaScreen> {
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedArea;
  String? _selectedSchoolType;
  String? _selectedPrimaryLanguage;
  String? _selectedSecondLanguage;

  bool _attemptedSubmit = false;

  final List<String> _categories = [
    'Boys only',
    'Girls only',
    'Both Boys and Girls',
  ];

  final List<String> _cities = [
    'Alexandria',
    'Aswan',
    'Asyut',
    'Beheira',
    'Beni Suef',
    'Cairo',
    'Dakahlia',
    'Damietta',
    'Faiyum',
    'Gharbia',
    'Giza',
    'Ismailia',
    'Kafr El Sheikh',
    'Luxor',
    'Matrouh',
    'Minya',
    'Monufia',
    'New Valley',
    'North Sinai',
    'Port Said',
    'Qalyubia',
    'Qena',
    'Red Sea',
    'Sharqia',
    'Sohag',
    'South Sinai',
    'Suez',
  ];

  final Map<String, List<String>> _cityAreas = {
    'Alexandria': ['Alexandria'],
    'Aswan': ['Aswan', 'Edfu', 'Kom Ombo'],
    'Asyut': ['Asyut', 'Abnub', 'Dayrut', 'Manfalut'],
    'Beheira': ['Damanhur', 'Rashid', 'Kafr El-Dawwar'],
    'Beni Suef': ['Beni Suef', 'Al Wasta', 'Naba'],
    'Cairo': ['Cairo', 'New Cairo', 'Helwan', 'Shubra El-Kheima'],
    'Dakahlia': ['Mansoura', 'Mit Ghamr', 'Talkha'],
    'Damietta': ['Damietta', 'Kafr Saad'],
    'Faiyum': ['Faiyum', 'Itsa', 'Tamiya'],
    'Gharbia': ['Tanta', 'Mahalla El-Kubra', 'Samanoud'],
    'Giza': ['Giza', '6th of October', 'Sheikh Zayed'],
    'Ismailia': ['Ismailia', 'Fayed'],
    'Kafr El Sheikh': ['Kafr El Sheikh', 'Fuwa', 'Desouk'],
    'Luxor': ['Luxor'],
    'Matrouh': ['Mersa Matruh', 'Siwa Oasis'],
    'Minya': ['Minya', 'Mallawi', 'Samalut'],
    'Monufia': ['Shibin El Kom', 'Menouf', 'Quesna'],
    'New Valley': ['Kharga', 'Dakhla Oasis', 'Balat'],
    'North Sinai': ['Arish', 'Rafah', 'El Hassana'],
    'Port Said': ['Port Said'],
    'Qalyubia': ['Banha', 'Qalyub', 'Shibin El Qanater'],
    'Qena': ['Qena', 'Nag Hammadi', 'Deshna'],
    'Red Sea': ['Hurghada', 'Marsa Alam', 'Safaga'],
    'Sharqia': ['Zagazig', '10th of Ramadan', 'Faqous'],
    'Sohag': ['Sohag', 'Tahta', 'Akhmim'],
    'South Sinai': ['El Tor', 'Sharm El Sheikh', 'Dahab'],
    'Suez': ['Suez'],
  };

  final List<String> _schoolTypes = [
    'National',
    'International',
    'American',
    'IG',
  ];

  final List<String> _primaryLanguages = ['English', 'Arabic', 'French'];

  final List<String> _secondLanguages = ['English', 'French', 'German'];

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool disabled = false,
    bool hasError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: disabled ? Colors.grey.shade300 : const Color(0xFFF0F0F0),
              border: Border.all(
                color: hasError ? Colors.red : Colors.black87, 
                width: hasError ? 2.0 : 1.0,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                icon: const SizedBox.shrink(), // Hide default icon
                onChanged: disabled ? null : onChanged,
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((String item) {
                    return _buildDropdownDisplayedValue(label, value, disabled);
                  }).toList();
                },
                hint: _buildDropdownDisplayedValue(label, value, disabled),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 4.0),
              child: Text(
                'Please select $label',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // New helper to build the row layout with tap blocking on the left
  Widget _buildDropdownDisplayedValue(String label, String? value, bool disabled) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Do nothing - this blocks the dropdown from opening when clicking the text
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                value != null ? "$label: $value" : label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        Container(width: 1, height: 48, color: Colors.black87),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
            size: 30,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Top illustration
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF9F9F9), // subtle circle behind image
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/kid_illustration.png',
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if the image isn't placed yet
                      return const Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.blueGrey,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildDropdown(
                label: 'Student Gender',
                value: _selectedCategory,
                items: _categories,
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                hasError: _attemptedSubmit && _selectedCategory == null,
              ),
              _buildDropdown(
                label: 'City',
                value: _selectedCity,
                items: _cities,
                onChanged: (val) {
                  setState(() {
                    _selectedCity = val;
                    _selectedArea = null; // Reset area when city changes
                  });
                },
                hasError: _attemptedSubmit && _selectedCity == null,
              ),
              _buildDropdown(
                label: 'Area',
                value: _selectedArea,
                items: _selectedCity != null
                    ? (_cityAreas[_selectedCity] ?? [])
                    : [],
                onChanged: (val) {
                  setState(() {
                    _selectedArea = val;
                  });
                },
                disabled: _selectedCity == null,
                hasError: _attemptedSubmit && _selectedArea == null && _selectedCity != null,
              ),
              _buildDropdown(
                label: 'School Type',
                value: _selectedSchoolType,
                items: _schoolTypes,
                onChanged: (val) {
                  setState(() {
                    _selectedSchoolType = val;
                  });
                },
                hasError: _attemptedSubmit && _selectedSchoolType == null,
              ),
              _buildDropdown(
                label: 'Primary Language',
                value: _selectedPrimaryLanguage,
                items: _primaryLanguages,
                onChanged: (val) {
                  setState(() {
                    _selectedPrimaryLanguage = val;
                  });
                },
                hasError: _attemptedSubmit && _selectedPrimaryLanguage == null,
              ),
              _buildDropdown(
                label: 'Second Language',
                value: _selectedSecondLanguage,
                items: _secondLanguages,
                onChanged: (val) {
                  setState(() {
                    _selectedSecondLanguage = val;
                  });
                },
                hasError: _attemptedSubmit && _selectedSecondLanguage == null,
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _attemptedSubmit = true;
                    });
                    
                    if (_selectedCategory == null ||
                        _selectedCity == null ||
                        _selectedArea == null ||
                        _selectedSchoolType == null ||
                        _selectedPrimaryLanguage == null ||
                        _selectedSecondLanguage == null) {
                      // Stop here and show a quick snackbar just in case
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select all required options.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SchoolsScreen(
                          city: _selectedCity,
                          area: _selectedArea,
                          category: _selectedCategory,
                          schoolType: _selectedSchoolType,
                          primaryLanguage: _selectedPrimaryLanguage,
                          secondLanguage: _selectedSecondLanguage,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'submit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => NotificationsScreen()));
          } else if (index == 2) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => ThematicMapScreen()));
          } else if (index == 3) {
            // Already here, but for consistency:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => SearchCriteriaScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFD6EBE8), // matching the light teal
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_outlined),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Map'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
        ],
      ),
    );
  }
}

