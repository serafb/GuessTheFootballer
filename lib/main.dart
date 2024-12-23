import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indovina il Calciatore',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SchermataIniziale(),
    );
  }
}

class SchermataIniziale extends StatefulWidget {
  @override
  _SchermataInizialeState createState() => _SchermataInizialeState();
}

class _SchermataInizialeState extends State<SchermataIniziale> {
  Map<String, dynamic> datiCalciatori = {};
  List<String> calciatoriTrovati = [];

  @override
  void initState() {
    super.initState();
    caricaDatiCalciatori();
  }

  Future<void> caricaDatiCalciatori() async {
    final String jsonString =
        await rootBundle.rootBundle.loadString('assets/calciatori_data.json');
    final Map<String, dynamic> calciatoriData = json.decode(jsonString);
    setState(() {
      datiCalciatori = calciatoriData;
      calciatoriTrovati = datiCalciatori.keys.toList();
    });
  }

  void cercaCalciatori(String nome) {
    setState(() {
      calciatoriTrovati = datiCalciatori.keys
          .where((calciatore) =>
              calciatore.toLowerCase().contains(nome.toLowerCase()))
          .toList();
    });
  }

  void avviaGioco(String calciatore) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiocoCalciatoreScreen(
          datiCalciatori: datiCalciatori,
          calciatore: calciatore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Indovina il Calciatore'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                final calciatoreCasuale = (datiCalciatori.keys.toList()..shuffle()).first;
                avviaGioco(calciatoreCasuale);
              },
              child: Text('Scegli un calciatore casuale'),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) => cercaCalciatori(value),
              decoration: InputDecoration(
                labelText: 'Cerca calciatore',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: calciatoriTrovati.length,
                itemBuilder: (context, index) {
                  final calciatore = calciatoriTrovati[index];
                  return ListTile(
                    title: Text(calciatore),
                    onTap: () => avviaGioco(calciatore),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GiocoCalciatoreScreen extends StatefulWidget {
  final Map<String, dynamic> datiCalciatori;
  final String calciatore;

  GiocoCalciatoreScreen({
    required this.datiCalciatori,
    required this.calciatore,
  });

  @override
  _GiocoCalciatoreScreenState createState() => _GiocoCalciatoreScreenState();
}

class _GiocoCalciatoreScreenState extends State<GiocoCalciatoreScreen> {
  late List<dynamic> carrieraCompleta;
  late String calciatore;
  int indice = 0;
  bool finito = false;
  final TextEditingController rispostaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    calciatore = widget.calciatore;
    final carriera = widget.datiCalciatori[calciatore];
    final giovanili = carriera['giovanili'];
    final squadreDiClub = carriera['squadre_di_club'];
    carrieraCompleta = [...giovanili, ...squadreDiClub];
  }

  void aggiornaCarriera() {
    setState(() {
      if (indice < carrieraCompleta.length - 1) {
        indice++;
      } else {
        finito = true; // Gioco finito
      }
    });
  }

  void verificaIndovinato() {
    String risposta = rispostaController.text.trim();
    // Converto la risposta e il nome del calciatore in minuscolo
    final paroleRisposta = risposta.toLowerCase().split(' ');
    final paroleCalciatore = calciatore.toLowerCase().split(' ');

    // Verifico se almeno una parola della risposta è presente nel nome del calciatore
    final isIndovinato = paroleRisposta.any((parola) => paroleCalciatore.contains(parola));

    if (isIndovinato) {
      // Se la risposta è corretta
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Congratulazioni!'),
          content: Text('Hai indovinato! Il calciatore era $calciatore.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Se la risposta è sbagliata
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sbagliato!'),
          content: Text('Riprova!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carriera = widget.datiCalciatori[calciatore];
    final giovanili = carriera['giovanili'];
    final squadreDiClub = carriera['squadre_di_club'];

    final dato = carrieraCompleta[indice];
    final periodo = dato['periodo'];
    final squadra = dato['squadra'];
    final presenze = dato['presenze'] ?? 'N/A';
    final gol = dato['gol'] ?? 'N/A';
    final categoria = indice < giovanili.length ? 'Giovanili' : 'Squadre di Club';

    return Scaffold(
      appBar: AppBar(
        title: Text('Indovina il Calciatore'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: indice + 1,
                itemBuilder: (context, index) {
                  final dato = carrieraCompleta[index];
                  final periodo = dato['periodo'];
                  final squadra = dato['squadra'];
                  final presenze = dato['presenze'] ?? 'N/A';
                  final gol = dato['gol'] ?? 'N/A';
                  final categoria =
                      index < giovanili.length ? 'Giovanili' : 'Squadre di Club';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(categoria)),
                        Expanded(child: Text(periodo)),
                        Expanded(child: Text(squadra)),
                        Expanded(child: Text(presenze.toString())),
                        Expanded(child: Text(gol.toString())),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: finito ? null : aggiornaCarriera,
              child: Text(finito ? 'Carriera terminata' : 'Prossima Squadra'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: rispostaController,
              decoration: InputDecoration(
                labelText: 'Indovina il calciatore',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: verificaIndovinato,
              child: Text('Verifica risposta'),
            ),
            SizedBox(height: 40),  // Distanziare i pulsanti
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Il calciatore era'),
                    content: Text(calciatore),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Mi arrendo'),
            ),
          ],
        ),
      ),
    );
  }
}
