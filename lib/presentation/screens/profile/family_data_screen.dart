// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/ts_color.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/parent_model.dart';
import 'edit_child_screen.dart';

class FamilyDataScreen extends StatelessWidget {
  final List<ParentModel> parents;
  final List<ChildModel> children;

  const FamilyDataScreen({
    super.key,
    required this.parents,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Keluarga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orang Tua',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (parents.isEmpty)
              const Text('Tidak ada data orang tua.')
            else
              ListView.separated(
                itemCount: parents.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _MemberCard(
                    name: parents[index].name,
                    role: parents[index].role.name,
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),

            const SizedBox(height: 32),
            const Text(
              'Anak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (children.isEmpty)
              const Text('Tidak ada data anak.')
            else
              ListView.separated(
                itemCount: children.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final child = children[index];
                  return _MemberCard(
                    name: child.name,
                    role: 'Anak',
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditChildScreen(child: child),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback? onEdit;

  const _MemberCard({required this.name, required this.role, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(role, style: TextStyle(color: TSColor.monochrome.grey)),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit, color: TSColor.mainTosca.primary),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
