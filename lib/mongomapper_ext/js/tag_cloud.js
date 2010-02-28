// TODO: port it to map reduce
function tagCloud(collection, q, limit) {
  var counts = db.eval(
    function(collection, q){
      var counts = {};
      db[collection].find(q, {"tags":1}).limit(500).forEach(
        function(p){
          if ( p.tags ){
            for ( var i=0; i<p.tags.length; i++ ){
              var name = p.tags[i];
              counts[name] = 1 + ( counts[name] || 0 );
            }
          }
        }
      );
      return counts;
    },
    collection,
    q
  );

  // maybe sort to by nice
  var sorted = [];
  for ( var tag in counts ){
    sorted.push( { name : tag , count : counts[tag] } )
  }

  return sorted.slice(0,limit||30);
}
