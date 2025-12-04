// ===================== File: contact_info_modal.dart =====================
// Purpose: Contact Info modal with:
//  - Dynamic height in VIEW mode
//  - FULL height in EDIT mode
//  - Country picker + formatted phone input
//  - Bottom sticky Save/Cancel bar
// ========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';
import '../controllers/profile_controller.dart';
import 'common_phone_field.dart';

class ContactInfoModal extends StatefulWidget {
  ContactInfoModal({super.key});

  @override
  State<ContactInfoModal> createState() => _ContactInfoModalState();
}

class _ContactInfoModalState extends State<ContactInfoModal> {
  final c = Get.find<ProfileController>();

  bool isEditing = false;

  // Editable controllers
  late TextEditingController emailCtrl;
  late TextEditingController linkedinCtrl;
  late TextEditingController githubCtrl;
  late TextEditingController websiteCtrl;

  // PHONE extra state
  late String phoneIso; // e.g. "TR"
  late String phoneCode; // e.g. "+90"
  late String phoneRaw; // digits only

  // dynamic height measurement (VIEW mode only)
  final contentKey = GlobalKey();
  double contentHeight = 0.0;

  @override
  void initState() {
    super.initState();
    final u = c.user.value;

    emailCtrl = TextEditingController(text: u?.email ?? "");
    linkedinCtrl = TextEditingController(text: u?.linkedinUrl ?? "");
    githubCtrl = TextEditingController(text: u?.githubUrl ?? "");
    websiteCtrl = TextEditingController(text: u?.website ?? "");

    // PHONE parsing
    phoneRaw = u?.phoneNumber ?? "";
    phoneIso = "TR"; // default
    phoneCode = "+90";
  }

  // ----------------------------------------------------------
  // FORMAT HELPERS
  // ----------------------------------------------------------
  String _formatPhone(String raw, String iso) {
    if (raw.isEmpty) return "";
    try {
      final parsed =
          PhoneNumber.parse(raw, callerCountry: IsoCode.fromJson(iso));
      return parsed.formatNsn(); // "530 123 4567"
    } catch (_) {
      return raw;
    }
  }

  String _extractDigits(String input) {
    return input.replaceAll(RegExp(r"[^0-9]"), "");
  }

  // ----------------------------------------------------------
  // VIEW TILE
  // ----------------------------------------------------------
  Widget buildViewTile({
    required IconData icon,
    required String? value,
    required String label,
  }) {
    if (value == null || value.trim().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyStrong),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // GENERIC EDIT TILE
  // ----------------------------------------------------------
  Widget buildEditTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.bodyStrong),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SAVE ACTION
  // ----------------------------------------------------------
  Future<void> _saveChanges() async {
    await c.updateEmail(emailCtrl.text.trim());
    await c.updateLinkedIn(linkedinCtrl.text.trim());
    await c.updateGithub(githubCtrl.text.trim());
    await c.updateWebsite(websiteCtrl.text.trim());

    // SAVE phoneRaw INTO FIRESTORE
    await c.updatePhone(phoneRaw);

    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = c.user.value;
    if (user == null) return const SizedBox();

    final screenHeight = MediaQuery.of(context).size.height;

    // -----------------------------------
    // VIEW → dynamic height
    // EDIT → full height
    // -----------------------------------
    double initialSize;
    double minSize;
    double maxSize = 0.9;

    if (!isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = contentKey.currentContext;
        if (ctx != null) {
          final newHeight = ctx.size?.height ?? 0;
          if (newHeight != contentHeight) {
            setState(() => contentHeight = newHeight);
          }
        }
      });

      double dynamicSize = (contentHeight / screenHeight).clamp(0.25, 0.6);

      initialSize = dynamicSize;
      minSize = dynamicSize;
    } else {
      initialSize = 0.9;
      minSize = 0.9;
    }

    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  key: contentKey,
                  controller: scroll,
                  padding: const EdgeInsets.all(20).copyWith(
                    bottom: isEditing ? 100 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${user.name} ${user.surname}",
                            style: AppTextStyles.headline,
                          ),
                          if (!isEditing)
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => setState(() => isEditing = true),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: AppColors.border.withOpacity(0.6),
                      ),
                      const SizedBox(height: 18),

                      Text("Contact Information", style: AppTextStyles.title),
                      const SizedBox(height: 12),

                      // VIEW MODE
                      if (!isEditing) ...[
                        buildViewTile(
                          icon: PhosphorIcons.envelope(),
                          value: user.email,
                          label: "Email",
                        ),
                        buildViewTile(
                          icon: PhosphorIcons.phone(),
                          value: user.phoneNumber,
                          label: "Phone",
                        ),
                        buildViewTile(
                          icon: PhosphorIcons.linkedinLogo(),
                          value: user.linkedinUrl,
                          label: "LinkedIn",
                        ),
                        buildViewTile(
                          icon: PhosphorIcons.githubLogo(),
                          value: user.githubUrl,
                          label: "GitHub",
                        ),
                        buildViewTile(
                          icon: PhosphorIcons.globe(),
                          value: user.website,
                          label: "Website",
                        ),
                      ],

                      // EDIT MODE
                      if (isEditing) ...[
                        buildEditTile(
                          icon: PhosphorIcons.envelope(),
                          label: "Email",
                          controller: emailCtrl,
                          type: TextInputType.emailAddress,
                        ),
                        CommonPhoneField(
                          iso: phoneIso,
                          dialCode: phoneCode,
                          raw: phoneRaw,
                          onChanged: (
                              {required iso, required dialCode, required raw}) {
                            setState(() {
                              phoneIso = iso;
                              phoneCode = dialCode;
                              phoneRaw = raw;
                            });
                          },
                        ),
                        buildEditTile(
                          icon: PhosphorIcons.linkedinLogo(),
                          label: "LinkedIn",
                          controller: linkedinCtrl,
                        ),
                        buildEditTile(
                          icon: PhosphorIcons.githubLogo(),
                          label: "GitHub",
                          controller: githubCtrl,
                        ),
                        buildEditTile(
                          icon: PhosphorIcons.globe(),
                          label: "Website",
                          controller: websiteCtrl,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // BOTTOM BUTTONS
              if (isEditing)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => isEditing = false),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saveChanges,
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
