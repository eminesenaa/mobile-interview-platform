// ===================== File: open_positions_controller.dart =====================
// Purpose:
// Controls Open Positions (Browse All) page
//
// Responsibilities:
// - Provide job postings list
// - Handle search (title-based)
// - Handle filtering (level / type)
// - Expose filtered list to UI
//
// IMPORTANT:
// - Uses mock data for now
// - Designed to be backend-ready
//
// TODO (Backend):
// - Replace mock data with API call
// - Move filtering to backend if needed
// - Add pagination
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpenPositionsController extends GetxController {
  // ===============================
  // DATA
  // ===============================

  /// All jobs (raw)
  final jobs = <Map<String, dynamic>>[].obs;

  /// Filtered jobs (UI uses this)
  final filteredJobs = <Map<String, dynamic>>[].obs;

  // ===============================
  // SEARCH & FILTER STATE
  // ===============================

  final searchQuery = "".obs;
  final selectedFilter = "All Roles".obs;

  // ===============================
  // APPLY FORM STATE
  // ===============================

  // CONTACT
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  // APPLICATION INFO
  final universityCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();

  // LINKS (optional)
  final portfolioCtrl = TextEditingController();
  final githubCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();

  // SKILLS
  final skillCtrl = TextEditingController();
  final skills = <String>[].obs;

  // RESUME
  final selectedResume = Rxn<String>(); // (şimdilik path/string)

  // ===============================
  // SELECTED JOB (DETAIL PAGE)
  // ===============================

  /// Currently selected job (for detail page)
  final selectedJob = Rxn<Map<String, dynamic>>();

  // ===============================
  // FILTER OPTIONS
  // ===============================

  final filters = [
    "All Roles",
    "Remote",
    "Senior",
    "Mid-Level",
    "Intern",
  ];

  // ===============================
  // LIFECYCLE
  // ===============================

  @override
  void onInit() {
    super.onInit();

    // ===============================
    // GET JOB FROM NAVIGATION
    // ===============================
    if (Get.arguments != null) {
      selectedJob.value = Get.arguments;
    }

    loadMockData();
    applyFilters();

    // TODO: fetch from backend
    fetchJobs();
  }

  // ===============================
  // MOCK DATA (RICH)
  // ===============================

  void loadMockData() {
    jobs.value = [
      {
        "id": "JP-1",
        "title": "Frontend Developer",
        "level": "Senior",
        "location": "Istanbul, Turkey",
        "workType": "Remote",
        "description":
            "Build and maintain modern, scalable, and high-performance user interfaces using React and TypeScript. Collaborate closely with designers and backend teams to deliver seamless user experiences. Optimize applications for speed and responsiveness, ensure cross-browser compatibility, and contribute to UI architecture decisions.",
        "requirements": [
          "4+ years of frontend development experience",
          "Strong proficiency in React and TypeScript",
          "Experience with state management libraries (Redux, Zustand, etc.)",
          "Solid understanding of responsive design and UI/UX principles",
          "Familiarity with REST APIs and modern frontend tooling",
        ],
        "salary": "\$4,000 - \$6,000",
      },
      {
        "id": "JP-2",
        "title": "Backend Engineer",
        "level": "Mid-Level",
        "location": "Berlin, Germany",
        "workType": "Hybrid",
        "description":
            "Design, develop, and maintain scalable backend systems and APIs using Node.js. Work with microservice architectures, integrate third-party services, and ensure high availability and performance. Collaborate with frontend and DevOps teams to deliver end-to-end solutions.",
        "requirements": [
          "3+ years of backend development experience",
          "Strong knowledge of Node.js and Express.js",
          "Experience with RESTful API design and microservices",
          "Familiarity with databases (PostgreSQL, MongoDB)",
          "Understanding of authentication, security, and performance optimization",
        ],
        "salary": "\$3,500 - \$5,000",
      },
      {
        "id": "JP-3",
        "title": "ML Engineer Intern",
        "level": "Intern",
        "location": "San Francisco, US",
        "workType": "On-site",
        "description":
            "Support the development of machine learning pipelines and assist in model training, evaluation, and deployment. Work with data scientists to preprocess datasets, experiment with models, and integrate ML solutions into production systems.",
        "requirements": [
          "Basic knowledge of machine learning concepts",
          "Experience with Python and libraries like NumPy, Pandas",
          "Familiarity with frameworks such as TensorFlow or PyTorch",
          "Understanding of data preprocessing and model evaluation",
          "Strong problem-solving and analytical thinking skills",
        ],
      },
      {
        "id": "JP-4",
        "title": "Mobile Developer",
        "level": "Mid-Level",
        "location": "London, UK",
        "workType": "Remote",
        "description":
            "Develop and maintain cross-platform mobile applications using Flutter. Ensure smooth performance, responsive UI, and seamless integration with backend services. Participate in code reviews and contribute to mobile architecture decisions.",
        "requirements": [
          "3+ years of mobile development experience",
          "Strong experience with Flutter and Dart",
          "Knowledge of REST API integration",
          "Understanding of mobile UI/UX best practices",
          "Experience with version control systems (Git)",
        ],
      },
      {
        "id": "JP-5",
        "title": "DevOps Engineer",
        "level": "Senior",
        "location": "Amsterdam, NL",
        "workType": "Hybrid",
        "description":
            "Design, implement, and maintain CI/CD pipelines and cloud infrastructure. Ensure system reliability, scalability, and security. Automate deployment processes and monitor system performance using modern DevOps tools.",
        "requirements": [
          "5+ years of experience in DevOps or related roles",
          "Strong knowledge of CI/CD tools (GitHub Actions, Jenkins, etc.)",
          "Experience with cloud platforms (AWS, Azure, or GCP)",
          "Familiarity with containerization (Docker, Kubernetes)",
          "Understanding of monitoring and logging systems",
        ],
      },
      {
        "id": "JP-6",
        "title": "Data Scientist",
        "level": "Senior",
        "location": "Remote",
        "workType": "Remote",
        "description":
            "Analyze large datasets to extract insights and build predictive models. Work closely with product and engineering teams to develop data-driven solutions. Communicate findings clearly and contribute to strategic decision-making.",
        "requirements": [
          "4+ years of experience in data science or analytics",
          "Strong knowledge of Python, Pandas, NumPy, and scikit-learn",
          "Experience with data visualization tools (Matplotlib, Tableau, etc.)",
          "Understanding of statistical modeling and machine learning algorithms",
          "Strong communication and storytelling skills with data",
        ],
      },
    ];
  }

  // ===============================
  // SEARCH
  // ===============================

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // ===============================
  // FILTER
  // ===============================

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  // ===============================
  // APPLY FILTER LOGIC
  // ===============================

  void applyFilters() {
    final query = searchQuery.value.toLowerCase();
    final filter = selectedFilter.value;

    filteredJobs.value = jobs.where((job) {
      final title = job["title"].toString().toLowerCase();
      final level = job["level"];
      final workType = job["workType"];

      // 🔍 Search condition
      final matchesSearch = title.contains(query);

      // 🎯 Filter condition
      bool matchesFilter = true;

      if (filter != "All Roles") {
        if (filter == "Remote") {
          matchesFilter = workType == "Remote";
        } else {
          matchesFilter = level == filter;
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ===============================
  // BACKEND READY FETCH
  // ===============================

  Future<void> fetchJobs() async {
    // TODO:
    /*
    final response = await api.getOpenPositions();

    jobs.value = response.jobs;
    applyFilters();
    */
  }

  // ===============================
  // SKILL ACTIONS
  // ===============================

  void addSkill() {
    final skill = skillCtrl.text.trim();

    if (skill.isEmpty) return;

    skills.add(skill);
    skillCtrl.clear();
  }

  void removeSkill(String skill) {
    skills.remove(skill);
  }

  // ===============================
  // RESUME ACTION
  // ===============================

  void pickResume() {
    // TODO: file picker eklenecek
    selectedResume.value = "resume.pdf";

    // Backend:
    /*
  final file = await FilePicker.pick();
  uploadResume(file);
  */
  }

  // ===============================
  // ACTIONS
  // ===============================

  void applyToJob(Map<String, dynamic> job) {
    setSelectedJob(job);

    // ===============================
    // TODO: NAVIGATE TO APPLY PAGE
    // ===============================
    /*
  Get.to(() => ApplyPage(), arguments: job);
  */

    print("Applying to ${job["title"]}");
  }

  // ===============================
  // SELECT JOB (NAVIGATION SUPPORT)
  // ===============================

  void setSelectedJob(Map<String, dynamic> job) {
    selectedJob.value = job;

    // ===============================
    // TODO (Backend)
    // ===============================
    /*
  - Optionally fetch full job detail by ID
  - Example:
    final detail = await api.getJobDetail(job["id"]);
    selectedJob.value = detail;
  */
  }

  // ===============================
  // SUBMIT APPLICATION
  // ===============================

  void submitApplication() {
    final data = {
      "jobId": selectedJob.value?["id"],
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "location": locationCtrl.text,
      "university": universityCtrl.text,
      "department": departmentCtrl.text,
      "skills": skills,
      "portfolio": portfolioCtrl.text,
      "github": githubCtrl.text,
      "linkedin": linkedinCtrl.text,
      "resume": selectedResume.value,
    };

    print("APPLICATION DATA:");
    print(data);

    // ===============================
    // TODO (BACKEND)
    // ===============================
    /*
  await api.submitApplication(data);
  */
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    universityCtrl.dispose();
    departmentCtrl.dispose();
    portfolioCtrl.dispose();
    githubCtrl.dispose();
    linkedinCtrl.dispose();
    skillCtrl.dispose();
    super.onClose();
  }

}
