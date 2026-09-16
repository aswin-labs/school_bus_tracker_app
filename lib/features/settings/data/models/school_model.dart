class SchoolModel {
  final int id;
  final String? name;
  final String? logo;
  final String? bgImage;
  final String? primaryColour;
  final String? secondaryColour;

  SchoolModel({
    required this.id,
    this.name,
    this.logo,
    this.bgImage,
    this.primaryColour,
    this.secondaryColour,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
    id: json["id"] is int
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? '') ?? 0,
    name: json["name"],
    logo: json["logo"],
    bgImage: json["bg_image"],
    primaryColour: json["primary_colour"],
    secondaryColour: json["secondary_colour"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "logo": logo,
    "bg_image": bgImage,
    "primary_colour": primaryColour,
    "secondary_colour": secondaryColour,
  };
}
