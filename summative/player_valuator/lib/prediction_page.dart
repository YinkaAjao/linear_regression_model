import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionPage extends StatefulWidget {
  const PredictionPage({Key? key}) : super(key: key);

  @override
  PredictionPageState createState() => PredictionPageState();
}

class PredictionPageState extends State<PredictionPage> {
  final String apiUrl = "https://scoutconnect-api.onrender.com/predict";

  final Map<String, TextEditingController> controllers = {
    'Overall': TextEditingController(text: '75'),
    'Potential': TextEditingController(text: '82'),
    'Age': TextEditingController(text: '22'),
    'Height': TextEditingController(text: '180'),
    'Weight': TextEditingController(text: '75'),
    'technical_skill': TextEditingController(text: '70'),
    'physical_ability': TextEditingController(text: '72'),
    'attacking_prowess': TextEditingController(text: '68'),
    'Preferred_Foot': TextEditingController(text: '1'),
    'Attacking_Work_Rate': TextEditingController(text: '2'),
    'Defensive_Work_Rate': TextEditingController(text: '1'),
  };

  bool isLoading = false;
  String predictionResult = '';
  String valueCategory = '';

  // ----------------------------
  // Format market value
  // ----------------------------
  String _formatCurrency(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toString();
  }

  // ----------------------------
  // Reusable Responsive Field
  // ----------------------------
  Widget _buildNumberField(String fieldKey, String label) {
    return SizedBox(
      width: 160,
      child: TextFormField(
        controller: controllers[fieldKey],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  // ----------------------------
  // Prediction Request
  // ----------------------------
  Future<void> makePrediction() async {
    for (var c in controllers.entries) {
      if (c.value.text.isEmpty) {
        setState(() => predictionResult = "Error: Please fill all fields.");
        return;
      }
    }

    setState(() {
      isLoading = true;
      predictionResult = "";
      valueCategory = "";
    });

    try {
      final payload = {
        'Overall': double.parse(controllers['Overall']!.text),
        'Potential': double.parse(controllers['Potential']!.text),
        'Age': int.parse(controllers['Age']!.text),
        'Height': double.parse(controllers['Height']!.text),
        'Weight': double.parse(controllers['Weight']!.text),
        'technical_skill': double.parse(controllers['technical_skill']!.text),
        'physical_ability': double.parse(controllers['physical_ability']!.text),
        'attacking_prowess': double.parse(controllers['attacking_prowess']!.text),
        'Preferred_Foot': int.parse(controllers['Preferred_Foot']!.text),
        'Attacking_Work_Rate': int.parse(controllers['Attacking_Work_Rate']!.text),
        'Defensive_Work_Rate': int.parse(controllers['Defensive_Work_Rate']!.text),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final value = data["predicted_value"];

        setState(() {
          predictionResult =
              "Predicted Market Value: €${_formatCurrency(value)}";
          valueCategory = data["value_category"];
        });
      } else {
        setState(() {
          predictionResult =
              "Error: ${response.statusCode} — ${response.body}";
        });
      }
    } catch (e) {
      setState(() => predictionResult = "Error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ScoutConnect Valuation"),
        elevation: 0,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---------------------
                    // PLAYER ATTRIBUTES CARD
                    // ---------------------
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Player Attributes",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildNumberField('Overall', 'Overall Rating'),
                                _buildNumberField('Potential', 'Potential'),
                                _buildNumberField('Age', 'Age'),
                                _buildNumberField('Height', 'Height (cm)'),
                                _buildNumberField('Weight', 'Weight (kg)'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ---------------------
                    // SKILLS CARD
                    // ---------------------
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Player Skills",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildNumberField(
                                    'technical_skill', 'Technical Skill'),
                                _buildNumberField(
                                    'physical_ability', 'Physical Ability'),
                                _buildNumberField(
                                    'attacking_prowess', 'Attacking Prowess'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ---------------------
                    // PLAYER PREFERENCES
                    // ---------------------
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Player Preferences",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildNumberField(
                                    'Preferred_Foot', 'Preferred Foot'),
                                _buildNumberField('Attacking_Work_Rate',
                                    'Attacking Work Rate'),
                                _buildNumberField('Defensive_Work_Rate',
                                    'Defensive Work Rate'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Foot: 0=Left, 1=Right | Work Rate: 0=Low, 1=Medium, 2=High',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ---------------------
                    // Predict Button
                    // ---------------------
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : makePrediction,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Predict Market Value",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------------------
                    // RESULT CARD
                    // ---------------------
                    if (predictionResult.isNotEmpty)
                      Card(
                        color: predictionResult.contains("Error")
                            ? Colors.red[50]
                            : Colors.green[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                predictionResult.contains("Error")
                                    ? Icons.error
                                    : Icons.attach_money,
                                color: predictionResult.contains("Error")
                                    ? Colors.red
                                    : Colors.green,
                                size: 45,
                              ),
                              const SizedBox(height: 14),

                              Text(
                                predictionResult,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: predictionResult.contains("Error")
                                      ? Colors.red
                                      : Colors.green[900],
                                ),
                              ),

                              if (valueCategory.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    valueCategory,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),

                              if (!predictionResult.contains("Error")) ...[
                                Text(
                                  "Confidence: ±€371,000",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                ),
                                Text(
                                  "Model Accuracy: 93.7%",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}