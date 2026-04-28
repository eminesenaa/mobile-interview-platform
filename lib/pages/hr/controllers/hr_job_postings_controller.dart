// ===================== File: hr_job_postings_controller.dart =====================
// Purpose:
// Controls job postings (Applications system)
//
// Responsibilities:
// - Manage active / closed postings
// - Handle navigation
// - Prepare data for UI
//
// IMPORTANT:
// - Uses mock data for now
// - Fully backend-ready structure
//
// TODO (Backend):
// - Fetch postings list
// - Update posting status (active → closed)
// - Connect applicants
// ===============================================================================

import 'package:get/get.dart';

import '../../../models/user.dart';
import '../candidate_application_detail_page.dart';
import '../job_posting_applicants_page.dart';
import '../job_posting_create_page.dart';
import '../job_posting_detail_page.dart';

class HrJobPostingsController extends GetxController {
  // ===============================
  // STATE
  // ===============================

  /// active / closed
  final selectedTab = "active".obs;

  /// postings lists
  final activePostings = <Map<String, dynamic>>[].obs;
  final closedPostings = <Map<String, dynamic>>[].obs;

  // ===============================
  // CREATE POSTING FORM STATE
  // ===============================

  final jobTitle = "".obs;
  final jobLevel = "".obs;
  final workType = "".obs;
  final country = "".obs;
  final city = "".obs;
  final salary = "".obs; // optional
  final description = "".obs;
  final requirements = "".obs;


  // ===============================
  // LIFECYCLE
  // ===============================
  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  // ===============================
  // TAB CHANGE
  // ===============================
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  // ===============================
  // NAVIGATION
  // ===============================

  void openPosting(Map<String, dynamic> posting) {
    final isClosed = posting["status"] == "closed";

    if (isClosed) {
      // 👉 CLOSED → candidate evaluation / results page
      // TODO: replace with actual route
      Get.snackbar("TODO", "Open Closed Posting Detail");
    } else {
      Get.to(() => JobPostingDetailPage(posting: posting));
    }
  }

  void createPosting() {
    Get.to(() => const JobPostingCreatePage());
  }


  // ===============================
  // OPEN APPLICANTS PAGE
  // ===============================
  void openApplicants(Map<String, dynamic> posting) {
    Get.to(() => JobPostingApplicantsPage(posting: posting));
  }

  // ===============================
  // OPEN CANDIDATE DETAIL
  // ===============================
  void openCandidateDetail(String postingId, String userId) {
    final posting = getPostingById(postingId);
    if (posting == null) return;

    final applicants = List<Map<String, dynamic>>.from(posting["applicants"]);

    final applicant =
    applicants.firstWhere((a) => a["userId"] == userId, orElse: () => {});

    if (applicant.isEmpty) return;

    final user = getUserByName(applicant["name"]);

    /// 🔥 PAGE'e gönderilecek data
    final application = {
      "id": userId,
      "name": applicant["name"],
      "status": applicant["status"],

      /// user info
      "email": user?.email ?? "-",
      "phone": user?.phoneNumber ?? "-",
      "location": user?.location ?? "-",

      /// application data (şimdilik mock)
      "position": posting["position"],
      "skills": ["React", "TypeScript", "CSS"],
      "coverLetter":
      "I am passionate about building modern UI applications and would love to join your team.",
      "portfolioUrl": "portfolio.com",
      "githubUrl": "github.com/user",
      "linkedinUrl": "linkedin.com/in/user",
      "resumeUrl": "resume.pdf",
    };

    Get.to(() => CandidateApplicationDetailPage(application: application));
  }

  // ===============================
  // ACCEPT APPLICANT
  // ===============================
  void acceptApplicant(String postingId, String userId) {
    final posting = getPostingById(postingId);
    if (posting == null) return;

    final applicants = List<Map<String, dynamic>>.from(posting["applicants"]);

    final index = applicants.indexWhere((a) => a["userId"] == userId);
    if (index == -1) return;

    applicants[index]["status"] = "accepted";

    posting["pending"] = (posting["pending"] ?? 1) - 1;
    posting["accepted"] = (posting["accepted"] ?? 0) + 1;

    posting["applicants"] = applicants;

    activePostings.refresh();

    Get.snackbar("Success", "Applicant accepted");
  }

  // ===============================
  // REJECT APPLICANT
  // ===============================
  void rejectApplicant(String postingId, String userId) {
    final posting = getPostingById(postingId);
    if (posting == null) return;

    final applicants = List<Map<String, dynamic>>.from(posting["applicants"]);

    final index = applicants.indexWhere((a) => a["userId"] == userId);
    if (index == -1) return;

    applicants[index]["status"] = "rejected";

    posting["pending"] = (posting["pending"] ?? 1) - 1;
    posting["rejected"] = (posting["rejected"] ?? 0) + 1;

    posting["applicants"] = applicants;

    activePostings.refresh();

    Get.snackbar("Success", "Applicant rejected");
  }


