function filter(collection, q, config) {
  var results = [];
  var counter = 0;

  var fields = {_keywords: 1};
  for(var i in config.select) {
    fields[config.select[i]] = 1;
  }

  var time = new Date().getTime();
  db[collection].find(q, fields).limit(500).forEach(
    function(doc) {
      var score = 0.0;
      for(var i in config.words) {
        var word = config.words[i];
        if(doc._keywords.indexOf(word) != -1 )
          score += 15.0;
      }

      for(var i in config.stemmed) {
        var word = config.stemmed[i];
        if(doc._keywords.indexOf(word) != -1 )
          score += (1.0 + word.length);
      }

      if(score >= config.min_score || 1.0 ) {
        delete doc._keywords;
        results.push({'score': score, 'doc': doc});
        counter += 1;
      }
    }
  );

  var sorted = results.sort(function(a,b) {
    return b.score - a.score;
  });

  time = (new Date().getTime() - time);

  return {total_entries: counter, elapsed_time:  time, results: sorted.slice(0, config.limit||500)};
}
