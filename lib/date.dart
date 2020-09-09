class DateException implements Exception {
  String _message;
  DateException(this._message);
  @override
  String toString() {
    return _message;
  }
}

class Date {
  int _day;
  int _month;
  int _year;
  Date(this._day, this._month, this._year);
  Date.now() : this.fromDateTime(DateTime.now());
  Date.fromString(String date) {
    var parts = date.split('-');
    _day = int.parse(parts[0]);
    _month = int.parse(parts[1]);
    _year = int.parse(parts[2]);
  }
  Date.fromDateTime(DateTime date) {
    _day = date.day;
    _month = date.month;
    _year = date.year;
  }
  @override
  String toString() {
    String dayFill = _day < 10 ? '0' : '';
    String monthFill = _month < 10 ? '0' : '';
    return dayFill +
        _day.toString() +
        '-' +
        monthFill +
        _month.toString() +
        '-' +
        _year.toString();
  }

  void nextDay() {
    ++_day;
    if (_day > daysInMonth) {
      nextMonth();
      _day = 1;
    }
  }

  void nextMonth() {
    ++_month;
    if (_month > 12) {
      ++_year;
      _month = 1;
    }
  }

  bool isLeap() => (_year % 4 == 0 && _year % 100 != 0) || _year % 400 == 0;

  static var _daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  int get daysInMonth {
    _daysInMonth[1] = isLeap() ? 29 : 28;
    return _daysInMonth[_month];
  }

  bool isSame(Date other) =>
      _year == other._year && _month == other._month && _day == other._day;

  bool operator <(Date other) =>
      _year < other._year ||
      _year == other._year && _month < other._month ||
      _year == other._year && _month == other._month && _day < other._day;

  static int difference(Date one, Date two) {
    return DateTime(one._year, one._month, one._day)
        .difference(DateTime(two._year, two._month, two._day))
        .inDays
        .abs();
  }
}
