String validatePhone(String value) {
    if (value.isEmpty) return 'Phone is required.';
    final RegExp nameExp = new RegExp(r'(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)');
    if (!nameExp.hasMatch(value))
      return 'Please enter only phone .';
    return null;
  }

  String validateEmail(String value) {
    if (value.isEmpty) return 'Email is required.';
    final RegExp nameExp = new RegExp(r'^\w+[\w-\.]*\@\w+((-\w+)|(\w*))\.[a-z]{2,3}$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only email.';
    return null;
  }

  String validateUrl(String value) {
    if (value.isEmpty) return 'URL is required.';
    final RegExp nameExp = new RegExp(r'(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?');
    if (!nameExp.hasMatch(value))
      return 'Please enter only URL.';
    return null;
  }

  String validateText(String value) {
    if (value.isEmpty) return 'Text is required.';
    final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String validateNotEmpty(String value) {
    if (value.isEmpty) return 'Text is required.';
    return null;
  }

  String validateNum(String value,int min, int max) {
    if (value.isEmpty) return 'Number is required.';
    double d = double.parse(value);
    if (d>=min && d<=max){
      return null;
    } 
    return 'Please enter number only between $min and $max.';
  }

  String validateStringMax(String value, int max) {
    if (value.isEmpty) return 'Text is required.';
    if (value.length > max){
      return 'Please enter only $max characters.';
    }
    return null;
  }

 String validateLat(String value) {
    if (value.isEmpty) return 'Number Decimal is required.';
    double lat = double.parse(value);
    if (!(lat>=-90 && lat <=90))
      return 'Please enter only latitude. (-90.0>=lat && lat<=90.0).';
    return null;
  }

  String validateLng(String value) {
    if (value.isEmpty) return 'Number Decimal is required.';
    double lng = double.parse(value);
    if (!(lng>=-180 && lng <=180))
      return 'Please enter only longitude. (-180.0>=lng && lng<=180.0).';
    return null;
  }

  String validateInt(String value) {
    if (value.isEmpty) return 'Number is required.';
    final RegExp nameExp = new RegExp(r'^\d+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only integer.';
    return null;
  }