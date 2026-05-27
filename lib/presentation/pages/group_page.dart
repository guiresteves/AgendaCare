import 'package:flutter/material.dart';

import '../widgets/agenda_scaffold.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    const responsaveis = [
      Person(
        name: 'Gabriel Augusto',
        role: 'Responsável',
        initials: 'GA',
        avatarColor: Color(0xFFF6CDFF),
        textColor: Color(0xFF9E1C8B),
      ),
      Person(
        name: 'Kauan Gabriel',
        role: 'Responsável',
        initials: 'KA',
        avatarColor: Color(0xFFF6CDFF),
        textColor: Color(0xFF9E1C8B),
      ),
      Person(
        name: 'Leonidas Moreira',
        role: 'Responsável',
        initials: 'LM',
        avatarColor: agendaBlue,
        textColor: Colors.white,
      ),
    ];

    const dependentes = [
      Person(
        name: 'Iago Messias',
        role: 'Dependente',
        initials: 'IM',
        avatarColor: Color(0xFF94C4F5),
        textColor: Colors.white,
      ),
      Person(
        name: 'Gustavo Menezes',
        role: 'Dependente',
        initials: 'GM',
        avatarColor: Color(0xFF94C4F5),
        textColor: Colors.white,
      ),
    ];

    return AgendaScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grupo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            'Veja e organize quem cuida, e quem é cuidado no seu grupo\nfamiliar',
            style: TextStyle(
              color: agendaMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 32),
          SectionTitle(title: 'Responsáveis', onAdd: () {}),
          const SizedBox(height: 13),
          PersonCard(people: responsaveis),
          const SizedBox(height: 28),
          SectionTitle(title: 'Dependentes', onAdd: () {}),
          const SizedBox(height: 13),
          PersonCard(people: dependentes),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3C3C43),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 30,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: agendaBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: onAdd,
            child: const Text(
              'Adicionar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < people.length; i++) ...[
            PersonTile(person: people[i]),
            if (i != people.length - 1)
              const Divider(
                height: 1,
                indent: 18,
                endIndent: 18,
                color: Color(0xFFE6E6E6),
              ),
          ],
        ],
      ),
    );
  }
}

class PersonTile extends StatelessWidget {
  const PersonTile({super.key, required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: person.avatarColor,
        child: Text(
          person.initials,
          style: TextStyle(
            color: person.textColor,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        person.name,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        person.role,
        style: const TextStyle(color: agendaMutedText, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF7E7777)),
    );
  }
}

class Person {
  const Person({
    required this.name,
    required this.role,
    required this.initials,
    required this.avatarColor,
    required this.textColor,
  });

  final String name;
  final String role;
  final String initials;
  final Color avatarColor;
  final Color textColor;
}
