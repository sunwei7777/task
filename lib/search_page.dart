import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '搜索',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _buildSearchAndFilterBar(),
    );
  }

  // 搜索和筛选栏
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                style: TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: '输入内容',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                  isDense: true,
                ),
                onChanged: (value) {},
              ),
            ),
          ),
          SizedBox(width: 12),
          // 筛选按钮
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4),
                Text(
                  '筛选',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
