import 'package:flutter/material.dart';
import 'package:pfe_test/models/learning_path_model.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'concept_detail_screen.dart';

class LearningPathScreen extends StatefulWidget {
  final LearningPath learningPath;

  const LearningPathScreen({
    super.key,
    required this.learningPath,
  });

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.learningPath.language} Learning Path'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Milestones'),
            Tab(text: 'Concepts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMilestonesTab(),
          _buildConceptsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Overall Progress
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha:  0.7),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: widget.learningPath.overallProgressPercentage /
                            100,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha:0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.learningPath.overallProgressPercentage}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Complete',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Completed',
                      '${widget.learningPath.totalConceptsCompleted}',
                      Colors.white,
                    ),
                    _buildStatItem(
                      'Remaining',
                      '${widget.learningPath.remainingConcepts}',
                      Colors.white,
                    ),
                    _buildStatItem(
                      'Total',
                      '${widget.learningPath.totalConcepts}',
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Level and Time Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Learning Journey',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha:0.2),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Current Level',
                        widget.learningPath.currentLevel,
                        '🎓',
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Started',
                        _formatDate(widget.learningPath.startedAt),
                        '📅',
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Milestones Completed',
                        '${widget.learningPath.completedMilestones}/${widget.learningPath.milestones.length}',
                        '🏆',
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Unlocked Milestones',
                        '${widget.learningPath.unlockedMilestones}/${widget.learningPath.milestones.length}',
                        '🔓',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Next Steps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Steps',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildNextStepCard(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.learningPath.milestones.length,
      itemBuilder: (context, index) {
        final milestone = widget.learningPath.milestones[index];
        return _buildMilestoneCard(milestone, index);
      },
    );
  }

  Widget _buildConceptsTab() {
    // Group concepts by status
    final completedConcepts =
        widget.learningPath.concepts.where((c) => c.isCompleted).toList();
    final inProgressConcepts = widget.learningPath.concepts
        .where((c) => !c.isCompleted && c.completionPercentage > 0)
        .toList();
    final remainingConcepts = widget.learningPath.concepts
        .where((c) => !c.isCompleted && c.completionPercentage == 0)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (completedConcepts.isNotEmpty)
            _buildConceptSection(
              'Completed',
              completedConcepts,
              Colors.green,
              '✅',
            ),
          if (inProgressConcepts.isNotEmpty)
            _buildConceptSection(
              'In Progress',
              inProgressConcepts,
              Colors.orange,
              '⏳',
            ),
          if (remainingConcepts.isNotEmpty)
            _buildConceptSection(
              'Not Started',
              remainingConcepts,
              Colors.grey,
              '🔒',
            ),
        ],
      ),
    );
  }

  Widget _buildConceptSection(
    String title,
    List<Concept> concepts,
    Color color,
    String emoji,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '${concepts.length}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...concepts.map((concept) => _buildConceptTile(concept)),
        ],
      ),
    );
  }

  Widget _buildConceptTile(Concept concept) {
    final isLocked = concept.completionPercentage == 0 &&
        concept.prerequisites.isNotEmpty &&
        !concept.prerequisites.every((id) =>
            widget.learningPath.concepts
                .firstWhere((c) => c.id == id)
                .isCompleted);

    return GestureDetector(
      onTap: !isLocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConceptDetailScreen(
                    concept: concept,
                    learningPath: widget.learningPath,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked
                ? Colors.grey.withValues(alpha: 0.3)
                : AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
         // opacity: isLocked ? 0.6 : 1,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  concept.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        concept.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        concept.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLocked)
                  const Icon(Icons.lock, size: 20, color: Colors.grey)
                else if (concept.isCompleted)
                  const Icon(Icons.check_circle,
                      size: 20, color: Colors.green)
                else
                  Text(
                    '${concept.completionPercentage}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: concept.completionPercentage / 100,
                minHeight: 6,
                backgroundColor: Colors.grey.withValues(alpha:0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  concept.isCompleted
                      ? Colors.green
                      : AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(LearningPathMilestone milestone, int index) {
    final isLocked = !milestone.isUnlocked;
    final relatedConcepts = widget.learningPath.concepts
        .where((c) => milestone.conceptIds.contains(c.id))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: milestone.isCompleted
              ? Colors.green.withValues(alpha:0.3)
              : isLocked
                  ? Colors.grey.withValues(alpha:0.2)
                  : AppTheme.primaryColor.withValues(alpha:0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Milestone Header
          Container(
            decoration: BoxDecoration(
              color: milestone.isCompleted
                  ? Colors.green.withValues(alpha:0.1)
                  : isLocked
                      ? Colors.grey.withValues(alpha:0.1)
                      : AppTheme.primaryColor.withValues(alpha:0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      milestone.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Milestone ${index + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          Text(
                            milestone.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (milestone.isCompleted)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 28)
                    else if (isLocked)
                      const Icon(Icons.lock, color: Colors.grey, size: 28)
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha:0.2),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '${milestone.completionPercentage}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  milestone.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${milestone.completionPercentage}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: milestone.completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withValues(alpha:0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      milestone.isCompleted
                          ? Colors.green
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Related Concepts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Concepts (${relatedConcepts.length})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: relatedConcepts
                      .map((concept) => Container(
                            decoration: BoxDecoration(
                              color: concept.isCompleted
                                  ? Colors.green.withValues(alpha:0.2)
                                  : AppTheme.primaryColor.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(concept.icon),
                                const SizedBox(width: 4),
                                Text(
                                  concept.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNextStepCard() {
    final nextConcept = widget.learningPath.concepts
        .firstWhere(
          (c) =>
              !c.isCompleted &&
              c.completionPercentage == 0 &&
              (c.prerequisites.isEmpty ||
                  c.prerequisites.every((id) =>
                      widget.learningPath.concepts
                          .firstWhere((concept) => concept.id == id)
                          .isCompleted)),
          orElse: () => widget.learningPath.concepts.first,
        );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConceptDetailScreen(
              concept: nextConcept,
              learningPath: widget.learningPath,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha:0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  nextConcept.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Continue Learning',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        nextConcept.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              nextConcept.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha:0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, String emoji) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
