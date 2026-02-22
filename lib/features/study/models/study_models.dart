class StudyMaterial {
  final String id;
  final String department;
  final String year;
  final String subjectName;
  final String category;
  final String title;
  final String? description;
  final String? fileUrl;
  final String? uploadedBy;
  final String? uploaderName;
  final DateTime? createdAt;

  StudyMaterial({
    required this.id,
    required this.department,
    required this.year,
    required this.subjectName,
    required this.category,
    required this.title,
    this.description,
    this.fileUrl,
    this.uploadedBy,
    this.uploaderName,
    this.createdAt,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) => StudyMaterial(
    id: json['id'] as String,
    department: json['department'] as String,
    year: json['year'] as String,
    subjectName: json['subjectName'] ?? json['subject_name'] as String,
    category: json['category'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    fileUrl: json['fileUrl'] ?? json['file_url'] as String?,
    uploadedBy: json['uploadedBy'] ?? json['uploaded_by'] as String?,
    uploaderName: json['uploaderName'] ?? json['uploader_name'] as String?,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
  );
}

const categoryLabels = <String, String>{
  'previous_year_papers': 'Previous Year Papers',
  'notes': 'Notes',
  'sessional_exams': 'Sessional Exams',
  'assignments': 'Assignments',
  'syllabus': 'Syllabus',
  'reference_books': 'Reference Books',
};
