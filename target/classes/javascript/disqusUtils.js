/* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
var disqus_shortname;
var disqus_identifier;
var disqus_url;
var disqus_title;

/**
 * This function replace the link "Show comment by the corresponding disqus thread"
 * @param source : The jquery object calling the function (Used to insert the disqus wrapper)
 */
function loadDisqus(source, shortname, identifier, url, title) {

    disqus_shortname = shortname;
    disqus_identifier = identifier;
    disqus_url = url;
    disqus_title = title;

    console.log("AFTER SETTING ");
    console.log('disqus_shortname : '+disqus_shortname );
    console.log('disqus_identifier : '+disqus_identifier );
    console.log('disqus_url : '+disqus_url );
    console.log('disqus_title : '+disqus_title );

    if (window.DISQUS) {

        console.log(' IN IF ');
        jQuery('#disqus_thread').appendTo(source.parent()); //append the HTML to the control parent

        //if Disqus exists, call it's reset method with new parameters
        DISQUS.reset({
            reload: true,
            config: function () {
                this.page.identifier = identifier;
                this.page.url = url;
                this.page.title = title;
            }
        });

    } else {
        console.log("IN ELSE");
        //insert a wrapper in HTML after the relevant "show comments" link
        jQuery('<div id="disqus_thread"></div>').insertAfter(source);

        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();

    }
}
