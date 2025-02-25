
import 'package:flutter_test/flutter_test.dart';
import 'package:main_app/MedicationCalculatorWidget.dart';

void main(){
  test('Oral Dosage should be 2.60ml mg&mg/ml',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.oralCalculation(130, 250, 5, WeightUnit.mg, WeightUnit.mg);
    expect(result,"2.60");
  });

  test('Oral Dosage should be 2.60ml g&mg/ml',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.oralCalculation(0.130, 250, 5, WeightUnit.g, WeightUnit.mg);
    expect(result,"2.60");
  });

  test('Oral Dosage should be 2.60ml g&g/ml',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.oralCalculation(0.130, 0.250, 5, WeightUnit.g, WeightUnit.g);
    expect(result,"2.60");
  });

  test('Oral Dosage should be 2.60ml mcg&mg/ml',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.oralCalculation(130000, 250, 5, WeightUnit.mcg, WeightUnit.mg);
    expect(result,"2.60");
  });

  test('Oral Dosage should be 2.60ml ng&mg/ml',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.oralCalculation(130000000, 250, 5, WeightUnit.ng, WeightUnit.mg);
    expect(result,"2.60");
  });

  test('Drops ',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.dropsCalculator(10,5,2);
    expect(result,"4.00");
  });

  test('Infusion Dosage',( ){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionDosageCalculation(800,500,60,15, WeightUnit.mg,InfVolUnit.mlhour, InfDosUnit.mcgmin);
    expect(result,"6.67");
  });

  test('Infusion Dosage 2',( ){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionDosageCalculation(800,500,60,15, WeightUnit.mg,InfVolUnit.mlhour, InfDosUnit.ngmin);
    expect(result,"6666.67");
  });
  test('Infusion Dosage 3',( ){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionDosageCalculation(800,500,60,15, WeightUnit.mg,InfVolUnit.mlmin, InfDosUnit.mcgmin);
    expect(result,"400.00");
  });
  test('Infusion Dosage 4',( ){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionDosageCalculation(0.800,500,60,15, WeightUnit.g,InfVolUnit.mlhour, InfDosUnit.mcgmin);
    expect(result,"6.67");
  });

  test('Infusion Volume',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionVolumeCalculator(800,500,60,6.67, WeightUnit.mg,InfVolUnit.mlhour, InfDosUnit.mcgmin);
    expect(result,"15.01");
  });
  test('Infusion Volume 2',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionVolumeCalculator(800,500,60,6.67, WeightUnit.mg,InfVolUnit.mlmin, InfDosUnit.mcgmin);
    expect(result,"0.25");

  });
  test('Infusion Volume 3',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionVolumeCalculator(0.800,500,60,6.67, WeightUnit.g,InfVolUnit.mlhour, InfDosUnit.mcgmin);
    expect(result,"15.01");
  });
  test('Infusion Volume 4',(){
    MedicationCalculatorWidget medicationCalculatorWidget = MedicationCalculatorWidget();
    String result = medicationCalculatorWidget.infusionVolumeCalculator(800,500,60,6670, WeightUnit.mg,InfVolUnit.mlhour, InfDosUnit.ngmin);
    expect(result,"15.01");
  });
}