import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/card_model.dart';
import 'package:todoapp/db/db_model.dart';

DatabaseControl db = DatabaseControl();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await db.open();

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<CardNtfr>(
          create: (context) => CardNtfr(), child: const TodoApp())));
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  @override
  void initState() {
    db.getCards(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialogg(context);
            await db.getCards(context);
          },
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text("ToDo App"),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                  children: List.generate(
                      Provider.of<CardNtfr>(context).cards.length,
                      (index) => CardWidget(
                            index: Provider.of<CardNtfr>(context, listen: false)
                                .cards[index]
                                .id!,
                            cardModel:
                                Provider.of<CardNtfr>(context, listen: false)
                                    .cards[index],
                          )))),
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final int index;
  final CardModel cardModel;

  const CardWidget({
    Key? key,
    required this.cardModel,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Hero(
        tag: "hero_${cardModel.id}",
        child: Material(
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext con) => ContentPage(
                            cardModel: cardModel,
                          )));
            },
            child: Card(
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cardModel.title!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const Spacer(),
                        CircleAvatar(
                          maxRadius: 30,
                          minRadius: 20,
                          foregroundImage: FileImage(File(cardModel.url!)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(cardModel.content!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16)),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          onPressed: () {
                            Provider.of<CardNtfr>(context, listen: false)
                                .deleteCard(index, db);
                            db.getCards(context);
                          },
                          icon: const Icon(CupertinoIcons.delete)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  final CardModel cardModel;
  const ContentPage({Key? key, required this.cardModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
          body: Hero(
              tag: "hero_${cardModel.id}",
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Image.file(File(cardModel.url!)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        cardModel.title!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        cardModel.content!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

Future showDialogg(BuildContext context) {
  TextEditingController titleCont = TextEditingController();
  TextEditingController contentCont = TextEditingController();

  String? _image;

  var pickedImage;
  final picker = ImagePicker();
  Future choiceImage() async {
    pickedImage = (await picker.pickImage(source: ImageSource.gallery));

    _image = (pickedImage!.path);
  }

  return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: const Text('New'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCont,
                  decoration: const InputDecoration(hintText: "Başlık"),
                ),
                TextField(
                  controller: contentCont,
                  decoration: const InputDecoration(hintText: "İçerik"),
                ),
                const SizedBox(height: 30),
                IconButton(
                    onPressed: () async {
                      await choiceImage();
                    },
                    icon: const Icon(Icons.upload)),
              ],
            ),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    await db.addCard(CardModel(
                        title: titleCont.text,
                        content: contentCont.text,
                        url: _image.toString()));
                    Navigator.pop(context);
                  })
            ],
          ));
}
