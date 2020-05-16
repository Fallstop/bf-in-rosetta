import 'package:flutter/material.dart';
import 'dart:io';
void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Flutter-BF',
			theme: ThemeData(
				// This is the theme of your application.
				//
				// Try running your application with "flutter run". You'll see the
				// application has a blue toolbar. Then, without quitting the app, try
				// changing the primarySwatch below to Colors.green and then invoke
				// "hot reload" (press "r" in the console where you ran "flutter run",
				// or simply save your changes to "hot reload" in a Flutter IDE).
				// Notice that the counter didn't reset back to zero; the application
				// is not restarted.
				primarySwatch: Colors.blue,
				// This makes the visual density adapt to the platform that you run
				// the app on. For desktop platforms, the controls will be smaller and
				// closer together (more dense) than on mobile platforms.
				visualDensity: VisualDensity.adaptivePlatformDensity,
			),
			home: MyHomePage(title: 'Flutter-BF'), 
			// home: Scaffold(
			//   appBar: AppBar(
			//     title: Text("yes"),
			//   ),
			//   body: inputForm(),
			// ),
		);
	}
}

class MyHomePage extends StatefulWidget {
	MyHomePage({Key key, this.title}) : super(key: key);

	// This widget is the home page of your application. It is stateful, meaning
	// that it has a State object (defined below) that contains fields that affect
	// how it looks.

	// This class is the configuration for the state. It holds the values (in this
	// case the title) provided by the parent (in this case the App widget) and
	// used by the build method of the State. Fields in a Widget subclass are
	// always marked "final".

	final String title;

	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class inputForm extends StatefulWidget {
	@override
	inputFormState createState() {
		return inputFormState();
	}
}

// Create a corresponding State class.
// This class holds data related to the form.
class inputFormState extends State<inputForm> {
	// Create a global key that uniquely identifies the Form widget
	// and allows validation of the form.
	//
	// Note: This is a GlobalKey<FormState>,
	// not a GlobalKey<MyCustomFormState>.
	final _formKey = GlobalKey<FormState>();
	final bfCodeInputController = TextEditingController();
	final inputsInputController = TextEditingController();
	@override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    bfCodeInputController.dispose();
		inputsInputController.dispose();
    super.dispose();
  }
	var outputText = "";
	void _runBF(bfCodeInput,inputsInput) async {
		print("Input Form passed validation");
		outputText = "\nLoading Inputs";
		List codeRaw = bfCodeInput.split("");
		List code = [];
		String char = '';
		for (char in codeRaw) {
			if (char == '<' || char == '>' || char == '+' || char == '-' || char == ',' || char == '.' || char == '[' || char == ']') {
				code.add(char);
			}
		}
		outputText += "\n"+code.join();

		final inputsRaw = inputsInput.split(",");
		List<int> inputs = [];
		for (char in inputsRaw){
			inputs.add(int.parse(char));
		}
		outputText += "\n"+inputs.join();

		outputText += "\nMatching Brackets";
		int bracket_nested_level = 0;
		List<int> bracket_data = [];
		int i = 0;
		int x = 0;
		while (i < code.length) {
			print("Matching bracket: "+i.toString()+", in code length: "+ code.length.toString());
			char = code[i];
			if (char == "[") {
				bracket_nested_level++;
				bracket_data.add(bracket_nested_level);
			} else if (char == "]") {
				x = i-1;
				while (x >= 0) {
					if (bracket_data[x] == bracket_nested_level) {
						bracket_data.add(x);
            print("Bracket Matched: "+x.toString());
            bracket_nested_level--;
						break;
					}
					x--;
				}
			} else {
				bracket_data.add(-1);
			}
			i++;
		}
		outputText += "\nBracket Matching done";
		int codePointer = 0;
		int inputPointer = 0;
		int memoryPointer = 0;
		List<int> memory = [0];
		while (codePointer < code.length) {
			char = code[codePointer];
			print("Excuting: "+codePointer.toString()+", Char: "+char);
			switch (char) {
				case ">":
					memoryPointer++;
					break;
				case "<":
					memoryPointer--;
					break;
				case "+":
					memory[memoryPointer]++;
					break;
				case "-":
					memory[memoryPointer]--;
					break;
				case ",":
					print("Taking input: "+inputs[inputPointer].toString());
					memory[memoryPointer] = inputs[inputPointer];
          inputPointer++;
					break;
				case ".":
          setState(() {
            outputText += "\n Output: " + memory[memoryPointer].toString();
          });
					break;
				case "]":
          print("Might be going back");
          if (memory[memoryPointer] != 0) {
            print("Going back to "+(bracket_data[codePointer]-1).toString());
            codePointer = bracket_data[codePointer]-1;
          }
					break;
			}
			while (memoryPointer >= memory.length) {
				memory.add(0);
			}
			codePointer++;
		}

	}

