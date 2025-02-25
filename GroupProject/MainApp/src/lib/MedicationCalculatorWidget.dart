import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'data/patient.dart';
import 'database.dart';

class MedicationCalculatorWidget extends StatefulWidget{

  /*
  This widget provides the functionality to do four types of medication calculation:
    1) Oral
    2) Infusion dosage
    3) Infusion volume
    4) Drops
  Infusion dosage and volume are closely related so are included in one calculation form

  The widget first launches a menu page with buttons which when selected will make
  the correct calculation fields be displayed on the page

  All fields who's units tend to be variable have their units expressed as a dropdown
  to avoid the nurses having to convert them

  IMPORTANT : To ensure auto logout please only call the StatelessMultiGraphWidget
  which wraps this in a SmartWidget
   */

  int age;
  bool ageGiven = false;
  int months;
  String _patientId = "NONE";
  List<bool> boygirl = [true, false]; //needed in weight estimation

  //initialisation with patient data
  MedicationCalculatorWidget.initWithAge(Database db, String patientId){
    Patient p= db.getPatient(patientId);
    this._patientId = p.getDisplayableId().toUpperCase();
    this.age = p.getAge();
    ageGiven = true;
  }

  //initialisation with no patient data
  MedicationCalculatorWidget();

  double getMassMultiplier(WeightUnit weightUnit){
    switch(weightUnit){
    //RELATIVE TO MG NOT TO GRAMS
      case(WeightUnit.g): return 1000;
      case(WeightUnit.mg): return 1;
      case(WeightUnit.mcg): return 0.001;
      case(WeightUnit.ng): return 0.000001;
    }
  }

  double getInfDoseMultiplier(InfDosUnit infDosUnit){
    switch(infDosUnit){
      case(InfDosUnit.gmin): return 60*1000.0;
      case(InfDosUnit.mgmin): return 60;
      case(InfDosUnit.mcgmin): return 60/1000.0;
      case(InfDosUnit.ngmin): return 60/1000000.0;
      case(InfDosUnit.ghour): return 1000;
      case(InfDosUnit.mghour): return 1;
      case(InfDosUnit.mcghour): return 1/1000.0;
      case(InfDosUnit.nghour): return 1/1000000.0;
    }
  }

  double getInfVolMultiplier(InfVolUnit infVolUnit){
    switch(infVolUnit){
      case InfVolUnit.mlmin:
        return 1/60;
      case InfVolUnit.mlhour:
        return 1;
    }
  }

  String oralCalculation(double dosage, double strength, double volume, WeightUnit weightUnit, WeightUnit strengthUnit){
    double result = dosage / strength * volume;
    //Multiply relative to mg for weight
    //inverse to mg for strength
    result *= getMassMultiplier(weightUnit);
    result /= getMassMultiplier(strengthUnit);
    return result.toStringAsFixed(2);
  }

  String infusionDosageCalculation(double strength, double volume, double weight, double mlperhour, WeightUnit strengthUnit, InfVolUnit infVolUnit, InfDosUnit infDosUnit){
    double result = strength/volume*mlperhour/weight;
    result *= getMassMultiplier(strengthUnit);
    result /= getInfVolMultiplier(infVolUnit);
    //THE RESULT IS NOW IN Mg per kg per hour
    result /= getInfDoseMultiplier(infDosUnit);
    return result.toStringAsFixed(2);
  }


  String infusionVolumeCalculator(double strength, double volume, double weight, double dosage, WeightUnit strengthUnit, InfVolUnit infVolUnit, InfDosUnit infDosUnit){
    double result = dosage* weight * volume / strength;

    result *= getInfDoseMultiplier(infDosUnit);
    result /= getMassMultiplier(strengthUnit);
    //result is now in ml/hour
    result *= getInfVolMultiplier(infVolUnit);
    return result.toStringAsFixed(2);
  }