  // ===============================
  // MOCK DATA
  // ===============================
  void loadMockData() {
    activePostings.value = [
      {
        "id": "JP-0001",
        "title": "Frontend Developer",
        "position": "Senior Frontend Developer",
        "level": "Senior",
        "location": "Istanbul, Turkey",
        "workType": "Remote",
        "salary": "\$4,000 - \$6,000 / mo",

        "applicantCount": 24,
        "accepted": 7,
        "rejected": 6,
        "pending": 5,
        "applicants": [
          {"userId": "U1", "name": "James Chen", "status": "accepted"},
          {"userId": "U2", "name": "Mia Kim", "status": "pending"},
          {"userId": "U3", "name": "Sara Reyes", "status": "rejected"},
        ],

        "status": "active",

        "description":
        "We are looking for a talented frontend developer to join our team.",

        "requirements": [
          "5+ years React experience",
          "TypeScript knowledge",
          "Strong CSS skills",
        ],

        "applicantsPreview": [
          {"userId": "U1", "name": "James Chen", "status": "accepted"},
          {"userId": "U2", "name": "Mia Kim", "status": "pending"},
          {"userId": "U3", "name": "Sara Reyes", "status": "rejected"},
        ],
      },

      {
        "id": "JP-0002",
        "title": "Backend Engineer",
        "position": "Mid-Level Backend Engineer",
        "level": "Mid-Level",
        "location": "Berlin, Germany",
        "workType": "Hybrid",
        "salary": "\$3,500 - \$5,000 / mo",

        "applicantCount": 18,
        "accepted": 4,
        "rejected": 6,
        "pending": 8,
        "applicants": [
          {"userId": "U4", "name": "Lukas Weber", "status": "accepted"},
          {"userId": "U5", "name": "Anna Schmidt", "status": "pending"},
          {"userId": "U6", "name": "Carlos Mendes", "status": "rejected"},
        ],

        "status": "active",

        "description":
        "Join our backend team to build scalable and robust APIs.",

        "requirements": [
          "3+ years backend experience",
          "Node.js or Java",
          "Database design knowledge",
        ],

        "applicantsPreview": [
          {"userId": "U4", "name": "Lukas Weber", "status": "accepted"},
          {"userId": "U5", "name": "Anna Schmidt", "status": "pending"},
          {"userId": "U6", "name": "Carlos Mendes", "status": "rejected"},
        ],
      },

      {
        "id": "JP-0003",
        "title": "ML Engineer Intern",
        "position": "Machine Learning Intern",
        "level": "Intern",
        "location": "San Francisco, US",
        "workType": "On-site",
        "salary": "\$1,500 - \$2,000 / mo",

        "applicantCount": 47,
        "accepted": 0,
        "rejected": 33,
        "pending": 14,
        "applicants": [
          {"userId": "U7", "name": "Kevin Lee", "status": "pending"},
          {"userId": "U8", "name": "Elena Petrova", "status": "pending"},
          {"userId": "U9", "name": "David Park", "status": "rejected"},
        ],

        "status": "active",

        "description":
        "Work on real-world ML models and data pipelines.",

        "requirements": [
          "Python knowledge",
          "Basic ML understanding",
          "TensorFlow or PyTorch",
        ],

        "applicantsPreview": [
          {"userId": "U7", "name": "Kevin Lee", "status": "pending"},
          {"userId": "U8", "name": "Elena Petrova", "status": "pending"},
          {"userId": "U9", "name": "David Park", "status": "rejected"},
        ],
      },

      {
        "id": "JP-0004",
        "title": "Mobile Developer",
        "position": "Junior Mobile Developer",
        "level": "Junior",
        "location": "Amsterdam, Netherlands",
        "workType": "Hybrid",
        "salary": "\$2,500 - \$3,500 / mo",

        "applicantCount": 21,
        "accepted": 6,
        "rejected": 8,
        "pending": 7,
        "applicants": [
          {"userId": "U10", "name": "Noah van Dijk", "status": "accepted"},
          {"userId": "U11", "name": "Emma Janssen", "status": "pending"},
          {"userId": "U12", "name": "Ali Demir", "status": "rejected"},
        ],

        "status": "active",

        "description":
        "Build cross-platform mobile apps using Flutter.",

        "requirements": [
          "Flutter knowledge",
          "Dart basics",
          "Mobile UI understanding",
        ],

        "applicantsPreview": [
          {"userId": "U10", "name": "Noah van Dijk", "status": "accepted"},
          {"userId": "U11", "name": "Emma Janssen", "status": "pending"},
          {"userId": "U12", "name": "Ali Demir", "status": "rejected"},
        ],
      },

      {
        "id": "JP-0005",
        "title": "DevOps Engineer",
        "position": "Senior DevOps Engineer",
        "level": "Senior",
        "location": "Toronto, Canada",
        "workType": "Remote",
        "salary": "\$5,000 - \$7,000 / mo",

        "applicantCount": 16,
        "accepted": 5,
        "rejected": 5,
        "pending": 6,
        "applicants": [
          {"userId": "U13", "name": "Oliver Brown", "status": "accepted"},
          {"userId": "U14", "name": "Sophie Martin", "status": "pending"},
          {"userId": "U15", "name": "Raj Patel", "status": "rejected"},
        ],

        "status": "active",

        "description":
        "Manage CI/CD pipelines and cloud infrastructure.",

        "requirements": [
          "AWS/GCP experience",
          "Docker & Kubernetes",
          "CI/CD pipelines",
        ],

        "applicantsPreview": [
          {"userId": "U13", "name": "Oliver Brown", "status": "accepted"},
          {"userId": "U14", "name": "Sophie Martin", "status": "pending"},
          {"userId": "U15", "name": "Raj Patel", "status": "rejected"},
        ],
      },
    ];

    closedPostings.value = [
      {
        "id": "JP-1001",
        "title": "Product Designer",
        "position": "Senior Product Designer",
        "level": "Senior",
        "location": "Remote Worldwide",
        "workType": "Full Remote",
        "salary": "\$4,500 - \$6,500 / mo",

        "applicants": 31,
        "accepted": 12,
        "rejected": 19,
        "pending": 0,

        "status": "closed",

        "description":
        "Design intuitive and beautiful product experiences.",

        "requirements": [
          "5+ years design experience",
          "Figma mastery",
          "UX research knowledge",
        ],

        "applicantsPreview": [
          {"userId": "U16", "name": "Laura Gomez", "status": "accepted"},
          {"userId": "U17", "name": "Daniel Wu", "status": "accepted"},
          {"userId": "U18", "name": "Anna Rossi", "status": "rejected"},
        ],
      },

      {
        "id": "JP-1002",
        "title": "iOS Developer",
        "position": "Junior iOS Developer",
        "level": "Junior",
        "location": "London, UK",
        "workType": "Hybrid",
        "salary": "\$3,000 - \$4,000 / mo",

        "applicants": 20,
        "accepted": 8,
        "rejected": 12,
        "pending": 0,

        "status": "closed",

        "description":
        "Develop and maintain iOS applications using Swift.",

        "requirements": [
          "Swift knowledge",
          "iOS fundamentals",
          "UIKit or SwiftUI",
        ],

        "applicantsPreview": [
          {"userId": "U19", "name": "Jack Wilson", "status": "accepted"},
          {"userId": "U20", "name": "Emily Clark", "status": "accepted"},
          {"userId": "U21", "name": "Leo Brown", "status": "rejected"},
        ],
      },

      {
        "id": "JP-1003",
        "title": "QA Engineer",
        "position": "Mid-Level QA Engineer",
        "level": "Mid-Level",
        "location": "Warsaw, Poland",
        "workType": "On-site",
        "salary": "\$2,800 - \$3,800 / mo",

        "applicants": 26,
        "accepted": 9,
        "rejected": 17,
        "pending": 0,

        "status": "closed",

        "description":
        "Ensure product quality with automated and manual testing.",

        "requirements": [
          "Testing fundamentals",
          "Automation tools",
          "Attention to detail",
        ],

        "applicantsPreview": [
          {"userId": "U22", "name": "Piotr Nowak", "status": "accepted"},
          {"userId": "U23", "name": "Kasia Zielinska", "status": "accepted"},
          {"userId": "U24", "name": "Ivan Petrov", "status": "rejected"},
        ],
      },

      {
        "id": "JP-1004",
        "title": "Data Scientist",
        "position": "Senior Data Scientist",
        "level": "Senior",
        "location": "New York, US",
        "workType": "Hybrid",
        "salary": "\$6,000 - \$8,000 / mo",

        "applicants": 34,
        "accepted": 11,
        "rejected": 23,
        "pending": 0,

        "status": "closed",

        "description":
        "Analyze data and build predictive models for business insights.",

        "requirements": [
          "Python & ML",
          "Statistics knowledge",
          "Data visualization",
        ],

        "applicantsPreview": [
          {"userId": "U25", "name": "Michael Scott", "status": "accepted"},
          {"userId": "U26", "name": "Rachel Green", "status": "accepted"},
          {"userId": "U27", "name": "Tom Harris", "status": "rejected"},
        ],
      },

      {
        "id": "JP-1005",
        "title": "UI/UX Designer",
        "position": "UI/UX Intern",
        "level": "Intern",
        "location": "Paris, France",
        "workType": "On-site",
        "salary": "\$1,200 - \$1,800 / mo",

        "applicants": 15,
        "accepted": 3,
        "rejected": 12,
        "pending": 0,

        "status": "closed",

        "description":
        "Assist in UI/UX design tasks and improve user experience.",

        "requirements": [
          "Basic design tools",
          "Creativity",
          "UX fundamentals",
        ],

        "applicantsPreview": [
          {"userId": "U28", "name": "Camille Dubois", "status": "accepted"},
          {"userId": "U29", "name": "Lucas Martin", "status": "accepted"},
          {"userId": "U30", "name": "Emma Laurent", "status": "rejected"},
        ],
      },
    ];
  }

