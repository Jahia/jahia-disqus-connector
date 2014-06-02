/* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
var disqus_shortname;
var disqus_identifier;
var disqus_url;
var disqus_title;


/**
 * This function replace the link "Show comment by the corresponding disqus thread"
 * @param source : The jquery object calling the function (Used to insert the disqus wrapper)
 */
function loadDisqus(source, shortname, identifier, url, title, publicKey) {

    disqus_shortname = shortname;
    disqus_identifier = identifier;
    disqus_url = url;
    disqus_title = title;
    if (window.DISQUS) {
        if(show)
        {
            $("#showThreads").hide();
            $("#hideThreads").show();
            $("#disqus_thread").show();
            show=false;
        }
        else
        {
            $("#hideThreads").hide();
            $("#showThreads").show();
            $("#disqus_thread").hide();
            getPostsCount(shortname,publicKey,url);
            show=true;
        }

    } else {
        //insert a wrapper in HTML after the relevant "show comments" link
        jQuery('<div id="disqus_thread"></div>').insertAfter(source);

        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
        $("#showThreads").hide();
        $("#hideThreads").show();
        show=false;

    }
}

