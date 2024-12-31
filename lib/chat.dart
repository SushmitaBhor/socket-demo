class Chat{
  final String content;
  final DateTime time;

  const Chat({required this.content,required this.time});

  factory Chat.fromJson(Map<String,dynamic> json)=>Chat(content: json['content'] as String,
      time: DateTime.parse(json['time'] as String));
  Map<String,dynamic> toJson()=>{
    'content':content,
    'time':time.toIso8601String(),
  };
}