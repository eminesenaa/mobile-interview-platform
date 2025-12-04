import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class CountrySelectorDropdown extends StatefulWidget {
  final Function(Country) onSelect;
  final Country? selected;

  const CountrySelectorDropdown({
    super.key,
    required this.onSelect,
    this.selected,
  });

  @override
  State<CountrySelectorDropdown> createState() => _CountrySelectorDropdownState();
}

class _CountrySelectorDropdownState extends State<CountrySelectorDropdown> {
  late List<Country> allCountries;
  late List<Country> filtered;

  @override
  void initState() {
    super.initState();
    allCountries = CountryService().getAll();
    filtered = List.from(allCountries);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 330,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SEARCH BAR
            TextField(
              onChanged: (q) {
                setState(() {
                  q = q.toLowerCase();
                  filtered = allCountries.where((c) {
                    return c.name.toLowerCase().contains(q) ||
                        c.countryCode.toLowerCase().contains(q) ||
                        "+${c.phoneCode}".contains(q);
                  }).toList();
                });
              },
              decoration: InputDecoration(
                hintText: "Search for countries",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // LIST (MAX 4)
            SizedBox(
              height: 240, // → tam 4 itemlik alan
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final c = filtered[index];
                  final isSelected = widget.selected?.countryCode == c.countryCode;

                  return InkWell(
                    onTap: () {
                      widget.onSelect(c);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Text(c.flagEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "${c.name} (+${c.phoneCode})",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check, color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
