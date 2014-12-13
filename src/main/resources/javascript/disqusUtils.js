/**
 * This function hide or show comment
 * @param url       : page URL
 * @param publicKey : Disqus account public Key
 */
function toggleDisqus() {
    if ($("#toggleThreads").data("isDisplayed")) {
        getPostsCount();
        $("#toggleThreads").data("isDisplayed", false);
        $("#disqus_thread").hide();
    } else {
        getDisqus();
        $("#toggleThreads").html(jsVarMap.hideComments);
        $("#toggleThreads").data("isDisplayed", true);
        $("#disqus_thread").show();
    }
}

/**
 * THis function call the Disqus API to get the thread posts count
 * @param url       : page URL
 * @param publicKey : Disqus account public Key
 */
function getPostsCount() {
    var getUrl = "https://disqus.com/api/3.0/threads/details.json?api_key=" + disqus_publicKey + "&thread=link:" + window.location.href + "&forum=" + disqus_shortname;
    $.get(getUrl, function (data) {
        $("#toggleThreads").html(jsVarMap.showComments + " (" + data.response.posts + ")");
    });
}

function getDisqus() {
    if (!window.DISQUS) {
        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function () {
            var dsq = document.createElement('script');
            dsq.type = 'text/javascript';
            dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    }
}