import 'package:dimensionleap/main.dart';
import 'package:dimensionleap/models/post.dart';
import 'package:flutter/material.dart';


class JobCardWidget extends StatelessWidget {

   final Post post;  
  final VoidCallback onToggleSave;

  const JobCardWidget({
    Key? key,
    required this.post,
    required this.onToggleSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format title for display
    String displayTitle = post.title.substring(0, 1).toUpperCase() + post.title.substring(1);
    if (displayTitle.length > 40) {
      displayTitle = displayTitle.substring(0, 40) + '...';
    }
    
    // Create company name
    String companyName = "Ora Apps Inc ${post.userId}";
    
    // Create location from body text
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
          // Header
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
                          onPressed: onToggleSave,
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
          
          // Metadata
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildJobMetaItem(Icons.location_on_outlined, location),
              _buildJobMetaItem(Icons.access_time, "2 to 8 yrs"),
              _buildJobMetaItem(Icons.attach_money, "Not Disclosed"),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
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
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color.fromARGB(255, 179, 213, 255),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
