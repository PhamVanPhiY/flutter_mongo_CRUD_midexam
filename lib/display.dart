import 'package:flutter/material.dart';
import 'package:flutter_mongodb_crud_midexam/MongoDBModel.dart';
import 'package:flutter_mongodb_crud_midexam/dbHelper/mongodb.dart';
import 'package:flutter_mongodb_crud_midexam/insert.dart';

class MongoDbDisplay extends StatefulWidget {
  const MongoDbDisplay({super.key});

  @override
  State<MongoDbDisplay> createState() => _MongoDbDisplayState();
}

class _MongoDbDisplayState extends State<MongoDbDisplay> {
  int totalTasks = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    var data = await MongoDatabase.getData();
    setState(() {
      totalTasks = data.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                'Total Tasks: $totalTasks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: FutureBuilder(
                  future: MongoDatabase.getData(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return displayCard(
                              MongoDbModel.fromJson(snapshot.data[index]),
                            );
                          },
                        );
                      } else {
                        return Center(child: Text("No data available."));
                      }
                    }
                  },
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  print("Create new task");
                  _navigateToInsertPage();
                },
                child: Icon(Icons.add),
                tooltip: 'Create Task',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInsertPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MongoDBInsert()),
    ).then((_) => _fetchData());
  }

  Widget displayCard(MongoDbModel data) {
    TextEditingController taskNameController =
        TextEditingController(text: data.taskName);

    // Phân tách giờ và phút từ data.time
    List<String> timeParts = data.time.split(':');
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    String priority = data.priority; // Giá trị mặc định cho dropdown
    final List<String> priorities = [
      'Not Important',
      'Important',
      'Very Important'
    ];
    bool isEditing = false; // Biến kiểm soát trạng thái chỉnh sửa

    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isEditing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: taskNameController,
                            decoration: InputDecoration(labelText: 'Task Name'),
                          ),
                          Row(
                            children: [
                              Text('Selected Time: '),
                              SizedBox(width: 10),
                              Text(
                                selectedTime.format(context),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                    });
                                  }
                                },
                                child: Text('Pick Time'),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: priority,
                            items: priorities.map((String priority) {
                              return DropdownMenuItem<String>(
                                value: priority,
                                child: Text(priority),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                priority = newValue!;
                              });
                            },
                            decoration: InputDecoration(labelText: 'Priority'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Task: ${data.taskName}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Time: ${data.time}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Priority: ${data.priority}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          isEditing = true; // Bật chế độ chỉnh sửa
                        });
                      },
                    ),
                    if (isEditing)
                      IconButton(
                        icon: Icon(Icons.save, color: Colors.green),
                        onPressed: () async {
                          // Lưu thay đổi
                          String formattedTime =
                              '${selectedTime.hour}:${selectedTime.minute}';
                          var updatedData = MongoDbModel(
                            taskName: taskNameController.text,
                            time: formattedTime,
                            priority: priority,
                          );
                          await MongoDatabase.update(data, updatedData);
                          setState(() {
                            isEditing = false; // Tắt chế độ chỉnh sửa
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Task updated successfully')));
                          _fetchData(); // Tải lại dữ liệu
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await MongoDatabase.delete(data);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Delete task successfully')));
                        _fetchData(); // Tải lại dữ liệu sau khi xóa
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