  String dropsCalculator(double volume, double time, double factor){
    double result = volume/time * factor;
    return result.toStringAsFixed(2);
  }

  @override
  _MedicationCalculatorWidgetState createState() => _MedicationCalculatorWidgetState();
}


class _MedicationCalculatorWidgetState extends State<MedicationCalculatorWidget> {

  WeightUnit selectedWeightUnit = WeightUnit.mg;
  WeightUnit selectedStrengthWeightUnit = WeightUnit.mg;
  InfDosUnit selectedInfDoseUnit = InfDosUnit.mcgmin;
  InfVolUnit selectedInfVolUnit = InfVolUnit.mlmin;
  Calculations selectedCalculation;
  Calculations selectedInfCalc = Calculations.InfusionDosage;
  List<bool> minhour = [true,false];
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _oralFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _infDoseFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _infFieldsKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _infFieldsVolumeKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _infFieldsDosageKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _dropFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _weightKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _ageKey = GlobalKey<FormState>();

  bool showCalc = false;
  String result = "";

  String enumToUnit(bool isVol, String val){
    if (isVol){
      return val.split(".")[1].replaceAll("l", "l/");
    }else{
      return val.split(".")[1].replaceAll("g", "g/kg/");
    }
  }
  String getUnit(){
    switch(selectedCalculation) {
      case Calculations.Oral:
      return "ml";
      case Calculations.Infusion:

        if (selectedInfCalc == Calculations.InfusionVolume) return enumToUnit(true, selectedInfVolUnit.toString());
        return enumToUnit(false, selectedInfDoseUnit.toString());

      case Calculations.InfusionDosage:
      return "Mcg/kg/min";
      case Calculations.InfusionVolume:
      return "ml/hr";
      case Calculations.DropsPerMinute:
      return "drops/min";
    }
  }

  String getButtonText(){
    if (selectedCalculation == Calculations.Infusion){
      if (selectedInfCalc == Calculations.InfusionDosage){
        return "CALCULATE DOSAGE";
      }else{
        return "CALCULATE VOLUME";
      }
    }
    return "CALCULATE";
  }

  String getResultText(){
    switch(selectedCalculation) {
      case Calculations.Infusion:
        if (selectedInfCalc == Calculations.InfusionVolume) return "The infusion should run at ";
        return "The child is receiving a dose of";
      default:
        return "Suggested Amount";
    }
  }

  String intValidator(String number) {
    if (int.tryParse(number) == null)
      return "Required";
    return null;
  }

  String doubleValidator(String number) {
    if (double.tryParse(number) == null)
      return "Required";
    return null;
  }

