// main.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GetJobApp());
}

class GetJobApp extends StatelessWidget {
  const GetJobApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetJob',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomePage(),
    );
  }
}

// Post model to handle the data structure from the API
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;
  bool isSaved;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
    this.isSaved = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  List<Post> _allPosts = [];
  List<Post> _recommendedPosts = [];
  List<Post> _suggestedPosts = [];
  List<Post> _alertPosts = [];
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Debounce implementation for search
  Timer? _debounce;
  
  @override
  void initState() {
    super.initState();
    _fetchPosts();
    
    // Add listeners for text changes with debouncing
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
  
  // Debounce method to delay search until user stops typing
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Apply filters
      _filterPosts();
    });
  }
  
  // Fetch posts from the API
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _allPosts = jsonData.map((data) => Post.fromJson(data)).toList();
        
        // Distribute posts to different sections
        _distributePosts();
      } else {
        setState(() {
          _errorMessage = 'Failed to load posts. Server responded with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching posts: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Distribute posts to different sections
  void _distributePosts() {
    if (_allPosts.isEmpty) return;
    
    setState(() {
      // Distribute posts evenly for display purposes
      _recommendedPosts = _allPosts.where((post) => post.id <= 33).toList();
      _suggestedPosts = _allPosts.where((post) => post.id > 33 && post.id <= 66).toList();
      _alertPosts = _allPosts.where((post) => post.id > 66).toList();
    });
  }
  
  // Filter posts based on search criteria
  void _filterPosts() {
    final String titleQuery = _titleController.text.toLowerCase();
    final String locationQuery = _locationController.text.toLowerCase();
    
    // If both fields are empty, reset to all posts
    if (titleQuery.isEmpty && locationQuery.isEmpty) {
      _distributePosts();
      setState(() {});
      return;
    }
    
    // Apply filters
    List<Post> filteredPosts = _allPosts.where((post) {
      bool matchesTitle = true;
      bool matchesLocation = true;
      
      if (titleQuery.isNotEmpty) {
        matchesTitle = post.title.toLowerCase().contains(titleQuery);
      }
      
      if (locationQuery.isNotEmpty) {
        // For demo purposes, we'll use the body text as a location proxy
        matchesLocation = post.body.toLowerCase().contains(locationQuery);
      }
      
      return matchesTitle && matchesLocation;
    }).toList();
    
    // Update displayed posts
    setState(() {
      // Distribute filtered posts evenly for display
      final int totalPosts = filteredPosts.length;
      final int postsPerSection = (totalPosts / 3).ceil();
      
      _recommendedPosts = filteredPosts.take(postsPerSection).toList();
      
      if (totalPosts > postsPerSection) {
        _suggestedPosts = filteredPosts.skip(postsPerSection).take(postsPerSection).toList();
      } else {
        _suggestedPosts = [];
      }
      
      if (totalPosts > postsPerSection * 2) {
        _alertPosts = filteredPosts.skip(postsPerSection * 2).toList();
      } else {
        _alertPosts = [];
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Top NavBar
                _buildNavBar(isDesktop),
                
                // Main Content
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Column(
                    children: [
                      // Content Area
                      if (!_isLoading)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 100 : 16, 
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column (Search + Jobs)
                              Expanded(
                                flex: isDesktop ? 7 : 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Search Section
                                    _buildSearchSection(isDesktop),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Recommended Jobs
                                    _buildJobsSection("Recommended Jobs", _recommendedPosts),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Suggested Jobs
                                    _buildJobsSection("Suggested Jobs", _suggestedPosts),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Job Alerts
                                    _buildJobAlertsSection(_alertPosts),
                                  ],
                                ),
                              ),
                              
                              // Profile & Right Sidebar (only shown on desktop)
                              if (isDesktop) 
                                const SizedBox(width: 20),
                              if (isDesktop)
                                Expanded(
                                  flex: 3,
                                  child: _buildProfileCard(),
                                ),
                            ],
                          ),
                        ),
                      
                      // Loading indicator
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      
                      // Error message if there's an error
                      if (_errorMessage.isNotEmpty)
                        Padding(
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
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavBar(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 16, 
        vertical: 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left navigation links
          Row(
            children: [
              // Home link
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Search Jobs link
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Search Jobs',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Companies link
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Companies',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Post Jobs link
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Post Jobs',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          
          // Logo (centered)
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
               
                 Image.asset('asset/100708567-removebg-preview.png',height: 50,),
                  const SizedBox(width: 8),
                  const Text(
                    'GetJob',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right side - notification and user
          Row(
            children: [
              // Notification Icon
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 24),
              
              // User Profile
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=John+Wick&background=random',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Hello, John Wick',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Fields
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              // Job Title Search
              Container(
                width: isDesktop ? 300 : double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'User Experience Designer',
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15, 
                      horizontal: 15,
                    ),
                  ),
                ),
              ),
              
              // Location Search
              Container(
                width: isDesktop ? 300 : double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    hintText: 'Hyattsville',
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.location_on_outlined),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.my_location, color: Colors.black, size: 20),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15, 
                      horizontal: 15,
                    ),
                  ),
                ),
              ),
              
              // Search Button
              ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2871FA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15, 
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              children: posts.map((post) => _buildDynamicJobCard(post)).toList(),
            ),
      ],
    );
  }

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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2871FA),
              ),
              child: const Text(
                'MANAGE ALERTS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        posts.isEmpty
          ? _buildEmptyState('No job alerts found matching your criteria.')
          : Column(
              children: posts.map((post) => _buildDynamicJobCard(post)).toList(),
            ),
      ],
    );
  }

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

  // Dynamic Job Card that uses actual data from the API
  Widget _buildDynamicJobCard(Post post) {
    // Format title for display - capitalize first letter
    String displayTitle = post.title.substring(0, 1).toUpperCase() + post.title.substring(1);
    if (displayTitle.length > 40) {
      displayTitle = displayTitle.substring(0, 40) + '...';
    }
    
    // Create company name from userId
    String companyName = "Ora Apps Inc ${post.userId}";
    
    // Create location from the first part of the body
    List<String> bodySentences = post.body.split('\n');
    String location = bodySentences.isNotEmpty 
        ? "Remote or ${bodySentences[0].substring(0, bodySentences[0].length > 20 ? 20 : bodySentences[0].length)}, MD, USA"
        : "Remote or Hyattsville, MD, USA";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: Center(
                  child: Text(
                    '${post.id}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: post.isSaved ? const Color(0xFF2871FA) : Colors.grey,
                            size: 22,
                          ),
                          onPressed: () => _toggleSavePost(post),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    Text(
                      companyName,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Job Metadata
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildJobMetaItem(Icons.location_on_outlined, location),
              _buildJobMetaItem(Icons.access_time, "2 to 8 yrs"),
              _buildJobMetaItem(Icons.attach_money, "Not Disclosed"),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Job Description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: const Color.fromARGB(255, 179, 213, 255),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.body,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color.fromARGB(255, 179, 213, 255),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://ui-avatars.com/api/?name=John+Wick+Paul&background=random&size=200',
            ),
          ),
          const SizedBox(height: 16),
          
          // Name and Title
          const Text(
            'John Wick Paul II',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Senior Data Base Analyst at\nOrr Appdata Inc',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Profile Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Update Resume',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),
          
          // Profile Completion
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Profile Completion',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Maintain your profile 100% to get more recruiter views',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Applied/Alerts Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Applied',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Jobs',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Custom',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Job Alerts',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}