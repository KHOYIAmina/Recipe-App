class DataModel {
  final String title;
  final String imageName;
  DataModel(
    this.title,
    this.imageName,
  );
}

List<DataModel> dataList = [
  DataModel("Butter Panneer", "assets/images/Butter-Panneer.jpg"),
  DataModel("French Toast", "assets/images/french-toast.jpg"),
  DataModel("Mexican Pizza", "assets/images/mexican-pizza.jpg"),
  DataModel("Ramen Noodles", "assets/images/ramen-noodles.jpg"),
];
