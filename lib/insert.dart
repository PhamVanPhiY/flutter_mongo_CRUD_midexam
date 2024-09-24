import 'package:flutter/material.dart';
import 'package:flutter_mongodb_crud_midexam/MongoDBModel.dart';
import 'package:flutter_mongodb_crud_midexam/dbHelper/mongodb.dart';
import 'package:flutter_mongodb_crud_midexam/display.dart';

class MongoDBInsert extends StatefulWidget {
  const MongoDBInsert({super.key});

  @override
  _MongoDBInsertState createState() => _MongoDBInsertState();
}

class _MongoDBInsertState extends State<MongoDBInsert> {
  final TextEditingController _taskNameController =
      TextEditingController(); // Controller cho TextField
  TimeOfDay? _selectedTime;
  String _priority = 'Not Important'; // Giá trị mặc định cho dropdown

  // Danh sách độ ưu tiên
  final List<String> _priorities = [
    'Not Important',
    'Important',
    'Very Important'
  ];

  // Hàm chọn thời gian
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Hàm xóa toàn bộ các trường
  void clearAll() {
    setState(() {
      _taskNameController.clear(); // Xóa giá trị TextField
      _selectedTime = null; // Xóa thời gian đã chọn
      _priority = 'Not Important'; // Reset dropdown về giá trị mặc định
    });
  }

  // Hủy controller để tránh rò rỉ bộ nhớ
  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar và tên người dùng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      _navigateToDisplayPage(); // Quay lại trang trước
                    },
                  ),
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/user.jpg'),
                      ),
                      SizedBox(width: 8),
                      Text('Phạm Văn Phi'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Nhập tên task
              TextField(
                controller: _taskNameController, // Sử dụng controller
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              SizedBox(height: 20),

              // Chọn thời gian
              Row(
                children: [
                  Text('Selected Time:'),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'No time selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _pickTime(context),
                    child: Text('Pick Time'),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Dropdown chọn mức độ ưu tiên
              DropdownButtonFormField<String>(
                value: _priority,
                items: _priorities.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              SizedBox(height: 40),

              // Nút thêm task
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen, // Màu xanh nhẹ
                  ),
                  onPressed: () async {
                    if (_taskNameController.text.isNotEmpty &&
                        _selectedTime != null) {
                      // Gọi hàm _insertData với các giá trị từ form
                      await _insertData(
                          _taskNameController.text, _selectedTime!, _priority);

                      // Hiển thị thông báo thêm thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Task added successfully!')));
                    } else {
                      // print("Task name or time is missing");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Task name or time is missing')));
                    }
                  },
                  child: Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDisplayPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MongoDbDisplay()),
    );
  }

  Future<void> _insertData(
      String taskName, TimeOfDay selectedTime, String priority) async {
    final String formattedTime = '${selectedTime.hour}:${selectedTime.minute}';
    print('Task Name: $taskName');
    print('Selected Time: $formattedTime');
    print('Priority: $priority');

    final data = MongoDbModel(
        taskName: taskName, time: formattedTime, priority: priority);
    var result = await MongoDatabase.insert(data);
    clearAll();
  }
}