  InputDecoration textInputDecoration = new InputDecoration(

    labelText: "Label Text",
    suffixText: '',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(
        color: Colors.amber,
        style: BorderStyle.solid,
      ),

    ),

  );

  var oralDosageController = TextEditingController();
  var stockStrengthController = TextEditingController();
  var stockVolumeController = TextEditingController();
  var infusionDosagemlperhourController = TextEditingController();
  var infusionVolumeDosageController = TextEditingController();
  var dropVolumeController = TextEditingController();
  var dropTimeController = TextEditingController();
  var dropFactorController = TextEditingController();
  var weightController = TextEditingController();
  var monthsController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ageController.addListener(() {
      setState(() {
        this.widget.age = int.tryParse(ageController.text);
      });
    });

    monthsController.addListener(() {
      setState(() {
        this.widget.months = int.tryParse(monthsController.text);
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    oralDosageController.dispose();
    stockStrengthController.dispose();
    stockVolumeController.dispose();
    infusionDosagemlperhourController.dispose();
    infusionVolumeDosageController.dispose();
    dropVolumeController.dispose();
    dropTimeController.dispose();
    dropFactorController.dispose();
    weightController.dispose();
    monthsController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void resetFields(){
    oralDosageController.clear();
    stockStrengthController.clear();
    stockVolumeController.clear();
    infusionDosagemlperhourController.clear();
    infusionVolumeDosageController.clear();
    dropVolumeController.clear();
    dropTimeController.clear();
    dropFactorController.clear();
    weightController.clear();
    monthsController.clear();
    selectedWeightUnit = WeightUnit.mg;
    selectedStrengthWeightUnit = WeightUnit.mg;
    selectedInfDoseUnit = InfDosUnit.mcgmin;
    result = "";
  }

  double estimateGirlWeight(){
    if (widget.age<2){
      switch(widget.months){
        case 0 : return 3.5;
        case 1 :
        case 2 : return 4.5;
        case 3 :
        case 4:
        case 5: return 6;
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11: return 7;
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:return 9;
        default: return 10;

      }
    }else{
      switch(widget.age){
        case 2: return 12;
        case 3: return 14;
        case 4: return 16;
        case 5: return 18;
        case 6: return 20;
        case 7: return 22;
        case 8: return 25;
        case 9: return 28;
        case 10: return 32;
        case 11: return 35;
        case 12: return 43;
        case 13 : return 43;
        case 14: return 50;
        default: return 70;
      }
    }
  }

  double estimateBoyWeight(){
    if (widget.age<2){
      switch(widget.months){
        case 0 : return 3.5;
        case 1 :
        case 2 : return 4.5;
        case 3 :
        case 4:
        case 5: return 6.5;
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11: return 8;
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:return 9.5;
        default: return 11;

      }
    }else{
      switch(widget.age){
        case 2: return 12;
        case 3: return 14;
        case 4: return 16;
        case 5: return 18;
        case 6: return 21;
        case 7: return 23;
        case 8: return 25;
        case 9: return 28;
        case 10: return 31;
        case 11: return 35;
        case 12: return 43;
        case 13 : return 43;
        case 14: return 50;
        default: return 70;
      }
    }
  }

  double getMassMultiplier(WeightUnit weightUnit){
    switch(weightUnit){
      //RELATIVE TO MG NOT TO GRAMS
      case(WeightUnit.g): return 1000;
      case(WeightUnit.mg): return 1;
      case(WeightUnit.mcg): return 0.001;
      case(WeightUnit.ng): return 0.000001;
    }
  }
  
  double getInfDoseMultiplier(InfDosUnit infDosUnit){
    switch(infDosUnit){
      case(InfDosUnit.gmin): return 60*1000.0;
      case(InfDosUnit.mgmin): return 60;
      case(InfDosUnit.mcgmin): return 60/1000.0;
      case(InfDosUnit.ngmin): return 60/1000000.0;
      case(InfDosUnit.ghour): return 1000;
      case(InfDosUnit.mghour): return 1;
      case(InfDosUnit.mcghour): return 1/1000.0;
      case(InfDosUnit.nghour): return 1/1000000.0;
    }
  }

  double getInfVolMultiplier(InfVolUnit infVolUnit){
    switch(infVolUnit){
      case InfVolUnit.mlmin:
        return 1/60;
      case InfVolUnit.mlhour:
        return 1;
    }
  }

  String validateForm(){
    switch(selectedCalculation){
      case Calculations.Oral:
        if(_oralFormKey.currentState.validate()){
          return widget.oralCalculation(double.parse(oralDosageController.text),
              double.parse(stockStrengthController.text),
              double.parse(stockVolumeController.text),
            selectedWeightUnit,
            selectedStrengthWeightUnit
          );
        }
        return "";
      case Calculations.Infusion:
          bool weightOk = _weightKey.currentState.validate();
          if(selectedInfCalc == Calculations.InfusionDosage){
            if (_infFieldsKey.currentState.validate() && weightOk &&
                _infFieldsVolumeKey.currentState.validate()) {
              return widget.infusionDosageCalculation(double.parse(stockStrengthController.text),
                  double.parse(stockVolumeController.text),
                  double.parse(weightController.text),
                  double.parse(infusionDosagemlperhourController.text),
                  selectedStrengthWeightUnit,
                  selectedInfVolUnit,
                  selectedInfDoseUnit);
            }
          }else{
    if(_infFieldsKey.currentState.validate() && weightOk&& _infFieldsDosageKey.currentState.validate()){
              return widget.infusionVolumeCalculator(double.parse(stockStrengthController.text),
                  double.parse(stockVolumeController.text),
                  double.parse(weightController.text),
                  double.parse(infusionVolumeDosageController.text),
                selectedStrengthWeightUnit,
                selectedInfVolUnit,
                  selectedInfDoseUnit
              );
            }
          }
          return "";
      case Calculations.DropsPerMinute:
        if (_dropFormKey.currentState.validate()){
          return widget.dropsCalculator(double.parse(dropVolumeController.text),
              double.parse(dropTimeController.text),
              double.parse(dropFactorController.text));
        }
        return "";
      default: return "";
    }
  }
  @override
  Widget build(BuildContext context) {

    ToggleButtons sexToggle = ToggleButtons(children: <Widget>[
      Text(" BOY "),
      Text(" GIRL "),
    ],
      onPressed: (int index) {
        setState(() {
          for (int buttonIndex = 0; buttonIndex < widget.boygirl.length; buttonIndex++) {
            if (buttonIndex == index) {
              widget.boygirl[buttonIndex] = true;
            } else {
              widget.boygirl[buttonIndex] = false;
            }
          }
        });
      },
      isSelected: widget.boygirl,
    );

    // ToggleButtons minhourToggle = ToggleButtons(children: <Widget>[
    //   Text(" MINS "),
    //   Text(" HOURS "),
    // ],
    //   onPressed: (int index) {
    //     setState(() {
    //       for (int buttonIndex = 0; buttonIndex < minhour.length; buttonIndex++) {
    //         if (buttonIndex == index) {
    //           minhour[buttonIndex] = true;
    //         } else {
    //           minhour[buttonIndex] = false;
    //         }
    //       }
    //     });
    //   },
    //   isSelected: minhour,
    // );

    Container weightUnitDropdown = Container(
      width: 100,
      child: DropDownFormField(
        titleText: "Unit",
        value: selectedWeightUnit,
        dataSource: [
          {
            "display": "g",
            "value": WeightUnit.g,
          },
          {
            "display": "mg",
            "value": WeightUnit.mg,
          },
          {
            "display": "mcg",
            "value": WeightUnit.mcg
          },
          {
            "display": "ng",
            "value": WeightUnit.ng,
          },
        ],
        textField: 'display',
        valueField: 'value',
        onSaved: (value) {
          setState(() {
            selectedWeightUnit = value;
          });
        },
        onChanged: (value) {
          setState(() {
            selectedWeightUnit = value;
          });
        },
      ),
    );

    Container infusionDosageDropdown = Container( 
      width: 150,
      child: DropDownFormField(
        titleText: "Unit",
        value: selectedInfDoseUnit,
        dataSource: [
          {
            "display": "g/kg/min",
            "value": InfDosUnit.gmin,
          },
          {
            "display": "mg/kg/min",
            "value": InfDosUnit.mgmin,
          },
          {
            "display": "mcg/kg/min",
            "value": InfDosUnit.mcgmin
          },
          {
            "display": "ng/kg/min",
            "value": InfDosUnit.ngmin,
          },
          {
            "display": "g/kg/hour",
            "value": InfDosUnit.ghour,
          },
          {
            "display": "mg/kg/hour",
            "value": InfDosUnit.mghour,
          },
          {
            "display": "mcg/kg/hour",
            "value": InfDosUnit.mcghour,
          },
          {
            "display": "ng/kg/hour",
            "value": InfDosUnit.nghour,
          },
        ],
        textField: 'display',
        valueField: 'value',
        onSaved: (value) {
          setState(() {
            selectedInfDoseUnit = value;
          });
        },
        onChanged: (value) {
          setState(() {
            selectedInfDoseUnit = value;
          });
        },
      ),
    );


    Container infusionVolumeDropdown = Container(
      width: 150,
      child: DropDownFormField(
        titleText: "Unit",
        value: selectedInfVolUnit,
        dataSource: [
          {
            "display": "ml/min",
            "value": InfVolUnit.mlmin,
          },
          {
            "display": "ml/hour",
            "value": InfVolUnit.mlhour,
          },
        ],
        textField: 'display',
        valueField: 'value',
        onSaved: (value) {
          setState(() {
            selectedInfVolUnit = value;
          });
        },
        onChanged: (value) {
          setState(() {
            selectedInfVolUnit = value;
          });
        },
      ),
    );


    Container strengthUnitDropdown = Container(
      width: 100,
      child: DropDownFormField(
        titleText: "Unit",
        value: selectedStrengthWeightUnit,
        dataSource: [
          {
            "display": "g/ml",
            "value": WeightUnit.g,
          },
          {
            "display": "mg/ml",
            "value": WeightUnit.mg,
          },
          {
            "display": "mcg/ml",
            "value": WeightUnit.mcg
          },
          {
            "display": "ng/ml",
            "value": WeightUnit.ng,
          },
        ],
        textField: 'display',
        valueField: 'value',
        onSaved: (value) {
          setState(() {
            selectedStrengthWeightUnit = value;
          });
        },
        onChanged: (value) {
          setState(() {
            selectedStrengthWeightUnit = value;
          });
        },
      ),
    );

    AlertDialog weightExtraInfo = AlertDialog(
        title: Text(
            "Extra Information Needed"),
        content: Form(
          key: _dialogFormKey,
          child : Column(
          children : [
            TextFormField(controller: monthsController,
                keyboardType: TextInputType.number,
                validator: intValidator,
                decoration: textInputDecoration.copyWith(
                    labelText: "Age - months",
                    suffixText: "months")),
        ]),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Colors.grey)),
            child: Text(
              'Back',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Colors.green)),
            child: Text(
              "CONFIRM",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                if(_dialogFormKey.currentState.validate()){

                  widget.months = int.parse(monthsController.text);
                  if(widget.boygirl[0]){
                  weightController.text = estimateBoyWeight().toString();
                  }else{
                  weightController.text = estimateGirlWeight().toString();}
                  Navigator.of(context).pop();
                }
              });
            },
          )
        ]);

    Container weightEstimation = Container(
      child : Column(
        children :[
          sexToggle,
          SizedBox(height: 10,),
        Offstage(
          offstage: widget.ageGiven,
            child : Form(
              key : _ageKey,
                child  :Container(
              width: MediaQuery.of(context).size.width-150,
            child :TextFormField(controller: ageController,
            keyboardType: TextInputType.number,
            validator: intValidator,
            decoration: textInputDecoration.copyWith(
                labelText: "Age (years)",
                suffixText: "years"))))),
          SizedBox(height: 10,),
          Row(
        children : [
          Container(
            width: MediaQuery.of(context).size.width-250,
            child : Form(
              key : _weightKey,
              child : TextFormField(controller: weightController,
          keyboardType: TextInputType.number,
          validator: doubleValidator,
          decoration: textInputDecoration.copyWith(
              labelText: "Weight (kg)",
              suffixText: "kg"))),
    ),
          ElevatedButton(
              onPressed: (){
                setState(() {
                  //Launch alert dialog to ask for extra information
                  if (widget.ageGiven || _ageKey.currentState.validate()){
                  if(widget.age<2){
                  showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ButtonBarTheme(
                      data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
                      child : weightExtraInfo
    );});
                }else{
                    if(widget.boygirl[0]){
                    weightController.text = estimateBoyWeight().toString();
                    }else{
                    weightController.text = estimateGirlWeight().toString();
                  }
                }
                }
                }

                );
              },
              child: Text("ESTIMATE")
          )

        ]
      )
        ]
      )
    );

    Row strengthEntry = Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width : (MediaQuery.of(context).size.width-150)/2,
            child : TextFormField(controller: stockStrengthController,
                keyboardType: TextInputType.number,
                validator: doubleValidator,
                decoration: textInputDecoration.copyWith(
                    labelText: "Stock Strength ")),
          ),
          Text("/", style: textStyle(),),
          Container(
            width : (MediaQuery.of(context).size.width-150)/2,
            child : TextFormField(controller: stockVolumeController,
                keyboardType: TextInputType.number,
                validator: doubleValidator,
                decoration: textInputDecoration.copyWith(
                    labelText: "Stock Volume(ml)",
                    suffixText: "ml")),
          ),
          strengthUnitDropdown
        ]);

    Form oralFields = Form(
      key: _oralFormKey,
        child : new Column(
           children: [
             Container(
               // width : MediaQuery.of(context).size.width-150,
               height: 80,
               child : Row(
                 children : [
                Container(
                    width : MediaQuery.of(context).size.width-150,

                    child:
                 TextFormField(controller: oralDosageController,
                   keyboardType: TextInputType.number,
                   validator: doubleValidator,
                   decoration: textInputDecoration.copyWith(
                       labelText: "Desired Dose "))),
             weightUnitDropdown,
             ]
        )),
             SizedBox(height: 10,),

             strengthEntry
        ]));

    Form infusionDosageFields = Form(
      key : _infDoseFormKey,
      child :
    Column(
      children: [
              weightEstimation,
              SizedBox(height: 10,),

              Container(
                width : MediaQuery.of(context).size.width-150,
                child : TextFormField(controller: infusionDosagemlperhourController,
                    keyboardType: TextInputType.number,
                    validator: doubleValidator,
                    decoration: textInputDecoration.copyWith(
                        labelText: " ml/hour",
                        suffixText: "ml/hour")),
              ),
              SizedBox(height: 10,),

              strengthEntry
            ]
    ));



    Form infusionVolumeFields = Form (
      // key : _infVolFormKey,
      child :
      Column(
              children:[
                weightEstimation,
                SizedBox(height: 10,),
                // minhourToggle,
                // SizedBox(height: 10,),

                Container(
                  // width : MediaQuery.of(context).size.width-150,
                  height: 80,
                  child : Row(
                      children : [
                        Container(
                            width : MediaQuery.of(context).size.width-250,

                            child:
                            TextFormField(controller: infusionVolumeDosageController,
                                keyboardType: TextInputType.number,
                                validator: doubleValidator,
                                decoration: textInputDecoration.copyWith(
                                  labelText:  "Infusion Dosage",))),
                        infusionDosageDropdown
                      ]),

                ),
                SizedBox(height: 10,),

                strengthEntry
              ]
    ));

    Form infusionFields = Form (
        child :
        Column(
            children:[
              weightEstimation,
              SizedBox(height: 15),
              Container(
                  width : MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          child:Text("What's the concentration of the medication in the syringe?", style : smallerTextStyle(), maxLines: 3, textAlign: TextAlign.center,))
                    ],
                  )),
              Form(key: _infFieldsKey, child : strengthEntry),
              Offstage(offstage: selectedInfCalc==Calculations.InfusionDosage,
                  child : Container(
                      width : MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                              child:Text("What is the dose you wish the patient to receive?", style : smallerTextStyle(), maxLines: 3, textAlign: TextAlign.center,))
                        ],
                      ))
              ),
              Container(
                  width : MediaQuery.of(context).size.width,

                  child : ListTile(
                title: Container(
                  // width : MediaQuery.of(context).size.width-150,
                    height: 80,
                    child : Form (
                      key: _infFieldsDosageKey,
                    child : Row(
                        children : [
                          Container(
                              width : MediaQuery.of(context).size.width-250,
                              child:
                              TextFormField(
                                  enabled: selectedInfCalc == Calculations.InfusionVolume,
                                  controller: infusionVolumeDosageController,
                                  keyboardType: TextInputType.number,
                                  validator: doubleValidator,
                                  decoration: textInputDecoration.copyWith(
                                    labelText:  "Infusion Dosage",))),
                          infusionDosageDropdown
                        ]))),
                leading: Radio(
                  value: Calculations.InfusionVolume,
                  groupValue: selectedInfCalc,
                  onChanged: (Calculations value) {
                    setState(() {
                      selectedInfCalc = value;
                      infusionDosagemlperhourController.clear();
                    });
                  },
                ),
              )),Offstage(offstage: selectedInfCalc==Calculations.InfusionVolume,
            child : Container(
              width : MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                child:Text("How fast is the infusion running?", style : smallerTextStyle(), maxLines: 3))
                  ],
                ))),

              Container(
                  width : MediaQuery.of(context).size.width,

                  child : ListTile(
                    title: Container(
                      // width : MediaQuery.of(context).size.width-150,
                      height: 80,
                      child : Form(
                        key: _infFieldsVolumeKey,
                       child : Row(
                          children : [
                            Container(
                                width : MediaQuery.of(context).size.width-250,
                                child:
                                TextFormField(
                                    enabled: selectedInfCalc == Calculations.InfusionDosage,
                                    controller: infusionDosagemlperhourController,
                                    keyboardType: TextInputType.number,
                                    validator: doubleValidator,
                                    decoration: textInputDecoration.copyWith(
                                      labelText:  "Infusion Volume",))),
                            infusionVolumeDropdown
                          ]))),

                leading: Radio(
                  value: Calculations.InfusionDosage,
                  groupValue: selectedInfCalc,
                  onChanged: (Calculations value) {
                    setState(() {
                      selectedInfCalc = value;
                      infusionVolumeDosageController.clear();

                    });
                  },
                ),
              )),
        ]));


    Form dropsFields = Form (
    key : _dropFormKey,
    child :
    Column(
      children : [
                Container(
                  width : MediaQuery.of(context).size.width-150,
                  child : TextFormField(controller: dropVolumeController,
                      keyboardType: TextInputType.number,
                      validator: doubleValidator,
                      decoration: textInputDecoration.copyWith(
                          labelText: " IV Volume (ml)",
                          suffixText: "ml")),
                ),
                SizedBox(height: 10,),

                Container(
                  width : MediaQuery.of(context).size.width-150,
                  child : TextFormField(controller: dropTimeController,
                      keyboardType: TextInputType.number,
                      validator: doubleValidator,
                      decoration: textInputDecoration.copyWith(
                          labelText: " Time (mins)",
                          suffixText: "mins")),
                ),
                SizedBox(height: 10,),

                Container(
                  width : MediaQuery.of(context).size.width-150,
                  child : TextFormField(controller: dropFactorController,
                      keyboardType: TextInputType.number,
                      validator: doubleValidator,
                      decoration: textInputDecoration.copyWith(
                          labelText: " Drop Factor (gtts/ml)",
                          suffixText: "gtts/ml")),
                ),
              ]
            )
        );

    Form getFormFields(){
      switch(selectedCalculation){
        case Calculations.Oral:
          return oralFields;
        case Calculations.Infusion:
          return infusionFields;
        case Calculations.DropsPerMinute:
          return dropsFields;
        default:
          return Form(
            child: Text(""),);
      }
    }

    String getTitle(){
      switch(selectedCalculation){
        case Calculations.Oral:
          return "Oral Dosage Calculation";
        case Calculations.Infusion:
          return "Infusion Calculation";
        case Calculations.DropsPerMinute:
          return "Drop Calculation";
        default:
          return "";
      }
    }

    Column calcSelectPage = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 100),
        Container(
        width : MediaQuery.of(context).size.width,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    Flexible(
    child:Text("What type of calculation would you like to perform?", maxLines: 3, style: textStyle(), textAlign: TextAlign.center,))])),
        // Flexible(child : Text("What type of calculation would you like to perform?", maxLines: 5, style: textStyle(),)),
        SizedBox(height: 20,),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(Colors.blue)),
          child: Text(
            "ORAL DOSAGE CALCULATION",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              selectedCalculation = Calculations.Oral;
              showCalc = true;

            }
            );
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(Colors.blue)),
          child: Text(
            "INFUSION CALCULATIONS",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              selectedCalculation = Calculations.Infusion;
              showCalc = true;

            }
            );
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(Colors.blue)),
          child: Text(
            "DROP CALCULATIONS",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              selectedCalculation = Calculations.DropsPerMinute;
              showCalc = true;
            }
            );
          },
        )
      ],
    );



    return GestureDetector(
        onTap: () {
      FocusManager.instance.primaryFocus.unfocus();
    },
        child : Scaffold(
          appBar: AppBar(
            title: Text("Medication Calculator"),
          ),
      body: SingleChildScrollView(
       child : Row(
        mainAxisAlignment: MainAxisAlignment.center,
      children : [
        Column(
        children : [
          Offstage(
              offstage: !widget.ageGiven,
              child : Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      )
                    ]),
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  SelectableText(
                    "You are seeing information for patient",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SelectableText(widget._patientId,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                ]),
              )),
          SizedBox(height: 10,),

          Container(
          width : MediaQuery.of(context).size.width-150,
          child: Offstage(
            offstage: showCalc,
            child : calcSelectPage
          ),
        ),
          SizedBox(height: 10,),
          Container(
            width : MediaQuery.of(context).size.width-150,
            child: Offstage(
                offstage: !showCalc,
                child : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children : [Text(getTitle(), style: textStyle(), maxLines: 3,)])
            ),
          ),
          SizedBox(height: 10,),
          getFormFields(),
        Offstage(
            offstage: !showCalc,
            child : ElevatedButton(style: ButtonStyle(
            backgroundColor:
            MaterialStateProperty.all(Colors.green)),
          child: Text(
            getButtonText(),
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              result = validateForm();
              print(result);
              if (result !=""){
              showDialog(
              context: context,
    builder: (BuildContext context) {
          return ButtonBarTheme(
          data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
          child : AlertDialog(
              title:Container(
                  width : MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          child:Text(getResultText(), maxLines: 3, textAlign: TextAlign.center,))
                    ],
                  )),

              content: Text(result + getUnit(), textAlign: TextAlign.center,),
              actions:
              <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.grey)),
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pop();
                    }
                    );
                  },
                )
              ]));
              }); }
            });
            },)),


          Offstage(
            offstage: !showCalc,
            child : ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Colors.grey)),
              child: Text(
                "RESET",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  resetFields();
                }
                );
              },
            )
          )
      ])])),
    ));
  }

  TextStyle textStyle() {
    return TextStyle(
      fontSize: 23,
      color: Colors.black.withOpacity(0.6),
    );
  }

  TextStyle smallerTextStyle() {
    return TextStyle(
      fontSize: 18,
      color: Colors.black.withOpacity(0.6),
    );
  }
}


enum Calculations{
  Oral,
  Infusion,
  InfusionDosage,
  InfusionVolume,
  DropsPerMinute
}


enum WeightUnit{
  g,
  mg,
  mcg,
  ng
}

enum InfDosUnit{
  gmin,
  mgmin,
  mcgmin,
  ngmin,
  ghour,
  mghour,
  mcghour,
  nghour
}

enum InfVolUnit{
  mlmin,
  mlhour
}

