import 'package:flutter/material.dart';

class FamilyExpansionTile<T> extends StatelessWidget {
  final String title;
  final List<T> members;
  final Set<T> selectedMembers;
  final Function(T member, bool isSelected) onChanged;

  const FamilyExpansionTile({
    super.key,
    required this.title,
    required this.members,
    required this.selectedMembers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
          children: [
            const TextSpan(text: 'Pilih '),
            TextSpan(
              text: title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' yang makan makanan ini'),
          ],
        ),
      ),
      initiallyExpanded: true,
      children: members.map((member) {
        final name = (member as dynamic).name;
        return CheckboxListTile(
          title: Text(name),
          value: selectedMembers.contains(member),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (isSelected) => onChanged(member, isSelected ?? false),
        );
      }).toList(),
    );
  }
}
