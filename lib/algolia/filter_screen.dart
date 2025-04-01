import 'package:ctown/algolia/search_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'expandable_headerview.dart';
import 'filter_footerview.dart';
import 'filter_headerview.dart';


class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

enum FiltersSection { none, sort, brand, size }

class _FiltersScreenState extends State<FiltersScreen> {
  FiltersSection activeSection = FiltersSection.none;

  bool _isActive(FiltersSection section) => section == activeSection;

  @override
  Widget build(BuildContext context) {
    final searchRepository = context.read<SearchRepository>();
    return Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
            left: 10,
            right: 10),
        child: Column(
          children: [
            const FiltersHeaderView(),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _brandHeader(),
                  if (_isActive(FiltersSection.brand))
                    const SizedBox.shrink()
                    // CategoryFilterView(
                    //   facets: searchRepository.brandFacets,
                    //   onToggle: searchRepository.toggleBrand,
                    // ),
                ],
              ),
            ),
            const Divider(),
            FiltersFooterView(
              metadata: searchRepository.searchMetadata,
              onClear: searchRepository.clearFilters,
            ),
          ],
        ));
  }

  Widget _brandHeader() {
    const section = FiltersSection.brand;
    return ExpandableHeaderView(
      title: const Text('Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      isActive: _isActive(section),
      onToggle: () => _toggleSection(section),
    );
  }

  _toggleSection(FiltersSection section) => setState(
          () => activeSection = _isActive(section) ? FiltersSection.none : section);
}
