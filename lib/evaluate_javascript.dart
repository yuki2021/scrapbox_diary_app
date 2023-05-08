// 今日のDailyページを開く
String setDiaryPageJavascriptSource() {
  return '''
    var diffDate = function (date, diffDays, diffMonths = 0, diffYears = 0) {
      var d = new Date(date);
      d.setDate(d.getDate() + diffDays);
      d.setMonth(d.getMonth() + diffMonths);
      d.setFullYear(d.getFullYear() + diffYears);
      var a = [
          d.getFullYear(),
          ('00' + (1 + d.getMonth())).slice(-2),
          ('00' + d.getDate()).slice(-2)
      ];
      return a.join('/');
    };
    var days = ["日", "月", "火", "水", "木", "金", "土"];
    var d = new Date();
    var year = d.getFullYear();
    var dt = d.getDate();
    var month = d.getMonth() + 1;
    var date = [
        year,
        ('00' + month).slice(-2),
        ('00' + dt).slice(-2)
    ];
    var day = days[d.getDay()];
    var title = date.join('/');
    var scrapboxProject = location.href.match(/scrapbox.io\\/([^\\/.]*)/)[1];
    var projectUrl = 'https://scrapbox.io/' + scrapboxProject + '/';
    var tags = [
        '[← ' + projectUrl + encodeURIComponent(diffDate(date.join('/'), -1)) +']',
        '#' + year,
        '#' + month + '月',
        '#' + day + '曜日',
        '[1ヶ月前 ' + projectUrl + encodeURIComponent(diffDate(date.join('/'), 0, -1)) +']',
        '[3ヶ月前 ' + projectUrl + encodeURIComponent(diffDate(date.join('/'), 0, -3)) +']',
        '[1年前 ' + projectUrl + encodeURIComponent(diffDate(date.join('/'), 0, 0, -1)) +']',
        '[→ ' + projectUrl + encodeURIComponent(diffDate(date.join('/'), +1)) +']'
    ];
    var body = encodeURIComponent(tags.join(' '));
    var scrapboxUrl = 'https://scrapbox.io/' + scrapboxProject + '/' + encodeURIComponent(title);
    window.open(scrapboxUrl + '?body=' + body);
  ''';
}

// 今日の日付のページを打刻して開く
String setTimeJavascriptSource() {
  return """
    var d = new Date();
    var year = d.getFullYear();
    var dt = d.getDate();
    var month = d.getMonth() + 1;
    var date = [
        year,
        ('00' + month).slice(-2),
        ('00' + dt).slice(-2)
    ];
    var title = date.join('/');
    var scrapboxProject = location.href.match(/scrapbox.io\\/([^\\/.]*)/)[1];
    var scrapboxUrl = 'https://scrapbox.io/' + scrapboxProject + '/' + encodeURIComponent(title);
    var now = new Date();
    var hour = now.getHours();
    var minute = now.getMinutes();
    var second = now.getSeconds();
    var body = encodeURIComponent('\\t' + date.join('/') + ' ' + hour + ':' + minute + ':' + second);
    window.open(scrapboxUrl + '?body=' + body);
    """;
}

// 今日のページを開く
String openTodayPageJavascriptSource() {
  return """
    var d = new Date();
    var year = d.getFullYear();
    var dt = d.getDate();
    var month = d.getMonth() + 1;
    var date = [
        year,
        ('00' + month).slice(-2),
        ('00' + dt).slice(-2)
    ];
    var title = date.join('/');
    var scrapboxProject = location.href.match(/scrapbox.io\\/([^\\/.]*)/)[1];
    var scrapboxUrl = 'https://scrapbox.io/' + scrapboxProject + '/' + encodeURIComponent(title);
    window.open(scrapboxUrl);
    """;
}