	@override
	Widget build(BuildContext context) {
		// Build a Form widget using the _formKey created above.
		return Form(
			key: _formKey,
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						TextFormField(
							decoration: InputDecoration(
								labelText: 'Enter BF code*'
							),
							validator: (value) {
								if (value.isEmpty) {
									return 'Please enter some text';
								}
								return null;
							},
							controller: bfCodeInputController,
						),
						TextFormField(
							decoration: InputDecoration(
								labelText: 'Enter inputs (comma seperated)'
							),
							validator: (value) {
								var splitValues = value.split(",");
								var valToBeTested;
								var vaild = true;
								var helpText = "Inputs need to be comma seperated and nurmic";
								for (valToBeTested in splitValues) {
									if (!isNumeric(valToBeTested)) {
										vaild = false;
										break;
									}
								}
								if (vaild == true) {
									return null;
								} else {
									return helpText;
								}	
							},
							controller: inputsInputController,
						),
						new Container(
							margin: const EdgeInsets.all(15.0),
							padding: const EdgeInsets.all(3.0),
							width: double.infinity,
							decoration: BoxDecoration(
								border: Border.all(color: Colors.blueAccent),
								color: Color.fromRGBO(230, 230, 230, 0.5),
							),
							child: RichText(text: TextSpan (
								text: "Outputs:",
								style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0, color: Colors.black),
								children: <TextSpan> [
									TextSpan(text: outputText, style: TextStyle(fontWeight: FontWeight.normal,fontSize: 15.0,fontStyle: FontStyle.normal)),
								]
							),),
				),
				FloatingActionButton(
						onPressed: () {
							// Validate returns true if the form is valid, or false
							// otherwise.
							print("Input Form submited, vaildating");
							if (_formKey.currentState.validate()) {
								// If the form is valid, display a Snackbar.
								Scaffold.of(context)
										.showSnackBar(SnackBar(content: Text('Running Code')));
								_runBF(bfCodeInputController.text,inputsInputController.text);
							}
							},
						tooltip: 'Run Code',
						child: Icon(Icons.play_arrow),
						),
					],
				),
			),
		);
	}
}

class _MyHomePageState extends State<MyHomePage> {
	int _counter = 0;



	@override
	Widget build(BuildContext context) {
		// This method is rerun every time setState is called, for instance as done
		// by the _incrementCounter method above.
		//
		// The Flutter framework has been optimized to make rerunning build methods
		// fast, so that you can just rebuild anything that needs updating rather
		// than having to individually change instances of widgets.
		return Scaffold(
			appBar: AppBar(
				// Here we take the value from the MyHomePage object that was created by
				// the App.build method, and use it to set our appbar title.
				title: Text(widget.title),
			),
			body:
				// Center is a layout widget. It takes a single child and positions it
				// in the middle of the parent.
				
				Column(
					// Column is also a layout widget. It takes a list of children and
					// arranges them vertically. By default, it sizes itself to fit its
					// children horizontally, and tries to be as tall as its parent.
					//
					// Invoke "debug painting" (press "p" in the console, choose the
					// "Toggle Debug Paint" action from the Flutter Inspector in Android
					// Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
					// to see the wireframe for each widget.
					//
					// Column has various properties to control how it sizes itself and
					// how it positions its children. Here we use mainAxisAlignment to
					// center the children vertically; the main axis here is the vertical
					// axis because Columns are vertical (the cross axis would be
					// horizontal).
					mainAxisAlignment: MainAxisAlignment.start,
					children: <Widget>[
						inputForm(),
					],
				),

		);
	}
}

bool isNumeric(String s) {
 if (s == null) {
	 return false;
 }
 return double.tryParse(s) != null;
}