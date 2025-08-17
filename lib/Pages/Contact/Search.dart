import 'package:flutter/material.dart';
import 'package:whats_up/Pages/Contact/Widgets/Contact.dart';
import 'package:whats_up/Pages/Contact/Widgets/ListContact.dart';
import 'package:whats_up/Pages/Contact/Widgets/TabBarSearch.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin {
  final FocusNode _nodeSearch = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _showClearIcon = false;
  late TabController _tabController;

  OverlayEntry? _contactOverlay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _controller.addListener(() {
      setState(() {
        _showClearIcon = _controller.text.isNotEmpty;
      });
    });

    _nodeSearch.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nodeSearch.dispose();
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showContactPopup(BuildContext context) {
    final overlay = Overlay.of(context);
    final width = MediaQuery.of(context).size.width;

    _contactOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hidePopup,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 50,
            left: width / 2,
            right: 12,
            child: const ContactPopup(),
          ),
        ],
      ),
    );

    overlay.insert(_contactOverlay!);
  }

  void _hidePopup() {
    _contactOverlay?.remove();
    _contactOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall!.copyWith(
          color: colorScheme.onPrimary,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text("Search contact", style: Theme.of(context).textTheme.bodySmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, size: 28),
            onPressed: () {
              if (_contactOverlay == null) {
                _showContactPopup(context);
              } else {
                _hidePopup();
              }
            },
          ),
        ],
        bottom: TabBarSearch(_tabController, context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.onPrimaryContainer,
              ),
              child: Row(
                children: [
                  Icon(Icons.person_search_sharp, size: 26, color: colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _nodeSearch,
                      style: textStyle,
                      cursorColor: colorScheme.primary,
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm liên hệ...",
                        hintStyle: textStyle.copyWith(color: colorScheme.onPrimary.withOpacity(0.6)),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        fillColor: colorScheme.onPrimaryContainer,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        suffixIcon: _showClearIcon
                            ? IconButton(
                                icon: Icon(Icons.close, color: colorScheme.onPrimary),
                                onPressed: () {
                                  _controller.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : Icon(Icons.qr_code_scanner_sharp, color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// TabBarView cần được đặt trong Expanded
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ListContact(),
                Center(child: Text("Groups")),
                Center(child: Text("Calls")),
                Center(child: Text("More")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