  /// ===============================
  /// MOCK USERS (FOR APPLICANTS)
  /// ===============================
  final mockUsers = <User>[
    User.initial(
      id: "U1",
      name: "James",
      surname: "Chen",
      username: "jchen",
      email: "james@test.com",
    ).copyWith(
      university: "MIT",
      department: "Computer Science",
    ),

    User.initial(
      id: "U2",
      name: "Mia",
      surname: "Kim",
      username: "mkim",
      email: "mia@test.com",
    ).copyWith(
      university: "Seoul National",
      department: "Software Eng.",
    ),

    User.initial(
      id: "U3",
      name: "Sara",
      surname: "Reyes",
      username: "sreyes",
      email: "sara@test.com",
    ).copyWith(
      university: "Barcelona Tech",
      department: "CS",
    ),
  ];

  // ===============================
  // CREATE POSTING (MOCK)
  // ===============================
  void submitPosting() {
    if (!isFormValid) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    final newPosting = {
      "title": jobTitle.value,
      "level": jobLevel.value,
      "location": "${city.value}, ${country.value}",
      "workType": workType.value,
      "salary": salary.value, // optional (UI’da gösterirsin)
      "applicants": 0,
      "accepted": 0,
      "pending": 0,
      "status": "active",
    };

    // 👉 listeye ekle (en üste)
    activePostings.insert(0, newPosting);

    // 👉 formu temizle
    resetForm();

    // 👉 geri dön
    Get.back();

    Get.snackbar("Success", "Job posting created");
  }
  // ===============================
  // RESET FORM
  // ===============================
  void resetForm() {
    jobTitle.value = "";
    jobLevel.value = "";
    workType.value = "";
    country.value = "";
    city.value = "";
    salary.value = "";
    description.value = "";
    requirements.value = "";
  }

