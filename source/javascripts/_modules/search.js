(function($, Modules) {
  'use strict';

  Modules.Search = function () {
    var $html = $('html');

    // needs adjusting for edge etc
    // http://caniuse.com/#search=URLSearchParams
      
    var params = new URLSearchParams(window.location.search)
    
    this.start = function ($element) {
      $.ajax({
        url: '/search.json',
        cache: true,
        method: 'GET',
        success: function(data) {
          var lunrData = data;
          var lunrIndex = lunr.Index.load(lunrData.index);
          var docs = lunrIndex.search(params.get('q')).slice(0,50).map(function(result) {
            return lunrData.docs[result.ref];
          });
          if (docs.length == 0) {
            $element.html('No results');
          }
          else {
            for (var i=0; i<docs.length; i++) {
              var doc = docs[i];
              var $li = $("<li>");
              var $a = $("<a>", {href: doc.url});
              $a.html(doc.title);
              $li.append($a);
              $element.append($li);
            }
          }
        }
      });
    }

  };
})(jQuery, window.GOVUK.Modules);
