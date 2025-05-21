import 'dart:async';
import 'package:dimensionleap/screens/widgets/app_bar_widget.dart';
import 'package:dimensionleap/screens/widgets/job_card_widget.dart';
import 'package:dimensionleap/screens/widgets/profile_widget.dart';
import 'package:dimensionleap/screens/widgets/search_widget.dart';
import 'package:dimensionleap/services/services.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Data
  List<Post> _allPosts = [];
  List<Post> _recommendedPosts = [];
  List<Post> _suggestedPosts = [];
  List<Post> _alertPosts = [];
  
  // State
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _debounce;
  
  @override
  void initState() {
    super.initState();
    _fetchPosts();
    
    // Add listeners for search
    _titleController.addListener(_onSearchChanged);
    _locationController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  // Debounce search
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterPosts();
    });
  }
  
  // Fetch posts from API
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      _allPosts = await ApiService.getPosts();
      _distributePosts();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Distribute posts to sections
  void _distributePosts() {
    if (_allPosts.isEmpty) return;
    
    setState(() {
      _recommendedPosts = _allPosts.where((post) => post.id <= 33).toList();
      _suggestedPosts = _allPosts.where((post) => post.id > 33 && post.id <= 66).toList();
      _alertPosts = _allPosts.where((post) => post.id > 66).toList();
    });
  }
  
  // Filter posts by search criteria
  void _filterPosts() {
    final String titleQuery = _titleController.text.toLowerCase();
    final String locationQuery = _locationController.text.toLowerCase();
    
    if (titleQuery.isEmpty && locationQuery.isEmpty) {
      _distributePosts();
      setState(() {});
      return;
    }
    
    List<Post> filteredPosts = _allPosts.where((post) {
      bool matchesTitle = titleQuery.isEmpty || post.title.toLowerCase().contains(titleQuery);
      bool matchesLocation = locationQuery.isEmpty || post.body.toLowerCase().contains(locationQuery);
      return matchesTitle && matchesLocation;
    }).toList();
    
    setState(() {
      final int totalPosts = filteredPosts.length;
      final int postsPerSection = (totalPosts / 3).ceil();
      
      _recommendedPosts = filteredPosts.take(postsPerSection).toList();
      _suggestedPosts = totalPosts > postsPerSection 
          ? filteredPosts.skip(postsPerSection).take(postsPerSection).toList() 
          : [];
      _alertPosts = totalPosts > postsPerSection * 2 
          ? filteredPosts.skip(postsPerSection * 2).toList() 
          : [];
    });
  }
  
  void _handleSearch() {
    _filterPosts();
  }

  void _toggleSavePost(Post post) {
    setState(() {
      post.isSaved = !post.isSaved;
    });
  }

  // Build job sections
  Widget _buildJobsSection(String title, List<Post> posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        posts.isEmpty
          ? _buildEmptyState('No jobs found matching your criteria.')
          : Column(
              children: posts.map((post) => JobCardWidget(
                post: post, 
                onToggleSave: () => _toggleSavePost(post),
              )).toList(),
            ),
      ],
    );
  }

  // Build job alerts section with manage button
  Widget _buildJobAlertsSection(List<Post> posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Job Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2871FA)),
              child: const Text(
                'MANAGE ALERTS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        posts.isEmpty
          ? _buildEmptyState('No job alerts found matching your criteria.')
          : Column(
              children: posts.map((post) => JobCardWidget(
                post: post, 
                onToggleSave: () => _toggleSavePost(post),
              )).toList(),
            ),
      ],
    );
  }

  // Empty state widget
  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Error message widget
  Widget _buildErrorMessage(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 16, 
        vertical: 20
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red.shade800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // App Bar
                AppBarWidget(isDesktop: isDesktop),
                
                // Loading
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                
                // Main Content
                if (!_isLoading)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Search + Jobs)
                        Expanded(
                          flex: isDesktop ? 7 : 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search
                              SearchWidget(
                                isDesktop: isDesktop,
                                titleController: _titleController,
                                locationController: _locationController,
                                onSearch: _handleSearch,
                              ),
                              const SizedBox(height: 20),
                              
                              // Job Sections
                              _buildJobsSection("Recommended Jobs", _recommendedPosts),
                              const SizedBox(height: 20),
                              _buildJobsSection("Suggested Jobs", _suggestedPosts),
                              const SizedBox(height: 20),
                              _buildJobAlertsSection(_alertPosts),
                            ],
                          ),
                        ),
                        
                        // Profile (Desktop only)
                        if (isDesktop) const SizedBox(width: 20),
                        if (isDesktop)
                          Expanded(
                            flex: 3,
                            child: ProfileWidget(),
                          ),
                      ],
                    ),
                  ),
                  
                // Error Message
                if (_errorMessage.isNotEmpty)
                  _buildErrorMessage(isDesktop),
              ],
            ),
          );
        },
      ),
    );
  }
}