  // ===============================
  // GET POSTING BY ID
  // ===============================
  Map<String, dynamic>? getPostingById(String id) {
    try {
      return [
        ...activePostings,
        ...closedPostings,
      ].firstWhere((p) => p["id"] == id);
    } catch (e) {
      return null;
    }
  }

  // ===============================
  // CLOSE POSTING (MOVE TO CLOSED)
  // ===============================
  void closePosting(String id) {
    final index = activePostings.indexWhere((p) => p["id"] == id);

    if (index == -1) return;

    final posting = activePostings[index];

    activePostings.removeAt(index);

    closedPostings.insert(0, {
      ...posting,
      "status": "closed",
    });

    Get.snackbar("Success", "Posting closed");
  }

  /// ===============================
  /// GET USER BY NAME (MOCK)
  /// ===============================
  User? getUserByName(String name) {
    try {
      return mockUsers.firstWhere(
            (u) => "${u.name} ${u.surname}" == name,
      );
    } catch (e) {
      return null;
    }
  }

  // ===============================
  // SEARCH APPLICANTS
  // ===============================
  List<Map<String, dynamic>> searchApplicants(
      List<Map<String, dynamic>> applicants,
      String query,
      ) {
    if (query.isEmpty) return applicants;

    final q = query.toLowerCase();

    return applicants.where((a) {
      final name = (a["name"] ?? "").toLowerCase();

      final user = getUserByName(a["name"] ?? "");
      final email = user?.email.toLowerCase() ?? "";

      return name.contains(q) || email.contains(q);
    }).toList();
  }


  // ===============================
  // VALIDATION
  // ===============================
  bool get isFormValid {
    return jobTitle.isNotEmpty &&
        jobLevel.isNotEmpty &&
        workType.isNotEmpty &&
        country.isNotEmpty &&
        city.isNotEmpty &&
        description.isNotEmpty &&
        requirements.isNotEmpty;
  }

// ===============================
// TODO: BACKEND METHODS
// ===============================
/*
  Future<void> fetchPostings() async {}

  Future<void> closePosting(String postingId) async {}

  Future<void> fetchApplicants(String postingId) async {}
  */
}
