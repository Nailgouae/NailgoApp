class StringHelper{

  bool stringContains(string,part){
    return string.toLowerCase().contains(part.toLowerCase());
  }
}

extension StringExtensions on String {
  Uri? toUri() => Uri.tryParse(this);
}